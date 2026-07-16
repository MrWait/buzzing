<template>
  <div class="doc-list">
    <div class="doc-list-header">
      <h3>文档</h3>
      <button class="btn-new" @click="showNewDoc = true">+ 新建</button>
    </div>
    <div v-if="showNewDoc" class="inline-form">
      <input v-model="newDocTitle" placeholder="文档标题" @keyup.enter="handleCreateDoc" />
      <button @click="handleCreateDoc">确定</button>
    </div>
    <div v-if="store.documents.length === 0" class="empty">暂无文档</div>
    <div
      v-for="doc in store.documents"
      :key="doc.id"
      class="doc-item"
      @click="openEditor(doc.id)"
    >
      <span class="doc-title">{{ doc.title }}</span>
      <span class="doc-time">{{ formatTime(doc.updated_at) }}</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useDocumentStore } from '@/stores/document'

const store = useDocumentStore()
const router = useRouter()
const showNewDoc = ref(false)
const newDocTitle = ref('')

function formatTime(iso: string): string {
  const d = new Date(iso)
  const now = new Date()
  const diff = now.getTime() - d.getTime()
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return `${Math.floor(diff / 60000)} 分钟前`
  if (diff < 86400000) return `${Math.floor(diff / 3600000)} 小时前`
  return d.toLocaleDateString('zh-CN')
}

function openEditor(docId: string) {
  router.push({ name: 'OfficeEditor', params: { docId: String(docId) } })
}

async function handleCreateDoc() {
  if (!newDocTitle.value.trim() || !store.currentSpaceId) return
  await store.createDocument(newDocTitle.value.trim(), store.currentSpaceId)
  newDocTitle.value = ''
  showNewDoc.value = false
}
</script>

<style scoped>
.doc-list-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}
.doc-list-header h3 {
  font-size: 16px;
  font-weight: 600;
}
.btn-new {
  padding: 4px 12px;
  background: #1a1a2e;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 13px;
}
.inline-form {
  display: flex;
  gap: 4px;
  margin-bottom: 12px;
}
.inline-form input {
  flex: 1;
  padding: 4px 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
}
.empty {
  color: #999;
  font-size: 14px;
  padding: 32px 0;
  text-align: center;
}
.doc-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 12px;
  border-radius: 4px;
  cursor: pointer;
  border-bottom: 1px solid #f0f0f0;
}
.doc-item:hover {
  background: #f5f5f5;
}
.doc-title {
  font-size: 14px;
  color: #333;
}
.doc-time {
  font-size: 12px;
  color: #999;
}
</style>
