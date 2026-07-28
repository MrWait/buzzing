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
      <span v-show="!sidebarCollapsed || sidebarFloating" class="sidebar-title">我的文档</span>
    </div>

    <div v-show="!sidebarCollapsed || sidebarFloating" class="sidebar-body">
      <!-- 搜索框 -->
      <button class="search-btn" @click="$emit('search')">
        <span>🔍</span><span>搜索文档</span>
        <span class="kbd">{{ shortcutHint }}</span>
      </button>

      <!-- 导航按钮 -->
      <button class="nav-btn" :class="{ active: activeSection === 'home' }" @click="switchSection('home')">
        <span>🏠</span><span>主页</span>
      </button>
      <button class="nav-btn" :class="{ active: activeSection === 'wikis' }" @click="switchSection('wikis')">
        <span>📚</span><span>知识库</span>
      </button>
      <button class="nav-btn" :class="{ active: activeSection === 'starred' }" @click="switchSection('starred')">
        <span>⭐</span><span>收藏</span>
      </button>

      <!-- 回收站 -->
      <button class="nav-btn trash-btn" @click="goTrash">
        <span>🗑</span><span>回收站</span>
      </button>

      <!-- 我的文档库目录树 -->
      <div class="section">
        <div class="section-title-row">
          <span class="section-title">我的文档库</span>
          <button class="section-add-btn" @click="showNewDoc = !showNewDoc">+</button>
        </div>
        <div v-if="showNewDoc" class="inline-form">
          <input v-model="newDocTitle" placeholder="文档标题" @keyup.enter="handleCreateDoc" />
          <button @click="handleCreateDoc">确定</button>
        </div>
        <div v-if="treeLoading" class="tree-loading">加载中…</div>
        <div v-else-if="tree.length === 0" class="tree-empty">暂无文档</div>
        <div v-if="showChildForm" class="inline-form">
          <input v-model="childDocTitle" placeholder="子文档标题" @keyup.enter="handleCreateChildDoc" />
          <button @click="handleCreateChildDoc">确定</button>
        </div>
        <DocTreeNode
          v-for="node in tree"
          :key="node.id"
          :node="node"
          :level="0"
          :expanded="store.personalExpandedMap"
          @add-child="onAddChild"
          @open-menu="onOpenMenu"
        />
      </div>
    </div>

    <ContextMenu
      v-model:open="menuOpen"
      :x="menuPos.x"
      :y="menuPos.y"
      :items="menuItems"
    />
  </aside>
</template>

<script setup lang="ts">
import { onMounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { docsApi, type DocTreeNode as DocTreeNodeDto } from '@/services/office/docs'
import { useDocumentStore } from '@/stores/document'
import { useAuthStore } from '@/stores/auth'
import DocTreeNode from './DocTreeNode.vue'
import ContextMenu, { type ContextMenuItem } from './ContextMenu.vue'

const emit = defineEmits<{
  (e: 'search'): void
  (e: 'collapse-change', collapsed: boolean): void
  (e: 'section-change', section: string): void
}>()

const store = useDocumentStore()
const authStore = useAuthStore()
const router = useRouter()

const activeSection = ref('home')
const tree = ref<DocTreeNodeDto[]>([])
const treeLoading = ref(false)
const showNewDoc = ref(false)
const newDocTitle = ref('')
const showChildForm = ref(false)
const childDocTitle = ref('')
const childParentId = ref('')

const menuOpen = ref(false)
const menuPos = ref<{ x: number; y: number }>({ x: 0, y: 0 })
const menuItems = ref<ContextMenuItem[]>([])
const menuTargetNode = ref<DocTreeNodeDto | null>(null)

const sidebarCollapsed = ref(false)
const sidebarFloating = ref(false)
let floatTimer: ReturnType<typeof setTimeout> | null = null

const shortcutHint = /Mac|iPhone|iPad/i.test(navigator.userAgent) ? '⌘K' : 'Ctrl+K'

onMounted(async () => {
  await loadPersonalTree()
})

watch(() => store.personalTreeTick, () => {
  loadPersonalTree()
})

async function loadPersonalTree() {
  treeLoading.value = true
  try {
    const { data } = await docsApi.personalTree()
    tree.value = data
  } finally {
    treeLoading.value = false
  }
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

function onAddChild(payload: { parentId: string }) {
  childParentId.value = payload.parentId
  childDocTitle.value = ''
  showChildForm.value = true
}

async function handleCreateChildDoc() {
  if (!childDocTitle.value.trim()) return
  try {
    await docsApi.createPersonal({
      title: childDocTitle.value.trim(),
      parent_id: childParentId.value,
    })
    childDocTitle.value = ''
    showChildForm.value = false
    await loadPersonalTree()
  } catch {
    // ignore
  }
}

async function handleCreateDoc() {
  if (!newDocTitle.value.trim()) return
  try {
    await docsApi.createPersonal({
      title: newDocTitle.value.trim(),
      parent_id: authStore.user?.id,
    })
    newDocTitle.value = ''
    showNewDoc.value = false
    await loadPersonalTree()
  } catch {
    // ignore
  }
}

function onOpenMenu(payload: { event: MouseEvent; node: DocTreeNodeDto }) {
  menuTargetNode.value = payload.node
  menuPos.value = { x: payload.event.clientX, y: payload.event.clientY }
  const node = payload.node
  const starred = store.starredSet.has(node.id)
  menuItems.value = [
    { key: 'open', label: '打开', icon: '📖', action: () => router.push({ name: 'OfficeEditor', params: { docId: node.id } }) },
    { key: 'newchild', label: '新建子页面', icon: '➕', action: () => onAddChild({ parentId: node.id }) },
    { key: 'star', label: starred ? '取消星标' : '添加星标', icon: '⭐', action: () => store.toggleStar(node.id) },
    { divider: true },
    { key: 'delete', label: '移到回收站', icon: '🗑', danger: true, action: () => handleDeleteDoc(node.id) },
  ]
  menuOpen.value = true
}

async function handleDeleteDoc(id: string) {
  await store.deleteDocument(id)
  await loadPersonalTree()
}

function switchSection(section: string) {
  activeSection.value = section
  if (section === 'home') {
    emit('section-change', 'home')
  } else if (section === 'wikis') {
    // scroll to wiki grid section in home
    emit('section-change', 'wikis')
  } else if (section === 'starred') {
    emit('section-change', 'starred')
  }
}

function goTrash() {
  activeSection.value = 'trash'
  emit('section-change', 'trash')
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
  width: 240px;
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
  min-width: 0;
  flex: 0 0 0;
  overflow: visible;
  border-right: none;
  height: auto;
  align-self: flex-start;
}
.sidebar.floating {
  position: absolute;
  left: 0;
  top: 0;
  height: 100%;
  width: 240px;
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
  margin-bottom: 8px;
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
.search-btn .kbd {
  margin-left: auto;
  font-size: 11px;
  padding: 1px 6px;
  background: #f3f4f6;
  border-radius: 4px;
  color: #9ca3af;
}
.nav-btn {
  width: 100%;
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 10px;
  margin-bottom: 4px;
  border: none;
  background: transparent;
  border-radius: 6px;
  cursor: pointer;
  font-size: 13px;
  color: #374151;
  text-align: left;
}
.nav-btn:hover {
  background: #f3f4f6;
}
.section {
  margin-top: 12px;
  border-top: 1px solid #eee;
  padding-top: 8px;
}
.section-title-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 4px 4px 6px;
}
.section-title {
  font-size: 11px;
  color: #9ca3af;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
.section-add-btn {
  width: 18px;
  height: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: none;
  border: none;
  border-radius: 3px;
  cursor: pointer;
  color: #9ca3af;
  font-size: 14px;
  line-height: 1;
  padding: 0;
}
.section-add-btn:hover {
  background: #e5e7eb;
  color: #374151;
}
.section-empty {
  color: #9ca3af;
  font-size: 12px;
  padding: 6px 4px;
}
.inline-form {
  display: flex;
  gap: 4px;
  margin-bottom: 8px;
  padding: 0 4px;
}
.inline-form input {
  flex: 1;
  padding: 4px 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 12px;
}
.inline-form button {
  padding: 4px 10px;
  background: #1565c0;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 12px;
}
.inline-form button:hover {
  background: #0d47a1;
}
.tree-loading, .tree-empty {
  padding: 8px 4px;
  color: #9ca3af;
  font-size: 12px;
}
.trash-btn {
  margin-top: 4px;
  margin-bottom: 0;
}
</style>
