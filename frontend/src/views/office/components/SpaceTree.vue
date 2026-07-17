<template>
  <div class="space-tree">
    <ul class="space-list">
      <li
        v-for="space in store.spaces"
        :key="space.id"
        class="space"
        :class="{ active: space.id === store.currentSpaceId }"
        draggable="true"
        @dragstart="onSpaceDragStart($event, space.id)"
        @dragover.prevent
        @drop.prevent="onSpaceDrop($event, space.id)"
        @contextmenu.prevent="openSpaceMenu($event, space)"
      >
        <div class="space-header" @click="selectSpace(space.id)">
          <span class="chevron" :class="{ open: expanded[space.id] }" @click.stop="toggleExpand(space.id)">▶</span>
          <span class="space-icon" :style="{ color: space.color ?? '#4b5563' }">
            {{ space.icon || '📁' }}
          </span>
          <span class="space-name">{{ space.name }}</span>
        </div>
        <div v-if="expanded[space.id]" class="tree">
          <DocTreeNode
            v-for="node in treeCache[space.id] ?? []"
            :key="node.id"
            :node="node"
            :space-id="space.id"
            :level="0"
            @open-menu="openDocMenu"
            @open-menu-more="openDocMenuMore"
            @add-child="handleAddChild"
            @drop-onto="handleDocDrop"
          />
        </div>
      </li>
    </ul>

    <ContextMenu
      v-model:open="menuOpen"
      :x="menuPos.x"
      :y="menuPos.y"
      :items="menuItems"
    />
    <IconPicker
      v-model:open="iconPickerOpen"
      @pick="onPickIcon"
    />
  </div>
</template>

<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'
import { useDocumentStore, type SpaceInfo } from '@/stores/document'
import ContextMenu, { type ContextMenuItem } from './ContextMenu.vue'
import IconPicker from './IconPicker.vue'
import DocTreeNode from './DocTreeNode.vue'
import type { DocTreeNode as DocTreeNodeDto } from '@/services/office/docs'

const store = useDocumentStore()
const expanded = reactive<Record<string, boolean>>({})
const treeCache = reactive<Record<string, DocTreeNodeDto[]>>({})

// 右键菜单
const menuOpen = ref(false)
const menuPos = ref<{ x: number; y: number }>({ x: 0, y: 0 })
const menuItems = ref<ContextMenuItem[]>([])

// 图标选择器
const iconPickerOpen = ref(false)
const iconTargetSpace = ref<string | null>(null)
const iconTargetDoc = ref<string | null>(null)

// 拖拽 payload：区分 space / doc
type DragPayload =
  | { type: 'space'; id: string }
  | { type: 'doc'; id: string; spaceId: string }
const dragging = ref<DragPayload | null>(null)

async function selectSpace(id: string) {
  await store.loadDocuments(id)
  if (!expanded[id]) {
    expanded[id] = true
    await loadTreeIfNeeded(id)
  }
}

async function toggleExpand(id: string) {
  expanded[id] = !expanded[id]
  if (expanded[id]) {
    await loadTreeIfNeeded(id)
  }
}

async function loadTreeIfNeeded(spaceId: string) {
  if (treeCache[spaceId]) return
  await store.loadTree(spaceId)
  treeCache[spaceId] = store.currentTree
}

// 每当 store.currentSpaceId + store.currentTree 变化，同步该空间缓存
watch(
  () => store.currentTree,
  (tree) => {
    if (store.currentSpaceId) {
      treeCache[store.currentSpaceId] = tree
    }
  },
)

// ---- 拖拽 ----
function onSpaceDragStart(e: DragEvent, id: string) {
  dragging.value = { type: 'space', id }
  e.dataTransfer?.setData('text/plain', `space:${id}`)
}

async function onSpaceDrop(e: DragEvent, targetSpaceId: string) {
  const data = dragging.value ?? decodeDrop(e)
  dragging.value = null
  if (!data) return
  if (data.type === 'space' && data.id !== targetSpaceId) {
    // 空间之间拖拽：交换 sort_order (简易方案：目标位置 sort_order 从当前空间列表推算)
    await swapSpaceOrder(data.id, targetSpaceId)
  } else if (data.type === 'doc') {
    // 文档拖到空间：移动到该空间根级
    await store.moveDocument(data.id, { spaceId: targetSpaceId, parentId: null })
    delete treeCache[data.spaceId]
    await loadTreeIfNeeded(targetSpaceId)
  }
}

function decodeDrop(e: DragEvent): DragPayload | null {
  const raw = e.dataTransfer?.getData('text/plain') ?? ''
  if (raw.startsWith('space:')) return { type: 'space', id: raw.slice(6) }
  if (raw.startsWith('doc:')) {
    const [id, spaceId] = raw.slice(4).split('@')
    return { type: 'doc', id, spaceId }
  }
  return null
}

async function swapSpaceOrder(dragId: string, dropId: string) {
  const list = store.spaces
  const dragIdx = list.findIndex(s => s.id === dragId)
  const dropIdx = list.findIndex(s => s.id === dropId)
  if (dragIdx < 0 || dropIdx < 0) return
  // 拖动项插入到目标位置
  const reordered = [...list]
  const [item] = reordered.splice(dragIdx, 1)
  reordered.splice(dropIdx, 0, item)
  // 批量更新 sort_order
  await Promise.all(
    reordered.map((s, idx) =>
      s.sort_order === idx ? Promise.resolve() : store.updateSpace(s.id, { sort_order: idx }),
    ),
  )
}

async function handleDocDrop(payload: { docId: string; fromSpaceId: string; targetSpaceId: string; targetParent: string | null }) {
  await store.moveDocument(payload.docId, {
    spaceId: payload.targetSpaceId,
    parentId: payload.targetParent,
  })
  delete treeCache[payload.fromSpaceId]
  delete treeCache[payload.targetSpaceId]
  await loadTreeIfNeeded(payload.targetSpaceId)
}

// ---- 右键菜单 ----
function openSpaceMenu(e: MouseEvent, space: SpaceInfo) {
  menuPos.value = { x: e.clientX, y: e.clientY }
  const isDefault = space.sp_type === 0
  menuItems.value = [
    { key: 'rename', label: '重命名', icon: '✏️', action: () => renameSpace(space) },
    { key: 'icon', label: '设置图标', icon: '🎨', action: () => {
      iconTargetSpace.value = space.id
      iconPickerOpen.value = true
    } },
    { key: 'newdoc', label: '新建文档', icon: '➕', action: () => quickCreateDoc(space.id) },
  ]
  if (!isDefault) {
    menuItems.value.push(
      { divider: true },
      { key: 'archive', label: space.archived_at ? '取消归档' : '归档', icon: '📦', action: () => store.archiveSpace(space.id, !space.archived_at) },
      { key: 'delete', label: '删除空间', icon: '🗑', danger: true, action: () => deleteSpace(space) },
    )
  }
  menuOpen.value = true
}

function handleAddChild(payload: { node: DocTreeNodeDto; spaceId: string }) {
  createChildDoc(payload.spaceId, payload.node.id)
}

function openDocMenuMore(payload: { el: HTMLElement; node: DocTreeNodeDto; spaceId: string }) {
  const rect = payload.el.getBoundingClientRect()
  menuPos.value = { x: rect.right - 160, y: rect.bottom + 4 }
  menuItems.value = buildDocMenuItems(payload.node, payload.spaceId)
  menuOpen.value = true
}

function buildDocMenuItems(node: DocTreeNodeDto, spaceId: string): ContextMenuItem[] {
  return [
    { key: 'newchild', label: '新建子页面', icon: '➕', action: () => createChildDoc(spaceId, node.id) },
    { key: 'icon', label: '设置图标', icon: '🎨', action: () => {
      iconTargetDoc.value = node.id
      iconPickerOpen.value = true
    } },
    { key: 'star', label: store.starredSet.has(node.id) ? '取消星标' : '添加星标', icon: '⭐', action: () => store.toggleStar(node.id) },
    { key: 'duplicate', label: '复制', icon: '📄', action: () => store.duplicateDocument(node.id, true) },
    { divider: true },
    { key: 'delete', label: '移到回收站', icon: '🗑', danger: true, action: () => store.deleteDocument(node.id) },
  ]
}

function openDocMenu(payload: { event: MouseEvent; node: DocTreeNodeDto; spaceId: string }) {
  menuPos.value = { x: payload.event.clientX, y: payload.event.clientY }
  menuItems.value = buildDocMenuItems(payload.node, payload.spaceId)
  menuOpen.value = true
}

async function renameSpace(space: SpaceInfo) {
  const name = window.prompt('空间名称', space.name)
  if (name && name.trim() && name !== space.name) {
    await store.updateSpace(space.id, { name: name.trim() })
  }
}

async function quickCreateDoc(spaceId: string) {
  const title = window.prompt('文档标题', '未命名')
  if (title && title.trim()) {
    await store.createDocument(title.trim(), spaceId)
  }
}

async function createChildDoc(spaceId: string, parentId: string) {
  const title = window.prompt('子页面标题', '未命名')
  if (title && title.trim()) {
    await store.createDocument(title.trim(), spaceId, parentId)
  }
}

async function deleteSpace(space: SpaceInfo) {
  if (!window.confirm(`删除空间"${space.name}"？文档不会随空间删除。`)) return
  await store.deleteSpace(space.id)
}

async function onPickIcon(icon: string) {
  const value = icon || undefined
  if (iconTargetSpace.value) {
    await store.updateSpace(iconTargetSpace.value, { icon: value })
    iconTargetSpace.value = null
  } else if (iconTargetDoc.value) {
    // 直接调 docs API 更新 icon
    const { docsApi } = await import('@/services/office/docs')
    await docsApi.update(iconTargetDoc.value, { icon: value })
    const spaceId = store.currentSpaceId
    if (spaceId) {
      delete treeCache[spaceId]
      await loadTreeIfNeeded(spaceId)
    }
    iconTargetDoc.value = null
  }
}

// 展示当前空间列表
computed(() => store.spaces)
</script>

<style scoped>
.space-list {
  list-style: none;
  padding: 0;
  margin: 0;
}
.space {
  border-radius: 4px;
}
.space.active > .space-header {
  background: #e3f2fd;
  color: #1565c0;
}
.space-header {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 6px 8px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  color: #1f2937;
}
.space-header:hover {
  background: #f3f4f6;
}
.chevron {
  display: inline-block;
  width: 12px;
  font-size: 9px;
  color: #9ca3af;
  transform: rotate(0);
  transition: transform 0.15s;
}
.chevron.open {
  transform: rotate(90deg);
}
.space-icon {
  font-size: 14px;
}
.space-name {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.tree {
  padding-left: 8px;
}
</style>
