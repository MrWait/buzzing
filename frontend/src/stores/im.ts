import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { ImWsClient } from '@/services/im/ws'
import * as imApi from '@/services/im/api'
import { lookup } from '@/services/im/proto'

export interface FeedItem {
  id: string
  chatId: string
  type: number
  status: number
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
  id: string
  chatId: string
  fromId: string
  tpy: number
  content: Uint8Array
  summary: string
  pos: number
  clientId: string
  createTimeMs: number
  status: number
  refMessageId: string
  reactions: Record<string, { total: number; me: boolean }>
  sendStatus?: SendStatus
  readCount?: number
}

export interface ChatItem {
  id: string
  chatType: number
  name: string
  avatar: string
  ownerId: string
  adminIds: string[]
  memberIds: string[]
  description: string
  joinMode: number
  globalMuteUntil: number
}

export interface UserItem {
  id: string
  name: string
  avatar: string
  status: number
}

export interface TypingUser {
  userId: string
  userName: string
  expireAt: number
}

export const useImStore = defineStore('im', () => {
  // ─── Connection ──────────────────────────────────────────────────
  const connected = ref(false)
  const connecting = ref(false)
  const wsClient = ref<ImWsClient | null>(null)

  // ─── Data ────────────────────────────────────────────────────────
  const feeds = ref<Map<string, FeedItem>>(new Map())
  const chats = ref<Map<string, ChatItem>>(new Map())
  const messages = ref<Map<string, MessageItem[]>>(new Map())
  const users = ref<Map<string, UserItem>>(new Map())
  const typingUsers = ref<Map<string, TypingUser[]>>(new Map())

  // ─── Reactive clock ───────────────────────────────────────────────
  const _now = ref(Date.now())
  setInterval(() => { _now.value = Date.now() }, 1000)

  // ─── Current session ─────────────────────────────────────────────
  const currentChatId = ref<string | null>(null)
  const currentFeedId = ref<string | null>(null)
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
      .filter(f => f.status < 4)
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

  async function loadFeeds(cursor: string = String(Date.now())) {
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

  async function loadMessages(chatId: string, pos: number = 0, count: number = 20) {
    loadingMessages.value = true
    try {
      const resp = await imApi.getMessagesByRange(chatId, pos, count, 1)
      mergeEntity(resp.entity)
      if (resp.entity?.messages) {
        const msgKeys = Object.keys(resp.entity.messages)
        if (msgKeys.length < count) {
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

  async function loadMoreMessages(chatId: string) {
    const msgs = messages.value.get(chatId) || []
    if (msgs.length === 0) return
    const minPos = Math.min(...msgs.map((m) => m.pos))
    await loadMessages(chatId, minPos, 20)
  }

  // ─── Send message ────────────────────────────────────────────────

  function addOptimisticMessage(chatId: string, content: Uint8Array, tpy: number, summary: string, refMessageId?: string, clientId?: string): MessageItem {
    const now = Date.now()
    const item: MessageItem = {
      id: String(nextLocalId()),
      chatId,
      fromId: '0',
      tpy,
      content,
      summary,
      pos: now,
      clientId: clientId || String(now),
      createTimeMs: now,
      status: 0,
      refMessageId: refMessageId || '0',
      reactions: {},
      sendStatus: 'sending',
    }
    const existing = messages.value.get(chatId) || []
    existing.push(item)
    messages.value.set(chatId, existing)
    return item
  }

  function removeOptimisticMessage(chatId: string, clientId: string) {
    const msgs = messages.value.get(chatId)
    if (!msgs) return
    const idx = msgs.findIndex((m) => m.clientId === clientId && Number(m.id) < 0)
    if (idx >= 0) {
      msgs.splice(idx, 1)
      messages.value.set(chatId, [...msgs])
    }
  }

  function markLocalMessageFailed(chatId: string, clientId: string) {
    const msgs = messages.value.get(chatId)
    if (!msgs) return
    if (Number(clientId) < 0) {
      const updated = msgs.map((m) => Number(m.id) < 0 ? { ...m, sendStatus: 'failed' as const } : m)
      messages.value.set(chatId, updated)
      return
    }
    const idx = msgs.findIndex((m) => m.clientId === clientId && Number(m.id) < 0)
    if (idx >= 0) {
      msgs[idx] = { ...msgs[idx], sendStatus: 'failed' }
      messages.value.set(chatId, [...msgs])
    }
  }

  async function sendTextMessage(chatId: string, text: string, refMessageId?: string) {
    const msgType = lookup('entity.MessageText')
    const content = msgType.encode(msgType.create({ text })).finish() as Uint8Array
    const summary = text
    const clientId = String(Date.now())
    addOptimisticMessage(chatId, content, 1, summary, refMessageId, clientId)
    try {
      const resp = await imApi.sendMessage(chatId, 1, content, Number(clientId), summary, refMessageId)
      mergeEntity(resp.entity)
      removeOptimisticMessage(chatId, clientId)
      return resp
    } catch (e) {
      markLocalMessageFailed(chatId, clientId)
      throw e
    }
  }

  async function sendImageMessage(chatId: string, _fileId: string, url: string, name: string, _mimeType: string, _size: number, thumbnailUrl?: string) {
    const msgType = lookup('entity.MessageImage')
    const content = msgType.encode(msgType.create({
      url,
      thumbnail_url: thumbnailUrl || url,
      width: 0,
      height: 0,
      alt_text: name,
    })).finish() as Uint8Array
    const summary = `[图片] ${name}`
    const clientId = String(Date.now())
    addOptimisticMessage(chatId, content, 2, summary, undefined, clientId)
    try {
      const resp = await imApi.sendMessage(chatId, 2, content, Number(clientId), summary)
      mergeEntity(resp.entity)
      removeOptimisticMessage(chatId, clientId)
      return resp
    } catch (e) {
      markLocalMessageFailed(chatId, clientId)
      throw e
    }
  }

  async function sendFileMessage(chatId: string, _fileId: string, url: string, name: string, mimeType: string, size: number) {
    const msgType = lookup('entity.MessageFile')
    const content = msgType.encode(msgType.create({
      name,
      size,
      mime_type: mimeType,
      url,
    })).finish() as Uint8Array
    const summary = `[文件] ${name}`
    const clientId = String(Date.now())
    addOptimisticMessage(chatId, content, 3, summary, undefined, clientId)
    try {
      const resp = await imApi.sendMessage(chatId, 3, content, Number(clientId), summary)
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
      for (const chat of Object.values(entity.chats) as any[]) {
        const nid = chat.id || '0'
        chats.value.set(nid, {
          id: nid,
          chatType: chat.chat_type || 0,
          name: chat.name || '',
          avatar: chat.avatar || '',
          ownerId: chat.owner_id || '0',
          adminIds: (chat.admin_ids || []).map(String),
          memberIds: (chat.member_ids || []).map(String),
          description: chat.description || '',
          joinMode: chat.join_mode || 0,
          globalMuteUntil: Number(chat.global_mute_until || 0),
        })
      }
    }

    // Merge feeds
    if (entity.feeds) {
      for (const feed of Object.values(entity.feeds) as any[]) {
        const nid = feed.id || '0'
        const chat = chats.value.get(nid)
        const status = Number(feed.status || 0)
        // Skip dissolved/deleted feeds
        if (status >= 4) {
          feeds.value.delete(nid)
          continue
        }
        feeds.value.set(nid, {
          id: nid,
          chatId: nid,
          type: feed.type || 0,
          status,
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
      for (const msg of Object.values(entity.messages) as any[]) {
        const nid = msg.id || '0'
        const chatId = msg.chat_id || '0'
        const item: MessageItem = {
          id: nid,
          chatId,
          fromId: msg.from_id || '0',
          tpy: msg.tpy || 0,
          content: msg.content || new Uint8Array(0),
          summary: msg.summary || '',
          pos: msg.pos || 0,
          clientId: msg.client_id || '0',
          createTimeMs: Number(msg.create_time_ms || 0),
          status: msg.status || 0,
          refMessageId: msg.ref_message_id || '0',
          reactions: {},
        }
        if (msg.reactions) {
          for (const [k, v] of Object.entries(msg.reactions) as [string, any][]) {
            item.reactions[k] = {
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
      for (const user of Object.values(entity.users) as any[]) {
        const nid = user.id || '0'
        users.value.set(nid, {
          id: nid,
          name: user.name || '',
          avatar: user.avatar || '',
          status: user.status || 0,
        })
      }
    }

    // Auto-fetch missing sender info for messages
    if (entity.messages) {
      const fromIds: string[] = []
      for (const msg of Object.values(entity.messages) as any[]) {
        const fid = String(msg.from_id || '0')
        if (fid && fid !== '0' && !users.value.has(fid)) {
          fromIds.push(fid)
        }
      }
      if (fromIds.length > 0) {
        const unique = [...new Set(fromIds)]
        ensureUsers(unique)
      }
    }
  }

  async function ensureUsers(ids: string[]) {
    const missing = ids.filter((id) => id && !users.value.has(id))
    if (missing.length === 0) return
    try {
      const resp = await imApi.getUserByIds(missing)
      if (resp?.users) {
        for (const user of resp.users) {
          const nid = user.id || '0'
          users.value.set(nid, {
            id: nid,
            name: user.name || '',
            avatar: user.avatar || '',
            status: user.status || 0,
          })
        }
      }
    } catch (e) {
      // ignore errors
    }
  }

  // ─── Push handling ───────────────────────────────────────────────

  function decodeAsPlain(typeName: string, payload: Uint8Array): any {
    const type = lookup(typeName)
    const decoded = type.decode(payload)
    return type.toObject(decoded, { longs: String, enums: String, defaults: true })
  }

  function handlePush(cmd: number, payload: Uint8Array) {
    try {
      switch (cmd) {
        case 1211: // PUSH_MESSAGES
          const pushMsg = decodeAsPlain('message.PushMessages', payload)
          mergeEntity(pushMsg.entity)
          break
        case 1111: // PUSH_FEED_LIST
          const pushFeed = decodeAsPlain('feed.PushFeedList', payload)
          mergeEntity(pushFeed.entity)
          break
        case 1215: // PUSH_REACTIONS
          const pushReaction = decodeAsPlain('message.PushMessageReactionRequest', payload)
          mergeEntity(pushReaction.entity)
          break
        case 1352: // PUSH_PRESENCE
          const presence = decodeAsPlain('presence.PushPresence', payload)
          const uid = presence.user_id || '0'
          const existing = users.value.get(uid)
          if (existing) {
            users.value.set(uid, { ...existing, status: presence.status || 0 })
          }
          break
        case 1404: // PUSH_TYPING
          const typing = decodeAsPlain('typing.PushTyping', payload)
          const chatId = typing.chat_id || '0'
          const now = Date.now()
          const list = typingUsers.value.get(chatId) || []
          const filtered = list.filter((t) => t.expireAt > now && t.userId !== (typing.user_id || '0'))
          filtered.push({
            userId: typing.user_id || '0',
            userName: typing.user_name || '',
            expireAt: Number(typing.expire_at_ms || now + 5000),
          })
          typingUsers.value.set(chatId, filtered)
          break
        case 1057: // PUSH_ENTITY_CHANGE
          const change = decodeAsPlain('entity.EntityChange', payload)
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

  async function recallMessage(msgId: string) {
    try {
      await imApi.recallMessage(msgId)
      const msgs = messages.value.get(currentChatId.value || '0') || []
      const idx = msgs.findIndex((m) => m.id === msgId)
      if (idx >= 0) {
        msgs[idx] = { ...msgs[idx], status: 6 }
        messages.value.set(currentChatId.value || '0', [...msgs])
      }
    } catch (e) {
      console.error('[im] recall error:', e)
    }
  }

  async function retrySendMessage(chatId: string, msg: MessageItem) {
    if (!msg.content) return
    const clientId = String(Date.now())
    try {
      removeOptimisticMessage(chatId, msg.clientId)
      addOptimisticMessage(chatId, msg.content, msg.tpy, msg.summary, msg.refMessageId || undefined, clientId)
      const resp = await imApi.sendMessage(chatId, msg.tpy, msg.content, Number(clientId), msg.summary, msg.refMessageId || undefined)
      mergeEntity(resp.entity)
      removeOptimisticMessage(chatId, clientId)
    } catch (e) {
      markLocalMessageFailed(chatId, clientId)
      throw e
    }
  }

  async function setReaction(messageId: string, reaction: number, set: boolean) {
    try {
      await imApi.setReaction(messageId, reaction, set)
    } catch (e) {
      console.error('[im] set reaction error:', e)
    }
  }

  async function sendTyping(chatId: string) {
    try {
      await imApi.sendTyping(chatId)
    } catch (e) {
      // ignore typing errors
    }
  }

  async function forwardMessages(toChatId: string, sourceChatId: string, messageIds: string[], forwardType: number = 0) {
    try {
      const resp = await imApi.forwardMessage(toChatId, sourceChatId, messageIds, forwardType)
      mergeEntity(resp.entity)
    } catch (e) {
      console.error('[im] forward error:', e)
    }
  }

  async function deleteMessage(msgId: string) {
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

  async function setFeedTop(feedId: string, top: boolean) {
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

  async function setFeedMute(feedId: string, mute: boolean) {
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

  async function removeFeed(feedId: string) {
    try {
      await imApi.removeFeed(feedId)
      feeds.value.delete(feedId)
    } catch (e) {
      console.error('[im] remove feed error:', e)
    }
  }

  async function activeFeed(feedId: string) {
    try {
      await imApi.activeFeed(feedId)
    } catch (e) {
      console.error('[im] active feed error:', e)
    }
  }

  // ─── Session management ──────────────────────────────────────────

  function selectChat(chatId: string | null) {
    currentChatId.value = chatId
    hasMoreMessages.value = true
    if (chatId && !messages.value.has(chatId)) {
      messages.value.set(chatId, [])
    }
  }

  // ─── Create Chat ─────────────────────────────────────────────────

  async function createP2pChat(myUserId: string, peerUserId: string) {
    try {
      const resp = await imApi.createChat({
        chat_type: 1,
        peer_a_id: myUserId,
        peer_b_id: peerUserId,
      })
      const chatId = String(resp.chat_id)
      if (resp.entities) {
        mergeEntity(resp.entities)
      }
      selectChat(chatId)
      return chatId
    } catch (e) {
      console.error('[im] create p2p chat error:', e)
      return null
    }
  }

  async function createGroupChat(myUserId: string, name: string, memberIds: string[]) {
    try {
      const allIds = [myUserId, ...memberIds.filter(id => id !== myUserId)]
      const resp = await imApi.createChat({
        chat_type: 2,
        owner_id: myUserId,
        name,
        member_ids: allIds,
      })
      const chatId = String(resp.chat_id)
      if (resp.entities) {
        mergeEntity(resp.entities)
      }
      selectChat(chatId)
      return chatId
    } catch (e) {
      console.error('[im] create group chat error:', e)
      return null
    }
  }

  async function quitChat(chatId: string) {
    try {
      await imApi.quitChat(chatId)
      await loadFeeds()
      selectChat(null)
    } catch (e) {
      console.error('[im] quit chat error:', e)
    }
  }

  async function dismissChat(chatId: string) {
    try {
      await imApi.dismissChat(chatId)
      await loadFeeds()
      selectChat(null)
    } catch (e) {
      console.error('[im] dismiss chat error:', e)
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
    currentChatId, currentFeedId, currentChat,
    loadingFeeds, loadingMessages, hasMoreMessages,
    // computed
    feedList, currentMessages,
    // state
    replyTarget,
    // reactive clock
    now: _now,
    // actions
    connectWs, disconnectWs,
    loadFeeds, loadMessages, loadMoreMessages,
    sendTextMessage, sendImageMessage, sendFileMessage,
    setReplyTarget, recallMessage, deleteMessage,
    setReaction, forwardMessages, sendTyping,
    retrySendMessage,
    setFeedTop, setFeedMute, removeFeed, activeFeed,
    mergeEntity, ensureUsers,
    selectChat,
    createP2pChat, createGroupChat,
    quitChat, dismissChat,
    reset,
  }
})
