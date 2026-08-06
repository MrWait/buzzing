<template>
  <div class="gm-panel">
    <div class="gm-body">
      <!-- 群权限 -->
      <div class="gm-section-title">群权限</div>
      <div class="gm-card">
        <div class="gm-card-inner">
          <div class="mute-tile" :class="{ on: globalMuted }" @click="toggleGlobalMute">
            <div class="mute-checkbox" :class="{ checked: globalMuted }">
              <svg v-if="globalMuted" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
            </div>
            <div class="mute-info">
              <div class="mute-title">全员禁言</div>
              <div class="mute-desc">{{ globalMuted ? '已开启' : '已关闭' }}</div>
            </div>
          </div>

          <div class="gm-divider"></div>

          <div class="join-mode-tile">
            <div class="jm-label">入群方式</div>
            <select class="jm-select" :value="joinMode" @change="onJoinModeChange($event)">
              <option :value="0">允许任何人</option>
              <option :value="1">需要审核</option>
              <option :value="2">禁止加入</option>
            </select>
          </div>
        </div>
      </div>

      <!-- 管理员设置 -->
      <div class="gm-section-title">管理员设置</div>
      <div class="gm-card">
        <div v-if="loadingAdmins" class="gm-loading">加载中...</div>
        <template v-else>
          <div v-if="admins.length === 0" class="gm-empty-row">
            <svg class="gm-empty-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#4a6cf7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3l1.9 5.7 6 0-4.8 3.5 1.8 5.8-4.9-3.6-4.9 3.6 1.8-5.8-4.8-3.5 6 0z"/></svg>
            <div class="gm-empty-info">
              <div class="gm-empty-title">暂无管理员</div>
              <div class="gm-empty-desc">群主可添加管理员协助管理群聊</div>
            </div>
            <button v-if="isOwner" class="gm-add-btn" title="添加管理员" @click="openAddAdmin">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#666" stroke-width="2" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            </button>
          </div>
          <template v-else>
            <div v-for="admin in admins" :key="String(admin.user_id)" class="gm-admin-row">
              <div class="gm-admin-avatar" :style="{ background: avatarColor(admin.name || '') }">
                {{ (admin.name || 'A').charAt(0) }}
              </div>
              <span class="gm-admin-name">{{ admin.name || `用户${admin.user_id}` }}</span>
              <button v-if="isOwner" class="gm-remove-btn" title="移除管理员" @click="removeAdmin(admin)">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#999" stroke-width="2" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
              </button>
            </div>
            <div v-if="isOwner" class="gm-add-admin-row" @click="openAddAdmin">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#4a6cf7" stroke-width="2" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
              <span>添加管理员</span>
            </div>
          </template>
        </template>
      </div>
    </div>

    <!-- 添加管理员选人 -->
    <MemberPicker :show="pickerShow" :exclude-ids="excludeForPicker" @confirm="onAddAdmin" @close="pickerShow = false" />

    <!-- 移除管理员确认 -->
    <Teleport to="body">
      <div v-if="removeTarget" class="gm-confirm-overlay" @click.self="removeTarget = null">
        <div class="gm-confirm-dialog">
          <div class="gm-confirm-title">移除管理员</div>
          <div class="gm-confirm-text">确定要将「{{ removeTarget.name }}」移出管理员吗？</div>
          <div class="gm-confirm-actions">
            <button class="btn btn-cancel" @click="removeTarget = null">取消</button>
            <button class="btn btn-danger" @click="confirmRemoveAdmin">移除</button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useImStore } from '@/stores/im'
import { useAuthStore } from '@/stores/auth'
import MemberPicker from './MemberPicker.vue'

const props = defineProps<{ chatId: string }>()

const im = useImStore()
const auth = useAuthStore()

const chat = computed(() => im.chats.get(props.chatId))
const myId = computed(() => String(auth.user?.id ?? ''))
const isOwner = computed(() => chat.value?.ownerId === myId.value)

const globalMuted = ref(false)
const joinMode = ref(0)

const admins = ref<any[]>([])
const loadingAdmins = ref(false)

const pickerShow = ref(false)
const removeTarget = ref<any>(null)

const excludeForPicker = computed(() => {
  const ids: string[] = [...(chat.value?.adminIds || [])]
  if (myId.value && !ids.includes(myId.value)) ids.push(myId.value)
  return ids
})

const joinLabels = ['允许任何人', '需要审核', '禁止加入']

onMounted(async () => {
  const chatData = chat.value
  if (chatData) {
    joinMode.value = chatData.joinMode ?? 0
  }
  const until = chatData?.globalMuteUntil || 0
  globalMuted.value = until > 0 && until > Date.now()
  await loadAdmins()
})

async function loadAdmins() {
  loadingAdmins.value = true
  const chatData = chat.value
  const resp = await im.getMembers(props.chatId, 1, 200)
  const adminIdSet = new Set(chatData?.adminIds || [])
  admins.value = (resp?.members || []).filter((m: any) => adminIdSet.has(String(m.user_id)))
  loadingAdmins.value = false
}

async function toggleGlobalMute() {
  const on = !globalMuted.value
  const untilMs = on ? Date.now() + 86400000 * 365 : 0
  await im.globalMute(props.chatId, untilMs)
  globalMuted.value = on
}

async function onJoinModeChange(e: Event) {
  const mode = Number((e.target as HTMLSelectElement).value)
  await im.updateChat(props.chatId, { join_mode: mode })
  joinMode.value = mode
}

function openAddAdmin() {
  pickerShow.value = true
}

async function onAddAdmin(ids: string[]) {
  const resp = await im.getMembers(props.chatId, 1, 200)
  const members = resp?.members || []
  const added = members.filter((m: any) => ids.includes(String(m.user_id)))
  await im.updateChat(props.chatId, { admin_ids_add: ids })
  const adminIdSet = new Set<string>([...(chat.value?.adminIds || []), ...ids])
  admins.value = members.filter((m: any) => adminIdSet.has(String(m.user_id)))
  if (added.length) {
    admins.value = [...added, ...admins.value.filter((m: any) => !ids.includes(String(m.user_id)))]
  }
}

function removeAdmin(admin: any) {
  removeTarget.value = admin
}

async function confirmRemoveAdmin() {
  const target = removeTarget.value
  removeTarget.value = null
  if (!target) return
  await im.updateChat(props.chatId, { admin_ids_remove: [String(target.user_id)] })
  await loadAdmins()
}

function avatarColor(name: string): string {
  const colors = ['#4a6cf7', '#f56c6c', '#67c23a', '#e6a23c', '#909399', '#409eff']
  let hash = 0
  for (let i = 0; i < name.length; i++) hash = name.charCodeAt(i) + ((hash << 5) - hash)
  return colors[Math.abs(hash) % colors.length]
}
</script>

<style scoped>
.gm-panel { display: flex; flex-direction: column; height: 100%; }
.gm-body { flex: 1; overflow-y: auto; padding: 16px; }
.gm-section-title {
  font-size: 14px;
  font-weight: 600;
  color: #333;
  margin-bottom: 8px;
}
.gm-card {
  background: #fff;
  border-radius: 8px;
  overflow: hidden;
  margin-bottom: 16px;
}
.gm-card-inner { padding: 4px 16px; }
.mute-tile {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 0;
  cursor: pointer;
  user-select: none;
}
.mute-checkbox {
  width: 18px;
  height: 18px;
  border: 2px solid #d0d0d0;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: all 0.15s;
}
.mute-checkbox.checked { background: #2b5ced; border-color: #2b5ced; }
.mute-info { flex: 1; }
.mute-title { font-size: 14px; font-weight: 500; color: #333; }
.mute-desc { font-size: 12px; color: #8f959e; margin-top: 2px; }
.gm-divider { height: 1px; background: #f0f0f0; }
.join-mode-tile { padding: 12px 0; }
.jm-label { font-size: 14px; font-weight: 500; color: #333; margin-bottom: 8px; }
.jm-select {
  width: 100%;
  border: 1px solid #ddd;
  border-radius: 6px;
  padding: 7px 10px;
  font-size: 13px;
  outline: none;
  background: #fff;
}
.jm-select:focus { border-color: #2b5ced; }
.gm-loading { padding: 20px; text-align: center; color: #999; font-size: 13px; }
.gm-empty-row { display: flex; align-items: center; gap: 20px; padding: 14px 16px; }
.gm-empty-icon { flex-shrink: 0; }
.gm-empty-info { flex: 1; }
.gm-empty-title { font-size: 14px; font-weight: 500; color: #333; }
.gm-empty-desc { font-size: 12px; color: #8f959e; margin-top: 2px; }
.gm-add-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  display: flex;
  align-items: center;
  color: #666;
}
.gm-add-btn:hover { background: #f0f0f0; }
.gm-admin-row {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 11px 16px;
}
.gm-admin-avatar {
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
}
.gm-admin-name { flex: 1; font-size: 14px; color: #333; }
.gm-remove-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  color: #999;
  display: flex;
  align-items: center;
}
.gm-remove-btn:hover { background: #f5f5f5; color: #f44336; }
.gm-add-admin-row {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px 16px;
  cursor: pointer;
  color: #2b5ced;
  font-size: 14px;
  border-top: 1px solid #f5f5f5;
}
.gm-add-admin-row:hover { background: #f7f9ff; }
.gm-confirm-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}
.gm-confirm-dialog { background: #fff; border-radius: 12px; padding: 24px; width: 320px; box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15); }
.gm-confirm-title { font-size: 16px; font-weight: 500; margin-bottom: 8px; }
.gm-confirm-text { font-size: 14px; color: #666; margin-bottom: 20px; }
.gm-confirm-actions { display: flex; justify-content: flex-end; gap: 8px; }
.btn { padding: 8px 20px; border-radius: 6px; font-size: 13px; cursor: pointer; border: 1px solid transparent; transition: all 0.15s; }
.btn-cancel { background: #f0f0f0; color: #333; }
.btn-cancel:hover { background: #e0e0e0; }
.btn-danger { background: #f44336; color: #fff; }
.btn-danger:hover { background: #d32f2f; }
</style>