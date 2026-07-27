import api from '@/services/api'

export interface WikiDto {
  id: string
  tenant_id: string
  name: string
  description: string | null
  icon: string | null
  cover: string | null
  creator_id: string
  home_doc_id: string | null
  created_at: string
  updated_at: string
}

export interface WikiDetailDto extends WikiDto {
  member_count: number
}

export interface WikiMemberDto {
  wiki_id: string
  user_id: string
  role: number
  joined_at: number
}

export const wikisApi = {
  list() {
    return api.get<WikiDto[]>('/office/wikis')
  },
  get(id: string) {
    return api.get<WikiDetailDto>(`/office/wikis/${id}`)
  },
  create(payload: { name: string; description?: string; icon?: string; cover?: string }) {
    return api.post<WikiDto>('/office/wikis', payload)
  },
  update(id: string, payload: { name?: string; description?: string; icon?: string; cover?: string }) {
    return api.patch<WikiDto>(`/office/wikis/${id}`, payload)
  },
  remove(id: string) {
    return api.delete(`/office/wikis/${id}`)
  },
  listMembers(id: string) {
    return api.get<WikiMemberDto[]>(`/office/wikis/${id}/members`)
  },
  addMember(id: string, userId: string, role?: number) {
    return api.post<WikiMemberDto>(`/office/wikis/${id}/members`, { user_id: userId, role })
  },
  removeMember(id: string, userId: string) {
    return api.delete(`/office/wikis/${id}/members/${userId}`)
  },
  recent(id: string) {
    return api.get(`/office/wikis/${id}/recent`)
  },
  listPins(id: string) {
    return api.get(`/office/wikis/${id}/pins`)
  },
  addPin(id: string, docId: string) {
    return api.post(`/office/wikis/${id}/pins`, { doc_id: docId })
  },
  removePin(id: string, docId: string) {
    return api.delete(`/office/wikis/${id}/pins/${docId}`)
  },
}
