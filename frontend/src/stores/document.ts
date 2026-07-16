import { defineStore } from 'pinia'
import { ref } from 'vue'
import api from '@/services/api'

export interface SpaceInfo {
  id: string
  name: string
  sp_type: number
  created_at: string
  updated_at: string
}

export interface DocInfo {
  id: string
  space_id: string
  title: string
  doc_type: number
  version: number
  created_at: string
  updated_at: string
}

export const useDocumentStore = defineStore('document', () => {
  const spaces = ref<SpaceInfo[]>([])
  const documents = ref<DocInfo[]>([])
  const currentSpaceId = ref('')

  async function loadSpaces() {
    const res = await api.get<SpaceInfo[]>('/office/spaces')
    spaces.value = res.data
    if (spaces.value.length > 0 && !currentSpaceId.value) {
      currentSpaceId.value = spaces.value[0].id
    }
  }

  async function loadDocuments(spaceId: string) {
    const res = await api.get<DocInfo[]>('/office/docs', { params: { space_id: spaceId } })
    documents.value = res.data
    currentSpaceId.value = spaceId
  }

  async function createDocument(title: string, spaceId: string) {
    await api.post('/office/docs', { space_id: spaceId, title })
    await loadDocuments(spaceId)
  }

  async function deleteDocument(id: string) {
    await api.delete(`/office/docs/${id}`)
    await loadDocuments(currentSpaceId.value)
  }

  async function createSpace(name: string) {
    await api.post('/office/spaces', { name })
    await loadSpaces()
  }

  return { spaces, documents, currentSpaceId, loadSpaces, loadDocuments, createDocument, deleteDocument, createSpace }
})
