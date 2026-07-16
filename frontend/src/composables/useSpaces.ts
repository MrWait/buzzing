import { ref } from 'vue'
import api from '@/services/api'
import type { SpaceInfo } from '@/stores/document'

export function useSpaces() {
  const spaces = ref<SpaceInfo[]>([])
  const loading = ref(false)

  async function load() {
    loading.value = true
    try {
      const res = await api.get<SpaceInfo[]>('/spaces')
      spaces.value = res.data
    } finally {
      loading.value = false
    }
  }

  return { spaces, loading, load }
}
