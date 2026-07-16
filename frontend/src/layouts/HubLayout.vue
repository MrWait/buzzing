<template>
  <div class="hub-layout">
    <header class="topbar">
      <span class="logo">Buzzing</span>
      <div class="topbar-right">
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
import { useAuthStore } from '@/stores/auth'
import { useRouter } from 'vue-router'

const auth = useAuthStore()
const router = useRouter()

function logout() {
  auth.clear()
  router.push({ name: 'Login' })
}
</script>

<style scoped>
.hub-layout {
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
}
.topbar-right {
  display: flex;
  align-items: center;
  gap: 12px;
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
