<template>
  <Teleport to="body">
    <div v-if="show" class="dialog-overlay" @click.self="onClose">
      <div class="create-chat-dialog">
        <div class="dialog-header">
          <span class="dialog-title">{{ props.mode === 'group' ? '创建群聊' : '创建单聊' }}</span>
          <button class="close-btn" @click="onClose">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
          </button>
        </div>

        <div class="dialog-body">
          <!-- 左侧：联系人列表 -->
          <div class="left-panel">
            <div class="search-box">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#999" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
              <input v-model="searchText" class="search-input" placeholder="搜索联系人" />
            </div>

            <div class="breadcrumb-bar">
              <template v-for="(label, i) in breadcrumbLabels" :key="i">
                <span v-if="i > 0" class="breadcrumb-sep">
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#999" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                </span>
                <span :class="['breadcrumb-item', { last: i === breadcrumbLabels.length - 1 }]" @click="onBreadcrumbClick(i)">
                  {{ label }}
                </span>
              </template>
            </div>

            <div class="contact-list">
              <div v-if="loading" class="state-text">加载中...</div>
              <template v-else>
                <div v-for="dept in currentDepts" :key="dept.id" class="row dept-row" @click="enterDept(dept)">
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#999" stroke-width="1.8" stroke-linecap="round"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
                  <span class="row-name">{{ dept.name }}</span>
                  <span class="row-count">{{ dept.memberIds.length }}</span>
                </div>
                <div v-for="user in filteredUsers" :key="user.id" class="row user-row" @click="toggleUser(user)">
                  <div class="checkbox" :class="{ checked: selectedIds.has(user.id) }" @click.stop="toggleUser(user)">
                    <svg v-if="selectedIds.has(user.id)" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                  </div>
                  <div class="user-avatar" :style="{ background: avatarColor(user.name) }">
                    {{ user.name.charAt(0) }}
                  </div>
                  <div class="user-info">
                    <div class="user-name">{{ user.name }}</div>
                    <div class="user-dept">{{ currentDeptLabel }}</div>
                  </div>
                </div>
              </template>
              <div v-if="!loading && currentDepts.length === 0 && filteredUsers.length === 0" class="state-text">暂无数据</div>
            </div>
          </div>

          <!-- 右侧：已选成员 -->
          <div class="right-panel">
            <div class="selected-header">已选 {{ selectedIds.size }} 人</div>
            <div class="selected-list">
              <div v-for="user in selectedUsers" :key="user.id" class="selected-item" @click="toggleUser(user)">
                <div class="selected-avatar" :style="{ background: avatarColor(user.name) }">
                  {{ user.name.charAt(0) }}
                </div>
                <div class="selected-name">{{ user.name }}</div>
                <button class="remove-btn" @click.stop="toggleUser(user)">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#999" stroke-width="2" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                </button>
              </div>
            </div>
            <div v-if="selectedIds.size === 0" class="selected-empty">选择联系人或部门中的成员</div>
          </div>
        </div>

        <!-- 底部操作栏 -->
        <div class="dialog-footer">
          <div v-if="props.mode === 'group' && selectedIds.size >= 2" class="group-name-box">
            <input v-model="groupName" class="group-name-input" placeholder="群名称（选填）" />
          </div>
          <div class="footer-actions">
            <button class="btn btn-cancel" @click="onClose">取消</button>
            <button
              v-if="props.mode === 'p2p' && selectedIds.size === 1"
              class="btn btn-primary"
              @click="onStartChat"
            >发起对话</button>
            <button
              v-if="props.mode === 'group' && selectedIds.size >= 2"
              class="btn btn-primary"
              @click="onCreateGroup"
            >创建群聊</button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useImStore } from '@/stores/im'
import { getDeptById } from '@/services/im/contacts'
import type { DeptInfo, UserInfo } from '@/services/im/contacts'

const props = defineProps<{ show: boolean; mode?: 'p2p' | 'group' }>()
const emit = defineEmits<{ close: [] }>()

const router = useRouter()
const auth = useAuthStore()
const im = useImStore()

const searchText = ref('')
const loading = ref(false)
const navPath = ref<{ id: number; name: string }[]>([])
const currentDepts = ref<DeptInfo[]>([])
const currentUsers = ref<UserInfo[]>([])
const deptCache = new Map<number, DeptInfo>()
const currentDeptId = ref(0)
const selectedIds = ref<Set<number>>(new Set())
const selectedUsersMap = ref<Map<number, UserInfo>>(new Map())
const groupName = ref('')

const tenantName = computed(() => auth.currentTenant?.name || '组织架构')

const breadcrumbLabels = computed(() => {
  const labels = ['组织架构', tenantName.value]
  for (const n of navPath.value) labels.push(n.name)
  return labels
})

const currentDeptLabel = computed(() => {
  if (navPath.value.length > 0) {
    return navPath.value[navPath.value.length - 1].name
  }
  return tenantName.value
})

const filteredUsers = computed(() => {
  const q = searchText.value.trim().toLowerCase()
  if (!q) return currentUsers.value
  return currentUsers.value.filter(u => u.name.toLowerCase().includes(q))
})

const selectedUsers = computed(() => {
  return Array.from(selectedIds.value).map(id => selectedUsersMap.value.get(id)).filter(Boolean) as UserInfo[]
})

function avatarColor(name: string): string {
  const colors = ['#4a6cf7', '#f56c6c', '#67c23a', '#e6a23c', '#909399', '#409eff']
  let hash = 0
  for (let i = 0; i < name.length; i++) hash = name.charCodeAt(i) + ((hash << 5) - hash)
  return colors[Math.abs(hash) % colors.length]
}

function toggleUser(user: UserInfo) {
  if (selectedIds.value.has(user.id)) {
    selectedIds.value.delete(user.id)
    selectedUsersMap.value.delete(user.id)
  } else {
    selectedIds.value.add(user.id)
    selectedUsersMap.value.set(user.id, user)
  }
}

async function enterRoot() {
  navPath.value = []
  currentDeptId.value = 0
  await navigateTo(0)
}

async function enterDept(dept: DeptInfo) {
  const existing = navPath.value.findIndex(n => n.id === dept.id)
  if (existing >= 0) {
    while (navPath.value.length > existing + 1) navPath.value.pop()
  } else {
    navPath.value.push({ id: dept.id, name: dept.name })
  }
  currentDeptId.value = dept.id
  await navigateTo(dept.id)
}

async function navigateTo(deptId: number) {
  loading.value = true
  try {
    const tenant = auth.currentTenant
    const fetchId = deptId === 0 && tenant ? 0 : deptId
    const resp = await getDeptById(fetchId, tenant ? tenant.id : undefined)
    for (const d of resp.departments) deptCache.set(d.id, d)
    if (deptId === 0) {
      currentDepts.value = resp.departments
    } else {
      const currentDept = deptCache.get(deptId)
      if (currentDept) {
        const subIds = new Set(currentDept.subDepartmentIds)
        currentDepts.value = resp.departments.filter(d => subIds.has(d.id))
      } else {
        currentDepts.value = resp.departments
      }
    }
    currentUsers.value = resp.users.sort((a, b) => a.name.localeCompare(b.name))
  } catch (e) {
    console.error('[create-chat] navigate error:', e)
  } finally {
    loading.value = false
  }
}

function onBreadcrumbClick(index: number) {
  if (index <= 1) {
    navPath.value = []
    currentDeptId.value = 0
    navigateTo(0)
    return
  }
  const targetIdx = index - 2
  if (targetIdx >= navPath.value.length) return
  while (navPath.value.length > targetIdx + 1) navPath.value.pop()
  const target = navPath.value[navPath.value.length - 1]
  currentDeptId.value = target.id
  navigateTo(target.id)
}

async function onStartChat() {
  const ids = Array.from(selectedIds.value)
  if (ids.length !== 1) return
  const myUserId = String(auth.user?.id ?? '')
  const peerUserId = String(ids[0])
  const chatId = await im.createP2pChat(myUserId, peerUserId)
  if (chatId) {
    im.selectChat(chatId)
    router.push({ name: 'ImChatMain' })
    onClose()
  }
}

async function onCreateGroup() {
  const ids = Array.from(selectedIds.value)
  if (ids.length < 2) return
  const myUserId = String(auth.user?.id ?? '')
  const name = groupName.value.trim() || ''
  const chatId = await im.createGroupChat(myUserId, name, ids.map(String))
  if (chatId) {
    im.selectChat(chatId)
    router.push({ name: 'ImChatMain' })
    onClose()
  }
}

function onClose() {
  selectedIds.value = new Set()
  selectedUsersMap.value = new Map()
  groupName.value = ''
  searchText.value = ''
  emit('close')
}

watch(() => props.show, (val) => {
  if (val) {
    enterRoot()
  }
})

onMounted(() => {
  if (props.show) enterRoot()
})
</script>

<style scoped>
.dialog-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.35);
  z-index: 10000;
  display: flex;
  align-items: center;
  justify-content: center;
}

.create-chat-dialog {
  width: 680px;
  height: 520px;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 12px 48px rgba(0,0,0,0.25);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.dialog-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 20px;
  border-bottom: 1px solid #e8e8e8;
  flex-shrink: 0;
}

.dialog-title {
  font-size: 15px;
  font-weight: 600;
  color: #333;
}

.close-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  color: #999;
  display: flex;
  align-items: center;
}
.close-btn:hover { background: #f0f0f0; color: #333; }

.dialog-body {
  flex: 1;
  display: flex;
  overflow: hidden;
}

.left-panel {
  flex: 1;
  display: flex;
  flex-direction: column;
  border-right: 1px solid #e8e8e8;
}

.search-box {
  display: flex;
  align-items: center;
  gap: 6px;
  margin: 12px 16px 8px;
  padding: 7px 10px;
  background: #f5f5f5;
  border-radius: 6px;
}

.search-input {
  flex: 1;
  border: none;
  background: transparent;
  font-size: 13px;
  outline: none;
}

.breadcrumb-bar {
  display: flex;
  align-items: center;
  height: 34px;
  padding: 0 16px;
  gap: 4px;
  flex-shrink: 0;
}

.breadcrumb-item {
  font-size: 12px;
  color: #666;
  cursor: pointer;
  white-space: nowrap;
}
.breadcrumb-item:hover { color: #333; }
.breadcrumb-item.last { color: #333; font-weight: 500; cursor: default; }
.breadcrumb-sep { display: flex; align-items: center; }

.contact-list {
  flex: 1;
  overflow-y: auto;
}

.state-text {
  padding: 60px 16px;
  text-align: center;
  color: #999;
  font-size: 13px;
}

.row {
  display: flex;
  align-items: center;
  padding: 9px 16px;
  cursor: pointer;
  transition: background 0.1s;
  gap: 10px;
}
.row:hover { background: #f5f5f5; }

.checkbox {
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
.checkbox.checked {
  background: #2b5ced;
  border-color: #2b5ced;
}

.user-avatar {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 600;
  flex-shrink: 0;
}

.user-info {
  flex: 1;
  min-width: 0;
}

.user-name {
  font-size: 14px;
  color: #333;
}

.user-dept {
  font-size: 11px;
  color: #999;
  margin-top: 1px;
}

.row-name {
  flex: 1;
  font-size: 14px;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.row-count {
  font-size: 11px;
  color: #999;
  flex-shrink: 0;
}

.right-panel {
  width: 200px;
  min-width: 200px;
  display: flex;
  flex-direction: column;
}

.selected-header {
  padding: 12px 16px 8px;
  font-size: 13px;
  font-weight: 500;
  color: #333;
}

.selected-list {
  flex: 1;
  overflow-y: auto;
  padding: 0 8px;
}

.selected-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px;
  border-radius: 6px;
  cursor: pointer;
  transition: background 0.1s;
}
.selected-item:hover { background: #f5f5f5; }

.selected-avatar {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 11px;
  font-weight: 600;
  flex-shrink: 0;
}

.selected-name {
  flex: 1;
  font-size: 13px;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.remove-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 2px;
  display: flex;
  align-items: center;
  flex-shrink: 0;
  opacity: 0;
  transition: opacity 0.15s;
}
.selected-item:hover .remove-btn { opacity: 1; }
.remove-btn:hover svg { stroke: #f44336; }

.selected-empty {
  padding: 40px 16px;
  text-align: center;
  color: #ccc;
  font-size: 12px;
}

.dialog-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 20px;
  border-top: 1px solid #e8e8e8;
  flex-shrink: 0;
}

.group-name-box {
  flex: 1;
  margin-right: 12px;
}

.group-name-input {
  width: 100%;
  padding: 7px 10px;
  border: 1px solid #e0e0e0;
  border-radius: 6px;
  font-size: 13px;
  outline: none;
}
.group-name-input:focus { border-color: #2b5ced; }

.footer-actions {
  display: flex;
  gap: 8px;
  flex-shrink: 0;
}

.btn {
  padding: 8px 20px;
  border-radius: 6px;
  font-size: 13px;
  cursor: pointer;
  border: 1px solid transparent;
  transition: all 0.15s;
}

.btn-cancel {
  background: #fff;
  border-color: #d0d0d0;
  color: #666;
}
.btn-cancel:hover { border-color: #999; color: #333; }

.btn-primary {
  background: #2b5ced;
  color: #fff;
  border-color: #2b5ced;
}
.btn-primary:hover { background: #1a4ed8; }
</style>
