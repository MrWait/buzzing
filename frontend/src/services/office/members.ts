import { apiV1, encodeReq } from '@/services/api_v1'
import { CMD } from './cmd'

export interface MemberDto {
  user_id: string
  name: string
  avatar: string | null
  role: number
  role_label: string
  joined_at: number
}

function memberFromProto(p: any): MemberDto {
  return {
    user_id: p.user_id?.toString() ?? '',
    name: p.name ?? '',
    avatar: p.avatar || null,
    role: p.role ?? 0,
    role_label: p.role_label ?? '',
    joined_at: Number(p.joined_at ?? 0),
  }
}

export const membersApi = {
  async list(docId: string) {
    const { data } = await apiV1(CMD.MEMBER_LIST, encodeReq('office.MemberListRequest', { doc_id: docId }), 'office.MemberListResponse')
    return (data.items ?? []).map(memberFromProto) as MemberDto[]
  },
  async add(docId: string, userId: string, role: number) {
    await apiV1(CMD.MEMBER_ADD, encodeReq('office.MemberAddRequest', { doc_id: docId, user_id: userId, role }))
  },
  async update(docId: string, userId: string, role: number) {
    await apiV1(CMD.MEMBER_UPDATE, encodeReq('office.MemberUpdateRequest', { doc_id: docId, user_id: userId, role }))
  },
  async remove(docId: string, userId: string) {
    await apiV1(CMD.MEMBER_REMOVE, encodeReq('office.MemberRemoveRequest', { doc_id: docId, user_id: userId }))
  },
}
