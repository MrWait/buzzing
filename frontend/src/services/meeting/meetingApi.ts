import protobuf from 'protobufjs'
import api from '@/services/api'
import { useAuthStore } from '@/stores/auth'
import entityProto from '../../../../proto/entity.proto?raw'
import commandProto from '../../../../proto/command.proto?raw'
import meetingProto from '../../../../proto/meeting.proto?raw'

let protoRoot: protobuf.Root | null = null

function getProto(): protobuf.Root {
  if (protoRoot) return protoRoot
  const root = new protobuf.Root()
  const files = [
    { name: 'entity.proto', content: entityProto },
    { name: 'command.proto', content: commandProto },
    { name: 'meeting.proto', content: meetingProto },
  ]
  for (const { content } of files) {
    const parsed = protobuf.parse(content, { keepCase: true })
    for (const child of parsed.root.nestedArray) {
      root.add(child)
    }
  }
  root.resolveAll()
  protoRoot = root
  return root
}

let ridCounter = 0
function nextRid(): string {
  ridCounter += 1
  return `${Date.now()}${ridCounter}`
}

export async function protoRequest(cmd: number, reqMsg: string, reqData: Record<string, any>, respMsg: string): Promise<any> {
  const root = getProto()
  const reqType = root.lookupType(reqMsg)
  const respType = root.lookupType(respMsg)
  // 后端 /v1 网关返回 entity::Packet { rid, cmd, code, http, payload }，
  // 业务消息编码在 payload 字段中，需先解 Packet 再取 payload 解业务消息
  const packetType = root.lookupType('entity.Packet')
  const reqPayload = reqType.encode(reqType.create(reqData)).finish()
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
      'rid': rid,
      'cmd': cmd.toString(),
      'Authorization': `Bearer ${auth.token}`,
    },
    responseType: 'arraybuffer',
  })
  const code = parseInt(res.headers['code'] || '0', 10)
  const data = new Uint8Array(res.data)
  if (code !== 0) {
    throw new Error(`proto request failed: cmd=${cmd} code=${code}`)
  }
  const packet = packetType.decode(data) as unknown as { payload: Uint8Array }
  return respType.decode(packet.payload)
}

export interface MeetingItem {
  roomId: string
  id: string
  title: string
  hostId: string
  status: number
  createdAt: number
  scheduledAt: number
  startedAt: number
  endedAt: number
  maxParticipants: number
  members: Array<{ userId: string; role: number; status: number; joinedAt: number; leftAt: number }>
}

function toMeetingItem(info: any): MeetingItem {
  return {
    roomId: info.room_id || '',
    id: info.id?.toString() || '',
    title: info.title || '',
    hostId: info.host_id?.toString() || '',
    status: info.status || 0,
    createdAt: Number(info.created_at || 0),
    scheduledAt: Number(info.scheduled_at || 0),
    startedAt: Number(info.started_at || 0),
    endedAt: Number(info.ended_at || 0),
    maxParticipants: info.max_participants || 0,
    members: (info.members || []).map((m: any) => ({
      userId: m.user_id?.toString() || '',
      role: m.role || 0,
      status: m.status || 0,
      joinedAt: Number(m.joined_at || 0),
      leftAt: Number(m.left_at || 0),
    })),
  }
}

export async function createMeeting(title: string, password?: string, scheduledAt?: number): Promise<MeetingItem> {
  const data: Record<string, any> = { title }
  if (password) data.password = password
  if (scheduledAt) data.scheduled_at = { low: scheduledAt, high: 0 }
  if (!scheduledAt) data.max_participants = 50
  const resp = await protoRequest(1800, 'meeting.MeetingCreateRequest', data, 'meeting.MeetingCreateResponse')
  return toMeetingItem(resp.meeting)
}

export async function joinMeetingApi(roomId: string, password?: string): Promise<MeetingItem> {
  const data: Record<string, any> = { room_id: roomId }
  if (password) data.password = password
  const resp = await protoRequest(1801, 'meeting.JoinMeetingRequest', data, 'meeting.JoinMeetingResponse')
  return toMeetingItem(resp.meeting)
}

export async function leaveMeetingApi(roomId: string): Promise<void> {
  await protoRequest(1802, 'meeting.LeaveMeetingRequest', { room_id: roomId }, 'meeting.LeaveMeetingResponse')
}

export async function endMeeting(roomId: string): Promise<void> {
  await protoRequest(1803, 'meeting.EndMeetingRequest', { room_id: roomId }, 'meeting.EndMeetingResponse')
}

export async function getMeetingInfo(roomId: string): Promise<MeetingItem> {
  const resp = await protoRequest(1804, 'meeting.GetMeetingInfoRequest', { room_id: roomId }, 'meeting.GetMeetingInfoResponse')
  return toMeetingItem(resp.meeting)
}

export async function getMeetingList(filter: number, page = 1, pageSize = 50): Promise<{ meetings: MeetingItem[]; total: number }> {
  const resp = await protoRequest(1805, 'meeting.MeetingGetListRequest', { filter, page, page_size: pageSize }, 'meeting.MeetingGetListResponse')
  return {
    meetings: (resp.meetings || []).map(toMeetingItem),
    total: Number(resp.total || 0),
  }
}

export async function kickMember(roomId: string, targetId: string): Promise<void> {
  await protoRequest(1806, 'meeting.KickMeetingRequest', { room_id: roomId, target_id: { low: parseInt(targetId), high: 0 } }, 'meeting.KickMeetingResponse')
}

export async function setRole(roomId: string, targetId: string, role: number): Promise<void> {
  await protoRequest(1807, 'meeting.SetRoleRequest', { room_id: roomId, target_id: { low: parseInt(targetId), high: 0 }, role }, 'meeting.SetRoleResponse')
}

export async function inviteMembers(roomId: string, targetIds: string[]): Promise<void> {
  const ids = targetIds.map(id => ({ low: parseInt(id), high: 0 }))
  await protoRequest(1808, 'meeting.InviteMeetingRequest', { room_id: roomId, target_ids: ids }, 'meeting.InviteMeetingResponse')
}