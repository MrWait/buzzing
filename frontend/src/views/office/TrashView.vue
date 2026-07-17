<template>
  <div class="trash-view">
    <header class="header">
      <h2>回收站</h2>
      <p class="tip">回收站中的文档将在删除 30 天后自动永久清除。</p>
    </header>
    <div v-if="store.trash.length === 0" class="empty">回收站为空</div>
    <ul v-else class="list">
      <li v-for="item in store.trash" :key="item.id" class="item">
        <div class="info">
          <span v-if="item.icon" class="icon">{{ item.icon }}</span>
          <span class="title">{{ item.title }}</span>
          <span class="days">剩余 {{ item.remaining_days }} 天</span>
        </div>
        <div class="actions">
          <button class="btn" @click="handleRestore(item.id)">恢复</button>
          <button class="btn danger" @click="handlePurge(item.id)">永久删除</button>
        </div>
      </li>
    </ul>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useDocumentStore } from '@/stores/document'

const store = useDocumentStore()

onMounted(async () => {
  await store.loadTrash()
})

async function handleRestore(id: string) {
  await store.restoreDocument(id)
}

async function handlePurge(id: string) {
  if (!window.confirm('确定要永久删除该文档？此操作不可恢复。')) return
  await store.purgeDocument(id)
}
</script>

<style scoped>
.trash-view {
  max-width: 900px;
  margin: 0 auto;
  padding: 24px;
}
.header {
  margin-bottom: 16px;
}
.header h2 {
  font-size: 20px;
  font-weight: 600;
  color: #1f2937;
}
.tip {
  color: #6b7280;
  font-size: 13px;
  margin-top: 4px;
}
.empty {
  color: #9ca3af;
  text-align: center;
  padding: 64px 0;
}
.list {
  list-style: none;
  padding: 0;
  margin: 0;
  border-top: 1px solid #eee;
}
.item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 8px;
  border-bottom: 1px solid #eee;
}
.info {
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 0;
}
.info .icon {
  font-size: 18px;
}
.info .title {
  font-size: 14px;
  color: #1f2937;
  font-weight: 500;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 380px;
}
.info .days {
  font-size: 12px;
  color: #b45309;
  background: #fef3c7;
  padding: 2px 8px;
  border-radius: 10px;
}
.actions {
  display: flex;
  gap: 8px;
}
.btn {
  padding: 4px 12px;
  border: 1px solid #d1d5db;
  background: #fff;
  border-radius: 4px;
  cursor: pointer;
  font-size: 13px;
  color: #374151;
}
.btn:hover {
  background: #f3f4f6;
}
.btn.danger {
  color: #b91c1c;
  border-color: #fca5a5;
}
.btn.danger:hover {
  background: #fef2f2;
}
</style>
