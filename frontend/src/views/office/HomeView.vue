<template>
  <div class="home">
    <PersonalSidebar
      @search="searchOpen = true"
      @collapse-change="onCollapseChange"
      @section-change="onSectionChange"
    />

    <section class="content" :class="{ 'sidebar-collapsed': contentShifted }">
      <HomePanel v-if="currentSection === 'home'" @navigate-wiki="onNavigateWiki" />
      <WikiGrid v-if="currentSection === 'wikis'" />
      <StarredView v-if="currentSection === 'starred'" />
      <TrashView v-if="currentSection === 'trash'" />
    </section>

    <SearchBar v-model:open="searchOpen" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import PersonalSidebar from './components/PersonalSidebar.vue'
import SearchBar from './components/SearchBar.vue'
import HomePanel from './components/HomePanel.vue'
import WikiGrid from './components/WikiGrid.vue'
import StarredView from './views/StarredView.vue'
import TrashView from './TrashView.vue'

const router = useRouter()
const route = useRoute()
const searchOpen = ref(false)
const contentShifted = ref(false)
const currentSection = ref(initSection())

function initSection(): string {
  const s = route.query.section
  if (s === 'wikis' || s === 'starred' || s === 'trash') return s
  return 'home'
}

function onSectionChange(section: string) {
  currentSection.value = section
  router.replace({ query: { section } })
}

function onCollapseChange(collapsed: boolean) {
  contentShifted.value = collapsed
}

function onNavigateWiki(wikiId: string) {
  router.push({ name: 'WikiHome', params: { wikiId } })
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
