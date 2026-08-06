<template>
  <div class="ml-panel">
    <div class="ml-toolbar">
      <div class="ml-search-box">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#999" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        <input v-model="keyword" class="ml-search-input" placeholder="搜索成员" @input="loadMembers(true)" />
      </div>
      <button v-if="canEdit" class="ml-add-btn" title="添加成员" @click="pickerShow = true">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#666" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14M5 12h14"/></svg>
      </button>
    </div>

    <div v-if="loading" class="ml-state">加载中...</div>
    <div v-else-if="members.length === 0" class="ml-state">暂无成员</div>
    <div v-else class="ml-list">
      <div v-for="m in members" :key="String(m.user_id)" class="ml-item">
        <div class="ml-avatar js-profile-open" :style="{ background: avatarColor(m.name || '') }" @click="openUser($event, m)">
          {{ (m.name || '?').charAt(0) }}
        </div>
        <div class="ml-info">
          <span class="ml-name">{{ m.name || `用户${m.user_id}` }}</span>
          <span v-if="String(m.user_id) === chat?.ownerId" class="ml-tag owner">群主</span>
          <span v-else-if="chat?.adminIds.includes(String(m.user_id))" class="ml-tag admin">管理员</span>
        </div>
        <div v-if="canAct(m)" class="ml-menu" @click.stop>
          <button class="ml-menu-btn" @click="openMenu($event, m)">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><circle cx="5" cy="12" r="1.6"/><circle cx="12" cy="12" r="1.6"/><circle cx="19" cy="12" r="1.6"/></svg>
          </button>
        </div>
      </div>
    </div>

    <!-- 添加成员选人 -->
    <MemberPicker :show="pickerShow" :exclude-ids="excludeForPicker" title="添加成员" @confirm="onAddMembers" @close="pickerShow = false" />

    <!-- 成员操作菜单 -->
    <Teleport to="body">
      <div v-if="menuMember" class="ml-menu-overlay" @click="menuMember = null"></div>
      <div v-if="menuMember" class="ml-menu-pop" :style="{ left: menuLeft + 'px', top: menuTop + 'px' }">
        <div v-if="isOwner && !isItemAdmin(menuMember) && !isItemOwner(menuMember)" class="ml-menu-item" @click="setAdmin(menuMember)">设为管理员</div>
        <div v-if="isOwner && isItemAdmin(menuMember)" class="ml-menu-item" @click="removeAdmin(menuMember)">移除管理员</div>
        <div v-if="isOwner && !isItemOwner(menuMember)" class="ml-menu-item" @click="transferOwner(menuMember)">转让群主</div>
        <div v-if="canEdit && !isItemOwner(menuMember)" class="ml-menu-item" @click="showMutePicker(menuMember)">禁言</div>
        <div v-if="canEdit && !isItemOwner(menuMember)" class="ml-menu-item danger" @click="kick(menuMember)">移出群聊</div>
      </div>
    </Teleport>

    <!-- 禁言时长选择 -->
    <Teleport to="body">
      <div v-if="muteMemberTarget" class="ml-confirm-overlay" @click.self="muteMemberTarget = null">
        <div class="ml-confirm-dialog">
          <div class="ml-confirm-title">选择禁言时长</div>
          <div class="ml-duration-list">
            <div class="ml-duration-item" @click="muteMember(muteMemberTarget, 3600000)">1小时</div>
            <div class="ml-duration-item" @click="muteMember(muteMemberTarget, 86400000)">24小时</div>
            <div class="ml-duration-item" @click="muteMember(muteMemberTarget, 604800000)">7天</div>
            <div class="ml-duration-item" @click="muteMember(muteMemberTarget, 2592000000)">30天</div>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- 转让/移出 确认（复用一个通用确认框） -->
    <Teleport to="body">
      <div v-if="confirmTarget" class="ml-confirm-overlay" @click.self="confirmTarget = null">
        <div class="ml-confirm-dialog">
          <div class="ml-confirm-title">{{ confirmTarget.title }}</div>
          <div class="ml-confirm-text">{{ confirmTarget.text }}</div>
          <div class="ml-confirm-actions">
            <button class="btn btn-cancel" @click="confirmTarget = null">取消</button>
            <button :class="['btn', confirmTarget.danger ? 'btn-danger' : 'btn-primary']" @click="execConfirm">{{ confirmTarget.okText }}</button>
          </div>
        </div>
      </div>
    </Teleport>

    <UserProfilePopup ref="userProfileRef" />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useImStore } from '@/stores/im'
import { useAuthStore } from '@/stores/auth'
import MemberPicker from './MemberPicker.vue'
import UserProfilePopup from '@/components/UserProfilePopup.vue'

const props = defineProps<{ chatId: string }>()

const im = useImStore()
const auth = useAuthStore()

const chat = computed(() => im.chats.get(props.chatId))
const myId = computed(() => String(auth.user?.id ?? ''))
const isOwner = computed(() => chat.value?.ownerId === myId.value)
const isAdmin = computed(() => chat.value?.adminIds.includes(myId.value) ?? false)
const canEdit = computed(() => isOwner.value || isAdmin.value)

const keyword = ref('')
const members = ref<any[]>([])
const loading = ref(false)
const pickerShow = ref(false)
const menuMember = ref<any>(null)
const menuLeft = ref(0)
const menuTop = ref(0)
const muteMemberTarget = ref<any>(null)
const confirmTarget = ref<{ title: string; text: string; okText: string; danger: boolean; fn: () => void } | null>(null)
const userProfileRef = ref<InstanceType<typeof UserProfilePopup>>()

const excludeForPicker = computed(() => {
  const ids = (chat.value?.memberIds || []).map(String)
  if (myId.value && !ids.includes(myId.value)) ids.push(myId.value)
  return ids
})

onMounted(() => {
  loadMembers(true)
})

async function loadMembers(reset = false) {
  loading.value = true
  const resp = await im.getMembers(props.chatId, 1, 200, keyword.value.trim())
  if (reset) {
    members.value = resp?.members || []
  } else {
    members.value.push(...(resp?.members || []))
  }
  loading.value = false
}

function canAct(m: any) {
  const mid = String(m.user_id)
  return canEdit.value && mid !== myId.value
}

function isItemOwner(m: any) {
  return String(m.user_id) === chat.value?.ownerId
}

function isItemAdmin(m: any) {
  return chat.value?.adminIds.includes(String(m.user_id)) ?? false
}

function openMenu(e: MouseEvent, m: any) {
  menuMember.value = m
  const rect = (e.target as HTMLElement).closest('.ml-menu-btn')?.getBoundingClientRect()
  menuLeft.value = rect ? rect.left - 120 : e.clientX - 120
  menuTop.value = rect ? rect.bottom + 4 : e.clientY + 4
}

function openUser(e: MouseEvent, m: any) {
  const uid = String(m.user_id)
  const fallbackName = m.name || `用户${uid}`
  userProfileRef.value?.open(e.clientX, e.clientY, uid, fallbackName, m.avatar || '')
}

async function onAddMembers(ids: string[]) {
  await im.addChatters(props.chatId, ids)
  await loadMembers(true)
}

async function setAdmin(m: any) {
  menuMember.value = null
  await im.updateChat(props.chatId, { admin_ids_add: [String(m.user_id)] })
}

async function removeAdmin(m: any) {
  menuMember.value = null
  await im.updateChat(props.chatId, { admin_ids_remove: [String(m.user_id)] })
}

function transferOwner(m: any) {
  menuMember.value = null
  confirmTarget.value = {
    title: '转让群主',
    text: `确定要将群主转让给「${m.name}」吗？`,
    okText: '确定',
    danger: false,
    fn: async () => {
      await im.updateChat(props.chatId, { owner_id: String(m.user_id) })
    },
  }
}

function kick(m: any) {
  menuMember.value = null
  confirmTarget.value = {
    title: '移出群聊',
    text: `确定要将「${m.name}」移出群聊吗？`,
    okText: '移出',
    danger: true,
    fn: async () => {
      await im.removeChatters(props.chatId, [String(m.user_id)])
      await loadMembers(true)
    },
  }
}

function showMutePicker(m: any) {
  menuMember.value = null
  muteMemberTarget.value = m
}

async function muteMember(m: any, durationMs: number) {
  muteMemberTarget.value = null
  await im.muteMember(props.chatId, String(m.user_id), Date.now() + durationMs)
}

function execConfirm() {
  const target = confirmTarget.value
  confirmTarget.value = null
  if (target) target.fn()
}

function avatarColor(name: string): string {
  const colors = ['#4a6cf7', '#f56c6c', '#67c23a', '#e6a23c', '#909399', '#409eff']
  let hash = 0
  for (let i = 0; i < name.length; i++) hash = name.charCodeAt(i) + ((hash << 5) - hash)
  return colors[Math.abs(hash) % colors.length]
}
</script>

<style scoped>
.ml-panel { flex: 1; overflow-y: auto; background: #fff; }
.ml-toolbar {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 12px;
  border-bottom: 1px solid #f0f0f0;
  position: sticky;
  top: 0;
  background: #fff;
  z-index: 1;
}
.ml-search-box {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 7px 10px;
  background: #f5f5f5;
  border-radius: 6px;
}
.ml-search-input { flex: 1; border: none; background: transparent; font-size: 13px; outline: none; }
.ml-add-btn {
  background: none;
  border: 1px solid #ddd;
  border-radius: 6px;
  cursor: pointer;
  padding: 6px;
  display: flex;
  align-items: center;
  color: #666;
}
.ml-add-btn:hover { background: #f0f6ff; color: #2b5ced; }
.ml-state { padding: 40px 16px; text-align: center; color: #999; font-size: 13px; }
.ml-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 11px 16px;
  border-bottom: 1px solid #f5f5f5;
}
.ml-item:hover { background: #fafafa; }
.ml-avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 13px;
  font-weight: 600;
  flex-shrink: 0;
  cursor: pointer;
}
.ml-info { flex: 1; min-width: 0; display: flex; align-items: center; gap: 6px; }
.ml-name { font-size: 14px; color: #333; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.ml-tag { font-size: 10px; padding: 1px 4px; border-radius: 3px; flex-shrink: 0; }
.ml-tag.owner { background: #fff3e0; color: #e65100; }
.ml-tag.admin { background: #e3f2fd; color: #1565c0; }
.ml-menu { flex-shrink: 0; }
.ml-menu-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  color: #999;
  display: flex;
  align-items: center;
}
.ml-menu-btn:hover { background: #f0f0f0; color: #333; }
.ml-menu-overlay { position: fixed; inset: 0; z-index: 20001; }
.ml-menu-pop {
  position: fixed;
  z-index: 20002;
  min-width: 160px;
  background: #fff;
  border: 1px solid #e8e8e8;
  border-radius: 8px;
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.14);
  padding: 6px 0;
}
.ml-menu-item { padding: 10px 16px; font-size: 13px; color: #333; cursor: pointer; }
.ml-menu-item:hover { background: #f5f5f5; }
.ml-menu-item.danger { color: #f44336; }
.ml-confirm-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 20003;
}
.ml-confirm-dialog { background: #fff; border-radius: 12px; padding: 24px; width: 320px; box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15); }
.ml-confirm-title { font-size: 16px; font-weight: 500; margin-bottom: 8px; }
.ml-confirm-text { font-size: 14px; color: #666; margin-bottom: 20px; }
.ml-confirm-actions { display: flex; justify-content: flex-end; gap: 8px; }
.ml-duration-list { display: flex; flex-direction: column; }
.ml-duration-item { padding: 12px 8px; font-size: 14px; color: #333; cursor: pointer; border-radius: 4px; }
.ml-duration-item:hover { background: #f5f5f5; }
.btn { padding: 8px 20px; border-radius: 6px; font-size: 13px; cursor: pointer; border: 1px solid transparent; transition: all 0.15s; }
.btn-cancel { background: #f0f0f0; color: #333; }
.btn-cancel:hover { background: #e0e0e0; }
.btn-primary { background: #2b5ced; color: #fff; }
.btn-primary:hover { background: #1a4ed8; }
.btn-danger { background: #f44336; color: #fff; }
.btn-danger:hover { background: #d32f2f; }
</style>