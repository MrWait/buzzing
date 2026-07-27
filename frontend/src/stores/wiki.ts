import { defineStore } from 'pinia'
import { ref } from 'vue'
import { wikisApi, type WikiDto } from '@/services/office/wikis'

const STORAGE_KEY = 'buzzing_pinned_wikis'

export const useWikiStore = defineStore('wiki', () => {
  const wikis = ref<WikiDto[]>([])
  const currentWikiId = ref<string | null>(null)
  const loading = ref(false)
  const pinnedWikiIds = ref<Set<string>>(new Set())

  function loadPinnedFromStorage() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY)
      if (raw) {
        const arr: string[] = JSON.parse(raw)
        pinnedWikiIds.value = new Set(arr)
      }
    } catch {
      pinnedWikiIds.value = new Set()
    }
  }

  function savePinnedToStorage() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify([...pinnedWikiIds.value]))
  }

  function togglePinWiki(id: string) {
    if (pinnedWikiIds.value.has(id)) {
      pinnedWikiIds.value.delete(id)
    } else {
      pinnedWikiIds.value.add(id)
    }
    savePinnedToStorage()
    // trigger reactivity by replacing the Set
    pinnedWikiIds.value = new Set(pinnedWikiIds.value)
  }

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

  return {
    wikis, currentWikiId, loading, pinnedWikiIds,
    loadWikis, setCurrentWiki, loadPinnedFromStorage, togglePinWiki,
  }
})
