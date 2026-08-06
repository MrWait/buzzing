<template>
  <div class="contacts-view">
    <!-- Left sidebar: search + categories -->
    <aside class="contacts-sidebar">
      <div class="sidebar-header">通讯录</div>
      <div class="sidebar-search">
        <svg class="search-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#999" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        <input v-model="searchText" class="search-input" placeholder="搜索" @input="onSearch" />
      </div>
      <div class="category-list">
        <div
          :class="['category-item', { active: activeCategory === 0 }]"
          @click="switchCategory(0)"
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
          <span>{{ tenantName }}</span>
        </div>
        <div
          :class="['category-item', { active: activeCategory === 1 }]"
          @click="switchCategory(1)"
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
          <span>常用联系人</span>
        </div>
        <div
          :class="['category-item', { active: activeCategory === 2 }]"
          @click="switchCategory(2)"
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
          <span>外部联系人</span>
        </div>
        <div
          :class="['category-item', { active: activeCategory === 3 }]"
          @click="switchCategory(3)"
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><line x1="20" y1="8" x2="20" y2="14"/><line x1="23" y1="11" x2="17" y2="11"/></svg>
          <span>新的好友</span>
        </div>
      </div>
    </aside>
    <!-- Right content -->
    <main class="contacts-content">
      <!-- Org tree mode -->
      <template v-if="activeCategory === 0">
        <div class="breadcrumb-bar">
          <template v-for="(label, i) in breadcrumbLabels" :key="i">
            <span
              v-if="i > 0"
              class="breadcrumb-sep"
            >
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#999" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
            </span>
            <span
              :class="['breadcrumb-item', { last: i === breadcrumbLabels.length - 1 }]"
              @click="onBreadcrumbClick(i)"
            >
              {{ label }}
            </span>
          </template>
        </div>
        <div class="org-list">
          <div v-if="loading" class="state-text">加载中...</div>
          <template v-else>
            <div
              v-for="dept in currentDepts"
              :key="dept.id"
              class="org-row dept-row"
              @click="enterDept(dept)"
            >
              <svg class="row-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#999" stroke-width="1.8" stroke-linecap="round"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
              <span class="row-name">{{ dept.name }}</span>
              <span class="row-count">{{ dept.memberIds.length }}人</span>
              <svg class="row-arrow" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#999" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
            </div>
            <div
              v-for="user in filteredUsers"
              :key="user.id"
              class="org-row user-row"
              @click="openUserProfile($event, user)"
            >
              <div class="user-avatar js-profile-open" :style="{ background: avatarColor(user.name) }" @click.stop="openUserProfile($event, user)">
                <img v-if="user.avatar" class="user-avatar-img" :src="user.avatar" />
                <span v-else>{{ user.name.charAt(0) }}</span>
              </div>
              <div class="user-info">
                <div class="user-name">{{ user.name }}</div>
                <div class="user-dept">{{ currentDeptName }}</div>
              </div>
              <span :class="['status-dot', { online: user.status === 1 }]" />
            </div>
          </template>
          <div v-if="!loading && currentDepts.length === 0 && filteredUsers.length === 0" class="state-text">暂无数据</div>
        </div>
      </template>
      <!-- Placeholder for other categories -->
      <div v-else class="placeholder-view">
        <div class="placeholder-text">{{ categoryPlaceholder }}</div>
      </div>
    </main>
  </div>

  <!-- 用户资料浮层 -->
  <UserProfilePopup ref="userProfileRef" />
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import UserProfilePopup from '@/components/UserProfilePopup.vue'
import { getDeptById } from '@/services/im/contacts'
import type { DeptInfo, UserInfo } from '@/services/im/contacts'

const auth = useAuthStore()

const tenantName = computed(() => auth.currentTenant?.name || '组织架构')

const activeCategory = ref(0)
const searchText = ref('')
const loading = ref(false)

const navPath = ref<{ id: number; name: string }[]>([])
const currentDepts = ref<DeptInfo[]>([])
const currentUsers = ref<UserInfo[]>([])
const deptCache = new Map<number, DeptInfo>()
const currentDeptId = ref(0)

const breadcrumbLabels = computed(() => {
  const labels = ['组织架构', tenantName.value]
  for (const n of navPath.value) {
    labels.push(n.name)
  }
  return labels
})

const currentDeptName = computed(() => {
  if (navPath.value.length > 0) {
    return navPath.value[navPath.value.length - 1].name
  }
  return tenantName.value
})

const filteredUsers = computed(() => {
  const q = searchText.value.trim().toLowerCase()
  if (!q) return currentUsers.value
  return currentUsers.value.filter((u) => u.name.toLowerCase().includes(q))
})

const categoryPlaceholder = computed(() => {
  const map = ['', '常用联系人功能开发中', '外部联系人功能开发中', '新的好友功能开发中']
  return map[activeCategory.value] || ''
})

function avatarColor(name: string): string {
  const colors = ['#4a6cf7', '#f56c6c', '#67c23a', '#e6a23c', '#909399', '#409eff']
  let hash = 0
  for (let i = 0; i < name.length; i++) {
    hash = name.charCodeAt(i) + ((hash << 5) - hash)
  }
  return colors[Math.abs(hash) % colors.length]
}

function switchCategory(mode: number) {
  activeCategory.value = mode
  searchText.value = ''
  if (mode === 0) {
    enterRoot()
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
    while (navPath.value.length > existing + 1) {
      navPath.value.pop()
    }
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
    for (const d of resp.departments) {
      deptCache.set(d.id, d)
    }
    // 只显示当前部门的子部门
    if (deptId === 0) {
      // root: filter top-level depts (parentId === 0 or the root department)
      // The API returns sub-departments of the root, which ARE the top-level ones
      currentDepts.value = resp.departments
    } else {
      // Filter: only show immediate children of current dept
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
    console.error('[contacts] navigate error:', e)
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
  while (navPath.value.length > targetIdx + 1) {
    navPath.value.pop()
  }
  const target = navPath.value[navPath.value.length - 1]
  currentDeptId.value = target.id
  navigateTo(target.id)
}

function onSearch() {
  // computed filteredUsers handles filtering
}

// 点击头像/整行：在点击位置弹用户资料浮层（用搜索结果同款浮层，统一交互）
const userProfileRef = ref<InstanceType<typeof UserProfilePopup>>()
function openUserProfile(e: MouseEvent, user: UserInfo) {
  userProfileRef.value?.open(e.clientX, e.clientY, String(user.id), user.name, user.avatar)
}

onMounted(() => {
  enterRoot()
})
</script>

<style scoped>
.contacts-view {
  display: flex;
  height: 100%;
  background: #fff;
}

/* ── Sidebar ── */
.contacts-sidebar {
  width: 220px;
  min-width: 220px;
  border-right: 1px solid #e8e8e8;
  display: flex;
  flex-direction: column;
  background: #f8f9fb;
}
.sidebar-header {
  padding: 16px 16px 8px;
  font-size: 14px;
  font-weight: 600;
  color: #333;
}
.sidebar-search {
  display: flex;
  align-items: center;
  gap: 6px;
  margin: 4px 12px 8px;
  padding: 6px 10px;
  background: #fff;
  border-radius: 6px;
  border: 1px solid #e0e0e0;
}
.search-icon {
  flex-shrink: 0;
}
.search-input {
  flex: 1;
  border: none;
  background: transparent;
  font-size: 13px;
  outline: none;
  padding: 0;
}
.category-list {
  flex: 1;
  padding: 0 8px;
}
.category-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 9px 10px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 13px;
  color: #333;
  transition: background 0.15s;
  margin-bottom: 2px;
}
.category-item:hover {
  background: #e8eaed;
}
.category-item.active {
  background: #d4e0ff;
  color: #2b5ced;
}
.category-item.active svg {
  stroke: #2b5ced;
}

/* ── Content ── */
.contacts-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.breadcrumb-bar {
  display: flex;
  align-items: center;
  height: 40px;
  padding: 0 16px;
  border-bottom: 1px solid #e8e8e8;
  gap: 4px;
  flex-shrink: 0;
}
.breadcrumb-item {
  font-size: 13px;
  color: #666;
  cursor: pointer;
  white-space: nowrap;
}
.breadcrumb-item:hover {
  color: #333;
}
.breadcrumb-item.last {
  color: #333;
  font-weight: 500;
  cursor: default;
}
.breadcrumb-sep {
  display: flex;
  align-items: center;
}
.org-list {
  flex: 1;
  overflow-y: auto;
}
.state-text {
  padding: 60px 20px;
  text-align: center;
  color: #999;
  font-size: 13px;
}
.org-row {
  display: flex;
  align-items: center;
  padding: 11px 16px;
  cursor: pointer;
  transition: background 0.15s;
  gap: 10px;
}
.org-row:hover {
  background: #f5f5f5;
}
.dept-row .row-icon {
  flex-shrink: 0;
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
  font-size: 12px;
  color: #999;
  flex-shrink: 0;
}
.row-arrow {
  flex-shrink: 0;
}
.user-avatar {
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
  overflow: hidden;
}
.user-avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
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
  font-size: 12px;
  color: #999;
  margin-top: 2px;
}
.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #ccc;
  flex-shrink: 0;
}
.status-dot.online {
  background: #10cc64;
}
.placeholder-view {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}
.placeholder-text {
  color: #999;
  font-size: 14px;
}

/* ── 用户资料浮层由 UserProfilePopup 组件承载 ── */
</style>
