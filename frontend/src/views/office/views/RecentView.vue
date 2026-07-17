<template>
  <div class="recent">
    <h2>最近访问</h2>
    <div v-if="store.recent.length === 0" class="empty">尚无访问记录。</div>
    <ul v-else class="list">
      <li
        v-for="item in store.recent"
        :key="item.doc.id"
        class="item"
        @click="open(item.doc.id)"
      >
        <span class="icon">{{ item.doc.icon || '📄' }}</span>
        <span class="title">{{ item.doc.title }}</span>
        <span class="time">{{ formatTime(item.visited_at) }}</span>
      </li>
    </ul>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useDocumentStore } from '@/stores/document'

const store = useDocumentStore()
const router = useRouter()

onMounted(async () => {
  await store.loadRecent()
})

function open(id: string) {
  router.push({ name: 'OfficeEditor', params: { docId: id } })
}

function formatTime(ms: number): string {
  const d = new Date(ms)
  const diff = Date.now() - ms
  if (diff < 60_000) return '刚刚'
  if (diff < 3_600_000) return `${Math.floor(diff / 60_000)} 分钟前`
  if (diff < 86_400_000) return `${Math.floor(diff / 3_600_000)} 小时前`
  return d.toLocaleString('zh-CN')
}
</script>

<style scoped>
.recent {
  max-width: 900px;
}
.recent h2 {
  font-size: 20px;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 12px;
}
.empty {
  color: #9ca3af;
  padding: 64px 0;
  text-align: center;
}
.list {
  list-style: none;
  padding: 0;
  margin: 0;
}
.item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 12px;
  border-bottom: 1px solid #f0f0f0;
  cursor: pointer;
}
.item:hover {
  background: #f5f5f5;
}
.item .icon {
  font-size: 16px;
}
.item .title {
  flex: 1;
  font-size: 14px;
  color: #1f2937;
}
.item .time {
  font-size: 12px;
  color: #9ca3af;
}
</style>
