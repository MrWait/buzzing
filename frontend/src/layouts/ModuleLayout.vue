<template>
  <div class="module-layout">
    <header class="topbar">
      <span class="logo" @click="goHub">Buzzing</span>
      <div class="topbar-right">
        <span class="module-name">{{ moduleName }}</span>
        <span v-if="auth.user" class="user-name">{{ auth.user.name }}</span>
        <button class="btn-logout" @click="logout">退出</button>
      </div>
    </header>
    <div class="main">
      <RouterView />
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()

const moduleName = computed(() => {
  const path = route.path
  if (path.startsWith('/office')) return '办公文档'
  if (path.startsWith('/calendar')) return '日历'
  if (path.startsWith('/todo')) return '任务'
  if (path.startsWith('/meeting')) return '视频会议'
  return ''
})

function goHub() {
  router.push({ name: 'Hub' })
}

function logout() {
  auth.clear()
  router.push({ name: 'Login' })
}
</script>

<style scoped>
.module-layout {
  display: flex;
  flex-direction: column;
  height: 100vh;
}
.topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 48px;
  padding: 0 16px;
  background: #1a1a2e;
  color: #fff;
}
.logo {
  font-weight: 600;
  font-size: 16px;
  cursor: pointer;
}
.topbar-right {
  display: flex;
  align-items: center;
  gap: 12px;
}
.module-name {
  font-size: 13px;
  color: rgba(255,255,255,0.6);
}
.user-name {
  font-size: 14px;
}
.btn-logout {
  background: none;
  border: 1px solid rgba(255,255,255,0.3);
  color: #fff;
  padding: 4px 12px;
  border-radius: 4px;
  cursor: pointer;
}
.main {
  flex: 1;
  overflow: auto;
}
</style>
