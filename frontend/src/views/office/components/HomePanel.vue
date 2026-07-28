<template>
  <div class="home-panel">
    <header class="hp-header">
      <h2>主页</h2>
      <div class="hp-header-right">
        <span class="hp-new-btn" @click="showCreate = !showCreate">+</span>
        <TopRightBar />
      </div>
    </header>

    <div v-if="showCreate" class="hp-create-form">
      <input
        v-model="newDocTitle"
        placeholder="文档标题"
        @keyup.enter="handleCreate"
      />
      <button @click="handleCreate">新建</button>
    </div>

    <nav class="hp-tabs">
      <button
        v-for="tab in tabs"
        :key="tab.key"
        class="hp-tab"
        :class="{ active: activeTab === tab.key }"
        @click="switchTab(tab.key)"
      >{{ tab.label }}</button>
    </nav>

    <div class="hp-content">
      <div v-if="loading" class="hp-loading">加载中…</div>
      <template v-else-if="items.length === 0">
        <div class="hp-empty">暂无文档</div>
      </template>
      <template v-else>
        <div class="hp-table-header">
          <span class="col-title">标题</span>
          <span class="col-location">位置</span>
          <span class="col-owner">所有者</span>
          <span class="col-created">创建时间</span>
          <span class="col-visited">最近访问</span>
          <span class="col-action">操作</span>
        </div>
        <div
          v-for="item in items"
          :key="item.id"
          class="hp-item"
          @click="openDoc(item.id)"
        >
          <span class="col-title">
            <span class="hp-item-icon">{{ item.icon || '📄' }}</span>
            <span class="hp-item-title">{{ item.title }}</span>
          </span>
          <span class="col-location">{{ item.wiki_id ? '知识库' : '个人空间' }}</span>
          <span class="col-owner">—</span>
          <span class="col-created">{{ formatDate(item.created_at) }}</span>
          <span class="col-visited">{{ (item as any).visited_at ? formatTime((item as any).visited_at) : formatTime(item.updated_at) }}</span>
          <span class="col-action">
            <span class="hp-item-more" @click="showMenu($event, item)">···</span>
          </span>
        </div>
      </template>
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
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { docsApi, type DocDto } from '@/services/office/docs'
import { useDocumentStore } from '@/stores/document'
import { useAuthStore } from '@/stores/auth'
import TopRightBar from '@/components/TopRightBar.vue'
import ContextMenu, { type ContextMenuItem } from './ContextMenu.vue'

interface TabDef { key: string; label: string }

const tabs: TabDef[] = [
  { key: 'recent', label: '最近访问' },
  { key: 'mine', label: '归我所有' },
  { key: 'shared', label: '与我共享' },
  { key: 'starred', label: '收藏' },
]

const router = useRouter()
const store = useDocumentStore()
const authStore = useAuthStore()
const activeTab = ref('recent')
const items = ref<DocDto[]>([])
const loading = ref(false)
const showCreate = ref(false)
const newDocTitle = ref('')

const menuOpen = ref(false)
const menuPos = ref<{ x: number; y: number }>({ x: 0, y: 0 })
const menuItems = ref<ContextMenuItem[]>([])
const menuDocId = ref<string | null>(null)

function showMenu(e: MouseEvent, doc: DocDto) {
  e.stopPropagation()
  menuDocId.value = doc.id
  menuPos.value = { x: e.clientX, y: e.clientY }
  const items: ContextMenuItem[] = [
    {
      key: 'open',
      label: '打开',
      icon: '📄',
      action: () => { if (menuDocId.value) openDoc(menuDocId.value) },
    },
    {
      key: 'new-tab',
      label: '在新标签页中打开',
      icon: '🔗',
      action: () => { if (menuDocId.value) window.open(`/office/docs/${menuDocId.value}`, '_blank') },
    },
    { divider: true },
    {
      key: 'copy-link',
      label: '复制链接',
      icon: '📋',
      action: () => { if (menuDocId.value) navigator.clipboard.writeText(`${window.location.origin}/office/docs/${menuDocId.value}`) },
    },
  ]
  if (activeTab.value === 'mine') {
    items.push(
      { divider: true },
      {
        key: 'delete',
        label: '删除',
        icon: '🗑',
        danger: true,
        action: async () => {
          if (!menuDocId.value) return
          await docsApi.trash(menuDocId.value)
          store.personalTreeTick++
          await loadTab(activeTab.value)
        },
      },
    )
  }
  menuItems.value = items
  menuOpen.value = true
}

onMounted(async () => {
  await loadTab('recent')
})

async function switchTab(key: string) {
  activeTab.value = key
  await loadTab(key)
}

async function loadTab(key: string) {
  loading.value = true
  try {
    switch (key) {
      case 'recent': {
        const { data } = await docsApi.recent(50)
        items.value = data.map((r: any) => ({ ...r.doc, visited_at: r.visited_at }))
        break
      }
      case 'mine': {
        const { data } = await docsApi.my()
        items.value = data
        break
      }
      case 'shared': {
        const { data } = await docsApi.shared()
        items.value = data
        break
      }
      case 'starred': {
        const { data } = await docsApi.starred()
        items.value = data
        break
      }
    }
  } finally {
    loading.value = false
  }
}

function openDoc(id: string) {
  router.push({ name: 'OfficeEditor', params: { docId: id } })
}

async function handleCreate() {
  if (!newDocTitle.value.trim()) return
  try {
    showCreate.value = false
    await docsApi.createPersonal({
      title: newDocTitle.value.trim(),
      parent_id: authStore.user?.id,
    })
    newDocTitle.value = ''
    store.personalTreeTick++
    await loadTab(activeTab.value)
  } catch {
    // ignore
  }
}

function formatTime(iso: string): string {
  if (!iso) return '—'
  const d = new Date(iso)
  const diff = Date.now() - d.getTime()
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return `${Math.floor(diff / 60000)} 分钟前`
  if (diff < 86400000) return `${Math.floor(diff / 3600000)} 小时前`
  return d.toLocaleDateString('zh-CN')
}

function formatDate(iso: string): string {
  if (!iso) return '—'
  const d = new Date(iso)
  return d.toLocaleDateString('zh-CN')
}
</script>

<style scoped>
.home-panel {
  max-width: 900px;
  margin: 0 auto;
}
.hp-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}
.hp-header-right {
  display: flex;
  align-items: center;
  gap: 8px;
}
.hp-header h2 {
  font-size: 20px;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}
.hp-new-btn {
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #1a1a2e;
  color: #fff;
  border-radius: 6px;
  cursor: pointer;
  font-size: 16px;
  font-weight: 600;
  line-height: 1;
}
.hp-new-btn:hover {
  background: #2a2a4e;
}
.hp-create-form {
  display: flex;
  gap: 8px;
  margin-bottom: 12px;
}
.hp-create-form input {
  flex: 1;
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 13px;
}
.hp-create-form button {
  padding: 8px 16px;
  background: #1565c0;
  color: #fff;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 13px;
}
.hp-tabs {
  display: flex;
  gap: 0;
  border-bottom: 1px solid #e5e7eb;
  margin-bottom: 16px;
}
.hp-tab {
  padding: 8px 16px;
  border: none;
  background: transparent;
  cursor: pointer;
  font-size: 13px;
  color: #6b7280;
  position: relative;
}
.hp-tab.active {
  color: #1565c0;
  font-weight: 500;
}
.hp-tab.active::after {
  content: '';
  position: absolute;
  bottom: -1px;
  left: 0;
  right: 0;
  height: 2px;
  background: #1565c0;
}
.hp-tab:hover {
  color: #374151;
}
.hp-loading, .hp-empty {
  color: #9ca3af;
  padding: 48px 0;
  text-align: center;
  font-size: 14px;
}
.hp-table-header {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr 1fr 1fr 40px;
  gap: 8px;
  padding: 8px 12px;
  border-bottom: 2px solid #e5e7eb;
  font-size: 12px;
  font-weight: 600;
  color: #6b7280;
}
.hp-item {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr 1fr 1fr 40px;
  gap: 8px;
  align-items: center;
  padding: 10px 12px;
  border-bottom: 1px solid #f0f0f0;
  cursor: pointer;
  border-radius: 4px;
}
.hp-item:hover {
  background: #f5f5f5;
}
.col-title {
  display: flex;
  align-items: center;
  gap: 6px;
  min-width: 0;
}
.col-location, .col-owner {
  font-size: 12px;
  color: #6b7280;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.col-created, .col-visited {
  font-size: 12px;
  color: #9ca3af;
  white-space: nowrap;
}
.hp-item-icon {
  font-size: 15px;
  flex-shrink: 0;
}
.hp-item-title {
  font-size: 14px;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.col-action {
  text-align: center;
}
.hp-item-more {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  color: #9ca3af;
  visibility: hidden;
  user-select: none;
  letter-spacing: 1px;
}
.hp-item:hover .hp-item-more {
  visibility: visible;
}
.hp-item-more:hover {
  background: #e5e7eb;
  color: #374151;
}
</style>
