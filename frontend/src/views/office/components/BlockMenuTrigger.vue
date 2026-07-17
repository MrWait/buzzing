<template>
  <div
    v-if="effectiveShow"
    class="block-menu-trigger"
    :style="{ top: top + 'px', left: left + 'px' }"
    @mouseenter="onEnter"
    @mouseleave="onLeave"
  >
    <button
      class="bm-button"
      :class="{ active: menuOpen }"
    >
      +
    </button>
    <div
      v-if="menuOpen"
      class="bm-menu"
      @mouseenter="onEnter"
      @mouseleave="onLeave"
    >
      <div
        v-for="(item, i) in items"
        :key="item.label"
        class="bm-item"
        :class="{ selected: i === selectedIndex }"
        @mousedown.prevent="execute(i)"
        @mouseenter="selectedIndex = i"
      >
        <span class="bm-icon" v-text="item.icon" />
        <div class="bm-info">
          <span class="bm-label">{{ item.label }}</span>
          <span class="bm-desc">{{ item.description }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { inject, ref, computed } from 'vue'
import type { Ref } from 'vue'
import type { EditorView } from 'prosemirror-view'
import type { Schema } from 'prosemirror-model'
import { useBlockMenu } from '../composables/useBlockMenu'
import { buildSlashItems } from '../composables/useSlashMenu'

const editorView = inject<Ref<EditorView | null>>('editorView')!
const schema = inject<Schema>('schema')!
const triggerImageUpload = inject<(() => void) | undefined>('triggerImageUpload', undefined)

const { show, top, left } = useBlockMenu(editorView)
const mouseInEditor = inject<Ref<boolean>>('mouseInEditor', ref(true))
const effectiveShow = computed(() => show.value && mouseInEditor.value)

const items = buildSlashItems(schema, triggerImageUpload)
const menuOpen = ref(false)
const selectedIndex = ref(0)
let hoverTimer: ReturnType<typeof setTimeout> | null = null

function onEnter() {
  if (hoverTimer) clearTimeout(hoverTimer)
  hoverTimer = setTimeout(() => {
    menuOpen.value = true
    selectedIndex.value = 0
  }, 80)
}

function onLeave() {
  if (hoverTimer) clearTimeout(hoverTimer)
  hoverTimer = setTimeout(() => {
    menuOpen.value = false
  }, 150)
}

function execute(index: number) {
  const view = editorView.value
  if (!view) return
  const item = items[index]
  if (!item) return
  const { state, dispatch } = view
  item.execute(state, (tr) => dispatch(tr))
  view.focus()
  menuOpen.value = false
}
</script>

<style scoped>
.block-menu-trigger {
  position: fixed;
  z-index: 200;
  display: flex;
  align-items: flex-start;
  pointer-events: auto;
}
.bm-button {
  width: 22px;
  height: 22px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid #d0d0d0;
  border-radius: 4px;
  background: #fff;
  color: #888;
  font-size: 14px;
  line-height: 1;
  cursor: pointer;
  padding: 0;
  transition: all 0.1s;
  flex-shrink: 0;
}
.bm-button:hover,
.bm-button.active {
  background: #f5f5f5;
  color: #333;
  border-color: #bbb;
}
.bm-menu {
  position: absolute;
  right: 0;
  top: 24px;
  min-width: 200px;
  max-height: 320px;
  overflow-y: auto;
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  padding: 4px;
}
.bm-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 7px 10px;
  border-radius: 6px;
  cursor: pointer;
  transition: background 0.1s;
}
.bm-item:hover,
.bm-item.selected {
  background: #f0f0f0;
}
.bm-icon {
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
.bm-info {
  display: flex;
  flex-direction: column;
  gap: 1px;
}
.bm-label {
  font-size: 13px;
  font-weight: 500;
  color: #333;
}
.bm-desc {
  font-size: 11px;
  color: #888;
}
</style>
