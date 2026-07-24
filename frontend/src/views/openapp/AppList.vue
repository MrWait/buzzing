<template>
  <div class="app-list">
    <header class="page-header">
      <h1>应用管理</h1>
      <router-link :to="{ name: 'AppCreate' }" class="btn-primary">
        创建应用
      </router-link>
    </header>

    <div v-if="store.loading" class="loading">加载中...</div>

    <div v-else-if="store.apps.length === 0" class="empty">
      <p>暂无应用，点击"创建应用"开始。</p>
    </div>

    <div v-else class="apps-grid">
      <div
        v-for="app in store.apps"
        :key="app.id"
        class="app-card"
        @click="$router.push({ name: 'AppDetail', params: { id: app.app_id } })"
      >
        <div class="app-avatar">{{ (app.name || '?').charAt(0).toUpperCase() }}</div>
        <div class="app-info">
          <h3>{{ app.name }}</h3>
          <p class="app-desc">{{ app.description || 'App ID: ' + app.app_id }}</p>
          <span class="app-status" :class="app.status">{{ app.status === 'active' ? '已启用' : app.status }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useOpenAppStore } from '@/stores/openapp'

const store = useOpenAppStore()

onMounted(() => {
  store.loadApps()
})
</script>

<style scoped>
.app-list {
  padding: 24px;
  max-width: 960px;
  margin: 0 auto;
}
.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 24px;
}
.page-header h1 {
  font-size: 24px;
  font-weight: 600;
  margin: 0;
}
.btn-primary {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 8px 20px;
  background: #1a73e8;
  color: #fff;
  border-radius: 6px;
  text-decoration: none;
  font-size: 14px;
}
.btn-primary:hover {
  background: #1557b0;
}
.loading,
.empty {
  text-align: center;
  color: #888;
  padding: 60px 0;
}
.apps-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 16px;
}
.app-card {
  display: flex;
  gap: 16px;
  padding: 20px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  cursor: pointer;
  transition: box-shadow 0.2s;
  background: #fff;
}
.app-card:hover {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}
.app-avatar {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  background: #e8f0fe;
  color: #1a73e8;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  font-weight: 600;
  flex-shrink: 0;
}
.app-info {
  flex: 1;
  min-width: 0;
}
.app-info h3 {
  margin: 0 0 4px;
  font-size: 16px;
  font-weight: 500;
}
.app-desc {
  margin: 0 0 8px;
  font-size: 13px;
  color: #666;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.app-status {
  font-size: 12px;
  padding: 2px 8px;
  border-radius: 10px;
  background: #e8f5e9;
  color: #2e7d32;
}
.app-status.inactive {
  background: #fce4ec;
  color: #c62828;
}
</style>
