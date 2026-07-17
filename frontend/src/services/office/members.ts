import api from '@/services/api'

export interface MemberDto {
  user_id: string
  name: string
  avatar: string | null
  role: number
  role_label: string
  joined_at: number
}

export const membersApi = {
  list(docId: string) {
    return api.get<MemberDto[]>(`/office/docs/${docId}/members`).then((r) => r.data)
  },
  add(docId: string, userId: string, role: number) {
    return api
      .post(`/office/docs/${docId}/members`, { user_id: userId, role })
      .then((r) => r.data)
  },
  update(docId: string, userId: string, role: number) {
    return api
      .patch(`/office/docs/${docId}/members/${userId}`, { role })
      .then((r) => r.data)
  },
  remove(docId: string, userId: string) {
    return api.delete(`/office/docs/${docId}/members/${userId}`).then((r) => r.data)
  },
}
