<template>
  <div class="doc-list">
    <div class="doc-list-header">
      <h3>{{ currentSpaceName || '文档' }}</h3>
      <button class="btn-new" @click="showNewDoc = true">+ 新建</button>
    </div>
    <div v-if="showNewDoc" class="inline-form">
      <input v-model="newDocTitle" placeholder="文档标题" @keyup.enter="handleCreateDoc" />
      <button @click="handleCreateDoc">确定</button>
    </div>
    <div v-if="store.documents.length === 0" class="empty">暂无文档</div>
    <div
      v-for="doc in sortedDocs"
      :key="doc.id"
      class="doc-item"
      @click="openEditor(doc.id)"
      @contextmenu.prevent="openMenu($event, doc)"
    >
      <span class="doc-icon">{{ doc.icon || '📄' }}</span>
      <span class="doc-title">{{ doc.title }}</span>
      <span v-if="store.starredSet.has(doc.id)" class="star-badge">⭐</span>
      <span class="doc-time">{{ formatTime(doc.updated_at) }}</span>
      <span class="doc-more" @click.stop="openMenuFromMore($event, doc)">···</span>
    </div>

    <ContextMenu
      v-model:open="menuOpen"
      :x="menuPos.x"
      :y="menuPos.y"
      :items="menuItems"
    />
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useDocumentStore, type DocInfo } from '@/stores/document'
import ContextMenu, { type ContextMenuItem } from './ContextMenu.vue'

const store = useDocumentStore()
const router = useRouter()
const showNewDoc = ref(false)
const newDocTitle = ref('')

const menuOpen = ref(false)
const menuPos = ref<{ x: number; y: number }>({ x: 0, y: 0 })
const menuItems = ref<ContextMenuItem[]>([])

// 展示空间内所有文档，按最近更新倒序
const sortedDocs = computed(() =>
  [...store.documents].sort((a, b) => new Date(b.updated_at).getTime() - new Date(a.updated_at).getTime()),
)
const currentSpaceName = computed(
  () => store.spaces.find(s => s.id === store.currentSpaceId)?.name ?? '',
)

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

function openMenu(e: MouseEvent, doc: DocInfo) {
  menuPos.value = { x: e.clientX, y: e.clientY }
  buildMenu(doc)
  menuOpen.value = true
}

function openMenuFromMore(e: MouseEvent, doc: DocInfo) {
  const el = e.currentTarget as HTMLElement
  const rect = el.getBoundingClientRect()
  menuPos.value = { x: rect.right - 160, y: rect.bottom + 4 }
  buildMenu(doc)
  menuOpen.value = true
}

function buildMenu(doc: DocInfo) {
  const starred = store.starredSet.has(doc.id)
  menuItems.value = [
    { key: 'open', label: '打开', icon: '📖', action: () => openEditor(doc.id) },
    { key: 'star', label: starred ? '取消星标' : '添加星标', icon: '⭐', action: () => store.toggleStar(doc.id) },
    { key: 'duplicate', label: '复制文档', icon: '📄', action: () => store.duplicateDocument(doc.id, true) },
    { divider: true },
    { key: 'delete', label: '移到回收站', icon: '🗑', danger: true, action: () => store.deleteDocument(doc.id) },
  ]
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
  align-items: center;
  gap: 8px;
  padding: 10px 12px;
  border-radius: 4px;
  cursor: pointer;
  border-bottom: 1px solid #f0f0f0;
}
.doc-item:hover {
  background: #f5f5f5;
}
.doc-icon {
  font-size: 15px;
}
.doc-title {
  flex: 1;
  font-size: 14px;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.star-badge {
  font-size: 12px;
}
.doc-time {
  font-size: 12px;
  color: #999;
}
.doc-more {
  font-size: 14px;
  color: #999;
  cursor: pointer;
  padding: 0 4px;
  border-radius: 4px;
  opacity: 0;
  letter-spacing: 1px;
  user-select: none;
}
.doc-item:hover .doc-more {
  opacity: 1;
}
.doc-more:hover {
  background: #e5e7eb;
  color: #374151;
}
</style>
