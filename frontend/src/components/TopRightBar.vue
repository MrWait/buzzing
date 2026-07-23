<template>
  <div class="top-right-bar">
    <!-- Hub 按钮 -->
    <div class="trb-hub-wrap" @click="hubOpen = !hubOpen" @mouseenter="hubOpen = true" @mouseleave="hubOpen = false">
      <button class="trb-hub-btn" aria-label="应用中心">
        <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
          <circle cx="3" cy="3" r="1.5" fill="currentColor"/>
          <circle cx="8" cy="3" r="1.5" fill="currentColor"/>
          <circle cx="13" cy="3" r="1.5" fill="currentColor"/>
          <circle cx="3" cy="8" r="1.5" fill="currentColor"/>
          <circle cx="8" cy="8" r="1.5" fill="currentColor"/>
          <circle cx="13" cy="8" r="1.5" fill="currentColor"/>
          <circle cx="3" cy="13" r="1.5" fill="currentColor"/>
          <circle cx="8" cy="13" r="1.5" fill="currentColor"/>
          <circle cx="13" cy="13" r="1.5" fill="currentColor"/>
        </svg>
      </button>
      <Transition name="fade">
        <div v-if="hubOpen" class="trb-dropdown trb-hub-dropdown" @click.stop>
          <div class="trb-hub-item" @click="goHub">
            <span class="trb-hub-icon">🏠</span>
            <span class="trb-hub-label">应用中心</span>
          </div>
          <div class="trb-hub-item" @click="goIm">
            <span class="trb-hub-icon">💬</span>
            <span class="trb-hub-label">即时通讯</span>
          </div>
          <div class="trb-hub-item" @click="goOffice">
            <span class="trb-hub-icon">📄</span>
            <span class="trb-hub-label">办公文档</span>
          </div>
          <div class="trb-hub-item" @click="goCalendar">
            <span class="trb-hub-icon">📅</span>
            <span class="trb-hub-label">日历</span>
          </div>
          <div class="trb-hub-item" @click="goTodo">
            <span class="trb-hub-icon">✓</span>
            <span class="trb-hub-label">任务</span>
          </div>
          <div class="trb-hub-item" @click="goMeeting">
            <span class="trb-hub-icon">📹</span>
            <span class="trb-hub-label">视频会议</span>
          </div>
        </div>
      </Transition>
    </div>

    <!-- 头像 -->
    <div class="trb-avatar-wrap" @mouseenter="avatarOpen = true" @mouseleave="avatarOpen = false">
      <img v-if="auth.user?.avatar" class="trb-avatar" :src="auth.user.avatar" alt="" />
      <div v-else class="trb-avatar trb-avatar-placeholder">{{ auth.user?.name?.charAt(0) || '?' }}</div>
      <Transition name="fade">
        <div v-if="avatarOpen" class="trb-dropdown trb-avatar-dropdown" @click.stop>
          <div class="trb-dropdown-item" @click="logout">退出登录</div>
        </div>
      </Transition>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const auth = useAuthStore()

const hubOpen = ref(false)
const avatarOpen = ref(false)

function goHub() { hubOpen.value = false; router.push({ name: 'Hub' }) }
function goIm() { hubOpen.value = false; router.push({ name: 'ImFeed' }) }
function goOffice() { hubOpen.value = false; router.push({ name: 'OfficeHome' }) }
function goCalendar() { hubOpen.value = false }
function goTodo() { hubOpen.value = false }
function goMeeting() { hubOpen.value = false; router.push({ name: 'MeetingHome' }) }

function logout() {
  auth.clear()
  router.push({ name: 'Login' })
}
</script>

<style scoped>
.top-right-bar {
  display: flex;
  align-items: center;
  gap: 8px;
}

.trb-hub-wrap, .trb-avatar-wrap {
  position: relative;
}

.trb-hub-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border: 1px solid #d0d0d0;
  border-radius: 6px;
  background: #fff;
  color: #666;
  cursor: pointer;
  transition: background 0.15s, color 0.15s;
}
.trb-hub-btn:hover {
  background: #f0f0f0;
  color: #333;
}

.trb-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  object-fit: cover;
  cursor: pointer;
  border: 2px solid #e0e0e0;
}
.trb-avatar:hover {
  border-color: #bbb;
}
.trb-avatar-placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
  background: #e0e0e0;
  color: #666;
  font-size: 14px;
  font-weight: 500;
}

.trb-dropdown {
  position: absolute;
  top: 100%;
  right: 0;
  margin-top: 6px;
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  box-shadow: 0 4px 16px rgba(0,0,0,0.12);
  z-index: 1000;
  min-width: 140px;
  padding: 4px;
  color: #333;
}

.trb-hub-dropdown {
  min-width: 160px;
}

.trb-hub-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 13px;
}
.trb-hub-item:hover {
  background: #f0f0f0;
}
.trb-hub-icon {
  font-size: 16px;
  width: 20px;
  text-align: center;
}
.trb-hub-label {
  white-space: nowrap;
}

.trb-avatar-dropdown {
  min-width: 120px;
}

.trb-dropdown-item {
  padding: 8px 12px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 13px;
  white-space: nowrap;
}
.trb-dropdown-item:hover {
  background: #f0f0f0;
}

.fade-enter-active, .fade-leave-active {
  transition: opacity 0.15s ease;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}
</style>
