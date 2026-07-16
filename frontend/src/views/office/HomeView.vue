<template>
  <div class="home">
    <aside class="sidebar">
      <h3>空间</h3>
      <SpaceTree />
      <button class="btn-new-space" @click="showNewSpace = true">+ 新建空间</button>
      <div v-if="showNewSpace" class="inline-form">
        <input v-model="newSpaceName" placeholder="空间名称" @keyup.enter="handleCreateSpace" />
        <button @click="handleCreateSpace">确定</button>
      </div>
    </aside>
    <section class="content">
      <DocList />
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useDocumentStore } from '@/stores/document'
import SpaceTree from './components/SpaceTree.vue'
import DocList from './components/DocList.vue'

const store = useDocumentStore()
const showNewSpace = ref(false)
const newSpaceName = ref('')

onMounted(async () => {
  await store.loadSpaces()
  if (store.currentSpaceId) {
    store.loadDocuments(store.currentSpaceId)
  }
})

async function handleCreateSpace() {
  if (!newSpaceName.value.trim()) return
  await store.createSpace(newSpaceName.value.trim())
  newSpaceName.value = ''
  showNewSpace.value = false
}
</script>

<style scoped>
.home {
  display: flex;
  height: 100%;
}
.sidebar {
  width: 240px;
  border-right: 1px solid #e0e0e0;
  padding: 16px;
  overflow-y: auto;
}
.sidebar h3 {
  margin-bottom: 12px;
  font-size: 14px;
  color: #666;
}
.btn-new-space {
  margin-top: 8px;
  padding: 6px 12px;
  background: none;
  border: 1px dashed #ccc;
  border-radius: 4px;
  color: #666;
  cursor: pointer;
  width: 100%;
}
.inline-form {
  display: flex;
  gap: 4px;
  margin-top: 8px;
}
.inline-form input {
  flex: 1;
  padding: 4px 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
}
.content {
  flex: 1;
  padding: 16px;
  overflow-y: auto;
}
</style>
