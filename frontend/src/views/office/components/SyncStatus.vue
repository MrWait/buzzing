<template>
  <div class="sync-status" :class="statusClass" role="status">
    <span class="dot" />
    <span class="text">{{ label }}</span>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { SaveState } from '@/composables/useYjs'

const props = defineProps<{
  state: SaveState
  lastSavedAt: number | null
  connected: boolean
}>()

const statusClass = computed(() => `sync-status--${props.state}`)

const label = computed(() => {
  if (props.state === 'offline' || !props.connected) {
    return '离线，本地已保存'
  }
  if (props.state === 'syncing') {
    return '正在同步…'
  }
  if (props.lastSavedAt) {
    return `已保存 · ${formatRelative(props.lastSavedAt)}`
  }
  return '已保存'
})

function formatRelative(ts: number): string {
  const diff = Math.max(0, Date.now() - ts)
  if (diff < 5_000) return '刚刚'
  if (diff < 60_000) return `${Math.floor(diff / 1000)}秒前`
  if (diff < 3_600_000) return `${Math.floor(diff / 60_000)}分钟前`
  const d = new Date(ts)
  return `${d.getHours().toString().padStart(2, '0')}:${d.getMinutes().toString().padStart(2, '0')}`
}
</script>

<style scoped>
.sync-status {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 12px;
  line-height: 1;
  color: #6b7280;
  background: #f3f4f6;
  user-select: none;
  transition: background-color 0.2s, color 0.2s;
}
.sync-status .dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: currentColor;
}
.sync-status--saved {
  color: #059669;
  background: #ecfdf5;
}
.sync-status--syncing {
  color: #2563eb;
  background: #eff6ff;
}
.sync-status--syncing .dot {
  animation: pulse 1s ease-in-out infinite;
}
.sync-status--offline {
  color: #b45309;
  background: #fffbeb;
}
@keyframes pulse {
  0%, 100% { opacity: 0.4; }
  50% { opacity: 1; }
}
</style>
