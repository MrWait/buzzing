import api from '@/services/api'
import { useAuthStore } from '@/stores/auth'
import { lookup, encode, nextRid } from './proto'

export async function protoRequest(
  cmd: number,
  reqMsg: string,
  reqData: Record<string, any>,
  respMsg: string,
): Promise<any> {
  const packetType = lookup('entity.Packet')
  const respType = lookup(respMsg)
  const reqPayload = encode(reqMsg, reqData)
  const rid = nextRid()
  const auth = useAuthStore()
  const boundary = `----FormBoundary${Date.now()}${Math.random()}`
  const encoder = new TextEncoder()
  const header = encoder.encode(
    `--${boundary}\r\nContent-Disposition: form-data; name="data"\r\nContent-Type: application/octet-stream\r\n\r\n`,
  )
  const footer = encoder.encode(`\r\n--${boundary}--\r\n`)
  const parts = [header, reqPayload, footer]
  const totalLen = parts.reduce((s, p) => s + p.byteLength, 0)
  const body = new Uint8Array(totalLen)
  let offset = 0
  for (const p of parts) {
    body.set(p, offset)
    offset += p.byteLength
  }
  const res = await api.post('/v1', body, {
    headers: {
      'Content-Type': `multipart/form-data; boundary=${boundary}`,
      rid,
      cmd: cmd.toString(),
      Authorization: `Bearer ${auth.token}`,
    },
    responseType: 'arraybuffer',
  })
  const code = parseInt(res.headers['code'] || '0', 10)
  const data = new Uint8Array(res.data)
  if (code !== 0) {
    throw new Error(`proto request failed: cmd=${cmd} code=${code}`)
  }
  const packet = packetType.decode(data) as unknown as { payload: Uint8Array }
  const decoded = respType.decode(packet.payload)
  return respType.toObject(decoded, { longs: String, enums: String, defaults: true })
}

// ─── Command enum ─────────────────────────────────────────────────

export const CMD = {
  FEED_GET_LIST: 1100,
  CHAT_CREATE: 1101,
  CHAT_ENTER: 1102,
  CHAT_QUIT: 1119,
  CHAT_DISMISS: 1110,
  CHAT_GET_BY_IDS: 1109,
  MESSAGE_SEND: 1203,
  MESSAGE_GET_BY_RANGE: 1213,
  MESSAGE_REVOKE: 1204,
  MESSAGE_DELETE: 1205,
  FORWARD_MESSAGE: 1216,
  REACTION_SET: 1214,
  FAVORITE_ADD: 1500,
  USER_GET_BY_IDS: 1300,
  USER_PRESENCE_UPDATE: 1351,
  TYPING: 1403,
  CHAT_UPDATE: 1106,
  FEED_REMOVE: 1114,
  FEED_SET_TOP: 1115,
  FEED_GET_TOP_LIST: 1116,
  FEED_ACTIVE: 1118,
  FEED_GET_BY_IDS: 1120,
  FEED_SET_MUTE: 1121,
} as const

// ─── Feed API ─────────────────────────────────────────────────────

export async function pullFeedList(cursor: string = '0', count: number = 20) {
  return protoRequest(
    CMD.FEED_GET_LIST,
    'feed.PullFeedListRequest',
    { cursor, count, prev_cursor: 0 },
    'feed.PullFeedListResponse',
  )
}

export async function setFeedTop(feedId: string, top: boolean) {
  return protoRequest(CMD.FEED_SET_TOP, 'feed.SetFeedTopRequest', { id: feedId, top }, 'feed.SetFeedTopResponse')
}

export async function setFeedMute(feedId: string, mute: boolean) {
  return protoRequest(CMD.FEED_SET_MUTE, 'feed.SetFeedMuteRequest', { id: feedId, mute }, 'feed.SetFeedMuteResponse')
}

export async function removeFeed(feedId: string) {
  return protoRequest(CMD.FEED_REMOVE, 'feed.RemoveFeedRequest', { id: feedId }, 'feed.RemoveFeedResponse')
}

export async function activeFeed(feedId: string) {
  return protoRequest(CMD.FEED_ACTIVE, 'feed.ActiveFeedRequest', { id: feedId }, 'feed.ActiveFeedResponse')
}

export async function getFeedTopList() {
  return protoRequest(CMD.FEED_GET_TOP_LIST, 'feed.GetFeedTopListRequest', {}, 'feed.GetFeedTopListResponse')
}

// ─── Chat API ─────────────────────────────────────────────────────

export async function createChat(chat: Record<string, any>) {
  return protoRequest(
    CMD.CHAT_CREATE,
    'chat.CreateChatRequest',
    { chat },
    'chat.CreateChatResponse',
  )
}

export async function enterChat(chatId: string) {
  return protoRequest(
    CMD.CHAT_ENTER,
    'chat.EnterChatRequest',
    { chat_id: chatId },
    'chat.EnterChatResponse',
  )
}

export async function getChatByIds(ids: string[]) {
  return protoRequest(
    CMD.CHAT_GET_BY_IDS,
    'chat.GetChatByIdsRequest',
    { ids },
    'chat.GetChatByIdsResponse',
  )
}

export async function quitChat(chatId: string) {
  return protoRequest(
    CMD.CHAT_QUIT,
    'chat.QuitChatRequest',
    { chat_id: chatId },
    'chat.QuitChatResponse',
  )
}

export async function dismissChat(chatId: string) {
  return protoRequest(
    CMD.CHAT_DISMISS,
    'chat.DismissChatRequest',
    { chat_id: chatId },
    'chat.DismissChatResponse',
  )
}

// ─── Message API ────────────────────────────────────────────────

export async function sendMessage(
  chatId: string,
  tpy: number,
  content: Uint8Array,
  clientId?: number,
  summary?: string,
  refMessageId?: string,
  refData?: Record<string, any>,
) {
  const msg: Record<string, any> = {
    chat_id: chatId,
    tpy,
    content,
    create_time_ms: Date.now(),
  }
  if (summary) msg.summary = summary
  if (refMessageId) msg.ref_message_id = refMessageId
  if (refData) msg.ref_data = refData
  return protoRequest(
    CMD.MESSAGE_SEND,
    'message.SendMessageRequest',
    { client_id: clientId || Date.now(), message: msg },
    'message.SendMessageResponse',
  )
}

export async function getMessagesByRange(
  chatId: string,
  pos: number,
  count: number,
  direct: number = 2,
) {
  return protoRequest(
    CMD.MESSAGE_GET_BY_RANGE,
    'message.GetMessageByRangeRequest',
    { chat_id: chatId, pos, count, direct },
    'message.GetMessageByRangeResponse',
  )
}

export async function recallMessage(id: string) {
  return protoRequest(
    CMD.MESSAGE_REVOKE,
    'message.RecallMessageRequest',
    { id },
    'message.RecallMessageResponse',
  )
}

export async function deleteMessage(messageId: string, mode: number = 0) {
  return protoRequest(
    CMD.MESSAGE_DELETE,
    'message.DeleteMessageRequest',
    { message_id: messageId, mode },
    'message.DeleteMessageResponse',
  )
}

export async function forwardMessage(
  chatId: string,
  sourceChatId: string,
  messageIds: string[],
  forwardType: number = 0,
) {
  return protoRequest(
    CMD.FORWARD_MESSAGE,
    'message.ForwardMessageRequest',
    { chat_id: chatId, forward_type: forwardType, source_chat_id: sourceChatId, message_ids: messageIds },
    'message.ForwardMessageResponse',
  )
}

export async function setReaction(messageId: string, reaction: number, set: boolean) {
  return protoRequest(
    CMD.REACTION_SET,
    'message.SetMessageReactionRequest',
    { message_id: messageId, reaction, set },
    'message.SetMessageReactionResponse',
  )
}

// ─── Typing API ────────────────────────────────────────────────────

export async function sendTyping(chatId: string) {
  return protoRequest(CMD.TYPING, 'typing.TypingRequest', { chat_id: chatId }, 'typing.TypingResponse')
}

// ─── User API ────────────────────────────────────────────────────

export async function getUserByIds(ids: string[]) {
  return protoRequest(
    CMD.USER_GET_BY_IDS,
    'user.GetUserByIdsRequest',
    { ids },
    'user.GetUserByIdsResponse',
  )
}
