<template>
  <nav class="nav-sidebar">
    <div class="nav-top">
      <div class="avatar" @click="showCreateMenu = !showCreateMenu">{{ userInitial }}</div>
      <button class="nav-icon-btn add-btn" title="创建" @click="showCreateMenu = !showCreateMenu">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
      </button>
      <Teleport to="body">
        <div v-if="showCreateMenu" class="create-menu" @click.stop @contextmenu.prevent>
          <div class="menu-item" @click="onCreateP2p">创建单聊</div>
          <div class="menu-item" @click="onCreateGroup">创建群聊</div>
        </div>
      </Teleport>
    </div>
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
import CreateChatDialog from './CreateChatDialog.vue'

const props = defineProps<{ active: string }>()
const emit = defineEmits<{ 'update:active': [value: string]; openSearch: [] }>()

const router = useRouter()
const auth = useAuthStore()

const showCreateMenu = ref(false)
const showCreateDialog = ref(false)
const createMode = ref<'p2p' | 'group'>('p2p')

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
  if (!target.closest('.nav-top') && !target.closest('.create-menu')) {
    showCreateMenu.value = false
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
  border-radius: 8px;
  background: #4a6cf7;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
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
</style>
