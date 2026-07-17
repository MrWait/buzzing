<template>
  <div class="home">
    <SpaceSidebar
      :active-view="view"
      @switch-view="onSwitchView"
      @search="searchOpen = true"
      @collapse-change="onCollapseChange"
    />

    <section class="content" :class="{ 'sidebar-collapsed': contentShifted }">
      <DocList v-if="view === 'space'" />
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
import SpaceSidebar from './components/SpaceSidebar.vue'
import DocList from './components/DocList.vue'
import SearchBar from './components/SearchBar.vue'
import StarredView from './views/StarredView.vue'
import RecentView from './views/RecentView.vue'
import TrashView from './TrashView.vue'

type ViewMode = 'space' | 'starred' | 'recent' | 'trash'

const store = useDocumentStore()
const searchOpen = ref(false)
const view = ref<ViewMode>('space')
const contentShifted = ref(false)

onMounted(async () => {
  await store.loadSpaces()
  await store.loadStarred()
  if (store.currentSpaceId) {
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
