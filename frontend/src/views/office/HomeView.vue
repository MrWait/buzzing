<template>
  <div class="home">
    <SpaceSidebar
      :active-view="view"
      @switch-view="onSwitchView"
      @search="searchOpen = true"
      @collapse-change="onCollapseChange"
    />

    <section class="content" :class="{ 'sidebar-collapsed': contentShifted }">
      <WikiHome v-if="view === 'wiki' && wikiStore.currentWikiId" />
      <DocList v-else-if="view === 'space'" />
      <StarredView v-else-if="view === 'starred'" />
      <RecentView v-else-if="view === 'recent'" />
      <TrashView v-else-if="view === 'trash'" />
    </section>

    <SearchBar v-model:open="searchOpen" />
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, watch } from 'vue'
import { useDocumentStore } from '@/stores/document'
import { useWikiStore } from '@/stores/wiki'
import SpaceSidebar from './components/SpaceSidebar.vue'
import DocList from './components/DocList.vue'
import SearchBar from './components/SearchBar.vue'
import WikiHome from './components/WikiHome.vue'
import StarredView from './views/StarredView.vue'
import RecentView from './views/RecentView.vue'
import TrashView from './TrashView.vue'

type ViewMode = 'wiki' | 'space' | 'starred' | 'recent' | 'trash'

const store = useDocumentStore()
const wikiStore = useWikiStore()
const searchOpen = ref(false)
const view = ref<ViewMode>('wiki')
const contentShifted = ref(false)

onMounted(async () => {
  await wikiStore.loadWikis()
  await store.loadSpaces()
  await store.loadStarred()
  if (wikiStore.currentWikiId) {
    view.value = 'wiki'
  } else if (store.currentSpaceId) {
    view.value = 'space'
    await store.loadDocuments(store.currentSpaceId)
  }
})

watch(
  () => store.currentSpaceId,
  async (id) => {
    if (id && view.value === 'space') {
      await store.loadDocuments(id)
    }
  },
)

watch(
  () => wikiStore.currentWikiId,
  (id) => {
    if (id && view.value !== 'wiki') {
      view.value = 'wiki'
    }
  },
)

function onCollapseChange(collapsed: boolean) {
  contentShifted.value = collapsed
}

function onSwitchView(v: ViewMode) {
  view.value = v
  if (v === 'starred') store.loadStarred()
  if (v === 'recent') store.loadRecent()
  if (v === 'trash') store.loadTrash()
}
</script>

<style scoped>
.home {
  display: flex;
  height: 100%;
  position: relative;
}

.content {
  flex: 1;
  min-width: 0;
  padding: 16px 24px;
  overflow-y: auto;
}
.content.sidebar-collapsed {
  padding-left: 60px;
}
</style>
