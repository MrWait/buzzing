import { apiV1, encodeReq } from '@/services/api_v1'
import { CMD } from './cmd'

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
  type: string
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

function versionFromProto(p: any): VersionDto {
  return {
    id: p.id?.toString() ?? '',
    document_id: p.document_id?.toString() ?? '',
    version_number: p.version_number ?? 0,
    title: p.title ?? '',
    description: p.description || null,
    creator_id: p.creator_id?.toString() ?? '',
    is_minor: !!p.is_minor,
    created_at: p.created_at ?? '',
  }
}

function diffLineFromProto(p: any): DiffLine {
  return {
    type: p.type ?? '',
    text: p.text ?? '',
    pos: p.pos ?? 0,
  }
}

export const versionsApi = {
  async list(docId: string, limit = 50, offset = 0) {
    const { data } = await apiV1(CMD.VERSION_LIST, encodeReq('office.VersionListRequest', { doc_id: docId, limit, offset }), 'office.VersionListResponse')
    return { data: (data.items ?? []).map(versionFromProto) as VersionDto[] }
  },
  async get(docId: string, versionId: string) {
    const { data } = await apiV1(CMD.VERSION_GET, encodeReq('office.VersionGetRequest', { doc_id: docId, version_id: versionId }), 'office.VersionGetResponse')
    return { data: versionFromProto(data.item) }
  },
  async create(docId: string, payload: { title: string; description?: string }) {
    const req: any = { doc_id: docId, title: payload.title }
    if (payload.description) req.description = payload.description
    const { data } = await apiV1(CMD.VERSION_CREATE, encodeReq('office.VersionCreateRequest', req), 'office.VersionCreateResponse')
    return { data: versionFromProto(data.item) }
  },
  async diff(docId: string, v1Id: string, v2Id: string) {
    const { data } = await apiV1(CMD.VERSION_DIFF, encodeReq('office.VersionDiffRequest', { doc_id: docId, v1_id: v1Id, v2_id: v2Id }), 'office.VersionDiffResponse')
    return {
      data: {
        ops: (data.ops ?? []).map(diffLineFromProto) as DiffLine[],
        stats: data.stats ?? { additions: 0, deletions: 0 },
      } as DiffResult,
    }
  },
  async restore(docId: string, versionId: string) {
    const { data } = await apiV1(CMD.VERSION_RESTORE, encodeReq('office.VersionRestoreRequest', { doc_id: docId, version_id: versionId }), 'office.VersionRestoreResponse')
    return { data: { ok: data.ok, new_version: data.new_version ?? 0 } }
  },
}
