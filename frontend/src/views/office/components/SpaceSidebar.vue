<template>
  <aside
    class="sidebar"
    :class="{ collapsed: sidebarCollapsed && !sidebarFloating, floating: sidebarFloating }"
    @mouseenter="onSidebarEnter"
    @mouseleave="onSidebarLeave"
  >
    <div class="sidebar-header">
      <button class="toggle-btn" @click="toggleSidebar">
        <span class="toggle-icon">{{ sidebarCollapsed ? '▶' : '◀' }}</span>
      </button>
      <span v-show="!sidebarCollapsed || sidebarFloating" class="sidebar-title">在线文档</span>
    </div>

    <div v-show="!sidebarCollapsed || sidebarFloating" class="sidebar-body">
      <button class="search-btn" @click="$emit('search')">
        <span class="search-icon">🔍</span>
        <span>搜索文档</span>
        <span class="kbd">{{ shortcutHint }}</span>
      </button>
      <div class="quick-group">
        <div class="section-title">快速访问</div>
        <button class="nav-item" :class="{ active: activeView === 'starred' }" @click="switchView('starred')">
          <span>⭐</span><span>星标</span>
        </button>
        <button class="nav-item" :class="{ active: activeView === 'recent' }" @click="switchView('recent')">
          <span>🕐</span><span>最近</span>
        </button>
        <button class="nav-item" :class="{ active: activeView === 'trash' }" @click="switchView('trash')">
          <span>🗑</span><span>回收站</span>
        </button>
      </div>

      <div class="section-title with-action">
        <span>空间</span>
        <button class="tiny" @click="showNewSpace = true">+</button>
      </div>
      <SpaceTree />
      <div v-if="showNewSpace" class="inline-form">
        <input v-model="newSpaceName" placeholder="空间名称" @keyup.enter="handleCreateSpace" />
        <button @click="handleCreateSpace">确定</button>
      </div>
    </div>
  </aside>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useDocumentStore } from '@/stores/document'
import SpaceTree from './SpaceTree.vue'

defineProps<{
  activeView?: string
}>()

const emit = defineEmits<{
  (e: 'switch-view', view: 'space' | 'starred' | 'recent' | 'trash'): void
  (e: 'search'): void
  (e: 'collapse-change', collapsed: boolean): void
}>()

const store = useDocumentStore()
const showNewSpace = ref(false)
const newSpaceName = ref('')

const sidebarCollapsed = ref(false)
const sidebarFloating = ref(false)
let floatTimer: ReturnType<typeof setTimeout> | null = null

const shortcutHint = /Mac|iPhone|iPad/i.test(navigator.userAgent) ? '⌘K' : 'Ctrl+K'

function switchView(v: 'space' | 'starred' | 'recent' | 'trash') {
  emit('switch-view', v)
}

async function handleCreateSpace() {
  if (!newSpaceName.value.trim()) return
  await store.createSpace(newSpaceName.value.trim())
  newSpaceName.value = ''
  showNewSpace.value = false
}

function toggleSidebar() {
  sidebarCollapsed.value = !sidebarCollapsed.value
  if (!sidebarCollapsed.value) {
    sidebarFloating.value = false
  }
  emit('collapse-change', sidebarCollapsed.value)
}

function onSidebarEnter() {
  clearFloatTimer()
  if (sidebarCollapsed.value && !sidebarFloating.value) {
    sidebarFloating.value = true
  }
}

function onSidebarLeave() {
  if (sidebarFloating.value) {
    floatTimer = setTimeout(() => {
      sidebarFloating.value = false
    }, 200)
  }
}

function clearFloatTimer() {
  if (floatTimer) {
    clearTimeout(floatTimer)
    floatTimer = null
  }
}
</script>

<style scoped>
.sidebar {
  width: 260px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  background: #fafafa;
  border-right: 1px solid #e5e7eb;
  transition: width 0.2s;
  overflow: hidden;
  z-index: 50;
}
.sidebar.collapsed {
  width: 0;
  overflow: visible;
  border-right: none;
}
.sidebar.floating {
  position: absolute;
  left: 0;
  top: 0;
  height: 100%;
  width: 260px;
  box-shadow: 4px 0 16px rgba(0, 0, 0, 0.12);
  border-right: 1px solid #e5e7eb;
  overflow: visible;
  z-index: 100;
}

.sidebar-header {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px;
  flex-shrink: 0;
}
.sidebar.collapsed .sidebar-header {
  position: absolute;
  left: 0;
  top: 0;
  background: transparent;
}

.toggle-btn {
  flex-shrink: 0;
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: none;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  color: #6b7280;
  font-size: 12px;
}
.toggle-btn:hover {
  background: #e5e7eb;
}

.sidebar-body {
  flex: 1;
  overflow-y: auto;
  padding: 0 12px 12px;
}

.sidebar-title {
  font-size: 14px;
  font-weight: 600;
  color: #333;
}
.search-btn {
  width: 100%;
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 10px;
  margin-bottom: 12px;
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  color: #6b7280;
  cursor: pointer;
  font-size: 13px;
}
.search-btn:hover {
  background: #f3f4f6;
}
.search-btn .search-icon {
  font-size: 12px;
}
.search-btn .kbd {
  margin-left: auto;
  font-size: 11px;
  padding: 1px 6px;
  background: #f3f4f6;
  border-radius: 4px;
  color: #9ca3af;
}

.quick-group {
  margin-bottom: 12px;
}
.section-title {
  font-size: 11px;
  color: #9ca3af;
  padding: 8px 4px 4px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
.section-title.with-action {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.tiny {
  background: none;
  border: none;
  color: #6b7280;
  cursor: pointer;
  font-size: 14px;
  padding: 0 4px;
  border-radius: 4px;
}
.tiny:hover {
  background: #e5e7eb;
}
.nav-item {
  width: 100%;
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 10px;
  border: none;
  background: transparent;
  border-radius: 4px;
  cursor: pointer;
  font-size: 13px;
  color: #374151;
  text-align: left;
}
.nav-item:hover {
  background: #f3f4f6;
}
.nav-item.active {
  background: #e3f2fd;
  color: #1565c0;
  font-weight: 500;
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
</style>
