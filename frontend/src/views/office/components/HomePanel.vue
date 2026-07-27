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
      <div v-else-if="items.length === 0" class="hp-empty">暂无文档</div>
      <div
        v-for="item in items"
        :key="item.id"
        class="hp-item"
        @click="openDoc(item.id)"
      >
        <span class="hp-item-icon">{{ item.icon || '📄' }}</span>
        <span class="hp-item-title">{{ item.title }}</span>
        <span class="hp-item-time">{{ formatTime(item.updated_at) }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { docsApi, type DocDto } from '@/services/office/docs'
import { useDocumentStore } from '@/stores/document'
import TopRightBar from '@/components/TopRightBar.vue'

interface TabDef { key: string; label: string }

const tabs: TabDef[] = [
  { key: 'recent', label: '最近访问' },
  { key: 'mine', label: '归我所有' },
  { key: 'shared', label: '与我共享' },
  { key: 'starred', label: '收藏' },
]

const router = useRouter()
const store = useDocumentStore()
const activeTab = ref('recent')
const items = ref<DocDto[]>([])
const loading = ref(false)
const showCreate = ref(false)
const newDocTitle = ref('')


onMounted(async () => {
  await store.ensureRootNodeId()
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
        items.value = data.map((r: any) => r.doc).filter((d: any) => d.id !== store.rootNodeId)
        break
      }
      case 'mine': {
        const { data } = await docsApi.my()
        items.value = data.filter(d => d.id !== store.rootNodeId)
        break
      }
      case 'shared': {
        const { data } = await docsApi.shared()
        items.value = data
        break
      }
      case 'starred': {
        const { data } = await docsApi.starred()
        items.value = data.filter(d => d.id !== store.rootNodeId)
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
      parent_id: store.rootNodeId ?? undefined,
    })
    newDocTitle.value = ''
    await loadTab(activeTab.value)
  } catch {
    // ignore
  }
}

function formatTime(iso: string): string {
  const d = new Date(iso)
  const diff = Date.now() - d.getTime()
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return `${Math.floor(diff / 60000)} 分钟前`
  if (diff < 86400000) return `${Math.floor(diff / 3600000)} 小时前`
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
.hp-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 12px;
  border-bottom: 1px solid #f0f0f0;
  cursor: pointer;
  border-radius: 4px;
}
.hp-item:hover {
  background: #f5f5f5;
}
.hp-item-icon {
  font-size: 15px;
}
.hp-item-title {
  flex: 1;
  font-size: 14px;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.hp-item-time {
  font-size: 12px;
  color: #9ca3af;
  white-space: nowrap;
}
</style>
