import { apiV1, encodeReq } from '@/services/api_v1'
import { CMD } from './cmd'

function toStr(v: any): string {
  return v?.toString?.() ?? ''
}

function toNullStr(v: any): string | null {
  if (v === null || v === undefined || v === '') return null
  return v.toString()
}

export interface WalkItem {
  id: string
  title: string
  icon: string | null
  /** 0=doc, 1=wiki, 2=user(个人空间虚拟根) */
  type?: number
}

export interface DocDto {
  id: string
  wiki_id: string | null
  parent_id: string | null
  title: string
  icon: string | null
  cover: string | null
  doc_type: number
  version: number
  trashed_at: string | null
  created_at: string
  updated_at: string
  walk: WalkItem[]
  role: number
  role_label: string
}

export interface DocTreeNode {
  id: string
  parent_id: string | null
  title: string
  icon: string | null
  children: DocTreeNode[]
}

export interface TrashItemDto {
  id: string
  wiki_id: string | null
  parent_id: string | null
  title: string
  icon: string | null
  cover: string | null
  doc_type: number
  version: number
  trashed_at: string | null
  created_at: string
  updated_at: string
  walk: WalkItem[]
  role: number
  role_label: string
  remaining_days: number
}

export interface StarItemDto {
  id: string
  wiki_id: string | null
  parent_id: string | null
  title: string
  icon: string | null
  cover: string | null
  doc_type: number
  version: number
  trashed_at: string | null
  created_at: string
  updated_at: string
  walk: WalkItem[]
  role: number
  role_label: string
  group_name: string | null
}

export interface RecentItemDto {
  doc: DocDto
  visited_at: number
}

export interface SearchResultDto {
  id: string
  title: string
  icon: string | null
  highlight: string
  matched_in: string
  updated_at: string
}

function docFromProto(p: any): DocDto {
  return {
    id: toStr(p.id),
    wiki_id: toNullStr(p.wiki_id),
    parent_id: toNullStr(p.parent_id),
    title: p.title ?? '',
    icon: toNullStr(p.icon),
    cover: toNullStr(p.cover),
    doc_type: p.doc_type ?? 0,
    version: p.version ?? 0,
    trashed_at: toNullStr(p.trashed_at),
    created_at: p.created_at ?? '',
    updated_at: p.updated_at ?? '',
    walk: (p.walk ?? []).map((w: any) => ({
      id: toStr(w.id),
      title: w.title ?? '',
      icon: toNullStr(w.icon),
      type: w.type ?? 0,
    })),
    role: p.role ?? 0,
    role_label: p.role_label ?? '',
  }
}

function treeNodeFromProto(n: any): DocTreeNode {
  return {
    id: toStr(n.id),
    parent_id: toNullStr(n.parent_id),
    title: n.title ?? '',
    icon: toNullStr(n.icon),
    children: (n.children ?? []).map(treeNodeFromProto),
  }
}

function recentItemFromProto(p: any): RecentItemDto {
  return {
    doc: docFromProto(p.doc),
    visited_at: Number(p.visited_at ?? 0),
  }
}

function starItemFromProto(p: any): StarItemDto {
  const doc = docFromProto(p.doc)
  return { ...doc, group_name: toNullStr(p.group_name) }
}

function trashItemFromProto(p: any): TrashItemDto {
  const doc = docFromProto(p.doc)
  return { ...doc, remaining_days: p.remaining_days ?? 0 }
}

function searchResultFromProto(p: any): SearchResultDto {
  return {
    id: toStr(p.id),
    title: p.title ?? '',
    icon: toNullStr(p.icon),
    highlight: p.highlight ?? '',
    matched_in: p.matched_in ?? '',
    updated_at: p.updated_at ?? '',
  }
}

export const docsApi = {
  async personalTree() {
    const { data } = await apiV1(CMD.DOC_PERSONAL_TREE, encodeReq('office.PersonalTreeRequest', {}), 'office.PersonalTreeResponse')
    return { data: (data.items ?? []).map(treeNodeFromProto) as DocTreeNode[] }
  },
  async createPersonal(payload: { title: string; parent_id?: string; icon?: string }) {
    const req: any = { title: payload.title }
    if (payload.parent_id) req.parent_id = payload.parent_id
    if (payload.icon) req.icon = payload.icon
    const { data } = await apiV1(CMD.DOC_CREATE, encodeReq('office.CreateDocRequest', req), 'office.CreateDocResponse')
    return { data: { id: toStr(data.id) } as any }
  },
  async get(id: string) {
    const { data } = await apiV1(CMD.DOC_GET, encodeReq('office.GetDocRequest', { doc_id: id }), 'office.GetDocResponse')
    return { data: docFromProto(data) }
  },
  async update(id: string, payload: { title?: string; icon?: string; cover?: string }) {
    await apiV1(CMD.DOC_UPDATE, encodeReq('office.UpdateDocRequest', { doc_id: id, ...payload }))
  },
  async trash(id: string) {
    await apiV1(CMD.DOC_DELETE, encodeReq('office.DeleteDocRequest', { doc_id: id }))
  },
  async list(wikiId: string) {
    const { data } = await apiV1(CMD.DOC_LIST, encodeReq('office.ListDocsRequest', { wiki_id: wikiId }), 'office.ListDocsResponse')
    return { data: (data.items ?? []).map(docFromProto) as DocDto[] }
  },
  async create(payload: { wiki_id: string; title: string; parent_id?: string; icon?: string }) {
    const { data } = await apiV1(CMD.DOC_CREATE, encodeReq('office.CreateDocRequest', payload), 'office.CreateDocResponse')
    return { data: { id: toStr(data.id) } as any }
  },
  async restore(id: string) {
    await apiV1(CMD.DOC_RESTORE, encodeReq('office.RestoreDocRequest', { doc_id: id }))
  },
  async purge(id: string) {
    await apiV1(CMD.DOC_PURGE, encodeReq('office.PurgeDocRequest', { doc_id: id }))
  },
  async move(id: string, payload: { parent_id?: string | null }) {
    await apiV1(CMD.DOC_MOVE, encodeReq('office.MoveDocRequest', { doc_id: id, parent_id: payload.parent_id || '' }))
  },
  async duplicate(id: string, includeChildren = false) {
    const { data } = await apiV1(CMD.DOC_DUPLICATE, encodeReq('office.DuplicateDocRequest', { doc_id: id, include_children: includeChildren }), 'office.DuplicateDocResponse')
    return { data: { id: toStr(data.id) } as any }
  },
  async visit(id: string) {
    await apiV1(CMD.DOC_VISIT, encodeReq('office.VisitDocRequest', { doc_id: id }))
  },
  async recent(limit = 20) {
    const { data } = await apiV1(CMD.DOC_RECENT, encodeReq('office.RecentDocsRequest', { limit }), 'office.RecentDocsResponse')
    return { data: (data.items ?? []).map(recentItemFromProto) as RecentItemDto[] }
  },
  async tree(wikiId: string) {
    const { data } = await apiV1(CMD.DOC_LIST_TREE, encodeReq('office.TreeDocsRequest', { wiki_id: wikiId }), 'office.TreeDocsResponse')
    return { data: (data.items ?? []).map(treeNodeFromProto) as DocTreeNode[] }
  },
  async trashList() {
    const { data } = await apiV1(CMD.DOC_TRASH_LIST, encodeReq('office.PersonalTreeRequest', {}), 'office.TrashListResponse')
    return { data: (data.items ?? []).map(trashItemFromProto) as TrashItemDto[] }
  },
  async starred() {
    const { data } = await apiV1(CMD.DOC_STARRED, encodeReq('office.PersonalTreeRequest', {}), 'office.StarredDocsResponse')
    return { data: (data.items ?? []).map(starItemFromProto) as StarItemDto[] }
  },
  async star(id: string, groupName?: string) {
    await apiV1(CMD.DOC_STAR, encodeReq('office.StarDocRequest', { doc_id: id, group_name: groupName ?? '' }))
  },
  async unstar(id: string) {
    await apiV1(CMD.DOC_UNSTAR, encodeReq('office.UnstarDocRequest', { doc_id: id }))
  },
  async search(payload: { q: string; wiki_id?: string; limit?: number }) {
    const { data } = await apiV1(CMD.DOC_SEARCH, encodeReq('office.SearchDocsRequest', payload), 'office.SearchDocsResponse')
    return { data: (data.items ?? []).map(searchResultFromProto) as SearchResultDto[] }
  },
  async my() {
    const { data } = await apiV1(CMD.DOC_MY, encodeReq('office.PersonalTreeRequest', {}), 'office.MyDocsResponse')
    return { data: (data.items ?? []).map(docFromProto) as DocDto[] }
  },
  async shared() {
    const { data } = await apiV1(CMD.DOC_SHARED, encodeReq('office.PersonalTreeRequest', {}), 'office.SharedDocsResponse')
    return { data: (data.items ?? []).map(docFromProto) as DocDto[] }
  },
}
