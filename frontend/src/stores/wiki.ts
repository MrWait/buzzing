import { defineStore } from 'pinia'
import { ref } from 'vue'
import { wikisApi, type WikiDto } from '@/services/office/wikis'

export const useWikiStore = defineStore('wiki', () => {
  const wikis = ref<WikiDto[]>([])
  const currentWikiId = ref<string | null>(null)
  const loading = ref(false)

  async function loadWikis(force = false) {
    if (!force && wikis.value.length > 0) return
    loading.value = true
    try {
      const { data } = await wikisApi.list()
      wikis.value = data
      if (data.length > 0 && !currentWikiId.value) {
        currentWikiId.value = data[0].id
      }
    } finally {
      loading.value = false
    }
  }

  function setCurrentWiki(id: string | null) {
    currentWikiId.value = id
  }

  return { wikis, currentWikiId, loading, loadWikis, setCurrentWiki }
})
