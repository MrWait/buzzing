import api from '@/services/api'

export interface SpaceDto {
  id: string
  name: string
  icon: string | null
  color: string | null
  sort_order: number
  sp_type: number
  archived_at: string | null
  created_at: string
  updated_at: string
}

export const spacesApi = {
  list() {
    return api.get<SpaceDto[]>('/office/spaces')
  },
  listArchived() {
    return api.get<SpaceDto[]>('/office/spaces/archived')
  },
  create(payload: { name: string; icon?: string; color?: string }) {
    return api.post<SpaceDto>('/office/spaces', payload)
  },
  update(id: string, payload: {
    name?: string
    icon?: string
    color?: string
    sort_order?: number
  }) {
    return api.put<SpaceDto>(`/office/spaces/${id}`, payload)
  },
  archive(id: string, archived: boolean) {
    return api.post<SpaceDto>(`/office/spaces/${id}/archive`, { archived })
  },
  delete(id: string) {
    return api.delete(`/office/spaces/${id}`)
  },
}
