<template>
  <div class="outline-panel" v-if="items.length > 0">
    <div class="outline-title">大纲</div>
    <div class="outline-items">
      <div
        v-for="item in items"
        :key="item.id"
        class="outline-item"
        :class="'outline-level-' + item.level"
        :title="item.text"
        @mousedown.prevent="scrollTo(item.pos)"
      >
        {{ item.text || '无标题' }}
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { inject } from 'vue'
import type { Ref } from 'vue'
import type { EditorView } from 'prosemirror-view'
import { useOutline } from '../composables/useOutline'

const editorView = inject<Ref<EditorView | null>>('editorView')!
const { items, scrollTo } = useOutline(editorView)
</script>

<style scoped>
.outline-panel {
  width: 200px;
  flex-shrink: 0;
  border-left: 1px solid #e0e0e0;
  background: #fafafa;
  padding: 16px 12px;
  overflow-y: auto;
  max-height: 100%;
}
.outline-title {
  font-size: 12px;
  font-weight: 600;
  color: #888;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: 12px;
}
.outline-items {
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.outline-item {
  font-size: 13px;
  color: #555;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 4px;
  transition: background 0.1s;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.outline-item:hover {
  background: #eee;
  color: #333;
}
.outline-level-1 { padding-left: 8px; font-weight: 600; }
.outline-level-2 { padding-left: 20px; font-weight: 500; }
.outline-level-3 { padding-left: 32px; }
.outline-level-4 { padding-left: 44px; font-size: 12px; }
.outline-level-5 { padding-left: 56px; font-size: 12px; }
.outline-level-6 { padding-left: 68px; font-size: 11px; color: #999; }
</style>
