<template>
  <!-- 用户资料浮层：飞书风格 — 大头像 + 信息卡片 + 操作按钮 + 详情字段 -->
  <Teleport to="body">
    <div v-if="visible" class="profile-popup-mask" @click.self="close"></div>
    <div
      v-if="visible"
      class="profile-popup"
      :style="{ left: left + 'px', top: top + 'px' }"
    >
      <div class="profile-popup-scroll">
        <div class="profile-popup-head">
          <div class="profile-popup-avatar" :style="{ background: avatarColor }">
            <img v-if="user?.avatar" class="profile-popup-avatar-img" :src="user.avatar" />
            <span v-else>{{ (user?.name || '?').charAt(0) }}</span>
          </div>
          <div class="profile-popup-name">{{ user?.name || '未知用户' }}</div>
          <div v-if="user?.position" class="profile-popup-position">{{ user.position }}</div>
        </div>

        <div class="profile-popup-actions">
          <div class="action-item" @click="sendMessage">
            <div class="action-icon">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
            </div>
            <span class="action-label">消息</span>
          </div>
          <div class="action-item action-disabled">
            <div class="action-icon">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
            </div>
            <span class="action-label">语音</span>
          </div>
          <div class="action-item action-disabled">
            <div class="action-icon">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="23 7 16 12 23 17 23 7"/><rect x="1" y="5" width="15" height="14" rx="2" ry="2"/></svg>
            </div>
            <span class="action-label">视频</span>
          </div>
        </div>

        <div class="profile-popup-divider"></div>

        <div class="profile-popup-info">
          <div v-if="user?.deptId" class="info-row">
            <span class="info-label">部门</span>
            <span class="info-value info-link">{{ deptName || user.deptId }}</span>
          </div>
          <div v-if="user?.superiorId && user?.superiorName" class="info-row">
            <span class="info-label">直属上级</span>
            <span class="info-value info-link">{{ user.superiorName }}</span>
          </div>
          <div v-if="user?.position" class="info-row">
            <span class="info-label">职务</span>
            <span class="info-value">{{ user.position }}</span>
          </div>
          <div v-if="user?.phone" class="info-row">
            <span class="info-label">手机号</span>
            <div class="info-value-row">
              <span class="info-value">{{ displayPhone }}</span>
              <span class="info-toggle" @click="togglePhone">
                {{ showFullPhone ? '隐藏' : '显示' }}
              </span>
            </div>
          </div>
          <div v-if="user?.email" class="info-row">
            <span class="info-label">邮箱</span>
            <span class="info-value info-link">{{ user.email }}</span>
          </div>
          <div v-if="user?.city" class="info-row">
            <span class="info-label">城市</span>
            <span class="info-value">{{ user.city }}</span>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useImStore } from '@/stores/im'

const im = useImStore()
const auth = useAuthStore()
const router = useRouter()

const visible = ref(false)
const left = ref(0)
const top = ref(0)
const curUserId = ref('')
const fallbackName = ref('')
const fallbackAvatar = ref('')
const showFullPhone = ref(false)
const deptName = ref('')

const user = computed(() => {
  const cached = im.users.get(curUserId.value)
  if (cached?.name) return cached
  if (fallbackName.value || fallbackAvatar.value) {
    return { id: curUserId.value, name: fallbackName.value, avatar: fallbackAvatar.value, status: 0 }
  }
  return cached
})

const avatarColor = computed(() => {
  const colors = ['#4a6cf7', '#f56c6c', '#67c23a', '#e6a23c', '#909399', '#409eff']
  const name = user.value?.name || '?'
  let hash = 0
  for (let i = 0; i < name.length; i++) {
    hash = name.charCodeAt(i) + ((hash << 5) - hash)
  }
  return colors[Math.abs(hash) % colors.length]
})

const displayPhone = computed(() => {
  const phone = user.value?.phone || ''
  if (!phone) return ''
  if (showFullPhone.value) return phone
  if (phone.length <= 7) return phone
  return phone.replace(/(\d{3})\d+(\d{4})/, '$1****$2')
})

watch(user, async (u) => {
  if (u?.deptId) {
    try {
      const resp = await im.getDeptInfo(u.deptId)
      deptName.value = resp?.departments?.[u.deptId]?.name || ''
    } catch {
      deptName.value = ''
    }
  }
}, { immediate: true })

function open(x: number, y: number, userId: string, name = '', avatar = '') {
  curUserId.value = userId
  fallbackName.value = name
  fallbackAvatar.value = avatar
  showFullPhone.value = false
  deptName.value = ''
  const w = 320
  const h = 480
  const vw = window.innerWidth
  const vh = window.innerHeight
  left.value = Math.min(x, vw - w - 8)
  top.value = Math.min(y, vh - h - 8)
  visible.value = true
}

function close() {
  visible.value = false
}

async function sendMessage() {
  const me = auth.user?.id || '0'
  close()
  if (curUserId.value === me) return
  const chatId = await im.createP2pChat(me, curUserId.value)
  if (chatId) {
    im.selectChat(chatId)
    router.push({ name: 'ImChatMain' })
  }
}

function togglePhone() {
  showFullPhone.value = !showFullPhone.value
}

defineExpose({ open, close })

function onDocClick(e: MouseEvent) {
  const target = e.target as HTMLElement
  if (target.closest('.profile-popup') || target.closest('.js-profile-open')) return
  visible.value = false
}

onMounted(() => document.addEventListener('click', onDocClick))
onUnmounted(() => document.removeEventListener('click', onDocClick))
</script>

<style scoped>
.profile-popup-mask {
  position: fixed;
  inset: 0;
  z-index: 19999;
}
.profile-popup {
  position: fixed;
  z-index: 20000;
  width: 320px;
  max-height: 70vh;
  background: #fff;
  border: 1px solid #e8e8e8;
  border-radius: 12px;
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.16);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.profile-popup-scroll {
  overflow-y: auto;
  padding: 20px 16px;
}
.profile-popup-head {
  display: flex;
  flex-direction: column;
  align-items: center;
}
.profile-popup-avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  font-weight: 600;
  overflow: hidden;
}
.profile-popup-avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.profile-popup-name {
  margin-top: 12px;
  font-size: 18px;
  font-weight: 600;
  color: #333;
  max-width: 100%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.profile-popup-position {
  margin-top: 4px;
  font-size: 13px;
  color: #8f959e;
}
.profile-popup-actions {
  display: flex;
  justify-content: center;
  gap: 24px;
  margin-top: 16px;
}
.action-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  cursor: pointer;
}
.action-item:not(.action-disabled):hover .action-icon {
  background: rgba(59, 130, 246, 0.1);
}
.action-icon {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: rgba(59, 130, 246, 0.08);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #3370ff;
  transition: background 0.2s;
}
.action-disabled .action-icon {
  background: #f5f5f5;
  color: #bbb;
}
.action-disabled .action-label {
  color: #bbb;
}
.action-label {
  font-size: 12px;
  color: #3370ff;
}
.profile-popup-divider {
  height: 1px;
  background: #e8e8e8;
  margin: 16px 0;
}
.profile-popup-info {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.info-row {
  display: flex;
  align-items: flex-start;
}
.info-label {
  width: 72px;
  flex-shrink: 0;
  font-size: 13px;
  color: #8f959e;
}
.info-value {
  flex: 1;
  font-size: 13px;
  color: #333;
}
.info-value-row {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 8px;
}
.info-link {
  color: #3370ff;
  cursor: pointer;
}
.info-link:hover {
  text-decoration: underline;
}
.info-toggle {
  font-size: 12px;
  color: #3370ff;
  cursor: pointer;
  padding: 2px 8px;
  border-radius: 4px;
  background: rgba(59, 130, 246, 0.08);
}
.info-toggle:hover {
  background: rgba(59, 130, 246, 0.15);
}
</style>
