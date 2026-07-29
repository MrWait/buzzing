import axios from 'axios'
import { apiV1, encodeReq } from '@/services/api_v1'
import { CMD } from './cmd'

const publicClient = axios.create({
  baseURL: '/api',
  timeout: 15000,
  headers: { 'Content-Type': 'application/json' },
})

export interface ShareInfoDto {
  id: string
  token: string
  url: string
  role: number
  role_label: string
  has_password: boolean
  expires_at: string | null
  max_visits: number | null
  visit_count: number
  revoked: boolean
  created_at: string
}

export interface CreateShareParams {
  role: number
  password?: string
  expires_at?: string
  max_visits?: number
}

export interface ShareResolveDto {
  doc_id: string
  title: string
  icon: string | null
  role: number
  role_label: string
  require_password: boolean
  token: string | null
}

function shareFromProto(p: any): ShareInfoDto {
  return {
    id: p.id?.toString() ?? '',
    token: p.token ?? '',
    url: p.url ?? '',
    role: p.role ?? 0,
    role_label: p.role_label ?? '',
    has_password: !!p.has_password,
    expires_at: p.expires_at || null,
    max_visits: p.max_visits ?? null,
    visit_count: p.visit_count ?? 0,
    revoked: !!p.revoked,
    created_at: p.created_at ?? '',
  }
}

export const sharesApi = {
  async create(docId: string, params: CreateShareParams) {
    const { data } = await apiV1(CMD.SHARE_CREATE, encodeReq('office.ShareCreateRequest', { doc_id: docId, ...params }), 'office.ShareCreateResponse')
    return shareFromProto(data.item) as ShareInfoDto
  },
  async list(docId: string) {
    const { data } = await apiV1(CMD.SHARE_LIST, encodeReq('office.ShareListRequest', { doc_id: docId }), 'office.ShareListResponse')
    return (data.items ?? []).map(shareFromProto) as ShareInfoDto[]
  },
  async revoke(shareId: string) {
    await apiV1(CMD.SHARE_REVOKE, encodeReq('office.ShareRevokeRequest', { share_id: shareId }))
  },
  async resolve(token: string) {
    const r = await publicClient.get<ShareResolveDto>(`/share/${token}`)
    return r.data
  },
  async verify(token: string, password: string) {
    const r = await publicClient.post<ShareResolveDto>(`/share/${token}/verify`, { password })
    return r.data
  },
}
