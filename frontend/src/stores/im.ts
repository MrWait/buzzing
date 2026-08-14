import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { useAuthStore } from '@/stores/auth'
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
  // 最后一条消息的发送者 id（msg→feed 派生时写入，用于群聊预览展示发送人）
  lastMsgFromId?: string
  // 最后一条消息 id（refer_id），用于冷启动时用 refer 消息补齐预览
  referId: string
  name: string
  avatar: string
  isTop: boolean
  isMute: boolean
  readPos: number
  // 服务端字段（data_sync §6.3）：badge 由客户端按 refer_badge - read_badge 本地派生
  referBadge: number
  readBadge: number
  referPos: number
}

export type SendStatus = 'sending' | 'sent' | 'failed'

export interface MessageReadState {
  total: number
  readCount: number
  unreadCount: number
  meRead: boolean
  // 服务端 readstate_version（变更单调递增），用作已读状态合并/回退守卫（对齐 SDK message_readstate_upsert）
  version: number
}

export interface MessageItem {
  id: string
  chatId: string
  fromId: string
  tpy: number
  content: Uint8Array
  summary: string
  pos: number
  badgeCount: number
  clientId: string
  createTimeMs: number
  status: number
  refMessageId: string
  reactions: Record<string, { total: number; me: boolean }>
  sendStatus?: SendStatus
  // 消息已读状态（服务端实体字段，仅本人消息会填充），见 data_sync §6.2
  readState?: MessageReadState
  // W4-4: 翻译结果（惰性拉取后写入）
  translation?: MessageTranslation
}

export interface MessageTranslation {
  originalText: string
  translatedText: string
  targetLang: string
  sourceLang: string
}

export interface AnnouncementInfo {
  title: string
  bodyText: string
  summary: string
  fromId: string
  createTimeMs: number
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
  // 群公告（系统消息 tpy==16，id==chatId），mergeEntity 从消息实体摘出
  announcement?: AnnouncementInfo
  // W4-1: 置顶消息列表（进入会话时经 CHAT_GET_PINNED_MESSAGES 拉取）
  pinnedMessages?: MessageItem[]
}

export interface UserItem {
  id: string
  name: string
  avatar: string
  status: number
  phone?: string
  email?: string
  position?: string
  city?: string
  deptId?: string
  superiorId?: string
  superiorName?: string
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
  // 已读独立实体缓存（key = message_id，见 docs/data_sync §5）：已读/表情为独立实体，
  // 与消息内容分离下发。消息列表换加载窗口、会话切换等场景下，消息行会被整体替换重建，
  // 若 readState 只存在消息行上就容易丢失；此 map 作为跨消息行的已读状态权威来源，
  // 与 SDK 的 messages 表 readstate 列语义对齐（sdk message_database/message.rs:read_state）。
  const readStates = ref<Map<string, MessageReadState>>(new Map())
  const users = ref<Map<string, UserItem>>(new Map())
  const typingUsers = ref<Map<string, TypingUser[]>>(new Map())
  // pipeline 实体脏标记（内存版：`${entityType}:${entityId}` → 变更 version），刷新即丢
  const dirty = ref<Map<string, Set<number>>>(new Map())

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

  // 全局总未读数：各会话 badge 之和（Web 内存版本地在 feeds 上聚合，等价于 SDK feed_get_badge_count）
  const totalUnread = computed(() => {
    let sum = 0
    for (const f of feeds.value.values()) {
      if (f.status < 4) sum += f.badge
    }
    return sum
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
      badgeCount: 0,
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

  async function sendTextMessage(
    chatId: string,
    text: string,
    refMessageId?: string,
    mentions?: { userId: string; name: string; offset: number; length: number }[],
  ) {
    const msgType = lookup('entity.MessageText')
    // W4-3: 结构化 @提及。后端 Step2 会从 MessageText.mentions 解析 at_ids 做通知与校验
    const content = msgType.encode(msgType.create({ text, mentions: mentions || [] })).finish() as Uint8Array
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

    // 会话被解散/删除（EntityStatus >= DISMISS_PENDING，服务端 chat_dismiss 走 chat 实体直推 status=Deleted
    // + feed 置 DismissPending 双通道）：移除会话/消息缓存；若正是当前进入的会话，同步清空当前会话，
    // 避免列表项已移除而聊天页仍停留在已解散的会话。
    function purgeChat(chatId: string) {
      chats.value.delete(chatId)
      feeds.value.delete(chatId)
      messages.value.delete(chatId)
      typingUsers.value.delete(chatId)
      if (currentChatId.value === chatId) {
        currentChatId.value = null
      }
    }

    // Merge chats
    if (entity.chats) {
      for (const chat of Object.values(entity.chats) as any[]) {
        const nid = chat.id || '0'
        // chat 实体直推已带 deleted/dismiss 状态：整会话清理（含当前会话）
        if (Number(chat.status || 0) >= 4) {
          purgeChat(nid)
          continue
        }
        // 保留已有公告（实体更新不一定携带 announcement）
        const prev = chats.value.get(nid)
        chats.value.set(nid, {
          id: nid,
          ...normalizeChat(chat),
          announcement: prev?.announcement,
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
          purgeChat(nid)
          continue
        }
        feeds.value.set(nid, {
          id: nid,
          chatId: nid,
          type: feed.type || 0,
          status,
          // 未读 = 服务端 refer_badge - 已读 read_badge（Web 内存版本地派生，不自造数据）
          referBadge: Number(feed.refer_badge || 0),
          readBadge: Number(feed.read_badge || 0),
          badge: Math.max(0, Number(feed.refer_badge || 0) - Number(feed.read_badge || 0)),
        updateTimeMs: Number(feed.update_time_ms || 0),
        lastMsg: feed.last_msg || '',
        lastMsgFromId: '',
        referId: String(feed.refer_id || '0'),
        name: chat?.name || '',
          avatar: chat?.avatar || '',
          isTop: feed.is_top === 1,
          isMute: feed.is_mute === 1,
          readPos: Number(feed.read_pos || 0),
          referPos: Number(feed.refer_pos || 0),
        })
      }
    }

    // Merge messages
    if (entity.messages) {
      // 已读/表情为独立实体（key = message_id），见 docs/data_sync §5。
      // 注意：protobufjs 对 map<int64, T> 的 key 解码为原始字节（非字符串），不能按 map key 匹配，
      // 统一改用 value 内部 id（ReadState.id / Reactions.id = message_id）做 key。
      const rsMap = readMapByValueId(entity.readstates)
      const rxMap = readMapByValueId(entity.reactions)
      // 已读状态先入独立缓存（key=message_id）：服务于消息行整体替换重建时的回填，
      // 以及会话列表中按 referId 直接取已读进度（feedReadPercent）
      if (Object.keys(rsMap).length > 0) applyReadStateMap(rsMap)
      for (const msg of Object.values(entity.messages) as any[]) {
        const nid = msg.id || '0'
        const chatId = msg.chat_id || '0'
        const item: MessageItem = {
          id: nid,
          chatId,
          fromId: String(msg.from_id || '0'),
          tpy: msg.tpy || 0,
          content: msg.content || new Uint8Array(0),
          summary: msg.summary || '',
          pos: msg.pos || 0,
          badgeCount: msg.badge_count || 0,
          clientId: msg.client_id || '0',
          createTimeMs: Number(msg.create_time_ms || 0),
          status: msg.status || 0,
          refMessageId: msg.ref_message_id || '0',
          reactions: {},
        }
        const rx = rxMap[nid]
        if (rx && rx.reactions) {
          for (const [k, v] of Object.entries(rx.reactions) as [string, any][]) {
            item.reactions[k] = {
              total: v.total || 0,
              me: v.me || false,
            }
          }
        }
        const rs = rsMap[nid]
        // 已读状态以独立缓存（key=message_id）为准：applyReadStateMap 已按版本守卫写入，
        // 防止 payload 携带的旧已读状态回退覆盖新的已读状态
        const cachedState = readStates.value.get(nid)
        if (rs || cachedState) {
          item.readState = cachedState || {
            total: rs.total || 0,
            readCount: rs.read_count || 0,
            unreadCount: rs.unread_count || 0,
            meRead: !!rs.me_read,
            version: Number(rs.version) || 0,
          }
        }
// 群公告：tpy==ANNOUNCEMENT(16) 且 id==chatId 的系统消息，摘入 chat.announcement，
        // 不进入消息列表渲染（与客户端 chat_view 一致）
        if (Number(msg.tpy) === 16 && nid === chatId) {
          const chatItem = chats.value.get(chatId)
          if (chatItem) {
            const title = decodeAnnouncementTitle(item.content, msg.summary)
            const bodyText = decodeAnnouncementBody(item.content, msg.summary)
            chats.value.set(chatId, {
              ...chatItem,
              announcement: {
                title,
                bodyText,
                summary: msg.summary || '',
                fromId: msg.from_id || '0',
                createTimeMs: Number(msg.create_time_ms || 0),
              },
            })
          }
          continue
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

    // 消息 → 会话水位/已读派生（data_sync §6 / §8.3）：与服务端 / SDK 同一套规则。
    // 新消息推进 refer_pos / refer_badge；自家消息（from_id == 当前用户）同步推进 read_pos / read_badge，
    // 未读 = refer_badge - read_badge 随之归零 / 下降。服务端 send 路径权威持久化已读但不推
    // PUSH_FEED_READ_STATUS，由各端在应用自家消息时本地推进（见 SDK feed_update_by_messages）。
    if (entity.messages) {
      const selfUid = useAuthStore().user?.id || '0'
      for (const msg of Object.values(entity.messages) as any[]) {
        const chatId = String(msg.chat_id || '0')
        const feed = feeds.value.get(chatId)
        if (!feed) continue
        const pos = Number(msg.pos || 0)
        let changed = false
        if (feed.referPos < pos) {
          feed.referPos = pos
          feed.referBadge = Number(msg.badge_count || 0)
          feed.updateTimeMs = Number(msg.create_time_ms || 0)
          feed.lastMsg = msg.summary || ''
          feed.lastMsgFromId = String(msg.from_id || '0')
          // 与 SDK feed_update_by_messages 对齐：refer_id 同步推进为新消息 id，
          // 避免后续按陈旧 refer_id 的预览兜底把 lastMsg 覆盖回旧值（见 im.ts mergeEntity 注释）
          feed.referId = String(msg.id || '0')
          changed = true
        }
        // 预览兜底：冷启动时 refer_pos 已是最新，按 refer_id 用 refer 消息补齐 lastMsg / 发送人。
        // 仅当本地尚未有发送人（lastMsgFromId 为空）时才补齐，避免覆盖已随新消息推进的本地预览。
        if (String(msg.id || '0') === feed.referId && !feed.lastMsgFromId) {
          feed.lastMsg = msg.summary || ''
          feed.lastMsgFromId = String(msg.from_id || '0')
          changed = true
        }
        if (String(msg.from_id || '0') === selfUid && feed.readPos < pos) {
          feed.readPos = pos
          feed.readBadge = Math.min(Number(msg.badge_count || 0), feed.referBadge)
          changed = true
        }
        if (changed) {
          feed.badge = Math.max(0, feed.referBadge - feed.readBadge)
          feeds.value.set(chatId, { ...feed })
        }
      }
    }

    // 仅已读/表情独立实体变更（无 messages）：按 key=message_id 就地更新已有消息的 readState / reactions
    // 同样按 value 内部 id 归一化（protobufjs map<int64> key 是原始字节，见 readMapByValueId 注释）
    const sideRs = readMapByValueId(entity.readstates)
    const sideRx = readMapByValueId(entity.reactions)
    if (Object.keys(sideRs).length > 0 || Object.keys(sideRx).length > 0) {
      console.log('[im][mergeEntity] side readstate/reaction payload', sideRs, sideRx)
      // 已读状态先按版本守卫写入独立缓存（key=message_id）
      if (Object.keys(sideRs).length > 0) applyReadStateMap(sideRs)
      messages.value.forEach((chatMsgs, cid) => {
        let changed = false
        const next = chatMsgs.map((m) => {
          const cached = readStates.value.get(m.id)
          const rx = sideRx[m.id]
          if (cached || rx) {
            const updated: MessageItem = { ...m }
            if (cached) {
              updated.readState = cached
              console.log('[im][mergeEntity] side update item', m.id, 'readState ->', cached, 'chat', cid)
            }
            if (rx && rx.reactions) {
              const nextRx: Record<string, { total: number; me: boolean }> = {}
              for (const [k, v] of Object.entries(rx.reactions) as [string, any][]) {
                nextRx[k] = { total: v.total || 0, me: v.me || false }
              }
              updated.reactions = nextRx
            }
            changed = true
            return updated
          }
          return m
        })
        if (changed) messages.value.set(cid, next)
      })
    } else {
      console.log('[im][mergeEntity] no readstate/reaction side payload, readStates cache size=', readStates.value.size)
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
          phone: user.phone || '',
          email: user.email || '',
          position: user.position || '',
          city: user.city || '',
          deptId: user.dept_id ? String(user.dept_id) : '',
          superiorId: user.superior_id ? String(user.superior_id) : '',
          superiorName: user.superior_name || '',
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

    // Auto-fetch missing peer info for P2P chats（对齐 SDK fill_entity：
    // 会话实体会携带 peer/member 用户，防止会话列表单聊渲染不出对方昵称/头像）
    if (entity.chats) {
      const peerIds: string[] = []
      for (const chat of Object.values(entity.chats) as any[]) {
        if (Number(chat.chat_type || 0) !== 1) continue
        const cid = chat.id || '0'
        const chatItem = chats.value.get(cid)
        const memberIds = chatItem?.memberIds || (chat.member_ids || []).map(String)
        const selfUid = useAuthStore().user?.id || '0'
        const peerId = memberIds.find((id: string) => id !== selfUid)
        if (peerId && !users.value.has(peerId)) peerIds.push(peerId)
      }
      if (peerIds.length > 0) {
        ensureUsers([...new Set(peerIds)])
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
            phone: user.phone || '',
            email: user.email || '',
            position: user.position || '',
            city: user.city || '',
            deptId: user.dept_id ? String(user.dept_id) : '',
            superiorId: user.superior_id ? String(user.superior_id) : '',
            superiorName: user.superior_name || '',
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

  // 解析公告标题：AnnouncementContent.title，缺省回退 summary
  function decodeAnnouncementTitle(content: Uint8Array, summary: string): string {
    try {
      const contentMsg = lookup('entity.AnnouncementContent')
      const decoded = contentMsg.toObject(contentMsg.decode(content), {
        longs: String, enums: String, defaults: true,
      })
      if (decoded.title) return decoded.title
    } catch (_) { /* ignore */ }
    return summary || ''
  }

  // 解析公告正文：AnnouncementContent.body（UTF-8），缺省回退 content/summary
  function decodeAnnouncementBody(content: Uint8Array, summary: string): string {
    try {
      const contentMsg = lookup('entity.AnnouncementContent')
      const decoded = contentMsg.toObject(contentMsg.decode(content), {
        longs: String, enums: String, bytes: Array, defaults: true,
      })
      if (decoded.body && decoded.body.length > 0) {
        return new TextDecoder().decode(new Uint8Array(decoded.body))
      }
    } catch (_) { /* ignore */ }
    return summary || ''
  }

  // 将 proto entity.Message 归一化为 MessageItem（getPinnedMessages 等场景复用）。
  // 已读/表情为独立实体（Entity.readstates/reactions），此处不内联，由 mergeEntity 侧通道补充。
  function toMessageItem(msg: any): MessageItem {
    const item: MessageItem = {
      id: msg.id || '0',
      chatId: msg.chat_id || '0',
      fromId: String(msg.from_id || '0'),
      tpy: msg.tpy || 0,
      content: msg.content || new Uint8Array(0),
      summary: msg.summary || '',
      pos: msg.pos || 0,
      badgeCount: msg.badge_count || 0,
      clientId: msg.client_id || '0',
      createTimeMs: Number(msg.create_time_ms || 0),
      status: msg.status || 0,
      refMessageId: msg.ref_message_id || '0',
      reactions: {},
    }
    // 消息行重建时回填已读缓存（key=message_id），避免消息整体替换丢失已读状态
    const cached = readStates.value.get(item.id)
    if (cached) item.readState = cached
    return item
  }

  // protobufjs 对 map<int64, T> 的 key 无法按 longs:String 转换为字符串（key 是原始字节乱码），
// 因此不能依赖 entity.readstates / entity.reactions 的 map key 做 按 msg.id 查找。
// 改为遍历 value，用 value 内部的 id 字段（ReadState.id = message_id，服务端 fill 恒填）做 key。
  function readMapByValueId(raw: Record<string, any> | any): Record<string, any> {
    const out: Record<string, any> = {}
    if (!raw || typeof raw !== 'object') return out
    for (const v of Object.values(raw) as any[]) {
      if (!v || !v.id) continue
      out[String(v.id)] = v
    }
    return out
  }

  // 解析服务端 entity.ReadState（raw）为 store 内 MessageReadState，并写入已读缓存
  function applyReadStateMap(rsRaw: Record<string, any>) {
    for (const rs of Object.values(rsRaw) as any[]) {
      if (!rs || !rs.id) continue
      const nid = String(rs.id)
      const state: MessageReadState = {
        total: rs.total || 0,
        readCount: rs.read_count || 0,
        unreadCount: rs.unread_count || 0,
        meRead: !!rs.me_read,
        // decodeAsPlain 用 longs:String，版本需转数值比较，避免字符串按位比较误跳更新
        version: Number(rs.version) || 0,
      }
      const existing = readStates.value.get(nid)
      // 已读状态版本守卫：新值不早于缓存值（防止旧已读状态回退覆盖新状态，见 push_message_readstate 注释）
      if (existing && existing.version > state.version) {
        console.log('[im][readState] SKIP older version', nid, 'existing=', existing, 'incoming=', state)
        continue
      }
      readStates.value.set(nid, state)
      console.log('[im][readState] cache set', nid, state, '|| existing=', existing)
    }
  }

  function handlePush(cmd: number, payload: Uint8Array) {
    try {
      switch (cmd) {
        case 1211: // PUSH_MESSAGES
          const pushMsg = decodeAsPlain('message.PushMessages', payload)
          console.log('[im][1211] push messages', 
            Object.keys(pushMsg.entity?.messages || {}).length, 'msgs,',
            'readstates:', Object.keys(pushMsg.entity?.readstates || {}).length, '->', pushMsg.entity?.readstates)
          mergeEntity(pushMsg.entity)
          break
        case 1111: // PUSH_FEED_LIST
          const pushFeed = decodeAsPlain('feed.PushFeedList', payload)
          mergeEntity(pushFeed.entity)
          break
        case 1117: // PUSH_FEED_READ_STATUS：会话已读位置变更，字段级防回退合并
          const readStatus = decodeAsPlain('feed.PushFeedReadStatus', payload)
          mergeFeedReadStatus(
            String(readStatus.chat_id || '0'),
            Number(readStatus.read_pos || 0),
            Number(readStatus.read_badge || 0),
          )
          break
        case 1212: // PUSH_MESSAGE_READSTATE：已读独立实体推送（entity.readstates，key=message_id）
          const readPush = decodeAsPlain('message.PushReadMessageRequest', payload)
          console.log('[im][1212] push readstate received', readPush.entity?.readstates)
          mergeEntity(readPush.entity)
          break
        case 1215: // PUSH_REACTIONS：表情独立实体推送（entity.reactions，key=message_id）
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
        case 1057: // PUSH_ENTITY_CHANGE：pipeline 实体变更信号
          // 已读/read_state/reaction 为独立实体（READSTATE/REACTION 类型），实时通道已携带最新值；
          // 此处记录脏标记（内存版，刷新即丢，不做持久化懒拉）。
          const change = decodeAsPlain('entity.EntityChange', payload)
          const dirtyKey = `${change.type}:${change.id}`
          if (dirty.value.has(dirtyKey)) {
            dirty.value.get(dirtyKey)!.add(change.version)
          } else {
            dirty.value.set(dirtyKey, new Set([change.version]))
          }
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

  // 会话已读位置字段级合并（防回退）：PUSH_FEED_READ_STATUS（1117）与本地读取收敛共用。
  // read_pos/read_badge 只进不退，本地无该 Feed 则忽略；合并后重算未读与全局角标。
  function mergeFeedReadStatus(chatId: string, readPos: number, readBadge: number) {
    const feed = feeds.value.get(chatId)
    if (!feed) return
    if (readPos <= feed.readPos) return
    feeds.value.set(chatId, {
      ...feed,
      readPos,
      readBadge,
      badge: Math.max(0, feed.referBadge - readBadge),
    })
  }

  // 上屏自动已读上报：message_ids 精确已读 + max_pos/max_badge_count 推进会话已读位置
  async function reportSeen(chatId: string, messageIds: string[], maxPos: number, maxBadgeCount: number) {
    if (!chatId) return
    if (messageIds.length === 0 && maxPos === 0) return
    try {
      await imApi.sendMessageRead(chatId, maxPos, maxBadgeCount, messageIds)
    } catch (e) {
      console.error('[im] report seen error:', e)
    }
  }

  // 标记整个会话已读：以 feed 最新位置（refer_pos + refer_badge）上报，服务端推进 read_pos 后回推角标清零
  async function markFeedRead(chatId: string) {
    const feed = feeds.value.get(chatId)
    if (!feed) return
    await reportSeen(chatId, [], feed.referPos, feed.referBadge)
  }

  // 已读详情：拉取某条消息的读/未读成员
  async function getReadMembers(chatId: string, messageId: string) {
    try {
      const resp = await imApi.getReadMembers(chatId, messageId)
      return resp.members || []
    } catch (e) {
      console.error('[im] get read members error:', e)
      return []
    }
  }

  // ─── Group management (W3) ─────────────────────────────────────

  // 群资料编辑（名称/描述/头像/入群方式），服务端响应 entity 回灌
  async function updateChat(chatId: string, data: Record<string, any> = {}) {
    try {
      const resp = await imApi.updateChat(chatId, data)
      mergeEntity(resp.entities)
    } catch (e) {
      console.error('[im] update chat error:', e)
    }
  }

  async function setAnnouncement(chatId: string, title: string, bodyText: string) {
    try {
      const body = Array.from(new TextEncoder().encode(bodyText))
      const resp = await imApi.setAnnouncement(chatId, title, 0, body, title)
      mergeEntity(resp.entities)
    } catch (e) {
      console.error('[im] set announcement error:', e)
      throw e
    }
  }

  async function deleteAnnouncement(chatId: string) {
    try {
      const resp = await imApi.deleteAnnouncement(chatId)
      mergeEntity(resp.entities)
    } catch (e) {
      console.error('[im] delete announcement error:', e)
      throw e
    }
  }

  // 全员禁言：untilMs=0 解禁
  async function globalMute(chatId: string, untilMs: number) {
    try {
      await imApi.globalMute(chatId, untilMs)
    } catch (e) {
      console.error('[im] global mute error:', e)
      throw e
    }
  }

  // 个体禁言：untilMs=0 解除
  async function muteMember(chatId: string, memberId: string, untilMs: number) {
    try {
      await imApi.muteMember(chatId, memberId, untilMs)
    } catch (e) {
      console.error('[im] mute member error:', e)
      throw e
    }
  }

  // ─── W4-1: 置顶消息 ─────────────────────────────────────────────
  // 注：Chat 实体无 pinned 字段（pin.proto 仅 message 列表 + chat 变更提示），
  // 故进入会话后通过 CHAT_GET_PINNED_MESSAGES 主动拉取维护 pinnedMessages。
  async function loadPinnedMessages(chatId: string): Promise<MessageItem[]> {
    try {
      const resp = await imApi.getPinnedMessages(chatId)
      const list = ((resp.messages || []) as any[]).map(toMessageItem).sort((a, b) => b.pos - a.pos)
      const chatItem = chats.value.get(chatId)
      if (chatItem) chats.value.set(chatId, { ...chatItem, pinnedMessages: list })
      return list
    } catch (e) {
      console.error('[im] load pinned messages error:', e)
      return []
    }
  }

  async function pinMessage(chatId: string, messageId: string) {
    try {
      await imApi.pinMessage(chatId, messageId)
      await loadPinnedMessages(chatId)
    } catch (e) {
      console.error('[im] pin message error:', e)
      throw e
    }
  }

  async function unpinMessage(chatId: string, messageId: string) {
    try {
      await imApi.unpinMessage(chatId, messageId)
      await loadPinnedMessages(chatId)
    } catch (e) {
      console.error('[im] unpin message error:', e)
      throw e
    }
  }

  // ─── W4-4: 翻译 ─────────────────────────────────────────────────
  async function translateMessage(messageId: string, chatId: string, targetLang: string) {
    try {
      const resp = await imApi.translateMessage(messageId, chatId, targetLang)
      const chatMsgs = messages.value.get(chatId)
      if (!chatMsgs) return
      const idx = chatMsgs.findIndex((m) => m.id === messageId)
      if (idx < 0) return
      chatMsgs[idx] = {
        ...chatMsgs[idx],
        translation: {
          originalText: resp.original_text || '',
          translatedText: resp.translated_text || '',
          targetLang: resp.target_lang || targetLang,
          sourceLang: resp.source_lang || '',
        },
      }
      messages.value.set(chatId, [...chatMsgs])
    } catch (e) {
      console.error('[im] translate message error:', e)
      throw e
    }
  }

  function clearTranslation(messageId: string, chatId: string) {
    const chatMsgs = messages.value.get(chatId)
    if (!chatMsgs) return
    const idx = chatMsgs.findIndex((m) => m.id === messageId)
    if (idx < 0) return
    chatMsgs[idx] = { ...chatMsgs[idx], translation: undefined }
    messages.value.set(chatId, [...chatMsgs])
  }

  // ─── W4-2: Thread ────────────────────────────────────────────────
  // 拉取并合并某根消息的回复（MESSAGE_GET_THREAD），返回消息列表便于 UI 展示
  async function loadThread(chatId: string, rootMessageId: string): Promise<MessageItem[]> {
    try {
      const resp = await imApi.getThread(chatId, rootMessageId)
      mergeEntity({ messages: resp.messages || [] })
      return ((resp.messages || []) as any[]).map(toMessageItem).sort((a, b) => a.pos - b.pos)
    } catch (e) {
      console.error('[im] load thread error:', e)
      return []
    }
  }

  // 成员列表（管理用，携带 role）
  async function getMembers(chatId: string, page: number = 1, pageSize: number = 50, keyword: string = '') {
    try {
      const resp = await imApi.getChatMembers(chatId, page, pageSize, keyword)
      return resp
    } catch (e) {
      console.error('[im] get members error:', e)
      return null
    }
  }

  // 添加群成员
  async function addChatters(chatId: string, ids: string[]) {
    try {
      await imApi.addChatChatters(chatId, ids)
    } catch (e) {
      console.error('[im] add chatters error:', e)
    }
  }

  // 移出群成员
  async function removeChatters(chatId: string, ids: string[]) {
    try {
      await imApi.removeChatChatters(chatId, ids)
    } catch (e) {
      console.error('[im] remove chatters error:', e)
    }
  }

  // 邀请链接：创建返回 code
  async function createInviteLink(chatId: string) {
    try {
      const resp = await imApi.createInviteLink(chatId)
      return resp.code || ''
    } catch (e) {
      console.error('[im] create invite link error:', e)
      return ''
    }
  }

  // 邀请码加入：成功返回 chat_id 并回灌 chat
  async function joinByInviteLink(code: string) {
    try {
      const resp = await imApi.joinByInviteLink(code)
      if (resp.chat_id && resp.chat) {
        const nid = String(resp.chat_id)
        chats.value.set(nid, { id: nid, ...normalizeChat(resp.chat) })
      }
      return resp
    } catch (e) {
      console.error('[im] join by invite link error:', e)
      return null
    }
  }

  async function revokeInviteLink(code: string) {
    try {
      await imApi.revokeInviteLink(code)
    } catch (e) {
      console.error('[im] revoke invite link error:', e)
    }
  }

  // 加群申请
  async function createJoinRequest(chatId: string) {
    try {
      const resp = await imApi.createJoinRequest(chatId)
      mergeEntity(resp.entities)
      return resp
    } catch (e) {
      console.error('[im] create join request error:', e)
      return null
    }
  }

  async function approveJoinRequest(requestId: string) {
    try {
      const resp = await imApi.approveJoinRequest(requestId)
      mergeEntity(resp.entities)
    } catch (e) {
      console.error('[im] approve join request error:', e)
    }
  }

  async function rejectJoinRequest(requestId: string) {
    try {
      await imApi.rejectJoinRequest(requestId)
    } catch (e) {
      console.error('[im] reject join request error:', e)
    }
  }

  async function listJoinRequests(chatId: string, status: number = 0) {
    try {
      return await imApi.listJoinRequests(chatId, status)
    } catch (e) {
      console.error('[im] list join requests error:', e)
      return null
    }
  }

  // 通用 chat 归一化（mergeEntity / 邀请加入共用）
  function normalizeChat(chat: any) {
    return {
      chatType: chat.chat_type || 0,
      name: chat.name || '',
      avatar: chat.avatar || '',
      ownerId: chat.owner_id || '0',
      adminIds: (chat.admin_ids || []).map(String),
      memberIds: (chat.member_ids || []).map(String),
      description: chat.description || '',
      joinMode: chat.join_mode || 0,
      globalMuteUntil: Number(chat.global_mute_until || 0),
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

    // W6-5: 启动拉取置顶会话列表（FEED_GET_TOP_LIST=1116），回填 isTop
  async function loadFeedTopList() {
    try {
      const resp = await imApi.getFeedTopList()
      if (resp?.entity) mergeEntity(resp.entity)
      if (resp?.ids && Array.isArray(resp.ids)) {
        const topIds = new Set(resp.ids.map(String))
        for (const [id, feed] of feeds.value) {
          const isTop = topIds.has(id)
          if (feed.isTop !== isTop) {
            feeds.value.set(id, { ...feed, isTop })
          }
        }
      }
    } catch (e) {
      console.error('[im] load feed top list error:', e)
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
    readStates.value = new Map()
    users.value = new Map()
    typingUsers.value = new Map()
    dirty.value = new Map()
    currentChatId.value = null
    loadingFeeds.value = false
    loadingMessages.value = false
    hasMoreMessages.value = true
  }

  // ─── 会话展示名/头像派生 ───────────────────────────────
  // P2P 会话无 name，展示名/头像取对方昵称与头像；群聊取群名。
  function peerIdOf(chat?: ChatItem): string {
    if (!chat || chat.chatType !== 1) return ''
    const me = useAuthStore().user?.id || '0'
    return chat.memberIds.find((id) => id !== me) || ''
  }

  function chatDisplayName(chat?: ChatItem): string {
    if (!chat) return ''
    if (chat.chatType === 2) return chat.name || ''
    if (chat.name) return chat.name
    const peerId = peerIdOf(chat)
    if (!peerId) return ''
    return users.value.get(peerId)?.name || ''
  }

  function chatDisplayAvatar(chat?: ChatItem): string {
    if (chat && chat.chatType === 1) {
      const peerId = peerIdOf(chat)
      const u = users.value.get(peerId)
      if (u?.avatar) return u.avatar
    }
    return chat?.avatar || ''
  }

  // 按 id 取用户资料（无则返回 undefined，方便 popup 等按需兜底）
  function getUser(id: string): UserItem | undefined {
    return users.value.get(id)
  }

  async function getDeptInfo(deptId: string): Promise<{ departments: Record<string, { id: string; name: string }> } | null> {
    try {
      const { getDeptById } = await import('@/services/im/contacts')
      const resp = await getDeptById(Number(deptId))
      return resp
    } catch {
      return null
    }
  }

  return {
    // state
    connected, connecting, wsClient,
    feeds, chats, messages, readStates, users, typingUsers,
    currentChatId, currentFeedId, currentChat,
    loadingFeeds, loadingMessages, hasMoreMessages,
    // computed
    feedList, currentMessages, totalUnread,
    // state
    replyTarget, dirty,
    // reactive clock
    now: _now,
    // actions
    connectWs, disconnectWs,
    loadFeeds, loadFeedTopList, loadMessages, loadMoreMessages,
    sendTextMessage, sendImageMessage, sendFileMessage,
    setReplyTarget, recallMessage, deleteMessage,
    setReaction, forwardMessages, sendTyping,
    retrySendMessage,
    setFeedTop, setFeedMute, removeFeed, activeFeed,
    mergeEntity, ensureUsers,
    mergeFeedReadStatus, reportSeen, getReadMembers, markFeedRead,
    updateChat, setAnnouncement, deleteAnnouncement,
    loadPinnedMessages, pinMessage, unpinMessage, translateMessage, clearTranslation, loadThread,
    globalMute, muteMember, getMembers, addChatters, removeChatters,
    createInviteLink, joinByInviteLink, revokeInviteLink,
    createJoinRequest, approveJoinRequest, rejectJoinRequest, listJoinRequests,
    selectChat,
    createP2pChat, createGroupChat,
    quitChat, dismissChat,
    chatDisplayName, chatDisplayAvatar, peerIdOf,
    getUser,
    getDeptInfo,
    reset,
  }
})
