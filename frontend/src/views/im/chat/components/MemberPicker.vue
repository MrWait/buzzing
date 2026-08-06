<template>
  <Teleport to="body">
    <div v-if="show" class="member-picker-overlay" @click.self="onClose">
      <div class="member-picker-dialog">
        <div class="mp-header">
          <span class="mp-title">{{ title }}</span>
          <button class="mp-close" @click="onClose">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
          </button>
        </div>

        <div class="mp-search-box">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#999" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
          <input v-model="searchText" class="mp-search-input" placeholder="搜索联系人" />
        </div>

        <div class="mp-breadcrumb">
          <template v-for="(label, i) in breadcrumbLabels" :key="i">
            <span v-if="i > 0" class="mp-breadcrumb-sep">
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#999" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
            </span>
            <span :class="['mp-breadcrumb-item', { last: i === breadcrumbLabels.length - 1 }]" @click="onBreadcrumbClick(i)">
              {{ label }}
            </span>
          </template>
        </div>

        <div class="mp-list">
          <div v-if="loading" class="mp-state">加载中...</div>
          <template v-else>
            <div v-for="dept in currentDepts" :key="dept.id" class="mp-row dept-row" @click="enterDept(dept)">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#999" stroke-width="1.8" stroke-linecap="round"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
              <span class="mp-row-name">{{ dept.name }}</span>
              <span class="mp-row-count">{{ dept.memberIds.length }}</span>
            </div>
            <div v-for="user in filteredUsers" :key="user.id" class="mp-row user-row" @click="toggleUser(user)">
              <div :class="['mp-checkbox', { checked: selectedIds.has(user.id) }]" @click.stop="toggleUser(user)">
                <svg v-if="selectedIds.has(user.id)" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
              </div>
              <div class="mp-avatar" :style="{ background: avatarColor(user.name) }">{{ user.name.charAt(0) }}</div>
              <div class="mp-user-info">
                <div class="mp-user-name">{{ user.name }}</div>
                <div v-if="user.deptName || currentDeptLabel" class="mp-user-dept">{{ user.deptName || currentDeptLabel }}</div>
              </div>
            </div>
          </template>
          <div v-if="!loading && currentDepts.length === 0 && filteredUsers.length === 0" class="mp-state">暂无数据</div>
        </div>

        <div class="mp-footer">
          <span v-if="selectedIds.size > 0" class="mp-selected-count">已选 {{ selectedIds.size }} 人</span>
          <div class="mp-footer-actions">
            <button class="btn btn-cancel" @click="onClose">取消</button>
            <button class="btn btn-primary" :disabled="selectedIds.size === 0" @click="onConfirm">确定</button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { getDeptById } from '@/services/im/contacts'
import type { DeptInfo, UserInfo } from '@/services/im/contacts'

const props = defineProps<{
  show: boolean
  title?: string
  // 需排除的用户 id（字符串），如已入群成员/现有管理员
  excludeIds?: string[]
}>()
const emit = defineEmits<{
  (e: 'close'): void
  (e: 'confirm', ids: string[]): void
}>()

const auth = useAuthStore()

const searchText = ref('')
const loading = ref(false)
const navPath = ref<{ id: number; name: string }[]>([])
const deptCache = new Map<number, DeptInfo>()
const currentDeptId = ref(0)
const currentDepts = ref<DeptInfo[]>([])
const currentUsers = ref<UserInfo[]>([])
const selectedIds = ref<Set<number>>(new Set())

const tenantName = computed(() => auth.currentTenant?.name || '组织架构')
const breadcrumbLabels = computed(() => {
  const labels = ['组织架构', tenantName.value]
  for (const n of navPath.value) labels.push(n.name)
  return labels
})
const currentDeptLabel = computed(() => {
  if (navPath.value.length > 0) return navPath.value[navPath.value.length - 1].name
  return tenantName.value
})

const excluded = computed(() => new Set(props.excludeIds || []))

const filteredUsers = computed(() => {
  const q = searchText.value.trim().toLowerCase()
  const base = currentUsers.value.filter((u) => !excluded.value.has(String(u.id)))
  if (!q) return base
  return base.filter((u) => u.name.toLowerCase().includes(q))
})

function avatarColor(name: string): string {
  const colors = ['#4a6cf7', '#f56c6c', '#67c23a', '#e6a23c', '#909399', '#409eff']
  let hash = 0
  for (let i = 0; i < name.length; i++) hash = name.charCodeAt(i) + ((hash << 5) - hash)
  return colors[Math.abs(hash) % colors.length]
}

function toggleUser(user: UserInfo) {
  if (excluded.value.has(String(user.id))) return
  if (selectedIds.value.has(user.id)) {
    selectedIds.value.delete(user.id)
  } else {
    selectedIds.value.add(user.id)
  }
}

async function enterRoot() {
  navPath.value = []
  currentDeptId.value = 0
  await navigateTo(0)
}

async function enterDept(dept: DeptInfo) {
  const existing = navPath.value.findIndex((n) => n.id === dept.id)
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
        currentDepts.value = resp.departments.filter((d) => subIds.has(d.id))
      } else {
        currentDepts.value = resp.departments
      }
    }
    currentUsers.value = resp.users.sort((a, b) => a.name.localeCompare(b.name))
  } catch (e) {
    console.error('[member-picker] navigate error:', e)
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

function onConfirm() {
  const ids = Array.from(selectedIds.value).map(String)
  emit('confirm', ids)
  onClose()
}

function onClose() {
  selectedIds.value = new Set()
  searchText.value = ''
  emit('close')
}

watch(
  () => props.show,
  (val) => {
    if (val) enterRoot()
  },
)
</script>

<style scoped>
.member-picker-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.35);
  z-index: 10000;
  display: flex;
  align-items: center;
  justify-content: center;
}
.member-picker-dialog {
  width: 520px;
  height: 440px;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 12px 48px rgba(0, 0, 0, 0.25);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.mp-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 20px;
  border-bottom: 1px solid #e8e8e8;
  flex-shrink: 0;
}
.mp-title { font-size: 15px; font-weight: 600; color: #333; }
.mp-close {
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  color: #999;
  display: flex;
  align-items: center;
}
.mp-close:hover { background: #f0f0f0; color: #333; }
.mp-search-box {
  display: flex;
  align-items: center;
  gap: 6px;
  margin: 12px 16px 4px;
  padding: 7px 10px;
  background: #f5f5f5;
  border-radius: 6px;
}
.mp-search-input {
  flex: 1;
  border: none;
  background: transparent;
  font-size: 13px;
  outline: none;
}
.mp-breadcrumb {
  display: flex;
  align-items: center;
  height: 34px;
  padding: 0 16px;
  gap: 4px;
  flex-shrink: 0;
}
.mp-breadcrumb-item { font-size: 12px; color: #666; cursor: pointer; white-space: nowrap; }
.mp-breadcrumb-item:hover { color: #333; }
.mp-breadcrumb-item.last { color: #333; font-weight: 500; cursor: default; }
.mp-breadcrumb-sep { display: flex; align-items: center; }
.mp-list { flex: 1; overflow-y: auto; }
.mp-state { padding: 40px 16px; text-align: center; color: #999; font-size: 13px; }
.mp-row {
  display: flex;
  align-items: center;
  padding: 9px 16px;
  cursor: pointer;
  transition: background 0.1s;
  gap: 10px;
}
.mp-row:hover { background: #f5f5f5; }
.mp-checkbox {
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
.mp-checkbox.checked { background: #2b5ced; border-color: #2b5ced; }
.mp-avatar {
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
.mp-user-info { flex: 1; min-width: 0; }
.mp-user-name { font-size: 14px; color: #333; }
.mp-user-dept { font-size: 11px; color: #999; margin-top: 1px; }
.mp-row-name { flex: 1; font-size: 14px; color: #333; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.mp-row-count { font-size: 11px; color: #999; flex-shrink: 0; }
.mp-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 20px;
  border-top: 1px solid #e8e8e8;
  flex-shrink: 0;
}
.mp-selected-count { font-size: 13px; color: #666; }
.mp-footer-actions { display: flex; gap: 8px; }
.btn { padding: 8px 20px; border-radius: 6px; font-size: 13px; cursor: pointer; border: 1px solid transparent; transition: all 0.15s; }
.btn-cancel { background: #fff; border-color: #d0d0d0; color: #666; }
.btn-cancel:hover { border-color: #999; color: #333; }
.btn-primary { background: #2b5ced; color: #fff; border-color: #2b5ced; }
.btn-primary:hover { background: #1a4ed8; }
.btn-primary:disabled { opacity: 0.5; cursor: not-allowed; }
</style>