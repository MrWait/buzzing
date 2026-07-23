import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { ImWsClient } from '@/services/im/ws'
import * as imApi from '@/services/im/api'
import { lookup } from '@/services/im/proto'

export interface FeedItem {
  id: number
  chatId: number
  type: number
  badge: number
  updateTimeMs: number
  lastMsg?: string
  name: string
  avatar: string
  isTop: boolean
  isMute: boolean
  readPos: number
}

export type SendStatus = 'sending' | 'sent' | 'failed'

export interface MessageItem {
  id: number
  chatId: number
  fromId: number
  tpy: number
  content: Uint8Array
  summary: string
  pos: number
  clientId: number
  createTimeMs: number
  status: number
  refMessageId: number
  reactions: Record<number, { total: number; me: boolean }>
  sendStatus?: SendStatus
  readCount?: number
}

export interface ChatItem {
  id: number
  chatType: number
  name: string
  avatar: string
  ownerId: number
  adminIds: number[]
  memberIds: number[]
  description: string
  joinMode: number
  globalMuteUntil: number
}

export interface UserItem {
  id: number
  name: string
  avatar: string
  status: number
}

export interface TypingUser {
  userId: number
  userName: string
  expireAt: number
}

export const useImStore = defineStore('im', () => {
  // ─── Connection ──────────────────────────────────────────────────
  const connected = ref(false)
  const connecting = ref(false)
  const wsClient = ref<ImWsClient | null>(null)

  // ─── Data ────────────────────────────────────────────────────────
  const feeds = ref<Map<number, FeedItem>>(new Map())
  const chats = ref<Map<number, ChatItem>>(new Map())
  const messages = ref<Map<number, MessageItem[]>>(new Map())
  const users = ref<Map<number, UserItem>>(new Map())
  const typingUsers = ref<Map<number, TypingUser[]>>(new Map())

  // ─── Current session ─────────────────────────────────────────────
  const currentChatId = ref<number | null>(null)
  const currentChat = computed(() => (currentChatId.value ? chats.value.get(currentChatId.value) : undefined))

  // ─── Local message ID counter for optimistic messages ────────────
  let localIdCounter = -1
  function nextLocalId(): number { return localIdCounter-- }

  // ─── Loading ─────────────────────────────────────────────────────
  const loadingFeeds = ref(false)
  const loadingMessages = ref(false)
  const hasMoreMessages = ref(true)

  // ─── Feed list (sorted) ──────────────────────────────────────────
  const feedList = computed(() => {
    const list = Array.from(feeds.value.values())
    list.sort((a, b) => {
      if (a.isTop !== b.isTop) return a.isTop ? -1 : 1
      return b.updateTimeMs - a.updateTimeMs
    })
    return list
  })

  // ─── Current messages ────────────────────────────────────────────
  const currentMessages = computed(() => {
    if (!currentChatId.value) return []
    return messages.value.get(currentChatId.value) || []
  })

  // ─── Actions ────────────────────────────────────────────────────

  function initWs() {
    if (wsClient.value) return
    const client = new ImWsClient()
    client.setOnStatusChange((ok) => {
      connected.value = ok
      connecting.value = false
    })
    client.setOnPush((cmd, payload) => handlePush(cmd, payload))
    wsClient.value = client
  }

  function connectWs() {
    initWs()
    connecting.value = true
    wsClient.value?.connect()
  }

  function disconnectWs() {
    wsClient.value?.disconnect()
    wsClient.value = null
    connected.value = false
    connecting.value = false
  }

  // ─── Feed loading ────────────────────────────────────────────────

  async function loadFeeds(cursor: number = 0) {
    loadingFeeds.value = true
    try {
      const resp = await imApi.pullFeedList(cursor)
      mergeEntity(resp.entity)
      return resp
    } catch (e) {
      console.error('[im] load feeds error:', e)
      throw e
    } finally {
      loadingFeeds.value = false
    }
  }

  // ─── Message loading ─────────────────────────────────────────────

  async function loadMessages(chatId: number, pos: number = 0, count: number = 20) {
    loadingMessages.value = true
    try {
      const resp = await imApi.getMessagesByRange(chatId, pos, count, 1)
      mergeEntity(resp.entity)
      if (resp.entity?.messages) {
        const msgIds = Object.keys(resp.entity.messages).map(Number)
        if (msgIds.length < count) {
          hasMoreMessages.value = false
        }
      }
      return resp
    } catch (e) {
      console.error('[im] load messages error:', e)
      throw e
    } finally {
      loadingMessages.value = false
    }
  }

  async function loadMoreMessages(chatId: number) {
    const msgs = messages.value.get(chatId) || []
    if (msgs.length === 0) return
    const minPos = Math.min(...msgs.map((m) => m.pos))
    await loadMessages(chatId, minPos, 20)
  }

  // ─── Send message ────────────────────────────────────────────────

  function addOptimisticMessage(chatId: number, content: Uint8Array, tpy: number, summary: string, refMessageId?: number, clientId?: number): MessageItem {
    const now = Date.now()
    const item: MessageItem = {
      id: nextLocalId(),
      chatId,
      fromId: 0,
      tpy,
      content,
      summary,
      pos: now,
      clientId: clientId || now,
      createTimeMs: now,
      status: 0,
      refMessageId: refMessageId || 0,
      reactions: {},
      sendStatus: 'sending',
    }
    const existing = messages.value.get(chatId) || []
    existing.push(item)
    messages.value.set(chatId, existing)
    return item
  }

  function removeOptimisticMessage(chatId: number, clientId: number) {
    const msgs = messages.value.get(chatId)
    if (!msgs) return
    const idx = msgs.findIndex((m) => m.clientId === clientId && m.id < 0)
    if (idx >= 0) {
      msgs.splice(idx, 1)
      messages.value.set(chatId, [...msgs])
    }
  }

  function markLocalMessageFailed(chatId: number, clientId: number) {
    const msgs = messages.value.get(chatId)
    if (!msgs) return
    if (clientId < 0) {
      // Mark all local messages in this chat as failed
      const updated = msgs.map((m) => m.id < 0 ? { ...m, sendStatus: 'failed' as const } : m)
      messages.value.set(chatId, updated)
      return
    }
    const idx = msgs.findIndex((m) => m.clientId === clientId && m.id < 0)
    if (idx >= 0) {
      msgs[idx] = { ...msgs[idx], sendStatus: 'failed' }
      messages.value.set(chatId, [...msgs])
    }
  }

  async function sendTextMessage(chatId: number, text: string, refMessageId?: number) {
    const msgType = lookup('entity.MessageText')
    const content = msgType.encode(msgType.create({ text })).finish() as Uint8Array
    const summary = text
    const clientId = Date.now()
    addOptimisticMessage(chatId, content, 1, summary, refMessageId, clientId)
    try {
      const resp = await imApi.sendMessage(chatId, 1, content, summary, clientId, refMessageId)
      mergeEntity(resp.entity)
      removeOptimisticMessage(chatId, clientId)
      return resp
    } catch (e) {
      markLocalMessageFailed(chatId, clientId)
      throw e
    }
  }

  async function sendImageMessage(chatId: number, fileId: number, url: string, name: string, mimeType: string, size: number, thumbnailUrl?: string) {
    const msgType = lookup('entity.MessageImage')
    const content = msgType.encode(msgType.create({
      url,
      thumbnail_url: thumbnailUrl || url,
      width: 0,
      height: 0,
      alt_text: name,
    })).finish() as Uint8Array
    const summary = `[图片] ${name}`
    const clientId = Date.now()
    addOptimisticMessage(chatId, content, 2, summary, undefined, clientId)
    try {
      const resp = await imApi.sendMessage(chatId, 2, content, summary, clientId)
      mergeEntity(resp.entity)
      removeOptimisticMessage(chatId, clientId)
      return resp
    } catch (e) {
      markLocalMessageFailed(chatId, clientId)
      throw e
    }
  }

  async function sendFileMessage(chatId: number, fileId: number, url: string, name: string, mimeType: string, size: number) {
    const msgType = lookup('entity.MessageFile')
    const content = msgType.encode(msgType.create({
      name,
      size,
      mime_type: mimeType,
      url,
    })).finish() as Uint8Array
    const summary = `[文件] ${name}`
    const clientId = Date.now()
    addOptimisticMessage(chatId, content, 3, summary, undefined, clientId)
    try {
      const resp = await imApi.sendMessage(chatId, 3, content, summary, clientId)
      mergeEntity(resp.entity)
      removeOptimisticMessage(chatId, clientId)
      return resp
    } catch (e) {
      markLocalMessageFailed(chatId, clientId)
      throw e
    }
  }

  // ─── Entity merge ────────────────────────────────────────────────

  function mergeEntity(entity: any) {
    if (!entity) return

    // Merge chats
    if (entity.chats) {
      for (const [id, chat] of Object.entries(entity.chats) as [string, any][]) {
        const nid = Number(id)
        chats.value.set(nid, {
          id: nid,
          chatType: chat.chat_type || 0,
          name: chat.name || '',
          avatar: chat.avatar || '',
          ownerId: Number(chat.owner_id || 0),
          adminIds: (chat.admin_ids || []).map(Number),
          memberIds: (chat.member_ids || []).map(Number),
          description: chat.description || '',
          joinMode: chat.join_mode || 0,
          globalMuteUntil: Number(chat.global_mute_until || 0),
        })
      }
    }

    // Merge feeds
    if (entity.feeds) {
      for (const [id, feed] of Object.entries(entity.feeds) as [string, any][]) {
        const nid = Number(id)
        const chatId = Number(feed.refer_id || 0)
        const chat = chats.value.get(chatId)
        feeds.value.set(nid, {
          id: nid,
          chatId,
          type: feed.type || 0,
          badge: feed.badge || 0,
          updateTimeMs: Number(feed.update_time_ms || 0),
          lastMsg: feed.last_msg || '',
          name: chat?.name || '',
          avatar: chat?.avatar || '',
          isTop: feed.is_top === 1,
          isMute: feed.is_mute === 1,
          readPos: feed.read_pos || 0,
        })
      }
    }

    // Merge messages
    if (entity.messages) {
      for (const [id, msg] of Object.entries(entity.messages) as [string, any][]) {
        const nid = Number(id)
        const chatId = Number(msg.chat_id || 0)
        const item: MessageItem = {
          id: nid,
          chatId,
          fromId: Number(msg.from_id || 0),
          tpy: msg.tpy || 0,
          content: msg.content || new Uint8Array(0),
          summary: msg.summary || '',
          pos: msg.pos || 0,
          clientId: Number(msg.client_id || 0),
          createTimeMs: Number(msg.create_time_ms || 0),
          status: msg.status || 0,
          refMessageId: Number(msg.ref_message_id || 0),
          reactions: {},
        }
        if (msg.reactions) {
          for (const [k, v] of Object.entries(msg.reactions) as [string, any][]) {
            item.reactions[Number(k)] = {
              total: v.total || 0,
              me: v.me || false,
            }
          }
        }
        const existing = messages.value.get(chatId) || []
        const idx = existing.findIndex((m) => m.id === nid)
        if (idx >= 0) {
          existing[idx] = item
        } else {
          existing.push(item)
        }
        existing.sort((a, b) => a.pos - b.pos)
        messages.value.set(chatId, existing)
      }
    }

    // Merge users
    if (entity.users) {
      for (const [id, user] of Object.entries(entity.users) as [string, any][]) {
        const nid = Number(id)
        users.value.set(nid, {
          id: nid,
          name: user.name || '',
          avatar: user.avatar || '',
          status: user.status || 0,
        })
      }
    }
  }

  // ─── Push handling ───────────────────────────────────────────────

  function handlePush(cmd: number, payload: Uint8Array) {
    try {
      switch (cmd) {
        case 1211: // PUSH_MESSAGES
          const pushMsg = lookup('message.PushMessages').decode(payload) as any
          mergeEntity(pushMsg.entity)
          break
        case 1111: // PUSH_FEED_LIST
          const pushFeed = lookup('feed.PushFeedList').decode(payload) as any
          mergeEntity(pushFeed.entity)
          break
        case 1215: // PUSH_REACTIONS
          const pushReaction = lookup('message.PushMessageReactionRequest').decode(payload) as any
          mergeEntity(pushReaction.entity)
          break
        case 1352: // PUSH_PRESENCE
          const presence = lookup('presence.PushPresence').decode(payload) as any
          const uid = Number(presence.user_id)
          const existing = users.value.get(uid)
          if (existing) {
            users.value.set(uid, { ...existing, status: presence.status || 0 })
          }
          break
        case 1404: // PUSH_TYPING
          const typing = lookup('typing.PushTyping').decode(payload) as any
          const chatId = Number(typing.chat_id)
          const now = Date.now()
          const list = typingUsers.value.get(chatId) || []
          const filtered = list.filter((t) => t.expireAt > now && t.userId !== Number(typing.user_id))
          filtered.push({
            userId: Number(typing.user_id),
            userName: typing.user_name || '',
            expireAt: Number(typing.expire_at_ms || now + 5000),
          })
          typingUsers.value.set(chatId, filtered)
          break
        case 1057: // PUSH_ENTITY_CHANGE
          const change = lookup('entity.EntityChange').decode(payload) as any
          console.log('[im] entity change:', change)
          break
        default:
          console.log('[im] unhandled push cmd:', cmd)
      }
    } catch (e) {
      console.error('[im] handle push error:', e)
    }
  }

  // ─── Message actions ──────────────────────────────────────────

  const replyTarget = ref<MessageItem | null>(null)

  function setReplyTarget(msg: MessageItem | null) {
    replyTarget.value = msg
  }

  async function recallMessage(msgId: number) {
    try {
      await imApi.recallMessage(msgId)
      const msgs = messages.value.get(currentChatId.value || 0) || []
      const idx = msgs.findIndex((m) => m.id === msgId)
      if (idx >= 0) {
        msgs[idx] = { ...msgs[idx], status: 6 }
        messages.value.set(currentChatId.value || 0, [...msgs])
      }
    } catch (e) {
      console.error('[im] recall error:', e)
    }
  }

  async function retrySendMessage(chatId: number, msg: MessageItem) {
    if (!msg.content) return
    const clientId = Date.now()
    try {
      // Remove the old failed message and re-add as sending
      removeOptimisticMessage(chatId, msg.clientId)
      addOptimisticMessage(chatId, msg.content, msg.tpy, msg.summary, msg.refMessageId || undefined, clientId)
      const resp = await imApi.sendMessage(chatId, msg.tpy, msg.content, msg.summary, clientId, msg.refMessageId || undefined)
      mergeEntity(resp.entity)
      removeOptimisticMessage(chatId, clientId)
    } catch (e) {
      markLocalMessageFailed(chatId, clientId)
      throw e
    }
  }

  async function setReaction(messageId: number, reaction: number, set: boolean) {
    try {
      await imApi.setReaction(messageId, reaction, set)
    } catch (e) {
      console.error('[im] set reaction error:', e)
    }
  }

  async function sendTyping(chatId: number) {
    try {
      await imApi.sendTyping(chatId)
    } catch (e) {
      // ignore typing errors
    }
  }

  async function forwardMessages(toChatId: number, sourceChatId: number, messageIds: number[], forwardType: number = 0) {
    try {
      const resp = await imApi.forwardMessage(toChatId, sourceChatId, messageIds, forwardType)
      mergeEntity(resp.entity)
    } catch (e) {
      console.error('[im] forward error:', e)
    }
  }

  async function deleteMessage(msgId: number) {
    try {
      await imApi.deleteMessage(msgId)
      const cid = currentChatId.value
      if (cid) {
        const msgs = messages.value.get(cid) || []
        messages.value.set(cid, msgs.filter((m) => m.id !== msgId))
      }
    } catch (e) {
      console.error('[im] delete error:', e)
    }
  }

  // ─── Feed actions ──────────────────────────────────────────────

  async function setFeedTop(feedId: number, top: boolean) {
    try {
      await imApi.setFeedTop(feedId, top)
      const feed = feeds.value.get(feedId)
      if (feed) {
        feeds.value.set(feedId, { ...feed, isTop: top })
      }
    } catch (e) {
      console.error('[im] set feed top error:', e)
    }
  }

  async function setFeedMute(feedId: number, mute: boolean) {
    try {
      await imApi.setFeedMute(feedId, mute)
      const feed = feeds.value.get(feedId)
      if (feed) {
        feeds.value.set(feedId, { ...feed, isMute: mute })
      }
    } catch (e) {
      console.error('[im] set feed mute error:', e)
    }
  }

  async function removeFeed(feedId: number) {
    try {
      await imApi.removeFeed(feedId)
      feeds.value.delete(feedId)
    } catch (e) {
      console.error('[im] remove feed error:', e)
    }
  }

  async function activeFeed(feedId: number) {
    try {
      await imApi.activeFeed(feedId)
    } catch (e) {
      console.error('[im] active feed error:', e)
    }
  }

  // ─── Session management ──────────────────────────────────────────

  function selectChat(chatId: number | null) {
    currentChatId.value = chatId
    hasMoreMessages.value = true
    if (chatId && !messages.value.has(chatId)) {
      messages.value.set(chatId, [])
    }
  }

  // ─── Cleanup ─────────────────────────────────────────────────────

  function reset() {
    feeds.value = new Map()
    chats.value = new Map()
    messages.value = new Map()
    users.value = new Map()
    typingUsers.value = new Map()
    currentChatId.value = null
    loadingFeeds.value = false
    loadingMessages.value = false
    hasMoreMessages.value = true
  }

  return {
    // state
    connected, connecting, wsClient,
    feeds, chats, messages, users, typingUsers,
    currentChatId, currentChat,
    loadingFeeds, loadingMessages, hasMoreMessages,
    // computed
    feedList, currentMessages,
    // state
    replyTarget,
    // actions
    connectWs, disconnectWs,
    loadFeeds, loadMessages, loadMoreMessages,
    sendTextMessage, sendImageMessage, sendFileMessage,
    setReplyTarget, recallMessage, deleteMessage,
    setReaction, forwardMessages, sendTyping,
    retrySendMessage,
    setFeedTop, setFeedMute, removeFeed, activeFeed,
    mergeEntity,
    selectChat,
    reset,
  }
})
