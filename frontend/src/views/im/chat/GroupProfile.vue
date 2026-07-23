<template>
  <div class="group-profile">
    <div class="profile-header">
      <button class="back-btn" @click="goBack">←</button>
      <span>群组信息</span>
    </div>

    <div class="profile-avatar">
      <div class="avatar-placeholder">{{ chat?.name?.charAt(0) || 'G' }}</div>
      <div class="profile-name">{{ chat?.name || '...' }}</div>
      <div class="profile-id">ID: {{ chatId }}</div>
    </div>

    <div class="profile-section">
      <div class="section-label">成员</div>
      <div class="member-count">{{ chat?.memberIds.length || 0 }} 人</div>
    </div>

    <div class="profile-section">
      <div class="section-label">描述</div>
      <div class="section-value">{{ chat?.description || '暂无描述' }}</div>
    </div>

    <div class="profile-section">
      <div class="section-label">创建者</div>
      <div class="section-value">{{ getOwnerName }}</div>
    </div>

    <div class="profile-section">
      <div class="section-label">管理员</div>
      <div class="section-value">{{ adminNames || '无' }}</div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useImStore } from '@/stores/im'

const route = useRoute()
const router = useRouter()
const im = useImStore()
const chatId = computed(() => Number(route.params.chatId))

const chat = computed(() => im.chats.get(chatId.value))

const getOwnerName = computed(() => {
  return im.users.get(chat.value?.ownerId || 0)?.name || `用户${chat.value?.ownerId || ''}`
})

const adminNames = computed(() => {
  const ids = chat.value?.adminIds || []
  return ids.map((id) => im.users.get(id)?.name || `用户${id}`).join('、')
})

function goBack() {
  router.back()
}
</script>

<style scoped>
.group-profile {
  height: 100%;
  overflow-y: auto;
  background: #f5f5f5;
}
.profile-header {
  display: flex;
  align-items: center;
  padding: 10px 16px;
  background: #fff;
  border-bottom: 1px solid #e0e0e0;
  gap: 8px;
  font-weight: 500;
}
.back-btn {
  background: none;
  border: none;
  font-size: 18px;
  cursor: pointer;
  padding: 2px 6px;
  color: #666;
}
.profile-avatar {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 24px 0;
  background: #fff;
}
.avatar-placeholder {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  background: #1976d2;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  font-weight: 500;
  margin-bottom: 8px;
}
.profile-name {
  font-size: 18px;
  font-weight: 500;
}
.profile-id {
  font-size: 12px;
  color: #999;
  margin-top: 4px;
}
.profile-section {
  background: #fff;
  padding: 12px 16px;
  margin-top: 8px;
}
.section-label {
  font-size: 12px;
  color: #999;
  margin-bottom: 4px;
}
.member-count {
  font-size: 14px;
  color: #1976d2;
}
.section-value {
  font-size: 14px;
  color: #333;
}
</style>
