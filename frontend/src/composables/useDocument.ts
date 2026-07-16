import { ref } from 'vue'
import api from '@/services/api'

export interface DocDetail {
  id: number
  space_id: number
  title: string
  doc_type: number
  version: number
  created_at: string
  updated_at: string
}

export function useDocument() {
  const doc = ref<DocDetail | null>(null)
  const loading = ref(false)

  async function load(docId: number) {
    loading.value = true
    try {
      const res = await api.get<DocDetail>(`/docs/${docId}`)
      doc.value = res.data
    } finally {
      loading.value = false
    }
  }

  return { doc, loading, load }
}
