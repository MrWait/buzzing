<template>
  <div class="editor-layout">
    <WikiSidebar :wiki-id="wikiId" />
    <div class="editor-view">
      <EditorContent :key="docId" :doc-id="docId" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import WikiSidebar from './components/WikiSidebar.vue'
import EditorContent from './components/EditorContent.vue'

const route = useRoute()
const wikiId = computed(() => route.params.wikiId as string)
const docId = computed(() => route.params.docId as string)
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
</style>
