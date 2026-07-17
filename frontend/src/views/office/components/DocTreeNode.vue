<template>
  <div class="doc-node">
    <div
      class="doc-row"
      :class="{ active: isActive }"
      :style="{ paddingLeft: `${8 + level * 12}px` }"
      draggable="true"
      @click="openDoc"
      @contextmenu.prevent="emitMenu"
      @dragstart="onDragStart"
      @dragover.prevent="onDragOver"
      @drop.prevent="onDrop"
      @dragleave="dropHover = false"
    >
      <span
        class="chevron"
        :class="{ open: expanded, hidden: !hasChildren }"
        @click.stop="toggle"
      >▶</span>
      <span class="doc-icon">{{ node.icon || '📄' }}</span>
      <span class="doc-title">{{ node.title || '未命名' }}</span>
      <span class="doc-add" @click.stop="emitAddChild">+</span>
      <span class="doc-more" @click.stop="emitMenuMore">···</span>
    </div>
    <div v-if="expanded && hasChildren" class="children">
      <DocTreeNode
        v-for="child in node.children"
        :key="child.id"
        :node="child"
        :space-id="spaceId"
        :level="level + 1"
        @open-menu="(payload) => $emit('open-menu', payload)"
        @open-menu-more="(payload) => $emit('open-menu-more', payload)"
        @add-child="(payload) => $emit('add-child', payload)"
        @drop-onto="(payload) => $emit('drop-onto', payload)"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import type { DocTreeNode as DocTreeNodeDto } from '@/services/office/docs'

const props = defineProps<{
  node: DocTreeNodeDto
  spaceId: string
  level: number
}>()
const emit = defineEmits<{
  (e: 'open-menu', payload: { event: MouseEvent; node: DocTreeNodeDto; spaceId: string }): void
  (e: 'open-menu-more', payload: { el: HTMLElement; node: DocTreeNodeDto; spaceId: string }): void
  (e: 'add-child', payload: { node: DocTreeNodeDto; spaceId: string }): void
  (e: 'drop-onto', payload: { docId: string; fromSpaceId: string; targetSpaceId: string; targetParent: string | null }): void
}>()

const router = useRouter()
const route = useRoute()
const expanded = ref(false)
const dropHover = ref(false)

const hasChildren = computed(() => props.node.children.length > 0)
const isActive = computed(() => String(route.params.docId ?? '') === props.node.id)

function openDoc() {
  router.push({ name: 'OfficeEditor', params: { docId: props.node.id } })
}

function toggle() {
  if (hasChildren.value) expanded.value = !expanded.value
}

function emitMenu(e: MouseEvent) {
  emit('open-menu', { event: e, node: props.node, spaceId: props.spaceId })
}

function emitMenuMore(e: MouseEvent) {
  emit('open-menu-more', { el: e.currentTarget as HTMLElement, node: props.node, spaceId: props.spaceId })
}

function emitAddChild() {
  emit('add-child', { node: props.node, spaceId: props.spaceId })
}

function onDragStart(e: DragEvent) {
  e.dataTransfer?.setData('text/plain', `doc:${props.node.id}@${props.spaceId}`)
}

function onDragOver() {
  dropHover.value = true
}

function onDrop(e: DragEvent) {
  dropHover.value = false
  const raw = e.dataTransfer?.getData('text/plain') ?? ''
  if (!raw.startsWith('doc:')) return
  const [id, fromSpaceId] = raw.slice(4).split('@')
  if (id === props.node.id) return
  emit('drop-onto', {
    docId: id,
    fromSpaceId,
    targetSpaceId: props.spaceId,
    targetParent: props.node.id,
  })
}
</script>

<style scoped>
.doc-node {
  user-select: none;
}
.doc-row {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 4px 8px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 13px;
  color: #374151;
}
.doc-row:hover {
  background: #f3f4f6;
}
.doc-row.active {
  background: #eff6ff;
  color: #2563eb;
  font-weight: 500;
}
.chevron {
  display: inline-block;
  width: 10px;
  font-size: 8px;
  color: #9ca3af;
  transition: transform 0.15s;
}
.chevron.open {
  transform: rotate(90deg);
}
.chevron.hidden {
  visibility: hidden;
}
.doc-icon {
  font-size: 13px;
}
.doc-title {
  flex: 1;
  min-width: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.doc-add {
  font-size: 14px;
  color: #9ca3af;
  cursor: pointer;
  padding: 0 4px;
  border-radius: 4px;
  opacity: 0;
  user-select: none;
  flex-shrink: 0;
}
.doc-row:hover .doc-add {
  opacity: 1;
}
.doc-add:hover {
  background: #e5e7eb;
  color: #374151;
}
.doc-more {
  font-size: 12px;
  color: #9ca3af;
  cursor: pointer;
  padding: 0 2px;
  border-radius: 4px;
  opacity: 0;
  letter-spacing: 1px;
  user-select: none;
  flex-shrink: 0;
}
.doc-row:hover .doc-more {
  opacity: 1;
}
.doc-more:hover {
  background: #e5e7eb;
  color: #374151;
}
</style>
