import axios from 'axios'
import api from '@/services/api'

// 公开分享接口用独立 axios 实例，避免 401 时误触发全局登出
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

export const sharesApi = {
  create(docId: string, params: CreateShareParams) {
    return api.post<ShareInfoDto>(`/office/docs/${docId}/share`, params).then((r) => r.data)
  },
  list(docId: string) {
    return api.get<ShareInfoDto[]>(`/office/docs/${docId}/shares`).then((r) => r.data)
  },
  revoke(shareId: string) {
    return api.delete(`/office/docs/shares/${shareId}`).then((r) => r.data)
  },
  resolve(token: string) {
    return publicClient.get<ShareResolveDto>(`/share/${token}`).then((r) => r.data)
  },
  verify(token: string, password: string) {
    return publicClient
      .post<ShareResolveDto>(`/share/${token}/verify`, { password })
      .then((r) => r.data)
  },
}
