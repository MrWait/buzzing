<template>
  <div class="group-profile">
    <div class="profile-header">
      <button class="back-btn" @click="goBack">←</button>
      <span>群组信息</span>
    </div>

    <div class="profile-body">
      <div class="profile-avatar">
        <div class="avatar-wrap" @click="canEdit ? openEdit() : null">
          <div class="avatar-placeholder"><img v-if="chat?.avatar" :src="chat.avatar" alt="" /><template v-else>{{ chat?.name?.charAt(0) || 'G' }}</template></div>
          <span v-if="canEdit" class="avatar-edit" title="编辑群资料">✎</span>
        </div>
        <div class="profile-name">{{ chat?.name || '...' }}</div>
        <div class="profile-id">ID: {{ chatId }}</div>
        <button v-if="canEdit" class="edit-link" @click="openEdit">编辑群资料</button>
      </div>

      <!-- 群权限（仅管理员/群主可见） -->
      <div v-if="canEdit" class="profile-section">
        <div class="section-label">群权限</div>
        <div class="perm-row">
          <span class="perm-label">全员禁言</span>
          <label class="switch">
            <input type="checkbox" :checked="isGlobalMuted" @change="onToggleGlobalMute" />
            <span class="slider"></span>
          </label>
        </div>
        <div class="perm-row">
          <span class="perm-label">入群方式</span>
          <select class="perm-select" :value="chat?.joinMode ?? 0" @change="onJoinModeChange($event)">
            <option :value="0">允许任何人</option>
            <option :value="1">需要审核</option>
            <option :value="2">禁止加入</option>
          </select>
        </div>
        <div class="perm-row clickable" @click="openJoinRequests">
          <span class="perm-label">入群申请</span>
          <span class="perm-arrow">›</span>
        </div>
      </div>

      <!-- 邀请 -->
      <div class="profile-section">
        <div class="section-label">邀请</div>
        <div class="perm-row clickable" @click="openInvite">
          <span class="perm-label">使用邀请码 / 生成邀请链接</span>
          <span class="perm-arrow">›</span>
        </div>
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

      <!-- 群资料编辑 -->
      <div v-if="editShow" class="modal-overlay" @click.self="editShow = false">
        <div class="modal-dialog">
          <div class="modal-header">编辑群资料</div>
          <input ref="avatarInput" type="file" accept="image/*" style="display:none" @change="onAvatarSelected" />
          <div class="edit-avatar" @click="avatarInput?.click()">
            <img v-if="editAvatar" :src="editAvatar" alt="" />
            <span v-else>{{ (editName || chat?.name || 'G').charAt(0) }}</span>
            <span class="edit-avatar-hint">更换头像</span>
          </div>
          <label class="edit-field">
            <span>群名称</span>
            <input v-model="editName" placeholder="群名称" />
          </label>
          <label class="edit-field">
            <span>群简介</span>
            <textarea v-model="editDesc" placeholder="群简介" rows="3"></textarea>
          </label>
          <div class="modal-actions">
            <button class="confirm-btn cancel" @click="editShow = false">取消</button>
            <button class="confirm-btn primary" :disabled="saving" @click="saveEdit">保存</button>
          </div>
        </div>
      </div>

      <!-- 入群申请 -->
      <div v-if="joinRequestsShow" class="modal-overlay" @click.self="closeJoinRequests">
        <div class="modal-dialog">
          <div class="modal-header">
            <span>入群申请</span>
            <button class="icon-btn" @click="closeJoinRequests">✕</button>
          </div>
          <div v-if="joinRequests.length === 0" class="modal-empty">暂无待处理的申请</div>
          <div v-else class="request-list">
            <div v-for="req in joinRequests" :key="req.id" class="request-item">
              <span class="request-name">{{ req.user_name || '用户' + req.user_id }}</span>
              <div class="request-actions">
                <button class="confirm-btn primary small" @click="handleApprove(req)">通过</button>
                <button class="confirm-btn danger small" @click="handleReject(req)">拒绝</button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 邀请 -->
      <div v-if="inviteShow" class="modal-overlay" @click.self="closeInvite">
        <div class="modal-dialog">
          <div class="modal-header">
            <span>邀请</span>
            <button class="icon-btn" @click="closeInvite">✕</button>
          </div>
          <div class="invite-body">
            <div class="invite-join">
              <input v-model="inviteCode" class="text-input" placeholder="输入邀请码" @keydown.enter="handleJoinByCode" />
              <button class="confirm-btn primary" :disabled="joining" @click="handleJoinByCode">加入</button>
            </div>
            <button v-if="canEdit" class="invite-create" @click="handleCreateInvite">生成新邀请链接</button>
            <div v-if="currentCode" class="invite-current">
              <div class="invite-code">邀请码: {{ currentCode }}</div>
              <a :href="inviteUrl" target="_blank" rel="noopener" class="invite-url">{{ inviteUrl }}</a>
              <button class="confirm-btn danger small" @click="handleRevokeInvite">撤销链接</button>
            </div>
            <div v-if="!isMember" class="invite-join-request">
              <button class="confirm-btn primary" @click="handleApplyJoin">申请加入该群聊</button>
            </div>
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
import api from '@/services/api'

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
const isAdmin = computed(() => chat.value?.adminIds.includes(myId.value) ?? false)
const isMember = computed(() => chat.value?.memberIds.includes(myId.value) ?? false)
const canEdit = computed(() => isOwner.value || isAdmin.value)
const showConfirm = ref(false)

const isGlobalMuted = computed(() => {
  const until = chat.value?.globalMuteUntil || 0
  return until > 0 && until > Date.now()
})

async function onToggleGlobalMute(e: Event) {
  const on = (e.target as HTMLInputElement).checked
  const untilMs = on ? Date.now() + 86400000 * 365 : 0
  await im.globalMute(cid.value, untilMs)
}

function onJoinModeChange(e: Event) {
  const mode = Number((e.target as HTMLSelectElement).value)
  im.updateChat(cid.value, { join_mode: mode })
}

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

// ─── 群资料编辑（W3-1）───────────────────────────────────────────
const editShow = ref(false)
const avatarInput = ref<HTMLInputElement>()
const editName = ref('')
const editDesc = ref('')
const editAvatar = ref('')
const saving = ref(false)

function openEdit() {
  editName.value = chat.value?.name || ''
  editDesc.value = chat.value?.description || ''
  editAvatar.value = chat.value?.avatar || ''
  editShow.value = true
}

async function onAvatarSelected(e: Event) {
  const input = e.target as HTMLInputElement
  const file = input?.files?.[0]
  if (!file) return
  const formData = new FormData()
  formData.append('file', file)
  try {
    const res = await api.post('/files/upload', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    editAvatar.value = res.data.url
  } catch (err) {
    console.error('[im] avatar upload error:', err)
  }
  input.value = ''
}

async function saveEdit() {
  if (saving.value) return
  const name = editName.value.trim()
  if (!name) return
  saving.value = true
  await im.updateChat(cid.value, {
    name,
    description: editDesc.value.trim(),
    ...(editAvatar.value && editAvatar.value !== chat.value?.avatar ? { avatar: editAvatar.value } : {}),
  })
  saving.value = false
  editShow.value = false
}

// ─── 入群申请（W3-5）─────────────────────────────────────────────
const joinRequestsShow = ref(false)
const joinRequests = ref<any[]>([])

async function openJoinRequests() {
  joinRequestsShow.value = true
  const resp = await im.listJoinRequests(cid.value, 0)
  joinRequests.value = resp?.requests || []
}

function closeJoinRequests() {
  joinRequestsShow.value = false
}

async function handleApprove(req: any) {
  await im.approveJoinRequest(req.id)
  joinRequests.value = joinRequests.value.filter((r) => r.id !== req.id)
}

async function handleReject(req: any) {
  await im.rejectJoinRequest(req.id)
  joinRequests.value = joinRequests.value.filter((r) => r.id !== req.id)
}

// ─── 邀请链接（W3-4）─────────────────────────────────────────────
const inviteShow = ref(false)
const inviteCode = ref('')
const joining = ref(false)
const currentCode = ref('')

const inviteUrl = computed(() => {
  if (!currentCode.value) return ''
  return `${window.location.origin}/im/invite/${currentCode.value}`
})

function openInvite() {
  inviteShow.value = true
  currentCode.value = ''
  inviteCode.value = ''
}

function closeInvite() {
  inviteShow.value = false
}

async function handleJoinByCode() {
  const code = inviteCode.value.trim()
  if (!code || joining.value) return
  joining.value = true
  const resp = await im.joinByInviteLink(code)
  joining.value = false
  if (resp?.chat_id) {
    inviteCode.value = ''
    inviteShow.value = false
    im.loadFeeds()
  } else {
    alert('邀请码无效或已过期')
  }
}

async function handleCreateInvite() {
  const code = await im.createInviteLink(cid.value)
  if (code) currentCode.value = code
}

async function handleRevokeInvite() {
  await im.revokeInviteLink(currentCode.value)
  currentCode.value = ''
}

async function handleApplyJoin() {
  await im.createJoinRequest(cid.value)
  alert('已提交入群申请，请等待管理员审核')
  inviteShow.value = false
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
.avatar-wrap {
  position: relative;
  cursor: pointer;
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
  overflow: hidden;
}
.avatar-placeholder img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.avatar-edit {
  position: absolute;
  right: -2px;
  bottom: 10px;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  background: #4a6cf7;
  color: #fff;
  font-size: 11px;
  display: flex;
  align-items: center;
  justify-content: center;
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
.edit-link {
  margin-top: 8px;
  background: none;
  border: 1px solid #e0e0e0;
  color: #1976d2;
  border-radius: 6px;
  padding: 4px 12px;
  font-size: 12px;
  cursor: pointer;
}
.edit-link:hover { background: #f0f6ff; }
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
.perm-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 0;
  font-size: 14px;
  color: #333;
}
.perm-row.clickable { cursor: pointer; }
.perm-row.clickable:hover { color: #1976d2; }
.perm-label { flex: 1; }
.perm-arrow { color: #999; }
.perm-select {
  border: 1px solid #ddd;
  border-radius: 6px;
  padding: 4px 8px;
  font-size: 13px;
}
.switch { position: relative; display: inline-block; width: 38px; height: 22px; }
.switch input { opacity: 0; width: 0; height: 0; }
.slider {
  position: absolute;
  cursor: pointer;
  inset: 0;
  background: #ccc;
  border-radius: 22px;
  transition: 0.2s;
}
.slider::before {
  content: '';
  position: absolute;
  height: 16px;
  width: 16px;
  left: 3px;
  top: 3px;
  background: #fff;
  border-radius: 50%;
  transition: 0.2s;
}
.switch input:checked + .slider { background: #f44336; }
.switch input:checked + .slider::before { transform: translateX(16px); }
.member-list {
  display: flex;
  flex-direction: column;
  gap: 6px;
  max-height: 220px;
  overflow-y: auto;
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
.member-name { font-size: 14px; color: #333; }
.member-badge { font-size: 10px; padding: 1px 4px; border-radius: 3px; }
.member-badge.owner { background: #fff3e0; color: #e65100; }
.member-badge.admin { background: #e3f2fd; color: #1565c0; }
.profile-actions { padding: 20px 16px; display: flex; justify-content: center; }
.action-btn {
  width: 100%;
  padding: 10px;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  cursor: pointer;
}
.action-btn.danger { background: #f44336; color: #fff; }
.action-btn.danger:hover { background: #d32f2f; }

/* modals */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.35);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}
.modal-dialog {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  width: 340px;
  max-height: 80vh;
  overflow-y: auto;
  box-shadow: 0 8px 24px rgba(0,0,0,0.15);
}
.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 16px;
  font-weight: 600;
  margin-bottom: 16px;
}
.icon-btn { background: none; border: none; font-size: 16px; cursor: pointer; color: #666; }
.modal-empty { text-align: center; color: #999; padding: 20px 0; font-size: 13px; }
.modal-actions { display: flex; justify-content: flex-end; gap: 8px; margin-top: 16px; }
.edit-avatar {
  width: 72px;
  height: 72px;
  border-radius: 50%;
  background: #1976d2;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 26px;
  margin: 0 auto 16px;
  overflow: hidden;
  position: relative;
  cursor: pointer;
}
.edit-avatar img { width: 100%; height: 100%; object-fit: cover; }
.edit-avatar-hint {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: rgba(0,0,0,0.5);
  color: #fff;
  font-size: 10px;
  text-align: center;
  padding: 2px 0;
}
.edit-field {
  display: flex;
  flex-direction: column;
  gap: 4px;
  margin-bottom: 12px;
  font-size: 13px;
  color: #666;
}
.edit-field input,
.edit-field textarea {
  border: 1px solid #ddd;
  border-radius: 6px;
  padding: 8px;
  font-size: 14px;
  outline: none;
  resize: none;
}
.edit-field input:focus,
.edit-field textarea:focus { border-color: #1976d2; }
.request-list { display: flex; flex-direction: column; gap: 4px; }
.request-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid #f0f0f0;
}
.request-name { font-size: 14px; }
.request-actions { display: flex; gap: 6px; }
.invite-body { display: flex; flex-direction: column; gap: 12px; }
.invite-join { display: flex; gap: 8px; }
.invite-join .text-input {
  flex: 1;
  border: 1px solid #ddd;
  border-radius: 6px;
  padding: 8px;
  font-size: 14px;
  outline: none;
}
.invite-create { padding: 8px; border: 1px solid #1976d2; color: #1976d2; background: #fff; border-radius: 8px; cursor: pointer; font-size: 14px; }
.invite-create:hover { background: #f0f6ff; }
.invite-current {
  display: flex;
  flex-direction: column;
  gap: 6px;
  padding: 10px;
  background: #f7f9fc;
  border-radius: 8px;
}
.invite-code { font-size: 14px; font-weight: 500; }
.invite-url { font-size: 12px; color: #1976d2; word-break: break-all; }
.invite-join-request { display: flex; }
.confirm-btn {
  padding: 8px 20px;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  cursor: pointer;
}
.confirm-btn.primary { background: #1976d2; color: #fff; }
.confirm-btn.primary:hover { background: #1565c0; }
.confirm-btn.primary:disabled { opacity: 0.5; cursor: not-allowed; }
.confirm-btn.danger { background: #f44336; color: #fff; }
.confirm-btn.danger:hover { background: #d32f2f; }
.confirm-btn.cancel { background: #f0f0f0; color: #333; }
.confirm-btn.small { padding: 4px 12px; font-size: 12px; }

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
.confirm-title { font-size: 16px; font-weight: 500; margin-bottom: 8px; }
.confirm-text { font-size: 14px; color: #666; margin-bottom: 20px; }
.confirm-actions { display: flex; justify-content: flex-end; gap: 8px; }
</style>