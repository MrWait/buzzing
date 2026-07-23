<template>
  <Teleport to="body">
    <div
      v-if="state.open"
      class="mention-popup"
      :style="{ top: state.top + 'px', left: state.left + 'px' }"
      @mousedown.prevent.stop
    >
      <div v-if="state.loading" class="mp-loading">搜索中…</div>
      <div v-else-if="state.items.length === 0" class="mp-empty">无结果</div>
      <div
        v-for="(item, i) in state.items"
        :key="item.id"
        class="mp-item"
        :class="{ active: i === state.selectedIndex }"
        @mousedown.prevent="onSelect(item)"
      >
        <span class="mp-avatar">{{ item.type === 'user' ? '👤' : '📄' }}</span>
        <span class="mp-label">{{ item.label }}</span>
        <span class="mp-type">{{ item.type === 'user' ? '用户' : '文档' }}</span>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import type { MentionState, MentionSuggestion } from '@/views/office/composables/useMention'

const props = defineProps<{
  state: MentionState
  onInsert: (item: MentionSuggestion) => void
}>()

function onSelect(item: MentionSuggestion) {
  props.onInsert(item)
}
</script>

<style scoped>
.mention-popup {
  position: absolute;
  z-index: 1000;
  min-width: 220px;
  max-width: 320px;
  max-height: 240px;
  overflow-y: auto;
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
  padding: 4px 0;
}
.mp-loading,
.mp-empty {
  padding: 12px 16px;
  color: #999;
  font-size: 13px;
  text-align: center;
}
.mp-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 12px;
  cursor: pointer;
  font-size: 13px;
  color: #333;
  transition: background 0.1s;
}
.mp-item:hover,
.mp-item.active {
  background: #e3f2fd;
}
.mp-avatar {
  font-size: 14px;
  width: 20px;
  text-align: center;
  flex-shrink: 0;
}
.mp-label {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.mp-type {
  font-size: 11px;
  color: #999;
  flex-shrink: 0;
}
</style>
