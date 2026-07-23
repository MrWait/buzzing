import { defineStore } from 'pinia'
import { ref } from 'vue'
import { docsApi, type DocDto, type DocTreeNode, type StarItemDto, type TrashItemDto, type RecentItemDto } from '@/services/office/docs'
import { spacesApi, type SpaceDto } from '@/services/office/spaces'

// 兼容旧调用点使用的字段名
export interface SpaceInfo extends SpaceDto {}
export interface DocInfo extends DocDto {}

export const useDocumentStore = defineStore('document', () => {
  const spaces = ref<SpaceInfo[]>([])
  const documents = ref<DocInfo[]>([])
  const currentTree = ref<DocTreeNode[]>([])
  const starred = ref<StarItemDto[]>([])
  const recent = ref<RecentItemDto[]>([])
  const trash = ref<TrashItemDto[]>([])
  const currentSpaceId = ref('')
  const starredSet = ref<Set<string>>(new Set())
  // M7 知识库过滤
  const filter = ref<{ wiki_id?: string }>({})

  async function loadSpaces() {
    const res = await spacesApi.list()
    spaces.value = res.data
    if (spaces.value.length > 0 && !currentSpaceId.value) {
      currentSpaceId.value = spaces.value[0].id
    }
  }

  async function loadDocuments(spaceId: string) {
    const res = await docsApi.list(spaceId)
    documents.value = res.data
    currentSpaceId.value = spaceId
  }

  async function loadTree(spaceId: string) {
    const res = await docsApi.tree(spaceId)
    currentTree.value = res.data
  }

  async function createDocument(title: string, spaceId: string, parentId?: string | null) {
    await docsApi.create({
      space_id: spaceId,
      title,
      parent_id: parentId ?? undefined,
    })
    await loadDocuments(spaceId)
    await loadTree(spaceId)
  }

  async function deleteDocument(id: string) {
    await docsApi.trash(id)
    if (currentSpaceId.value) {
      await loadDocuments(currentSpaceId.value)
      await loadTree(currentSpaceId.value)
    }
  }

  async function restoreDocument(id: string) {
    await docsApi.restore(id)
    await loadTrash()
    if (currentSpaceId.value) {
      await loadDocuments(currentSpaceId.value)
      await loadTree(currentSpaceId.value)
    }
  }

  async function purgeDocument(id: string) {
    await docsApi.purge(id)
    await loadTrash()
  }

  async function moveDocument(id: string, payload: { spaceId?: string; parentId?: string | null }) {
    await docsApi.move(id, { space_id: payload.spaceId, parent_id: payload.parentId })
    if (currentSpaceId.value) {
      await loadDocuments(currentSpaceId.value)
      await loadTree(currentSpaceId.value)
    }
  }

  async function duplicateDocument(id: string, includeChildren = false) {
    const res = await docsApi.duplicate(id, includeChildren)
    if (currentSpaceId.value) {
      await loadDocuments(currentSpaceId.value)
      await loadTree(currentSpaceId.value)
    }
    return res.data
  }

  async function createSpace(name: string, extra?: { icon?: string; color?: string }) {
    await spacesApi.create({ name, ...extra })
    await loadSpaces()
  }

  async function updateSpace(id: string, payload: { name?: string; icon?: string; color?: string; sort_order?: number }) {
    await spacesApi.update(id, payload)
    await loadSpaces()
  }

  async function archiveSpace(id: string, archived: boolean) {
    await spacesApi.archive(id, archived)
    await loadSpaces()
  }

  async function deleteSpace(id: string) {
    await spacesApi.delete(id)
    await loadSpaces()
  }

  async function loadStarred() {
    const res = await docsApi.starred()
    starred.value = res.data
    starredSet.value = new Set(res.data.map(s => s.id))
  }

  async function toggleStar(id: string) {
    if (starredSet.value.has(id)) {
      await docsApi.unstar(id)
      starredSet.value.delete(id)
    } else {
      await docsApi.star(id)
      starredSet.value.add(id)
    }
    await loadStarred()
  }

  async function loadRecent(limit = 20) {
    const res = await docsApi.recent(limit)
    recent.value = res.data
  }

  async function loadTrash() {
    const res = await docsApi.trashList()
    trash.value = res.data
  }

  function setFilter(f: { wiki_id?: string }) {
    filter.value = f
  }

  async function reportVisit(id: string) {
    try {
      await docsApi.visit(id)
    } catch {
      // 记录访问失败不影响主流程
    }
  }

  return {
    // state
    spaces, documents, currentTree, starred, recent, trash, currentSpaceId, starredSet, filter,
    // spaces
    loadSpaces, createSpace, updateSpace, archiveSpace, deleteSpace,
    // documents
    loadDocuments, loadTree, createDocument, deleteDocument, restoreDocument, purgeDocument,
    moveDocument, duplicateDocument, reportVisit,
    // views
    loadStarred, toggleStar, loadRecent, loadTrash, setFilter,
  }
})
