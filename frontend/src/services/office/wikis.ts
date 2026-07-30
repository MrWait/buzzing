import { apiV1, encodeReq } from '@/services/api_v1'
import { CMD } from './cmd'

export interface WikiDto {
  id: string
  name: string
  description: string | null
  icon: string | null
  cover: string | null
  creator_id: string
  home_doc_id: string | null
  created_at: string
  updated_at: string
  visibility: number
  allow_external_share: boolean
  reader_permission: number
}

export interface WikiDetailDto extends WikiDto {
  member_count: number
}

export interface WikiMemberDto {
  wiki_id: string
  user_id: string
  role: number
  joined_at: number
  name: string
  avatar: string
}

function wikiFromProto(p: any): WikiDto {
  return {
    id: p.id?.toString() ?? '',
    name: p.name ?? '',
    description: p.description || null,
    icon: p.icon || null,
    cover: p.cover || null,
    creator_id: p.creator_id?.toString() ?? '',
    home_doc_id: p.home_doc_id ? p.home_doc_id.toString() : null,
    created_at: p.created_at ?? '',
    updated_at: p.updated_at ?? '',
    visibility: p.visibility ?? 0,
    allow_external_share: p.allow_external_share ?? true,
    reader_permission: p.reader_permission ?? 0,
  }
}

function wikiMemberFromProto(p: any): WikiMemberDto {
  return {
    wiki_id: p.wiki_id?.toString() ?? '',
    user_id: p.user_id?.toString() ?? '',
    role: p.role ?? 0,
    joined_at: Number(p.joined_at ?? 0),
    name: p.name ?? '',
    avatar: p.avatar ?? '',
  }
}

export const wikisApi = {
  async list() {
    const { data } = await apiV1(CMD.WIKI_LIST, encodeReq('office.PersonalTreeRequest', {}), 'office.WikiListResponse')
    return { data: (data.items ?? []).map(wikiFromProto) as WikiDto[] }
  },
  async get(id: string) {
    const { data } = await apiV1(CMD.WIKI_GET, encodeReq('office.WikiGetRequest', { wiki_id: id }), 'office.WikiGetResponse')
    const wiki = data.detail?.wiki ? wikiFromProto(data.detail.wiki) : ({} as WikiDto)
    const detail: WikiDetailDto = { ...wiki, member_count: data.detail?.member_count ?? 0 }
    return { data: detail }
  },
  async create(payload: { name: string; description?: string; icon?: string; cover?: string }) {
    const { data } = await apiV1(CMD.WIKI_CREATE, encodeReq('office.WikiCreateRequest', payload), 'office.WikiCreateResponse')
    return { data: wikiFromProto(data.item) as WikiDto }
  },
  async update(id: string, payload: { name?: string; description?: string; icon?: string; cover?: string }) {
    const { data } = await apiV1(CMD.WIKI_UPDATE, encodeReq('office.WikiUpdateRequest', { wiki_id: id, ...payload }), 'office.WikiUpdateResponse')
    return { data: wikiFromProto(data.item) as WikiDto }
  },
  async updateSecurity(id: string, payload: { visibility: number; allow_external_share: boolean; reader_permission: number }) {
    const { data } = await apiV1(CMD.WIKI_UPDATE_SECURITY, encodeReq('office.WikiUpdateSecurityRequest', { wiki_id: id, ...payload }), 'office.WikiUpdateResponse')
    return { data: wikiFromProto(data.item) as WikiDto }
  },
  async remove(id: string) {
    await apiV1(CMD.WIKI_DELETE, encodeReq('office.WikiDeleteRequest', { wiki_id: id }))
  },
  async listMembers(id: string) {
    const { data } = await apiV1(CMD.WIKI_MEMBER_LIST, encodeReq('office.WikiMemberListRequest', { wiki_id: id }), 'office.WikiMemberListResponse')
    return { data: (data.items ?? []).map(wikiMemberFromProto) as WikiMemberDto[] }
  },
  async addMember(id: string, userId: string, role?: number) {
    const { data } = await apiV1(CMD.WIKI_MEMBER_ADD, encodeReq('office.WikiMemberAddRequest', { wiki_id: id, user_id: userId, role: role ?? 1 }), 'office.WikiMemberAddResponse')
    return { data: wikiMemberFromProto(data.item) as WikiMemberDto }
  },
  async removeMember(id: string, userId: string) {
    await apiV1(CMD.WIKI_MEMBER_REMOVE, encodeReq('office.WikiMemberRemoveRequest', { wiki_id: id, user_id: userId }))
  },
  async recent(id: string) {
    const { data } = await apiV1(CMD.WIKI_RECENT, encodeReq('office.WikiRecentListRequest', { wiki_id: id }), 'office.WikiRecentListResponse')
    return { data: data.items ?? [] }
  },
  async listPins(id: string) {
    const { data } = await apiV1(CMD.WIKI_PIN_LIST, encodeReq('office.WikiPinListRequest', { wiki_id: id }), 'office.WikiPinListResponse')
    return { data: (data.items ?? []) as any[] }
  },
  async addPin(id: string, docId: string) {
    await apiV1(CMD.WIKI_PIN_ADD, encodeReq('office.WikiPinAddRequest', { wiki_id: id, doc_id: docId }))
  },
  async removePin(id: string, docId: string) {
    await apiV1(CMD.WIKI_PIN_REMOVE, encodeReq('office.WikiPinRemoveRequest', { wiki_id: id, doc_id: docId }))
  },
}
