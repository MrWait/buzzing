<template>
  <div class="editor-layout">
    <SpaceSidebar
      @search="searchOpen = true"
      @switch-view="navigateToView"
      @collapse-change="(c) => editorShifted = c"
    />
    <div class="editor-view" :class="{ 'sidebar-collapsed': editorShifted }">
      <EditorContent :key="docId" :doc-id="docId" v-model:search-open="searchOpen" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import SpaceSidebar from './components/SpaceSidebar.vue'
import EditorContent from './components/EditorContent.vue'

const route = useRoute()
const router = useRouter()
const docId = computed(() => route.params.docId as string)
const searchOpen = ref(false)
const editorShifted = ref(false)

function navigateToView(view: string) {
  if (view === 'trash') {
    router.push({ name: 'OfficeTrash' })
  } else {
    router.push({ name: 'OfficeHome' })
  }
}
</script>

<style scoped>
.editor-layout {
  display: flex;
  height: 100%;
  overflow: hidden;
}
.editor-view {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  overflow-y: auto;
}
.editor-view.sidebar-collapsed {
  padding-left: 60px;
}
</style>
