<template>
  <div class="editor-layout">
    <PersonalSidebar
      @search="searchOpen = true"
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
import PersonalSidebar from './components/PersonalSidebar.vue'
import EditorContent from './components/EditorContent.vue'

const route = useRoute()
const router = useRouter()
const docId = computed(() => route.params.docId as string)
const searchOpen = ref(false)
const editorShifted = ref(false)

function onSectionChange(section: string) {
  router.push({ name: 'OfficeHome', query: { section } })
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
