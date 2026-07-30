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
      <button class="home-btn" title="个人空间主页" @click="goHome">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
          <polyline points="9 22 9 12 15 12 15 22"/>
        </svg>
      </button>
      <span v-show="!sidebarCollapsed || sidebarFloating" class="sidebar-title">知识库</span>
    </div>

    <div v-show="!sidebarCollapsed || sidebarFloating" class="sidebar-body">

      <!-- 当前 wiki 信息 -->
      <div v-if="wiki" class="wiki-header">
        <span class="wiki-icon">{{ wiki.icon || '📚' }}</span>
        <span class="wiki-name">{{ wiki.name || '知识库' }}</span>
        <button v-if="isAdmin" class="wiki-settings-btn" title="知识库设置" @click="showSettings = true">⚙</button>
      </div>

      <!-- 置顶文档 -->
      <div class="section">
        <div class="section-title">置顶</div>
        <div v-if="pinnedDocs.length === 0" class="section-empty">暂无置顶</div>
        <div
          v-for="doc in pinnedDocs"
          :key="doc.id"
          class="pinned-item"
          @click="openDoc(doc.id)"
        >
          <span class="pi-icon">{{ doc.icon || '📄' }}</span>
          <span class="pi-name">{{ doc.title }}</span>
        </div>
      </div>

      <!-- 文档目录树 -->
      <div class="section">
        <div class="section-title-row">
          <span class="section-title">页面</span>
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
          v-for="node in displayTree"
          :key="node.id"
          :node="node"
          :level="0"
          :wiki-id="wikiId"
          :expanded="expandedMap"
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

    <WikiSettingsDialog
      :open="showSettings"
      :wiki="wiki ?? null"
      @close="showSettings = false"
      @saved="onSettingsSaved"
    />
  </aside>
</template>

<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useWikiStore } from '@/stores/wiki'
import { useDocumentStore } from '@/stores/document'
import { docsApi, type DocTreeNode as DocTreeNodeDto } from '@/services/office/docs'
import { wikisApi } from '@/services/office/wikis'
import DocTreeNode from './DocTreeNode.vue'
import ContextMenu, { type ContextMenuItem } from './ContextMenu.vue'
import WikiSettingsDialog from './WikiSettingsDialog.vue'

const props = defineProps<{
  wikiId: string
}>()

const router = useRouter()
const wikiStore = useWikiStore()
const store = useDocumentStore()
const authStore = useAuthStore()

const tree = ref<DocTreeNodeDto[]>([])
const treeLoading = ref(false)
const expandedMap = reactive(new Map<string, boolean>())
const showNewDoc = ref(false)
const newDocTitle = ref('')
const showChildForm = ref(false)
const childDocTitle = ref('')
const childParentId = ref('')
const pinnedDocs = ref<DocTreeNodeDto[]>([])

const showSettings = ref(false)

const menuOpen = ref(false)
const menuPos = ref<{ x: number; y: number }>({ x: 0, y: 0 })
const menuItems = ref<ContextMenuItem[]>([])
const menuTargetNode = ref<DocTreeNodeDto | null>(null)

const sidebarCollapsed = ref(false)
const sidebarFloating = ref(false)
let floatTimer: ReturnType<typeof setTimeout> | null = null

const wiki = computed(() => wikiStore.wikis.find(w => w.id === props.wikiId))
const currentUserId = computed(() => authStore.user?.id ?? '')
const userWikiRole = ref(0)
// Admin=3, Owner=4
const isAdmin = computed(() => userWikiRole.value >= 3)

const displayTree = computed(() => {
  if (!wiki.value?.home_doc_id) return tree.value
  return tree.value.flatMap(node =>
    node.id === wiki.value!.home_doc_id ? node.children : [node],
  )
})

async function loadUserRole(wikiId: string) {
  if (!wiki.value) return
  if (wiki.value.creator_id === currentUserId.value) {
    userWikiRole.value = 4 // Owner
    return
  }
  try {
    const { data } = await wikisApi.listMembers(wikiId)
    const me = data.find(m => m.user_id === currentUserId.value)
    userWikiRole.value = me?.role ?? 0
  } catch {
    userWikiRole.value = 0
  }
}

onMounted(async () => {
  await wikiStore.loadWikis()
  wikiStore.setCurrentWiki(props.wikiId)
  await loadTree(props.wikiId)
  await loadPins(props.wikiId)
  await loadUserRole(props.wikiId)
})

watch(() => props.wikiId, async (id) => {
  wikiStore.setCurrentWiki(id)
  await loadTree(id)
  await loadPins(id)
  await loadUserRole(id)
})

watch(() => props.wikiId, async (id) => {
  wikiStore.setCurrentWiki(id)
  await loadTree(id)
  await loadPins(id)
})

async function loadTree(wikiId: string) {
  treeLoading.value = true
  try {
    await store.loadTree(wikiId)
    tree.value = store.currentTree
  } finally {
    treeLoading.value = false
  }
}

async function loadPins(wikiId: string) {
  try {
    const { data } = await wikisApi.listPins(wikiId)
    pinnedDocs.value = data
  } catch {
    pinnedDocs.value = []
  }
}

function onSettingsSaved() {
  showSettings.value = false
}

function goHome() {
  router.push({ name: 'OfficeHome' })
}

function openDoc(id: string) {
  router.push({ name: 'WikiEditor', params: { wikiId: props.wikiId, docId: id } })
}

function toggleSidebar() {
  sidebarCollapsed.value = !sidebarCollapsed.value
  if (!sidebarCollapsed.value) {
    sidebarFloating.value = false
  }
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
    await docsApi.create({
      wiki_id: props.wikiId,
      title: childDocTitle.value.trim(),
      parent_id: childParentId.value,
    })
    childDocTitle.value = ''
    showChildForm.value = false
    await loadTree(props.wikiId)
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
    { key: 'open', label: '打开', icon: '📖', action: () => openDoc(node.id) },
    { key: 'newchild', label: '新建子页面', icon: '➕', action: () => onAddChild({ parentId: node.id }) },
    { key: 'star', label: starred ? '取消星标' : '添加星标', icon: '⭐', action: () => store.toggleStar(node.id) },
    { divider: true },
    { key: 'delete', label: '移到回收站', icon: '🗑', danger: true, action: () => handleDeleteDoc(node.id) },
  ]
  menuOpen.value = true
}

async function handleDeleteDoc(id: string) {
  await store.deleteDocument(id)
  await loadTree(props.wikiId)
}

async function handleCreateDoc() {
  if (!newDocTitle.value.trim()) return
  await store.createDocument(newDocTitle.value.trim(), props.wikiId)
  newDocTitle.value = ''
  showNewDoc.value = false
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
  overflow: visible;
  border-right: none;
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
.home-btn {
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
}
.home-btn:hover {
  background: #e5e7eb;
  color: #1565c0;
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
.wiki-header {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 10px;
  margin-bottom: 8px;
  border-bottom: 1px solid #eee;
}
.wiki-icon {
  font-size: 18px;
}
.wiki-name {
  flex: 1;
  font-size: 14px;
  font-weight: 600;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.wiki-settings-btn {
  flex-shrink: 0;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: none;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  color: #9ca3af;
  font-size: 14px;
  opacity: 0.6;
}
.wiki-settings-btn:hover {
  opacity: 1;
  background: #e5e7eb;
  color: #374151;
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
.pinned-item {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 5px 8px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 13px;
  color: #374151;
}
.pinned-item:hover {
  background: #f3f4f6;
}
.pi-icon {
  font-size: 14px;
  flex-shrink: 0;
}
.pi-name {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
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
</style>
