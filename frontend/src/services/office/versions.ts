import api from '@/services/api'

export interface VersionDto {
  id: string
  document_id: string
  version_number: number
  title: string
  description: string | null
  creator_id: string
  is_minor: boolean
  created_at: string
}

export interface DiffLine {
  type: 'equal' | 'insert' | 'delete'
  text: string
  pos: number
}

export interface DiffStats {
  additions: number
  deletions: number
}

export interface DiffResult {
  ops: DiffLine[]
  stats: DiffStats
}

export const versionsApi = {
  list(docId: string, limit = 50, offset = 0) {
    return api.get<VersionDto[]>(`/office/docs/${docId}/versions`, {
      params: { limit, offset },
    })
  },
  get(docId: string, versionId: string) {
    return api.get<VersionDto>(`/office/docs/${docId}/versions/${versionId}`)
  },
  create(docId: string, payload: { title: string; description?: string }) {
    return api.post<VersionDto>(`/office/docs/${docId}/versions`, payload)
  },
  diff(docId: string, v1Id: string, v2Id: string) {
    return api.post<DiffResult>(`/office/docs/${docId}/versions/diff`, {
      v1_id: v1Id,
      v2_id: v2Id,
    })
  },
  restore(docId: string, versionId: string) {
    return api.post<{ ok: boolean; new_version: number }>(
      `/office/docs/${docId}/versions/${versionId}/restore`,
    )
  },
}
