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
  // 命令号以 proto/command.proto:83-85 为准：1204=RESEND / 1205=RECALL / 1206=DELETE
  MESSAGE_RESEND: 1204,
  MESSAGE_RECALL: 1205,
  MESSAGE_DELETE: 1206,
  // 已读回执：消息级已读 + 会话已读位置（max_pos + 透传 max_badge_count），见 data_sync §6
  MESSAGE_READ: 1209,
  // 已读详情：按 message_id 拉取读/未读成员
  MESSAGE_GET_READ_MEMBERS: 1218,
  FORWARD_MESSAGE: 1216,
  REACTION_SET: 1214,
  FAVORITE_ADD: 1500,
  USER_GET_BY_IDS: 1300,
  USER_PRESENCE_UPDATE: 1351,
  TYPING: 1403,
  CHAT_UPDATE: 1106,
  // M2: 群管理 (1122-1133)
  CHAT_SET_ANNOUNCEMENT: 1122,
  CHAT_DELETE_ANNOUNCEMENT: 1123,
  CHAT_MUTE_MEMBER: 1124,
  CHAT_GLOBAL_MUTE: 1125,
  CHAT_INVITE_LINK_CREATE: 1126,
  CHAT_INVITE_LINK_JOIN: 1127,
  CHAT_INVITE_LINK_REVOKE: 1128,
  CHAT_JOIN_REQUEST_CREATE: 1129,
  CHAT_JOIN_REQUEST_APPROVE: 1130,
  CHAT_JOIN_REQUEST_REJECT: 1131,
  CHAT_JOIN_REQUEST_LIST: 1132,
  CHAT_GET_MEMBERS: 1133,
  // W4-1: Pin 消息 (1134-1136)
  CHAT_PIN_MESSAGE: 1134,
  CHAT_UNPIN_MESSAGE: 1135,
  CHAT_GET_PINNED_MESSAGES: 1136,
  FEED_REMOVE: 1114,
  FEED_SET_TOP: 1115,
  FEED_GET_TOP_LIST: 1116,
  FEED_ACTIVE: 1118,
  FEED_GET_BY_IDS: 1120,
  FEED_SET_MUTE: 1121,
  // W4-4: 翻译
  TRANSLATE_MESSAGE: 1420,
  // W4-6: 搜索
  SEARCH_MESSAGE: 1401,
  GLOBAL_SEARCH: 1406,
  // W4-2: Thread
  MESSAGE_GET_THREAD: 1217,
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

// ─── Group management (W3) ────────────────────────────────────────

export async function updateChat(chatId: string, data: Record<string, any> = {}) {
  return protoRequest(
    CMD.CHAT_UPDATE,
    'chat.UpdateChatRequest',
    { chat_id: chatId, ...data },
    'chat.UpdateChatResponse',
  )
}

export async function getChatMembers(chatId: string, page: number = 1, pageSize: number = 50, keyword: string = '') {
  return protoRequest(
    CMD.CHAT_GET_MEMBERS,
    'chat.GetMembersRequest',
    { chat_id: chatId, page, page_size: pageSize, keyword },
    'chat.GetMembersResponse',
  )
}

export async function setAnnouncement(chatId: string, title: string, tpy: number, body: number[], summary: string) {
  return protoRequest(
    CMD.CHAT_SET_ANNOUNCEMENT,
    'chat.SetAnnouncementRequest',
    { chat_id: chatId, title, tpy, body, summary },
    'chat.SetAnnouncementResponse',
  )
}

export async function deleteAnnouncement(chatId: string) {
  return protoRequest(
    CMD.CHAT_DELETE_ANNOUNCEMENT,
    'chat.DeleteAnnouncementRequest',
    { chat_id: chatId },
    'chat.DeleteAnnouncementResponse',
  )
}

export async function muteMember(chatId: string, memberId: string, untilMs: number) {
  return protoRequest(
    CMD.CHAT_MUTE_MEMBER,
    'mute.MuteMemberRequest',
    { chat_id: chatId, member_id: memberId, until_ms: untilMs },
    'mute.MuteMemberResponse',
  )
}

export async function globalMute(chatId: string, untilMs: number) {
  return protoRequest(
    CMD.CHAT_GLOBAL_MUTE,
    'mute.GlobalMuteRequest',
    { chat_id: chatId, until_ms: untilMs },
    'mute.GlobalMuteResponse',
  )
}

export async function createInviteLink(chatId: string, expiresAt: number = 0, maxUses: number = 0) {
  return protoRequest(
    CMD.CHAT_INVITE_LINK_CREATE,
    'invite.InviteLinkCreateRequest',
    { chat_id: chatId, expires_at: expiresAt, max_uses: maxUses },
    'invite.InviteLinkCreateResponse',
  )
}

export async function joinByInviteLink(code: string) {
  return protoRequest(
    CMD.CHAT_INVITE_LINK_JOIN,
    'invite.InviteLinkJoinRequest',
    { code },
    'invite.InviteLinkJoinResponse',
  )
}

export async function revokeInviteLink(code: string) {
  return protoRequest(
    CMD.CHAT_INVITE_LINK_REVOKE,
    'invite.InviteLinkRevokeRequest',
    { code },
    'invite.InviteLinkRevokeResponse',
  )
}

export async function createJoinRequest(chatId: string) {
  return protoRequest(
    CMD.CHAT_JOIN_REQUEST_CREATE,
    'join_request.JoinRequestCreateRequest',
    { chat_id: chatId },
    'join_request.JoinRequestCreateResponse',
  )
}

export async function approveJoinRequest(requestId: string) {
  return protoRequest(
    CMD.CHAT_JOIN_REQUEST_APPROVE,
    'join_request.JoinRequestApproveRequest',
    { request_id: requestId },
    'join_request.JoinRequestApproveResponse',
  )
}

export async function rejectJoinRequest(requestId: string) {
  return protoRequest(
    CMD.CHAT_JOIN_REQUEST_REJECT,
    'join_request.JoinRequestRejectRequest',
    { request_id: requestId },
    'join_request.JoinRequestRejectResponse',
  )
}

export async function listJoinRequests(chatId: string, status: number = 0, page: number = 1, pageSize: number = 20) {
  return protoRequest(
    CMD.CHAT_JOIN_REQUEST_LIST,
    'join_request.JoinRequestListRequest',
    { chat_id: chatId, status, page, page_size: pageSize },
    'join_request.JoinRequestListResponse',
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

// ─── W4-1: Pin 消息 ───────────────────────────────────────────────

export async function pinMessage(chatId: string, messageId: string) {
  return protoRequest(
    CMD.CHAT_PIN_MESSAGE,
    'pin.PinMessageRequest',
    { chat_id: chatId, message_id: messageId },
    'pin.PinMessageResponse',
  )
}

export async function unpinMessage(chatId: string, messageId: string) {
  return protoRequest(
    CMD.CHAT_UNPIN_MESSAGE,
    'pin.UnpinMessageRequest',
    { chat_id: chatId, message_id: messageId },
    'pin.UnpinMessageResponse',
  )
}

export async function getPinnedMessages(chatId: string) {
  return protoRequest(
    CMD.CHAT_GET_PINNED_MESSAGES,
    'pin.GetPinnedMessagesRequest',
    { chat_id: chatId },
    'pin.GetPinnedMessagesResponse',
  )
}

// ─── W4-4: 翻译 ───────────────────────────────────────────────────

export async function translateMessage(messageId: string, chatId: string, targetLang: string) {
  return protoRequest(
    CMD.TRANSLATE_MESSAGE,
    'translate.TranslateMessageRequest',
    { message_id: messageId, chat_id: chatId, target_lang: targetLang },
    'translate.TranslateMessageResponse',
  )
}

// ─── W4-6: 搜索 ───────────────────────────────────────────────────

// 会话内/筛选搜索（chat_id=0 不限）
export async function searchMessages(
  keyword: string,
  filter: Record<string, any> = {},
  page: number = 1,
  pageSize: number = 20,
) {
  return protoRequest(
    CMD.SEARCH_MESSAGE,
    'search.SearchRequest',
    { keyword, page, page_size: pageSize, filter },
    'search.SearchMessagesResponse',
  )
}

// 全局搜索：并行搜索 message/chat/user/file 并合并返回顶部结果
export async function globalSearch(keyword: string, types: string[] = [], page: number = 1, pageSize: number = 10) {
  return protoRequest(
    CMD.GLOBAL_SEARCH,
    'search.GlobalSearchRequest',
    { keyword, page, page_size: pageSize, types },
    'search.GlobalSearchResponse',
  )
}

// ─── W4-2: Thread ─────────────────────────────────────────────────

export async function getThread(chatId: string, rootMessageId: string, page: number = 1, pageSize: number = 50) {
  return protoRequest(
    CMD.MESSAGE_GET_THREAD,
    'thread.GetThreadRequest',
    { chat_id: chatId, root_message_id: rootMessageId, page, page_size: pageSize },
    'thread.GetThreadResponse',
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
    CMD.MESSAGE_RECALL,
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

// 上屏已读上报：message_ids 为精确消息级已读；max_pos/max_badge_count 推进会话已读位置
export async function sendMessageRead(
  chatId: string,
  maxPos: number,
  maxBadgeCount: number,
  messageIds: string[],
) {
  return protoRequest(
    CMD.MESSAGE_READ,
    'message.MessageReadRequest',
    { chat_id: chatId, max_pos: maxPos, max_badge_count: maxBadgeCount, message_ids: messageIds },
    'message.MessageReadResponse',
  )
}

// 已读详情：返回某条消息的读/未读成员列表（is_read 区分）
export async function getReadMembers(chatId: string, messageId: string) {
  return protoRequest(
    CMD.MESSAGE_GET_READ_MEMBERS,
    'message.GetReadMembersRequest',
    { chat_id: chatId, message_id: messageId },
    'message.GetReadMembersResponse',
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
