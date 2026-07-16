<template>
  <div class="tenant-select">
    <h2>选择身份</h2>
    <p class="account-name">账号：{{ auth.accountName }}</p>
    <div class="tenant-list">
      <div
        v-for="lu in auth.loginUsers"
        :key="lu.token"
        class="tenant-card"
        @click="handleSelect(lu)"
      >
        <div class="tenant-avatar">{{ displayName(lu).charAt(0) }}</div>
        <div class="tenant-info">
          <div class="tenant-name">{{ displayName(lu) }}</div>
          <div class="tenant-user">{{ lu.user.name }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import type { LoginUser } from '@/services/auth'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()

onMounted(() => {
  if (!auth.loginUsers.length) {
    router.replace({ name: 'Login' })
  }
})

function displayName(lu: LoginUser): string {
  return lu.tenant?.name || '个人'
}

function handleSelect(lu: LoginUser) {
  auth.selectIdentity(lu)
  const redirect = (route.query.redirect as string) || '/hub'
  router.push(redirect)
}
</script>

<style scoped>
.tenant-select {
  max-width: 480px;
  margin: 60px auto;
  padding: 0 16px;
}
.tenant-select h2 {
  text-align: center;
  margin-bottom: 8px;
  font-weight: 600;
}
.account-name {
  text-align: center;
  color: #999;
  font-size: 14px;
  margin-bottom: 24px;
}
.tenant-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.tenant-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  cursor: pointer;
  transition: border-color 0.2s, box-shadow 0.2s;
}
.tenant-card:hover {
  border-color: #1a1a2e;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}
.tenant-avatar {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  background: #1a1a2e;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  font-weight: 600;
  flex-shrink: 0;
}
.tenant-info {
  flex: 1;
}
.tenant-name {
  font-size: 16px;
  font-weight: 500;
  color: #333;
}
.tenant-user {
  font-size: 13px;
  color: #999;
  margin-top: 2px;
}
</style>
