import api from '@/services/api'

export interface DocDto {
  id: string
  space_id: string
  parent_id: string | null
  title: string
  icon: string | null
  cover: string | null
  doc_type: number
  version: number
  trashed_at: string | null
  created_at: string
  updated_at: string
}

export interface DocTreeNode {
  id: string
  parent_id: string | null
  title: string
  icon: string | null
  children: DocTreeNode[]
}

export interface TrashItemDto extends DocDto {
  remaining_days: number
}

export interface StarItemDto extends DocDto {
  group_name: string | null
}

export interface RecentItemDto {
  doc: DocDto
  visited_at: number
}

export interface SearchResultDto {
  id: string
  space_id: string
  title: string
  icon: string | null
  highlight: string
  matched_in: 'title' | 'content'
  updated_at: string
}

export const docsApi = {
  list(spaceId: string) {
    return api.get<DocDto[]>('/office/docs', { params: { space_id: spaceId } })
  },
  get(id: string) {
    return api.get<DocDto>(`/office/docs/${id}`)
  },
  create(payload: { space_id: string; title: string; parent_id?: string; icon?: string }) {
    return api.post<DocDto>('/office/docs', payload)
  },
  update(id: string, payload: { title?: string; icon?: string; cover?: string }) {
    return api.patch<DocDto>(`/office/docs/${id}`, payload)
  },
  trash(id: string) {
    return api.delete(`/office/docs/${id}`)
  },
  restore(id: string) {
    return api.post<DocDto>(`/office/docs/${id}/restore`)
  },
  purge(id: string) {
    return api.delete(`/office/docs/${id}/purge`)
  },
  move(id: string, payload: { space_id?: string; parent_id?: string | null }) {
    return api.post<DocDto>(`/office/docs/${id}/move`, {
      space_id: payload.space_id,
      parent_id: payload.parent_id === null ? '0' : payload.parent_id,
    })
  },
  duplicate(id: string, includeChildren = false) {
    return api.post<DocDto>(`/office/docs/${id}/duplicate`, { include_children: includeChildren })
  },
  visit(id: string) {
    return api.post(`/office/docs/${id}/visit`)
  },
  recent(limit = 20) {
    return api.get<RecentItemDto[]>('/office/docs/recent', { params: { limit } })
  },
  tree(spaceId: string) {
    return api.get<DocTreeNode[]>('/office/docs/tree', { params: { space_id: spaceId } })
  },
  trashList() {
    return api.get<TrashItemDto[]>('/office/docs/trash')
  },
  starred() {
    return api.get<StarItemDto[]>('/office/docs/starred')
  },
  star(id: string, groupName?: string) {
    return api.post(`/office/docs/${id}/star`, { group_name: groupName ?? null })
  },
  unstar(id: string) {
    return api.delete(`/office/docs/${id}/star`)
  },
  search(payload: { q: string; space_id?: string; limit?: number }) {
    return api.post<SearchResultDto[]>('/office/docs/search', payload)
  },
}
