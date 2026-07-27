<template>
  <div class="doc-list">
    <div class="doc-list-header">
      <h3>{{ currentWikiName || '文档' }}</h3>
      <div class="header-actions">
        <div class="new-btn-wrap" ref="newBtnRef">
          <button class="btn-new" @click="toggleNewMenu">+</button>
          <Transition name="fade">
            <div v-if="newMenuOpen" class="new-dropdown">
              <div class="new-dropdown-item" @click="handleNewDoc">新建文档</div>
            </div>
          </Transition>
        </div>
        <TopRightBar />
      </div>
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
import { useWikiStore } from '@/stores/wiki'
import ContextMenu, { type ContextMenuItem } from './ContextMenu.vue'
import TopRightBar from '@/components/TopRightBar.vue'

const store = useDocumentStore()
const wikiStore = useWikiStore()
const router = useRouter()

const showNewDoc = ref(false)
const newDocTitle = ref('')
const newMenuOpen = ref(false)
const newBtnRef = ref<HTMLElement>()

const menuOpen = ref(false)
const menuPos = ref<{ x: number; y: number }>({ x: 0, y: 0 })
const menuItems = ref<ContextMenuItem[]>([])

const sortedDocs = computed(() =>
  [...store.documents].sort((a, b) => new Date(b.updated_at).getTime() - new Date(a.updated_at).getTime()),
)
const currentWikiName = computed(
  () => wikiStore.wikis.find(w => w.id === store.currentWikiId)?.name ?? '',
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
  if (!newDocTitle.value.trim() || !store.currentWikiId) return
  await store.createDocument(newDocTitle.value.trim(), store.currentWikiId)
  newDocTitle.value = ''
  showNewDoc.value = false
}

function toggleNewMenu() {
  newMenuOpen.value = !newMenuOpen.value
}

function handleNewDoc() {
  newMenuOpen.value = false
  showNewDoc.value = true
}

function onDocClick(e: MouseEvent) {
  if (newBtnRef.value && !newBtnRef.value.contains(e.target as Node)) {
    newMenuOpen.value = false
  }
}
if (typeof window !== 'undefined') {
  window.addEventListener('click', onDocClick)
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
.header-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}
.new-btn-wrap {
  position: relative;
}
.btn-new {
  width: 32px;
  height: 32px;
  background: #1a1a2e;
  color: #fff;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 18px;
  line-height: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}
.btn-new:hover {
  background: #2a2a4e;
}
.new-dropdown {
  position: absolute;
  top: 100%;
  right: 0;
  margin-top: 4px;
  min-width: 120px;
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  box-shadow: 0 4px 16px rgba(0,0,0,0.12);
  z-index: 1000;
  padding: 4px;
}
.new-dropdown-item {
  padding: 8px 12px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 13px;
  white-space: nowrap;
  color: #333;
}
.new-dropdown-item:hover {
  background: #f0f0f0;
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
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.15s ease;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}
</style>
