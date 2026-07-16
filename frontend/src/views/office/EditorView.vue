<template>
  <div class="editor-view">
    <Toolbar :title="title" @save="handleSave" />
    <ProseEditor />
    <Collaborators />
  </div>
</template>

<script setup lang="ts">
import { ref, provide, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import api from '@/services/api'
import { useYjs } from '@/composables/useYjs'
import Toolbar from './components/Toolbar.vue'
import ProseEditor from './components/ProseEditor.vue'
import Collaborators from './components/Collaborators.vue'

const route = useRoute()
const docId = route.params.docId as string
const title = ref('')

onMounted(async () => {
  const res = await api.get(`/office/docs/${docId}`)
  title.value = res.data.title
})

const { provider, type } = useYjs(docId)
provide('yjs-type', type)
provide('yjs-provider', provider)

function handleSave() {
  // persistence is handled by Yjs periodic save on server
}
</script>

<style scoped>
.editor-view {
  display: flex;
  flex-direction: column;
  height: 100%;
}
</style>
