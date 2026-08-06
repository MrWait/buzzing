<template>
  <div class="group-profile">
    <div class="profile-header">
      <button v-if="currentView !== 'main'" class="back-btn" title="返回" @click="goBackLevel">←</button>
      <span class="profile-title">{{ headerTitle }}</span>
      <button class="close-btn" title="关闭" @click="$emit('close')">✕</button>
    </div>

    <!-- 一级：群设置/群资料 -->
    <div v-if="currentView === 'main'" class="profile-body">
      <!-- 群信息头部：头像 + 名称 + 描述 + 分享 + chevron -->
      <div class="info-header">
        <div class="avatar-wrap" @click="canEdit ? enterEdit() : null">
          <div class="avatar-placeholder"><img v-if="chat?.avatar" :src="chat.avatar" alt="" /><template v-else>{{ chat?.name?.charAt(0) || 'G' }}</template></div>
          <span v-if="canEdit" class="avatar-edit" title="编辑群资料">✎</span>
        </div>
        <div class="info-main">
          <div class="info-name">{{ chat?.name || '...' }}</div>
          <div v-if="chat?.description" class="info-desc">{{ chat.description }}</div>
        </div>
        <button class="header-icon-btn" title="分享" @click="shareShow = true">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
        </button>
        <button class="header-icon-btn" title="群信息" @click="enterEdit">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
        </button>
      </div>

      <!-- 群公告 -->
      <div class="setting-tile" @click="openAnnounce">
        <svg class="tile-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6"/><path d="M8 13h8M8 17h8"/></svg>
        <div class="tile-text">
          <div class="tile-title">群公告</div>
          <div v-if="announcementSummary" class="tile-subtitle">{{ announcementSummary }}</div>
        </div>
        <svg class="tile-chevron" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
      </div>

      <!-- 群成员：扁平行 + 搜索 + 头像网格 -->
      <div class="members-section">
        <div class="setting-tile" @click="enterMembers">
          <svg class="tile-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/></svg>
          <div class="tile-text">
            <div class="tile-title">群成员</div>
          </div>
          <span class="tile-value">{{ memberCount }}人</span>
          <svg class="tile-chevron" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
        </div>

        <div class="member-search-box">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#999" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
          <input v-model="memberKeyword" class="member-search-input" placeholder="搜索群成员" @input="loadMembers(true)" />
        </div>
        <div v-if="membersLoading" class="member-avatars-loading">加载中...</div>
        <div v-else-if="memberAvatars.length > 0" class="member-avatars">
          <div v-for="m in memberAvatars" :key="String(m.user_id)" class="member-avatar-item js-profile-open" @click="openUser($event, m)">
            <img v-if="m.avatar" :src="m.avatar" alt="" />
            <span v-else>{{ (m.name || '?').charAt(0) }}</span>
          </div>
          <button class="member-add-btn" title="添加成员" @click="pickerShow = true">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#666" stroke-width="2" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
          </button>
        </div>
      </div>

      <!-- 群管理（管理员/群主可见） -->
      <div v-if="canEdit" class="setting-tile" @click="enterManage">
        <svg class="tile-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 1a3 3 0 0 0-3 3v1H7a2 2 0 0 0-2 2v.5A7.97 7.97 0 0 0 4 12v3a4 4 0 0 0 4 4h8a4 4 0 0 0 4-4v-3a7.97 7.97 0 0 0-1-4.5V7a2 2 0 0 0-2-2h-2V4a3 3 0 0 0-3-3z"/><circle cx="12" cy="12" r="3"/></svg>
        <div class="tile-text">
          <div class="tile-title">群管理</div>
          <div class="tile-subtitle">禁言、入群方式、管理员设置</div>
        </div>
        <svg class="tile-chevron" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
      </div>

      <!-- 入群申请（管理员/群主可见） -->
      <div v-if="canEdit" class="setting-tile" @click="enterJoinRequests">
        <svg class="tile-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
        <div class="tile-text">
          <div class="tile-title">入群申请</div>
        </div>
        <svg class="tile-chevron" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
      </div>

      <!-- 危险区 -->
      <div class="danger-zone">
        <button v-if="isOwner" class="danger-btn transfer" @click="showTransferHint = true">转让群主</button>
        <button class="danger-btn leave" @click="showConfirm = true">退出群聊</button>
      </div>
    </div>

    <!-- 二级页 -->
    <template v-else>
      <GroupManagePanel v-if="currentView === 'manage'" :chat-id="cid" />
      <GroupEditPanel v-else-if="currentView === 'edit'" :chat-id="cid" />
      <JoinRequestsPanel v-else-if="currentView === 'joinRequests'" :chat-id="cid" />
      <MemberListPanel v-else-if="currentView === 'members'" :chat-id="cid" />
    </template>

    <!-- 确认弹窗 -->
    <Teleport to="body">
      <div v-if="showConfirm" class="confirm-overlay" @click.self="showConfirm = false">
        <div class="confirm-dialog">
          <div class="confirm-title">退出群聊</div>
          <div class="confirm-text">确定要退出该群聊吗？</div>
          <div class="confirm-actions">
            <button class="confirm-btn cancel" @click="showConfirm = false">取消</button>
            <button class="confirm-btn ok" @click="handleQuit">退出</button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- 转让群主提示 -->
    <Teleport to="body">
      <div v-if="showTransferHint" class="confirm-overlay" @click.self="showTransferHint = false">
        <div class="confirm-dialog">
          <div class="confirm-title">转让群主</div>
          <div class="confirm-text">此功能需要在成员列表中操作。请前往成员列表，点击目标成员操作菜单选择「转让群主」。</div>
          <div class="confirm-actions">
            <button class="confirm-btn cancel" @click="showTransferHint = false">知道了</button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- 分享/邀请对话框 -->
    <ShareDialog :show="shareShow" :chat-id="cid" @close="shareShow = false" />

    <!-- 添加成员选人 -->
    <MemberPicker :show="pickerShow" :exclude-ids="excludeForPicker" title="添加成员" @confirm="onAddMembers" @close="pickerShow = false" />

    <!-- 用户资料浮层 -->
    <UserProfilePopup ref="userProfileRef" />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useImStore } from '@/stores/im'
import { useAuthStore } from '@/stores/auth'
import UserProfilePopup from '@/components/UserProfilePopup.vue'
import GroupManagePanel from './components/GroupManagePanel.vue'
import GroupEditPanel from './components/GroupEditPanel.vue'
import JoinRequestsPanel from './components/JoinRequestsPanel.vue'
import MemberListPanel from './components/MemberListPanel.vue'
import MemberPicker from './components/MemberPicker.vue'
import ShareDialog from './components/ShareDialog.vue'

const props = defineProps<{ chatId?: string }>()
const emit = defineEmits<{ (e: 'close'): void; (e: 'open-announce'): void }>()

const auth = useAuthStore()
const im = useImStore()

const cid = computed<string>(() => props.chatId || '')
const chat = computed(() => im.chats.get(cid.value))
const myId = computed(() => String(auth.user?.id ?? ''))
const isOwner = computed(() => chat.value?.ownerId === myId.value)
const isAdmin = computed(() => chat.value?.adminIds.includes(myId.value) ?? false)
const canEdit = computed(() => isOwner.value || isAdmin.value)
const memberCount = computed(() => chat.value?.memberIds.length || 0)

const announcementSummary = computed(() => chat.value?.announcement?.summary || '')

type View = 'main' | 'manage' | 'edit' | 'joinRequests' | 'members'
const currentView = ref<View>('main')

const headerTitle = computed(() => {
  switch (currentView.value) {
    case 'manage': return '群管理'
    case 'edit': return '群信息'
    case 'joinRequests': return '入群申请'
    case 'members': return '群成员'
    default: return '设置'
  }
})

function goBackLevel() {
  currentView.value = 'main'
}

function enterManage() { currentView.value = 'manage' }
function enterEdit() { currentView.value = 'edit' }
function enterJoinRequests() { currentView.value = 'joinRequests' }
function enterMembers() { currentView.value = 'members' }

function openAnnounce() {
  emit('open-announce')
}

// ─── 群成员（一级页头像网格）────────────────────────────────────
const memberKeyword = ref('')
const membersRef = ref<any[]>([])
const membersLoading = ref(false)
const memberAvatars = computed(() => membersRef.value.slice(0, 8))

async function loadMembers(reset = true) {
  membersLoading.value = true
  const resp = await im.getMembers(cid.value, 1, 100, memberKeyword.value.trim())
  if (reset) membersRef.value = resp?.members || []
  membersLoading.value = false
}

// ─── 添加成员 ──────────────────────────────────────────────────
const pickerShow = ref(false)
const excludeForPicker = computed(() => {
  const ids = (chat.value?.memberIds || []).map(String)
  if (myId.value && !ids.includes(myId.value)) ids.push(myId.value)
  return ids
})

async function onAddMembers(ids: string[]) {
  await im.addChatters(cid.value, ids)
  await loadMembers(true)
}

// ─── 退出群聊 ─────────────────────────────────────────────────
const showConfirm = ref(false)
const showTransferHint = ref(false)

async function handleQuit() {
  showConfirm.value = false
  await im.quitChat(cid.value)
  emit('close')
}

// ─── 用户资料浮层 ─────────────────────────────────────────────
const userProfileRef = ref<InstanceType<typeof UserProfilePopup>>()
function openUser(e: MouseEvent, m: any) {
  const uid = String(m.user_id)
  const fallbackName = m.name || `用户${uid}`
  userProfileRef.value?.open(e.clientX, e.clientY, uid, fallbackName, m.avatar || '')
}

// ─── 分享对话框 ───────────────────────────────────────────────
const shareShow = ref(false)

onMounted(() => {
  loadMembers(true)
})

watch(
  () => props.chatId,
  () => {
    currentView.value = 'main'
    loadMembers(true)
  },
)
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
.profile-title { flex: 1; }
.back-btn {
  background: none;
  border: none;
  font-size: 18px;
  cursor: pointer;
  padding: 2px 6px;
  color: #666;
}
.close-btn {
  background: none;
  border: none;
  font-size: 16px;
  cursor: pointer;
  color: #999;
  padding: 2px 6px;
}
.close-btn:hover { color: #333; }
.profile-body {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
}

/* 群信息头部 */
.info-header {
  display: flex;
  align-items: center;
  gap: 12px;
  background: #fff;
  border-radius: 8px;
  padding: 12px;
  margin-bottom: 8px;
}
.avatar-wrap { position: relative; cursor: pointer; flex-shrink: 0; }
.avatar-placeholder {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: #1976d2;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  font-weight: 500;
  overflow: hidden;
}
.avatar-placeholder img { width: 100%; height: 100%; object-fit: cover; }
.avatar-edit {
  position: absolute;
  right: -2px;
  bottom: 0;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  background: #4a6cf7;
  color: #fff;
  font-size: 11px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid #fff;
}
.info-main { flex: 1; min-width: 0; }
.info-name { font-size: 16px; font-weight: 500; color: #333; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.info-desc { font-size: 12px; color: #8f959e; margin-top: 2px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.header-icon-btn {
  background: none;
  border: none;
  cursor: pointer;
  color: #8f959e;
  padding: 4px;
  border-radius: 4px;
  display: flex;
  align-items: center;
  flex-shrink: 0;
}
.header-icon-btn:hover { background: #f0f0f0; color: #333; }

/* 扁平设置行 */
.setting-tile {
  display: flex;
  align-items: center;
  gap: 12px;
  background: #fff;
  border-radius: 8px;
  padding: 12px;
  cursor: pointer;
  margin-bottom: 8px;
  transition: background 0.1s;
}
.setting-tile:hover { background: #f9fafb; }
.tile-icon { color: #2b5ced; flex-shrink: 0; }
.tile-text { flex: 1; min-width: 0; }
.tile-title { font-size: 14px; font-weight: 500; color: #333; }
.tile-subtitle { font-size: 12px; color: #8f959e; margin-top: 2px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.tile-value { font-size: 12px; color: #8f959e; flex-shrink: 0; }
.tile-chevron { color: #c0c4cc; flex-shrink: 0; }

/* 群成员搜索 + 头像网格 */
.members-section { background: #fff; border-radius: 8px; padding: 4px 12px 12px; margin-bottom: 8px; }
.member-search-box {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 7px 10px;
  background: #f5f5f5;
  border-radius: 6px;
  margin-bottom: 8px;
}
.member-search-input { flex: 1; border: none; background: transparent; font-size: 13px; outline: none; }
.member-avatars-loading { padding: 8px 0; font-size: 12px; color: #999; }
.member-avatars { display: flex; align-items: center; gap: 8px; }
.member-avatar-item {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: #1976d2;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 13px;
  font-weight: 500;
  overflow: hidden;
  cursor: pointer;
  flex-shrink: 0;
}
.member-avatar-item img { width: 100%; height: 100%; object-fit: cover; }
.member-add-btn {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  border: 1px solid #e0e0e0;
  background: #f5f5f5;
  color: #666;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  flex-shrink: 0;
}
.member-add-btn:hover { background: #eef3ff; color: #2b5ced; }

/* 危险区 */
.danger-zone { margin-top: 16px; display: flex; flex-direction: column; gap: 8px; margin-bottom: 24px; }
.danger-btn {
  width: 100%;
  padding: 10px;
  border-radius: 8px;
  font-size: 14px;
  cursor: pointer;
  background: #fff;
}
.danger-btn.transfer { border: 1px solid #e0e0e0; color: #2b5ced; }
.danger-btn.leave { border: 1px solid rgba(244, 67, 54, 0.5); color: #f44336; }
.danger-btn:hover { background: #fcfcfc; }

/* modals */
.confirm-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 20011;
}
.confirm-dialog {
  background: #fff;
  border-radius: 12px;
  padding: 24px;
  width: 320px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
}
.confirm-title { font-size: 16px; font-weight: 500; margin-bottom: 8px; }
.confirm-text { font-size: 14px; color: #666; margin-bottom: 20px; }
.confirm-actions { display: flex; justify-content: flex-end; gap: 8px; }
.confirm-btn { padding: 8px 20px; border: none; border-radius: 6px; font-size: 13px; cursor: pointer; }
.confirm-btn.cancel { background: #f0f0f0; color: #333; }
.confirm-btn.ok { background: #f44336; color: #fff; }
.confirm-btn.ok:hover { background: #d32f2f; }
</style>