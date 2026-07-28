<template>
  <div class="starred">
    <div class="starred-header">
      <h2>星标文档</h2>
      <TopRightBar />
    </div>
    <div v-if="store.starred.length === 0" class="empty">尚无星标文档，在文档列表右键"添加星标"。</div>
    <ul v-else class="list">
      <li
        v-for="item in store.starred"
        :key="item.id"
        class="item"
        @click="open(item.id)"
      >
        <span class="icon">{{ item.icon || '📄' }}</span>
        <span class="title">{{ item.title }}</span>
        <span class="time">{{ formatTime(item.updated_at) }}</span>
      </li>
    </ul>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import TopRightBar from '@/components/TopRightBar.vue'
import { useDocumentStore } from '@/stores/document'

const store = useDocumentStore()
const router = useRouter()

onMounted(async () => {
  await store.loadStarred()
})

function open(id: string) {
  router.push({ name: 'OfficeEditor', params: { docId: id } })
}

function formatTime(iso: string): string {
  const d = new Date(iso)
  return d.toLocaleString('zh-CN')
}
</script>

<style scoped>
.starred {
  max-width: 900px;
}
.starred-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}
.starred-header h2 {
  font-size: 20px;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
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
