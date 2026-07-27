<template>
  <div class="doc-node">
    <div
      class="doc-row"
      :class="{ active: isActive }"
      :style="{ paddingLeft: `${8 + level * 12}px` }"
      @click="openDoc"
      @contextmenu.prevent="emitMenu"
    >
      <span
        class="chevron"
        :class="{ open: expanded, hidden: !hasChildren }"
        @click.stop="toggle"
      >▶</span>
      <span class="doc-icon">{{ node.icon || '📄' }}</span>
      <span class="doc-title">{{ node.title || '未命名' }}</span>
      <span class="doc-add" @click.stop="emitAddChild">+</span>
      <span class="doc-more" @click.stop="emitMenu">···</span>
    </div>
    <div v-if="expanded && hasChildren" class="children">
      <DocTreeNode
        v-for="child in node.children"
        :key="child.id"
        :node="child"
        :level="level + 1"
        @add-child="(payload) => $emit('add-child', payload)"
        @open-menu="(payload) => $emit('open-menu', payload)"
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
  level: number
}>()

const emit = defineEmits<{
  (e: 'add-child', payload: { parentId: string }): void
  (e: 'open-menu', payload: { event: MouseEvent; node: DocTreeNodeDto }): void
}>()

const router = useRouter()
const route = useRoute()
const expanded = ref(false)

const hasChildren = computed(() => props.node.children.length > 0)
const isActive = computed(() => String(route.params.docId ?? '') === props.node.id)

function openDoc() {
  router.push({ name: 'OfficeEditor', params: { docId: props.node.id } })
}

function toggle() {
  if (hasChildren.value) expanded.value = !expanded.value
}

function emitAddChild() {
  emit('add-child', { parentId: props.node.id })
}

function emitMenu(e: MouseEvent) {
  emit('open-menu', { event: e, node: props.node })
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
