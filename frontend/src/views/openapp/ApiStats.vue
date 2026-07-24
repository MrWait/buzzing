<template>
  <div class="api-stats">
    <header class="page-header">
      <router-link :to="{ name: 'AppList' }" class="back-link">&larr; 返回</router-link>
      <h1>API 调用统计</h1>
    </header>

    <div v-if="loading" class="loading">加载中...</div>

    <template v-else-if="store.dashboard">
      <div class="stats-overview">
        <div class="stat-card">
          <span class="stat-value">{{ store.dashboard.total_apps }}</span>
          <span class="stat-label">总应用数</span>
        </div>
        <div class="stat-card">
          <span class="stat-value">{{ store.dashboard.total_installations }}</span>
          <span class="stat-label">总安装量</span>
        </div>
        <div class="stat-card">
          <span class="stat-value">{{ store.dashboard.total_calls_today }}</span>
          <span class="stat-label">今日调用</span>
        </div>
        <div class="stat-card">
          <span class="stat-value">{{ store.dashboard.pending_reviews }}</span>
          <span class="stat-label">待审核</span>
        </div>
      </div>

      <div class="trends-card" v-if="store.trends.length > 0">
        <h3>趋势（近 7 天）</h3>
        <table class="data-table">
          <thead>
            <tr>
              <th>日期</th>
              <th>调用次数</th>
              <th>安装数</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="t in store.trends" :key="t.date">
              <td>{{ t.date }}</td>
              <td>{{ t.calls }}</td>
              <td>{{ t.installations }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useOpenAppStore } from '@/stores/openapp'

const store = useOpenAppStore()
const loading = ref(true)

onMounted(async () => {
  await store.loadDashboard()
  loading.value = false
})
</script>

<style scoped>
.api-stats {
  padding: 24px;
  max-width: 960px;
  margin: 0 auto;
}
.page-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 24px;
}
.page-header h1 {
  font-size: 24px;
  font-weight: 600;
  margin: 0;
}
.back-link {
  color: #1a73e8;
  text-decoration: none;
  font-size: 14px;
}
.loading {
  text-align: center;
  color: #888;
  padding: 60px;
}
.stats-overview {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  margin-bottom: 32px;
}
.stat-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 24px;
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
}
.stat-value {
  font-size: 32px;
  font-weight: 700;
  color: #1a73e8;
}
.stat-label {
  font-size: 14px;
  color: #666;
  margin-top: 4px;
}
.trends-card {
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 24px;
}
.trends-card h3 {
  margin: 0 0 16px;
  font-size: 16px;
  font-weight: 500;
}
.data-table {
  width: 100%;
  border-collapse: collapse;
}
.data-table th,
.data-table td {
  text-align: left;
  padding: 10px 12px;
  border-bottom: 1px solid #f0f0f0;
  font-size: 14px;
}
.data-table th {
  font-weight: 500;
  color: #666;
  background: #fafafa;
}
</style>
