<template>
  <Teleport to="body">
    <div
      v-if="visible"
      ref="menuRef"
      class="slash-menu"
      :style="{ left: position.left + 'px', top: position.top + 'px' }"
    >
      <div
        v-for="(item, i) in filteredItems"
        :key="item.label"
        class="slash-item"
        :class="{ selected: i === selectedIndex }"
        @mousedown.prevent="execute(i)"
        @mouseenter="selectedIndex = i"
      >
        <span class="slash-icon" v-text="item.icon" />
        <div class="slash-info">
          <span class="slash-label">{{ item.label }}</span>
          <span class="slash-desc">{{ item.description }}</span>
        </div>
      </div>
      <div v-if="filteredItems.length === 0" class="slash-empty">无匹配项</div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { inject, onMounted, onUnmounted, ref } from 'vue'
import type { Ref } from 'vue'
import type { EditorView } from 'prosemirror-view'
import type { Schema } from 'prosemirror-model'
import { useSlashMenu, buildSlashItems, type SlashMenuItem } from '../composables/useSlashMenu'

const editorView = inject<Ref<EditorView | null>>('editorView')!
const schema = inject<Schema>('schema')!
const triggerImageUpload = inject<(() => void) | undefined>('triggerImageUpload', undefined)

const items = ref<SlashMenuItem[]>(buildSlashItems(schema, triggerImageUpload))

const { visible, filter, selectedIndex, filteredItems, position, execute } = useSlashMenu(editorView, items)

const menuRef = ref<HTMLElement | null>(null)

function onGlobalKeyDown(e: KeyboardEvent) {
  if (!visible.value) return
  if (e.key === 'ArrowDown') {
    e.preventDefault()
    selectedIndex.value = Math.min(selectedIndex.value + 1, filteredItems.value.length - 1)
  } else if (e.key === 'ArrowUp') {
    e.preventDefault()
    selectedIndex.value = Math.max(selectedIndex.value - 1, 0)
  } else if (e.key === 'Enter') {
    e.preventDefault()
    execute(selectedIndex.value)
  }
}

function onGlobalClick(e: MouseEvent) {
  if (visible.value && menuRef.value && !menuRef.value.contains(e.target as Node)) {
    selectedIndex.value = 0
  }
}

onMounted(() => {
  document.addEventListener('keydown', onGlobalKeyDown)
  document.addEventListener('mousedown', onGlobalClick)
})
onUnmounted(() => {
  document.removeEventListener('keydown', onGlobalKeyDown)
  document.removeEventListener('mousedown', onGlobalClick)
})

// referenced by useSlashMenu's plugin; not used directly in template
void filter
</script>

<style scoped>
.slash-menu {
  position: fixed;
  min-width: 220px;
  max-height: 320px;
  overflow-y: auto;
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  z-index: 300;
  padding: 4px;
}
.slash-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 8px 10px;
  border-radius: 6px;
  cursor: pointer;
  transition: background 0.1s;
}
.slash-item:hover,
.slash-item.selected {
  background: #f0f0f0;
}
.slash-icon {
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f5f5;
  border-radius: 6px;
  font-size: 14px;
  flex-shrink: 0;
}
.slash-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.slash-label {
  font-size: 14px;
  font-weight: 500;
  color: #333;
}
.slash-desc {
  font-size: 12px;
  color: #888;
}
.slash-empty {
  padding: 16px;
  text-align: center;
  color: #999;
  font-size: 13px;
}
</style>
