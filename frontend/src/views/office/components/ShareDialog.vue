<template>
  <div v-if="open" class="share-panel" @mousedown.stop @click.stop>
    <div class="sp-arrow"></div>

    <header class="sd-header">
      <div class="sd-header-left">
        <button v-if="pageStack.length > 1" class="sd-back" @click="goBack">←</button>
        <h3>{{ pageTitle }}</h3>
      </div>
      <div class="top-right">
        <div class="doc-perm-wrap">
          <button class="perm-btn" @click="showDocPermission = !showDocPermission">文档权限设置</button>
          <div v-if="showDocPermission" class="perm-dropdown">
            <div class="perm-option" @click="setDocPermission(2)">可编辑（默认）</div>
            <div class="perm-option" @click="setDocPermission(1)">可评论</div>
            <div class="perm-option" @click="setDocPermission(0)">只读</div>
          </div>
        </div>
      </div>
    </header>

    <!-- =========== Main Page =========== -->
    <div v-if="currentPage === 'main'" class="sd-body">
      <!-- Row 1: Collaborator avatars -->
      <div class="sd-row collab-row">
        <label>邀请协作者</label>
        <div class="collab-avatars">
          <template v-for="m in visibleMembers" :key="m.user_id">
            <div class="avatar-item">
              <img v-if="m.avatar" :src="m.avatar" class="avatar-img" :title="m.name" />
              <span v-else class="avatar-fallback" :title="m.name">{{ initials(m.name) }}</span>
            </div>
          </template>
          <button v-if="extraCount > 0" class="more-btn" @click="goTo('manage')">
            +{{ extraCount }}
          </button>
          <button v-else class="more-btn" @click="goTo('manage')">管理</button>
        </div>
      </div>

      <!-- Row 3: Search input -->
      <div class="sd-row search-row" ref="searchWrapRef">
        <input
          v-model="searchQuery"
          class="search-input"
          placeholder="搜索用户或群组…"
          @input="onSearchInput"
          @focus="onSearchFocus"
          @keydown.enter.prevent="onSearchEnter"
          @keydown.down.prevent="onSearchKeydown('down')"
          @keydown.up.prevent="onSearchKeydown('up')"
        />
        <Transition name="fade">
          <div v-if="showSuggestions" class="search-dropdown">
            <div
              v-for="(u, i) in searchResults"
              :key="u.id"
              class="search-item"
              :class="{ active: i === searchSelectedIndex }"
              @mousedown.prevent="selectSearchResult(u)"
            >
              <img v-if="u.avatar" :src="u.avatar" class="search-avatar" />
              <span v-else class="search-avatar search-avatar-fb">{{ initials(u.name) }}</span>
              <span class="search-name">{{ u.name }}</span>
            </div>
            <div v-if="searchQuery && !searching && searchResults.length === 0" class="search-empty">无匹配结果</div>
            <div v-if="searching" class="search-empty">搜索中…</div>
          </div>
        </Transition>
      </div>

      <!-- Row 4: Link share label -->
      <div class="sd-row label-row">
        <label>链接分享</label>
      </div>

      <!-- Row 5: Scope + permission -->
      <div class="sd-row link-row">
        <div class="link-left">
          <select v-model.number="shareScope" class="scope-select" @change="onShareScopeChange">
            <option :value="0">未开启</option>
            <option :value="1">组织内</option>
            <option :value="2">互联网</option>
          </select>
        </div>
        <div class="link-right">
          <select v-model.number="shareRole" class="role-select" @change="onShareRoleChange">
            <option :value="0">只读</option>
            <option :value="1">可评论</option>
          </select>
        </div>
      </div>

      <!-- Row 6: Copy + QR -->
      <div class="sd-row action-row">
        <button class="action-btn copy-btn" @click="copyLink">
          {{ copyTip || '复制链接' }}
        </button>
        <button class="action-btn qr-btn" @click="showQR = !showQR">{{ showQR ? '关闭二维码' : '分享二维码' }}</button>
      </div>
      <div v-if="showQR && shareUrl" class="qr-area">
        <img :src="qrDataUrl" v-if="qrDataUrl" class="qr-img" />
        <div v-else class="qr-placeholder">生成中…</div>
      </div>
    </div>

    <!-- =========== Manage Page =========== -->
    <div v-if="currentPage === 'manage'" class="sd-body">
      <div v-if="!members.length && !membersLoading" class="sd-empty">暂无协作者</div>
      <div v-if="membersLoading" class="sd-empty">加载中…</div>
      <div v-for="m in members" :key="m.user_id" class="member-row">
        <div class="member-info">
          <img v-if="m.avatar" :src="m.avatar" class="member-avatar" />
          <span v-else class="member-avatar member-avatar-fb">{{ initials(m.name) }}</span>
          <div class="member-name-wrap">
            <span class="member-name">{{ m.name }}</span>
            <span v-if="m.role === ROLE_OWNER" class="owner-badge">所有者</span>
          </div>
        </div>
        <div class="member-actions">
          <select
            v-if="m.role !== ROLE_OWNER"
            :value="m.role"
            class="member-role-select"
            @change="onRoleChange(m, ($event.target as HTMLSelectElement).value)"
          >
            <option :value="ROLE_VIEWER">只读</option>
            <option :value="ROLE_COMMENTER">可评论</option>
            <option :value="ROLE_EDITOR">可编辑</option>
          </select>
          <span v-else class="role-tag owner-tag">所有者</span>
          <button
            v-if="m.role !== ROLE_OWNER"
            class="remove-btn"
            @click="removeMember(m)"
          >移除</button>
        </div>
      </div>
    </div>

    <!-- =========== Invite Page =========== -->
    <div v-if="currentPage === 'invite'" class="sd-body">
      <div class="invite-user-row">
        <img v-if="inviteTarget?.avatar" :src="inviteTarget.avatar" class="invite-avatar" />
        <span v-else class="invite-avatar invite-avatar-fb">{{ initials(inviteTarget?.name || '') }}</span>
        <span class="invite-name">{{ inviteTarget?.name }}</span>
      </div>
      <div class="invite-role-row">
        <label>协作者权限</label>
        <select v-model.number="inviteRole" class="invite-role-select">
          <option :value="ROLE_VIEWER">只读</option>
          <option :value="ROLE_COMMENTER">可评论</option>
          <option :value="ROLE_EDITOR">可编辑</option>
        </select>
      </div>
      <button
        class="invite-confirm-btn"
        :disabled="inviting"
        @click="confirmInvite"
      >{{ inviting ? '邀请中…' : '邀请' }}</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, nextTick, onMounted, ref, watch } from 'vue'

import { sharesApi, type ShareInfoDto } from '@/services/office/shares'
import { membersApi, type MemberDto } from '@/services/office/members'
import api from '@/services/api'
import { ROLE_COMMENTER, ROLE_EDITOR, ROLE_OWNER, ROLE_VIEWER } from '@/composables/usePermission'
import QRCode from 'qrcode'

const props = defineProps<{ open: boolean; docId: string }>()
const emit = defineEmits<{ (e: 'update:open', v: boolean): void }>()

const pageStack = ref<string[]>(['main'])
const currentPage = computed(() => pageStack.value[pageStack.value.length - 1])
const pageTitle = computed(() => {
  switch (currentPage.value) {
    case 'main': return '共享文档'
    case 'manage': return '管理协作者'
    case 'invite': return '邀请协作者'
    default: return ''
  }
})

function goTo(page: string) { pageStack.value.push(page) }
function goBack() { if (pageStack.value.length > 1) pageStack.value.pop() }



// Members
const members = ref<MemberDto[]>([])
const membersLoading = ref(false)

const visibleMembers = computed(() => {
  const sorted = [...members.value].sort((a, b) => {
    if (a.role === ROLE_OWNER) return -1
    if (b.role === ROLE_OWNER) return 1
    return 0
  })
  return sorted.slice(0, 5)
})

const extraCount = computed(() => Math.max(0, members.value.length - 5))

async function loadMembers() {
  membersLoading.value = true
  try {
    members.value = await membersApi.list(props.docId)
  } catch { /* ignore */ }
  finally { membersLoading.value = false }
}

async function onRoleChange(m: MemberDto, val: string) {
  const role = Number(val)
  try {
    await membersApi.update(props.docId, m.user_id, role)
    m.role = role
  } catch { await loadMembers() }
}

async function removeMember(m: MemberDto) {
  try {
    await membersApi.remove(props.docId, m.user_id)
    members.value = members.value.filter(x => x.user_id !== m.user_id)
  } catch { /* ignore */ }
}

// Search
interface SearchUser { id: string; name: string; avatar: string | null }
const searchQuery = ref('')
const searchResults = ref<SearchUser[]>([])
const searchSelectedIndex = ref(0)
const searching = ref(false)
const showSuggestions = ref(false)
const searchWrapRef = ref<HTMLElement>()
let searchDebounce: ReturnType<typeof setTimeout> | null = null

async function doSearch(q: string) {
  if (!q.trim()) {
    searchResults.value = []
    showSuggestions.value = false
    searching.value = false
    return
  }
  searching.value = true
  showSuggestions.value = true
  try {
    const { data } = await api.get<SearchUser[]>('/office/mentions/users', { params: { q } })
    searchResults.value = data
    searchSelectedIndex.value = 0
  } catch { searchResults.value = [] }
  finally { searching.value = false }
}

function onSearchInput() {
  if (searchDebounce) clearTimeout(searchDebounce)
  searchDebounce = setTimeout(() => doSearch(searchQuery.value), 200)
}

function onSearchFocus() {
  if (searchQuery.value.trim()) doSearch(searchQuery.value)
}

function onSearchKeydown(dir: 'up' | 'down') {
  if (!showSuggestions.value || searchResults.value.length === 0) return
  if (dir === 'down') {
    searchSelectedIndex.value = (searchSelectedIndex.value + 1) % searchResults.value.length
  } else {
    searchSelectedIndex.value = (searchSelectedIndex.value - 1 + searchResults.value.length) % searchResults.value.length
  }
}

function onSearchEnter() {
  if (showSuggestions.value && searchResults.value.length > 0) {
    selectSearchResult(searchResults.value[searchSelectedIndex.value])
  }
}

function onDocClick(e: MouseEvent) {
  if (searchWrapRef.value && !searchWrapRef.value.contains(e.target as Node)) {
    showSuggestions.value = false
  }
}
if (typeof window !== 'undefined') {
  window.addEventListener('click', onDocClick)
}

// Invite
const inviteTarget = ref<SearchUser | null>(null)
const inviteRole = ref(ROLE_VIEWER)
const inviting = ref(false)

function selectSearchResult(u: SearchUser) {
  inviteTarget.value = u
  searchQuery.value = ''
  showSuggestions.value = false
  goTo('invite')
}

async function confirmInvite() {
  if (!inviteTarget.value || inviting.value) return
  inviting.value = true
  try {
    await membersApi.add(props.docId, inviteTarget.value.id, inviteRole.value)
    await loadMembers()
    goBack()
  } catch { /* ignore */ }
  finally { inviting.value = false }
}

// Doc-level permission
const showDocPermission = ref(false)
function setDocPermission(_r: number) {
  showDocPermission.value = false
}

// Link share
const shares = ref<ShareInfoDto[]>([])
const shareScope = ref(0)
const shareRole = ref(0)
const shareUrl = ref('')
const copyTip = ref('')

async function loadShares() {
  try {
    shares.value = await sharesApi.list(props.docId)
    const active = shares.value.find(s => !s.revoked)
    if (active) {
      shareUrl.value = `${window.location.origin}${active.url}`
      shareScope.value = 2
      shareRole.value = active.role
    } else {
      shareUrl.value = ''
      shareScope.value = 0
    }
  } catch { shares.value = [] }
}

async function onShareScopeChange() {
  if (shareScope.value === 0) {
    const active = shares.value.find(s => !s.revoked)
    if (active) {
      try { await sharesApi.revoke(active.id); await loadShares() } catch { /* ignore */ }
    }
  } else {
    const active = shares.value.find(s => !s.revoked)
    if (!active) {
      try { await sharesApi.create(props.docId, { role: shareRole.value }); await loadShares() } catch { /* ignore */ }
    }
  }
}

async function onShareRoleChange() {
  const active = shares.value.find(s => !s.revoked)
  if (active) {
    try {
      await sharesApi.revoke(active.id)
      await sharesApi.create(props.docId, { role: shareRole.value })
      await loadShares()
    } catch { /* ignore */ }
  }
}

async function copyLink() {
  if (!shareUrl.value) {
    try {
      await sharesApi.create(props.docId, { role: shareRole.value })
      await loadShares()
      await nextTick()
    } catch { return }
  }
  if (shareUrl.value) {
    try {
      await navigator.clipboard.writeText(shareUrl.value)
      copyTip.value = '已复制'
      setTimeout(() => { copyTip.value = '' }, 2000)
    } catch { /* ignore */ }
  }
}

// QR
const showQR = ref(false)
const qrDataUrl = ref('')

watch(shareUrl, async (url) => {
  if (url && showQR.value) {
    try { qrDataUrl.value = await QRCode.toDataURL(url, { width: 160, margin: 2 }) }
    catch { qrDataUrl.value = '' }
  }
}, { immediate: true })

watch(showQR, async (v) => {
  if (v && shareUrl.value && !qrDataUrl.value) {
    try { qrDataUrl.value = await QRCode.toDataURL(shareUrl.value, { width: 160, margin: 2 }) }
    catch { qrDataUrl.value = '' }
  }
})

// Init
watch(() => [props.open, props.docId], ([open]) => {
  if (open) {
    pageStack.value = ['main']
    showDocPermission.value = false
    showQR.value = false
    qrDataUrl.value = ''
    copyTip.value = ''
    searchQuery.value = ''
    searchResults.value = []
    showSuggestions.value = false
    loadMembers()
    loadShares()
  }
})

onMounted(() => {
  if (props.open) { loadMembers(); loadShares() }
})

function initials(name: string) {
  return (name || '?').trim().slice(0, 2).toUpperCase()
}
</script>

<style scoped>
.share-panel {
  position: absolute;
  top: calc(100% + 8px);
  right: 0;
  z-index: 200;
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
  width: 480px;
  max-height: 80vh;
  display: flex;
  flex-direction: column;
}
.sp-arrow {
  position: absolute;
  top: -6px;
  right: 20px;
  width: 10px;
  height: 10px;
  background: #fff;
  border-left: 1px solid #e0e0e0;
  border-top: 1px solid #e0e0e0;
  transform: rotate(45deg);
}
.sd-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 16px 10px;
  border-bottom: 1px solid #eee;
  flex-shrink: 0;
}
.sd-header-left {
  display: flex;
  align-items: center;
  gap: 6px;
}
.sd-header-left h3 {
  margin: 0;
  font-size: 15px;
  font-weight: 600;
}
.sd-back {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 16px;
  color: #666;
  padding: 0 4px;
}
.sd-back:hover { color: #333; }
.sd-body {
  padding: 10px 16px 16px;
  overflow-y: auto;
  flex: 1;
}
.sd-row { margin-bottom: 12px; }
.top-right { display: flex; align-items: center; gap: 8px; }
.doc-info {
  display: flex;
  align-items: center;
  gap: 6px;
  min-width: 0;
}
.doc-icon { font-size: 16px; flex-shrink: 0; }
.doc-title {
  font-size: 13px;
  font-weight: 500;
  color: #1f2937;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.doc-perm-wrap { position: relative; }
.perm-btn {
  padding: 4px 10px;
  border: 1px solid #d0d0d0;
  border-radius: 5px;
  background: #fff;
  cursor: pointer;
  font-size: 11px;
  color: #555;
  white-space: nowrap;
}
.perm-btn:hover { background: #f5f5f5; }
.perm-dropdown {
  position: absolute;
  top: 100%; right: 0;
  margin-top: 4px;
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 6px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  z-index: 10;
  min-width: 130px;
}
.perm-option {
  padding: 7px 12px;
  font-size: 12px;
  cursor: pointer;
}
.perm-option:hover { background: #f5f5f5; }

.collab-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.collab-row label { font-size: 12px; color: #666; flex-shrink: 0; margin-right: 10px; }
.collab-avatars {
  display: flex;
  align-items: center;
  gap: 4px;
  flex-wrap: wrap;
  justify-content: flex-end;
}
.avatar-item { flex-shrink: 0; }
.avatar-img {
  width: 26px; height: 26px;
  border-radius: 50%; object-fit: cover;
}
.avatar-fallback {
  display: inline-flex; align-items: center; justify-content: center;
  width: 26px; height: 26px; border-radius: 50%;
  background: #e3f2fd; color: #1565c0;
  font-size: 10px; font-weight: 600;
}
.more-btn {
  padding: 0 7px; height: 26px;
  border: 1px solid #d0d0d0; border-radius: 13px;
  background: #fff; cursor: pointer;
  font-size: 11px; color: #666;
}
.more-btn:hover { background: #f5f5f5; }

.search-row { position: relative; }
.search-input {
  width: 100%; padding: 7px 10px;
  border: 1px solid #d0d0d0; border-radius: 5px;
  font-size: 12px; outline: none; box-sizing: border-box;
}
.search-input:focus { border-color: #1565c0; }
.search-dropdown {
  position: absolute; top: 100%; left: 0; right: 0;
  margin-top: 4px; background: #fff;
  border: 1px solid #e0e0e0; border-radius: 6px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  z-index: 20; max-height: 200px; overflow-y: auto; padding: 4px;
}
.search-item {
  display: flex; align-items: center; gap: 6px;
  padding: 6px 10px; border-radius: 5px; cursor: pointer;
}
.search-item:hover, .search-item.active { background: #f0f0f0; }
.search-avatar {
  width: 26px; height: 26px; border-radius: 50%; object-fit: cover;
}
.search-avatar-fb {
  display: flex; align-items: center; justify-content: center;
  background: #e3f2fd; color: #1565c0; font-size: 10px; font-weight: 600;
}
.search-name { font-size: 12px; color: #333; }
.search-empty {
  padding: 10px; text-align: center; color: #999; font-size: 12px;
}

.label-row label { font-size: 12px; color: #666; }
.link-row { display: flex; align-items: center; gap: 10px; }
.link-left { flex: 1; }
.link-right { flex: 1; }
.scope-select, .role-select {
  width: 100%; padding: 7px 8px;
  border: 1px solid #d0d0d0; border-radius: 5px;
  font-size: 12px; background: #fff; outline: none;
}
.scope-select:focus, .role-select:focus { border-color: #1565c0; }

.action-row { display: flex; gap: 10px; }
.action-btn {
  flex: 1; padding: 7px 0;
  border: 1px solid #d0d0d0; border-radius: 5px;
  background: #fff; cursor: pointer;
  font-size: 12px; color: #333; text-align: center;
}
.action-btn:hover { background: #f5f5f5; }
.copy-btn { border-color: #1565c0; color: #1565c0; }
.copy-btn:hover { background: #e3f2fd; }

.qr-area {
  display: flex; justify-content: center; margin-top: 6px;
}
.qr-img { width: 140px; height: 140px; }
.qr-placeholder {
  width: 140px; height: 140px;
  display: flex; align-items: center; justify-content: center;
  color: #999; font-size: 12px; background: #fafafa; border-radius: 6px;
}

.sd-empty { padding: 24px 0; text-align: center; color: #999; font-size: 12px; }

.member-row {
  display: flex; align-items: center; justify-content: space-between;
  padding: 7px 0; border-bottom: 1px solid #f0f0f0;
}
.member-info { display: flex; align-items: center; gap: 8px; }
.member-avatar {
  width: 30px; height: 30px; border-radius: 50%; object-fit: cover;
}
.member-avatar-fb {
  display: flex; align-items: center; justify-content: center;
  background: #e3f2fd; color: #1565c0; font-size: 11px; font-weight: 600;
}
.member-name-wrap { display: flex; align-items: center; gap: 5px; }
.member-name { font-size: 13px; color: #333; }
.owner-badge {
  padding: 1px 5px; background: #ede7f6; color: #5e35b1;
  border-radius: 3px; font-size: 10px;
}
.member-actions { display: flex; align-items: center; gap: 6px; }
.member-role-select {
  padding: 3px 6px; border: 1px solid #d0d0d0;
  border-radius: 3px; font-size: 12px; background: #fff;
}
.role-tag { padding: 3px 6px; border-radius: 3px; font-size: 11px; }
.owner-tag { background: #ede7f6; color: #5e35b1; }
.remove-btn {
  padding: 3px 8px; border: none; border-radius: 3px;
  background: transparent; color: #d32f2f; cursor: pointer; font-size: 11px;
}
.remove-btn:hover { background: #ffebee; }

.invite-user-row {
  display: flex; align-items: center; gap: 10px; padding: 14px 0;
}
.invite-avatar {
  width: 36px; height: 36px; border-radius: 50%; object-fit: cover;
}
.invite-avatar-fb {
  display: flex; align-items: center; justify-content: center;
  background: #e3f2fd; color: #1565c0; font-size: 13px; font-weight: 600;
}
.invite-name { font-size: 14px; font-weight: 500; color: #1f2937; }
.invite-role-row {
  display: flex; align-items: center; gap: 10px; margin-bottom: 16px;
}
.invite-role-row label { font-size: 12px; color: #666; flex-shrink: 0; }
.invite-role-select {
  flex: 1; padding: 7px 8px;
  border: 1px solid #d0d0d0; border-radius: 5px;
  font-size: 12px; background: #fff; outline: none;
}
.invite-confirm-btn {
  width: 100%; padding: 8px 0; border: none; border-radius: 5px;
  background: #1565c0; color: #fff; cursor: pointer; font-size: 13px; font-weight: 500;
}
.invite-confirm-btn:hover:not(:disabled) { background: #0d47a1; }
.invite-confirm-btn:disabled { background: #90caf9; cursor: not-allowed; }

.fade-enter-active, .fade-leave-active { transition: opacity 0.12s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>
