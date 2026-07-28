import { defineStore } from 'pinia'
import { reactive, ref } from 'vue'
import { docsApi, type DocDto, type DocTreeNode, type StarItemDto, type TrashItemDto, type RecentItemDto } from '@/services/office/docs'


export interface DocInfo extends DocDto {}

export const useDocumentStore = defineStore('document', () => {
  const documents = ref<DocInfo[]>([])
  const currentTree = ref<DocTreeNode[]>([])
  const starred = ref<StarItemDto[]>([])
  const recent = ref<RecentItemDto[]>([])
  const trash = ref<TrashItemDto[]>([])
  const currentWikiId = ref('')
  const starredSet = ref<Set<string>>(new Set())
  const personalTreeTick = ref(0)
  const personalExpandedMap = reactive(new Map<string, boolean>())

  async function loadDocuments(wikiId: string) {
    const res = await docsApi.list(wikiId)
    documents.value = res.data
    currentWikiId.value = wikiId
  }

  async function loadTree(wikiId: string) {
    const res = await docsApi.tree(wikiId)
    currentTree.value = res.data
  }

  async function createDocument(title: string, wikiId: string, parentId?: string | null) {
    await docsApi.create({
      wiki_id: wikiId,
      title,
      parent_id: parentId ?? undefined,
    })
    await loadDocuments(wikiId)
    await loadTree(wikiId)
  }

  async function deleteDocument(id: string) {
    await docsApi.trash(id)
    if (currentWikiId.value) {
      await loadDocuments(currentWikiId.value)
      await loadTree(currentWikiId.value)
    }
  }

  async function restoreDocument(id: string) {
    await docsApi.restore(id)
    await loadTrash()
    if (currentWikiId.value) {
      await loadDocuments(currentWikiId.value)
      await loadTree(currentWikiId.value)
    }
  }

  async function purgeDocument(id: string) {
    await docsApi.purge(id)
    await loadTrash()
  }

  async function moveDocument(id: string, payload: { parentId?: string | null }) {
    await docsApi.move(id, { parent_id: payload.parentId })
    if (currentWikiId.value) {
      await loadDocuments(currentWikiId.value)
      await loadTree(currentWikiId.value)
    }
  }

  async function duplicateDocument(id: string, includeChildren = false) {
    const res = await docsApi.duplicate(id, includeChildren)
    if (currentWikiId.value) {
      await loadDocuments(currentWikiId.value)
      await loadTree(currentWikiId.value)
    }
    return res.data
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

  async function reportVisit(id: string) {
    try {
      await docsApi.visit(id)
    } catch {
      // 记录访问失败不影响主流程
    }
  }

  return {
    documents, currentTree, starred, recent, trash, currentWikiId, starredSet, personalTreeTick, personalExpandedMap,
    loadDocuments, loadTree, createDocument, deleteDocument, restoreDocument, purgeDocument,
    moveDocument, duplicateDocument, reportVisit,
    loadStarred, toggleStar, loadRecent, loadTrash,
  }
})
