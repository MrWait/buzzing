import api from '@/services/api'

export interface WikiDto {
  id: string
  tenant_id: string
  name: string
  description: string | null
  icon: string | null
  cover: string | null
  creator_id: string
  created_at: string
  updated_at: string
}

export interface WikiDetailDto extends WikiDto {
  member_count: number
  space_count: number
}

export interface WikiMemberDto {
  wiki_id: string
  user_id: string
  role: number
  joined_at: number
}

export const wikisApi = {
  /** 当前用户可访问的知识库列表 */
  list() {
    return api.get<WikiDto[]>('/office/wikis')
  },
  /** 知识库详情（含 member_count / space_count） */
  get(id: string) {
    return api.get<WikiDetailDto>(`/office/wikis/${id}`)
  },
  /** 创建知识库 */
  create(payload: { name: string; description?: string; icon?: string; cover?: string }) {
    return api.post<WikiDto>('/office/wikis', payload)
  },
  /** 更新知识库 */
  update(id: string, payload: { name?: string; description?: string; icon?: string; cover?: string }) {
    return api.patch<WikiDto>(`/office/wikis/${id}`, payload)
  },
  /** 删除知识库 */
  remove(id: string) {
    return api.delete(`/office/wikis/${id}`)
  },
  /** 成员列表 */
  listMembers(id: string) {
    return api.get<WikiMemberDto[]>(`/office/wikis/${id}/members`)
  },
  /** 添加成员 */
  addMember(id: string, userId: string, role?: number) {
    return api.post<WikiMemberDto>(`/office/wikis/${id}/members`, { user_id: userId, role })
  },
  /** 移除成员 */
  removeMember(id: string, userId: string) {
    return api.delete(`/office/wikis/${id}/members/${userId}`)
  },
  /** 知识库空间列表 */
  listSpaces(id: string) {
    return api.get(`/office/wikis/${id}/spaces`)
  },
  /** 最近更新文档 */
  recent(id: string) {
    return api.get(`/office/wikis/${id}/recent`)
  },
  /** 置顶文档列表 */
  listPins(id: string) {
    return api.get(`/office/wikis/${id}/pins`)
  },
  /** 置顶文档 */
  addPin(id: string, docId: string) {
    return api.post(`/office/wikis/${id}/pins`, { doc_id: docId })
  },
  /** 取消置顶 */
  removePin(id: string, docId: string) {
    return api.delete(`/office/wikis/${id}/pins/${docId}`)
  },
}
