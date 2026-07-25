<template>
  <div class="group-profile">
    <div class="profile-header">
      <button class="back-btn" @click="goBack">←</button>
      <span>群组信息</span>
    </div>

    <div class="profile-body">
      <div class="profile-avatar">
        <div class="avatar-placeholder">{{ chat?.name?.charAt(0) || 'G' }}</div>
        <div class="profile-name">{{ chat?.name || '...' }}</div>
        <div class="profile-id">ID: {{ chatId }}</div>
      </div>

      <div class="profile-section">
        <div class="section-label">群成员（{{ chat?.memberIds.length || 0 }}）</div>
        <div class="member-list">
          <div v-for="uid in chat?.memberIds || []" :key="uid" class="member-item">
            <div class="member-avatar">{{ getUserName(uid).charAt(0) }}</div>
            <div class="member-info">
              <span class="member-name">{{ getUserName(uid) }}</span>
              <span v-if="uid === chat?.ownerId" class="member-badge owner">群主</span>
              <span v-else-if="chat?.adminIds.includes(uid)" class="member-badge admin">管理员</span>
            </div>
          </div>
        </div>
      </div>

      <div class="profile-section">
        <div class="section-label">描述</div>
        <div class="section-value">{{ chat?.description || '暂无描述' }}</div>
      </div>

      <div class="profile-actions">
        <button v-if="isOwner" class="action-btn danger" @click="showConfirm = true">解散群聊</button>
        <button v-else class="action-btn danger" @click="showConfirm = true">退出群聊</button>
      </div>
    </div>

    <!-- 确认弹窗 -->
    <Teleport to="body">
      <div v-if="showConfirm" class="confirm-overlay" @click.self="showConfirm = false">
        <div class="confirm-dialog">
          <div class="confirm-title">{{ isOwner ? '解散群聊' : '退出群聊' }}</div>
          <div class="confirm-text">{{ isOwner ? '确定解散群聊？此操作不可撤销。' : '确定退出群聊？' }}</div>
          <div class="confirm-actions">
            <button class="confirm-btn cancel" @click="showConfirm = false">取消</button>
            <button class="confirm-btn ok" @click="handleConfirm">确定</button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useImStore } from '@/stores/im'
import { useAuthStore } from '@/stores/auth'

const props = defineProps<{ chatId?: string }>()
const emit = defineEmits<{ (e: 'close'): void }>()

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()

const cid = computed<string>(() => {
  if (props.chatId) return props.chatId
  const p = route.params.chatId
  return Array.isArray(p) ? (p[0] ?? '') : (p ?? '')
})

const im = useImStore()
const chat = computed(() => im.chats.get(cid.value))
const myId = computed(() => String(auth.user?.id ?? ''))
const isOwner = computed(() => chat.value?.ownerId === myId.value)
const showConfirm = ref(false)

function getUserName(uid: string): string {
  return im.users.get(uid)?.name || `用户${uid}`
}

async function handleConfirm() {
  showConfirm.value = false
  if (isOwner.value) {
    await im.dismissChat(cid.value)
  } else {
    await im.quitChat(cid.value)
  }
  emit('close')
}

function goBack() {
  if (props.chatId) {
    emit('close')
  } else {
    router.back()
  }
}

onMounted(() => {
  const memberIds = chat.value?.memberIds
  if (memberIds && memberIds.length > 0) {
    im.ensureUsers(memberIds)
  }
})
</script>

<style scoped>
.group-profile {
  display: flex;
  flex-direction: column;
  height: 100%;
  background: #f5f5f5;
  width: 340px;
  flex-shrink: 0;
  border-left: 1px solid #e0e0e0;
}
.profile-header {
  display: flex;
  align-items: center;
  padding: 10px 16px;
  background: #fff;
  border-bottom: 1px solid #e0e0e0;
  gap: 8px;
  font-weight: 500;
  flex-shrink: 0;
}
.back-btn {
  background: none;
  border: none;
  font-size: 18px;
  cursor: pointer;
  padding: 2px 6px;
  color: #666;
}
.profile-body {
  flex: 1;
  overflow-y: auto;
}
.profile-avatar {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 24px 0;
  background: #fff;
  flex-shrink: 0;
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
  margin-bottom: 8px;
}
.section-value {
  font-size: 14px;
  color: #333;
}
.member-list {
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.member-item {
  display: flex;
  align-items: center;
  gap: 8px;
}
.member-avatar {
  width: 28px;
  height: 28px;
  border-radius: 4px;
  background: #1976d2;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 500;
  flex-shrink: 0;
}
.member-info {
  display: flex;
  align-items: center;
  gap: 6px;
}
.member-name {
  font-size: 14px;
  color: #333;
}
.member-badge {
  font-size: 10px;
  padding: 1px 4px;
  border-radius: 3px;
}
.member-badge.owner {
  background: #fff3e0;
  color: #e65100;
}
.member-badge.admin {
  background: #e3f2fd;
  color: #1565c0;
}
.profile-actions {
  padding: 20px 16px;
  display: flex;
  justify-content: center;
}
.action-btn {
  width: 100%;
  padding: 10px;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  cursor: pointer;
}
.action-btn.danger {
  background: #f44336;
  color: #fff;
}
.action-btn.danger:hover {
  background: #d32f2f;
}
.confirm-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}
.confirm-dialog {
  background: #fff;
  border-radius: 12px;
  padding: 24px;
  width: 320px;
  box-shadow: 0 8px 24px rgba(0,0,0,0.15);
}
.confirm-title {
  font-size: 16px;
  font-weight: 500;
  margin-bottom: 8px;
}
.confirm-text {
  font-size: 14px;
  color: #666;
  margin-bottom: 20px;
}
.confirm-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}
.confirm-btn {
  padding: 8px 20px;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  cursor: pointer;
}
.confirm-btn.cancel {
  background: #f0f0f0;
  color: #333;
}
.confirm-btn.ok {
  background: #f44336;
  color: #fff;
}
</style>
