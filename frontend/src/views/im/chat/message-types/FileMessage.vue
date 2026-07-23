<template>
  <div class="file-msg">
    <span class="file-icon">📎</span>
    <div class="file-info">
      <span class="file-name">{{ name }}</span>
      <span class="file-size">{{ formatSize(size) }}</span>
    </div>
    <a v-if="url" :href="url" target="_blank" class="file-download" download>下载</a>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { lookup } from '@/services/im/proto'

const props = defineProps<{ content: Uint8Array }>()
const name = ref('')
const size = ref(0)
const url = ref('')

onMounted(() => {
  try {
    const decoded = lookup('entity.MessageFile').decode(props.content) as any
    name.value = decoded.name || ''
    size.value = Number(decoded.size || 0)
    url.value = decoded.url || ''
  } catch {
    name.value = '文件'
  }
})

function formatSize(bytes: number): string {
  if (bytes === 0) return ''
  if (bytes < 1024) return bytes + 'B'
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + 'KB'
  return (bytes / (1024 * 1024)).toFixed(1) + 'MB'
}
</script>

<style scoped>
.file-msg {
  display: flex;
  align-items: center;
  gap: 8px;
}
.file-icon {
  font-size: 24px;
}
.file-info {
  display: flex;
  flex-direction: column;
  min-width: 0;
}
.file-name {
  font-size: 13px;
  font-weight: 500;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.file-size {
  font-size: 11px;
  color: #999;
}
.file-download {
  font-size: 12px;
  color: #1976d2;
  text-decoration: none;
  flex-shrink: 0;
}
</style>
