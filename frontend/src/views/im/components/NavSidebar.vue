<template>
  <nav class="nav-sidebar">
    <div class="nav-top">
      <div class="avatar" title="个人中心" @click="onToggleAvatar">
        <img v-if="auth.user?.avatar" class="avatar-img" :src="auth.user.avatar" alt="" />
        <span v-else>{{ userInitial }}</span>
      </div>
      <button class="nav-icon-btn add-btn" title="创建" @click="onToggleCreate">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
      </button>
      <Teleport to="body">
        <div v-if="showPersonalMenu" class="personal-menu" @click.stop @contextmenu.prevent>
          <div class="pm-header">
            <div class="pm-avatar-wrap">
              <img v-if="auth.user?.avatar" class="pm-avatar" :src="auth.user.avatar" alt="" />
              <div v-else class="pm-avatar pm-avatar-fallback">{{ userInitial }}</div>
              <span class="pm-status-dot" :style="{ background: statuses[status].color }"></span>
            </div>
            <div class="pm-user">
              <div class="pm-name">{{ auth.user?.name || '?' }}</div>
              <div class="pm-tenant">{{ currentTenantName }}</div>
            </div>
          </div>
          <div class="pm-status" @click="cycleStatus">
            <span class="pm-status-dot pm-status-inline" :style="{ background: statuses[status].color }"></span>
            <span class="pm-status-label">{{ statuses[status].label }}</span>
            <span class="pm-chevron">›</span>
          </div>
          <div class="pm-divider"></div>
          <div class="pm-item" @click="onPlaceholder('我的资料')">我的资料</div>
          <div class="pm-item" @click="onPlaceholder('我的二维码')">我的二维码</div>
          <div class="pm-item" @click="onPlaceholder('设置')">设置</div>
          <div class="pm-divider"></div>
          <div class="pm-item pm-item-danger" @click="logout">退出登录</div>
        </div>
      </Teleport>
      <Teleport to="body">
        <div v-if="showCreateMenu" class="create-menu" @click.stop @contextmenu.prevent>
          <div class="menu-item" @click="onCreateP2p">创建单聊</div>
          <div class="menu-item" @click="onCreateGroup">创建群聊</div>
        </div>
      </Teleport>
    </div>
    <div v-if="toast" class="nav-toast">{{ toast }}</div>
    <div class="nav-actions">
      <button class="nav-icon-btn search-btn" title="搜索" @click="$emit('openSearch')">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
      </button>
    </div>
    <div class="nav-items">
      <button
        v-for="item in navItems"
        :key="item.key"
        :class="['nav-item', { active: active === item.key }]"
        :title="item.label"
        @click="onNavClick(item)"
      >
        <span class="nav-icon" v-html="item.icon"></span>
        <span v-if="item.key === 'chat' && im.totalUnread > 0" class="nav-badge">{{ formatUnread(im.totalUnread) }}</span>
      </button>
    </div>
    <div class="nav-spacer" />
    <CreateChatDialog :show="showCreateDialog" :mode="createMode" @close="showCreateDialog = false" />
  </nav>
</template>

<script setup lang="ts">
import { computed, ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useImStore } from '@/stores/im'
import CreateChatDialog from './CreateChatDialog.vue'

const props = defineProps<{ active: string }>()
const emit = defineEmits<{ 'update:active': [value: string]; openSearch: [] }>()

const router = useRouter()
const auth = useAuthStore()
const im = useImStore()

function formatUnread(n: number): string {
  return n > 99 ? '99+' : String(n)
}

const showCreateMenu = ref(false)
const showPersonalMenu = ref(false)
const showCreateDialog = ref(false)
const createMode = ref<'p2p' | 'group'>('p2p')

// 个人菜单：与桌面端 NaviBar 的 PersonalPopup 对齐
const statuses = [
  { label: '离线', color: '#999999' },
  { label: '在线', color: '#10CC64' },
  { label: '忙碌', color: '#f44336' },
  { label: '离开', color: '#ff9800' },
]
const status = ref(1) // 默认在线

function cycleStatus() {
  status.value = (status.value + 1) % statuses.length
}

const currentTenantName = computed(() => auth.currentTenant?.name || '个人')

const toast = ref('')
let toastTimer: number | undefined
function showToast(msg: string) {
  toast.value = msg
  if (toastTimer) window.clearTimeout(toastTimer)
  toastTimer = window.setTimeout(() => {
    toast.value = ''
  }, 2000)
}

function onToggleAvatar() {
  showPersonalMenu.value = !showPersonalMenu.value
  showCreateMenu.value = false
}

function onToggleCreate() {
  showCreateMenu.value = !showCreateMenu.value
  showPersonalMenu.value = false
}

// 资料 / 二维码 / 设置 在 Web 端暂无对应页面，先占位提示（与桌面端保持菜单项一致）
function onPlaceholder(label: string) {
  showPersonalMenu.value = false
  showToast(`${label}功能开发中`)
}

function logout() {
  showPersonalMenu.value = false
  auth.clear()
  router.push({ name: 'Login' })
}

const userInitial = computed(() => {
  return auth.user?.name?.charAt(0)?.toUpperCase() || '?'
})

interface NavItem {
  key: string
  label: string
  icon: string
  action: 'route' | 'tab'
  route?: string
  url?: string
}

const navItems: NavItem[] = [
  { key: 'chat', label: '消息', icon: '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>', action: 'route', route: '/im/feed' },
  { key: 'calendar', label: '日历', icon: '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>', action: 'route', route: '/im/calendar' },
  { key: 'contacts', label: '通讯录', icon: '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>', action: 'route', route: '/im/contacts' },
  { key: 'docs', label: '文档', icon: '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>', action: 'tab', url: '/office' },
  { key: 'apps', label: '应用', icon: '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>', action: 'tab', url: '/open' },
]

function onNavClick(item: NavItem) {
  showCreateMenu.value = false
  showPersonalMenu.value = false
  if (item.action === 'tab' && item.url) {
    window.open(item.url, '_blank')
  } else if (item.action === 'route' && item.route) {
    emit('update:active', item.key)
    router.push(item.route)
  }
}

function onCreateP2p() {
  showCreateMenu.value = false
  createMode.value = 'p2p'
  showCreateDialog.value = true
}

function onCreateGroup() {
  showCreateMenu.value = false
  createMode.value = 'group'
  showCreateDialog.value = true
}

function onClickOutside(e: MouseEvent) {
  const target = e.target as HTMLElement
  if (!target.closest('.nav-top') && !target.closest('.create-menu') && !target.closest('.personal-menu')) {
    showCreateMenu.value = false
    showPersonalMenu.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', onClickOutside)
})
onUnmounted(() => {
  document.removeEventListener('click', onClickOutside)
})
</script>

<style scoped>
.nav-sidebar {
  width: 52px;
  min-width: 52px;
  display: flex;
  flex-direction: column;
  align-items: center;
  background: #1e1e2d;
  padding: 10px 0;
  gap: 2px;
}
.nav-top {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  margin-bottom: 8px;
}
.avatar {
  width: 34px;
  height: 34px;
  border-radius: 50%;
  background: #4a6cf7;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  overflow: hidden;
  position: relative;
}
.avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.avatar:hover {
  background: #3d5ae0;
}
.avatar:hover .avatar-img {
  filter: brightness(0.92);
}
.nav-icon-btn {
  width: 34px;
  height: 34px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: transparent;
  border: none;
  color: #8e8ea0;
  cursor: pointer;
  transition: all 0.15s;
}
.nav-icon-btn:hover {
  background: rgba(255,255,255,0.08);
  color: #d0d0d8;
}
.nav-actions {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 8px;
}
.nav-items {
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.nav-item {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: transparent;
  border: none;
  color: #8e8ea0;
  cursor: pointer;
  transition: all 0.15s;
}
.nav-item:hover {
  background: rgba(255,255,255,0.08);
  color: #d0d0d8;
}
.nav-item.active {
  background: rgba(255,255,255,0.12);
  color: #fff;
}
.nav-item {
  position: relative;
}
.nav-badge {
  position: absolute;
  top: 2px;
  right: 0;
  min-width: 16px;
  height: 16px;
  padding: 0 4px;
  border-radius: 8px;
  background: #f44336;
  color: #fff;
  font-size: 10px;
  line-height: 16px;
  text-align: center;
  box-sizing: border-box;
}
.nav-spacer {
  flex: 1;
}
.create-menu {
  position: fixed;
  left: 56px;
  top: 8px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 4px 16px rgba(0,0,0,0.15);
  min-width: 140px;
  padding: 4px;
  z-index: 9999;
}
.create-menu .menu-item {
  padding: 8px 14px;
  font-size: 13px;
  color: #333;
  cursor: pointer;
  border-radius: 6px;
  white-space: nowrap;
}
.create-menu .menu-item:hover {
  background: #f0f2f5;
}

/* 个人菜单（与桌面端 PersonalPopup 对齐） */
.personal-menu {
  position: fixed;
  left: 56px;
  top: 8px;
  width: 280px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 4px 16px rgba(0,0,0,0.15);
  padding: 4px 0;
  z-index: 9999;
}
.pm-header {
  display: flex;
  align-items: center;
  padding: 12px 16px 10px;
}
.pm-avatar-wrap {
  position: relative;
  width: 36px;
  height: 36px;
  margin-right: 12px;
}
.pm-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  object-fit: cover;
  background: #4a6cf7;
}
.pm-avatar-fallback {
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 15px;
  font-weight: 600;
}
.pm-status-dot {
  position: absolute;
  right: -1px;
  bottom: -1px;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  border: 2px solid #fff;
}
.pm-status-inline {
  position: static;
  width: 10px;
  height: 10px;
  border: none;
  margin-right: 8px;
}
.pm-user {
  min-width: 0;
}
.pm-name {
  font-size: 14px;
  font-weight: 600;
  color: #333;
  line-height: 20px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.pm-tenant {
  font-size: 12px;
  color: #888;
  margin-top: 2px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.pm-status {
  display: flex;
  align-items: center;
  padding: 8px 16px;
  cursor: pointer;
  transition: background 0.15s;
}
.pm-status:hover {
  background: #f7f8fa;
}
.pm-status-label {
  font-size: 13px;
  color: #333;
}
.pm-chevron {
  margin-left: auto;
  color: #bbb;
  font-size: 16px;
  line-height: 1;
}
.pm-divider {
  height: 1px;
  background: #f0f2f5;
  margin: 4px 0;
}
.pm-item {
  padding: 9px 16px;
  font-size: 13px;
  color: #333;
  cursor: pointer;
  transition: background 0.15s;
}
.pm-item:hover {
  background: #f7f8fa;
}
.pm-item-danger {
  color: #f44336;
}
.pm-item-danger:hover {
  background: #fff1f0;
}

/* 占位提示 toast */
.nav-toast {
  position: fixed;
  left: 50%;
  bottom: 48px;
  transform: translateX(-50%);
  max-width: 70vw;
  padding: 9px 18px;
  border-radius: 8px;
  background: rgba(0,0,0,0.72);
  color: #fff;
  font-size: 13px;
  z-index: 10000;
  white-space: nowrap;
  pointer-events: none;
  animation: nav-toast-in 0.2s ease;
}
@keyframes nav-toast-in {
  from { opacity: 0; transform: translateX(-50%) translateY(6px); }
  to { opacity: 1; transform: translateX(-50%) translateY(0); }
}
</style>
