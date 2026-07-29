<template>
  <div v-if="open" class="member-panel" @mousedown.stop @click.stop>
    <div class="mp-arrow"></div>
    <h3 class="mp-title">成员管理</h3>

    <div class="add-row">
      <div class="user-search-wrap" ref="searchWrapRef">
        <input
          v-model="searchQuery"
          placeholder="搜索用户添加…"
          @input="onSearchInput"
          @focus="searchFocused = true"
          @keydown.down.prevent="onSearchKeydown('down')"
          @keydown.up.prevent="onSearchKeydown('up')"
          @keydown.enter.prevent="onSearchEnter"
        />
        <div v-if="selectedUser" class="selected-user">
          <img v-if="selectedUser.avatar" :src="selectedUser.avatar" class="sel-avatar" />
          <div v-else class="sel-avatar sel-avatar-fallback">{{ initials(selectedUser.name) }}</div>
          <span class="sel-name">{{ selectedUser.name }}</span>
          <button class="sel-clear" @click="selectedUser = null; searchQuery = ''">✕</button>
        </div>
        <Transition name="fade">
          <div v-if="showSuggestions" class="search-suggestions">
            <div
              v-for="(u, i) in searchResults"
              :key="u.id"
              class="suggestion-item"
              :class="{ active: i === searchSelectedIndex }"
              @mousedown.prevent="selectUser(u)"
            >
              <img v-if="u.avatar" :src="u.avatar" class="suggestion-avatar" />
              <div v-else class="suggestion-avatar suggestion-avatar-fallback">{{ u.name.charAt(0) }}</div>
              <div class="suggestion-info">
                <div class="suggestion-name">{{ u.name }}</div>
              </div>
            </div>
            <div v-if="searchQuery && !searching && searchResults.length === 0" class="no-results">
              无匹配用户
            </div>
            <div v-if="searching" class="search-loading">搜索中…</div>
          </div>
        </Transition>
      </div>
      <select v-model.number="newRole">
        <option :value="ROLE_VIEWER">阅读者</option>
        <option :value="ROLE_COMMENTER">评论者</option>
        <option :value="ROLE_EDITOR">编辑者</option>
      </select>
      <button class="btn-primary" :disabled="!selectedUser || submitting" @click="addMember">
        添加
      </button>
    </div>

    <div v-if="errMsg" class="err">{{ errMsg }}</div>

    <ul v-if="!loading" class="member-list">
      <li v-for="m in members" :key="m.user_id" class="member-row">
        <div class="member-info">
          <img v-if="m.avatar" :src="m.avatar" class="avatar" />
          <div v-else class="avatar avatar-fallback">{{ initials(m.name) }}</div>
          <div>
            <div class="name">{{ m.name }}</div>
            <div class="uid">{{ m.user_id }}</div>
          </div>
        </div>
        <div class="member-actions">
          <select
            v-if="m.role !== ROLE_OWNER"
            :value="m.role"
            @change="onRoleChange(m.user_id, ($event.target as HTMLSelectElement).value)"
          >
            <option :value="ROLE_VIEWER">阅读者</option>
            <option :value="ROLE_COMMENTER">评论者</option>
            <option :value="ROLE_EDITOR">编辑者</option>
          </select>
          <span v-else class="owner-tag">所有者</span>
          <button
            v-if="m.role !== ROLE_OWNER"
            class="btn-remove"
            @click="removeMember(m.user_id)"
          >
            移除
          </button>
        </div>
      </li>
    </ul>
    <div v-else class="loading">加载中…</div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, watch } from 'vue'
import { membersApi, type MemberDto } from '@/services/office/members'
import { apiV1, encodeReq } from '@/services/api_v1'
import { CMD } from '@/services/office/cmd'
import {
  ROLE_COMMENTER,
  ROLE_EDITOR,
  ROLE_OWNER,
  ROLE_VIEWER,
} from '@/composables/usePermission'

interface SearchUser {
  id: string
  name: string
  avatar: string | null
}

const props = defineProps<{ open: boolean; docId: string }>()

const members = ref<MemberDto[]>([])
const loading = ref(false)
const submitting = ref(false)
const errMsg = ref<string | null>(null)

const newRole = ref<number>(ROLE_VIEWER)

// 用户搜索
const searchQuery = ref('')
const selectedUser = ref<SearchUser | null>(null)
const searchResults = ref<SearchUser[]>([])
const searchSelectedIndex = ref(0)
const searching = ref(false)
const searchFocused = ref(false)
const searchWrapRef = ref<HTMLElement>()
let searchDebounce: ReturnType<typeof setTimeout> | null = null

const showSuggestions = ref(false)

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
    const { data } = await apiV1(CMD.MENTION_USERS, encodeReq('office.MentionUsersRequest', { q }), 'office.MentionUsersResponse')
    searchResults.value = (data.items ?? []).map((u: any) => ({ id: u.id?.toString() ?? '', name: u.name ?? '', avatar: u.avatar || null }))
    searchSelectedIndex.value = 0
  } catch {
    searchResults.value = []
  } finally {
    searching.value = false
  }
}

function onSearchInput() {
  if (selectedUser.value) {
    selectedUser.value = null
  }
  if (searchDebounce) clearTimeout(searchDebounce)
  searchDebounce = setTimeout(() => doSearch(searchQuery.value), 200)
}

function selectUser(u: SearchUser) {
  selectedUser.value = u
  searchQuery.value = ''
  showSuggestions.value = false
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
    selectUser(searchResults.value[searchSelectedIndex.value])
  }
}

// 点击外部关闭搜索下拉
function onDocClick(e: MouseEvent) {
  if (searchWrapRef.value && !searchWrapRef.value.contains(e.target as Node)) {
    showSuggestions.value = false
  }
}
if (typeof window !== 'undefined') {
  window.addEventListener('click', onDocClick)
}

async function refresh() {
  loading.value = true
  errMsg.value = null
  try {
    members.value = await membersApi.list(props.docId)
  } catch (e) {
    errMsg.value = e instanceof Error ? e.message : String(e)
  } finally {
    loading.value = false
  }
}

watch(
  () => [props.open, props.docId],
  ([open]) => {
    if (open) refresh()
  },
)
onMounted(() => {
  if (props.open) refresh()
})

async function addMember() {
  if (!selectedUser.value || submitting.value) return
  submitting.value = true
  errMsg.value = null
  try {
    await membersApi.add(props.docId, String(selectedUser.value.id), newRole.value)
    selectedUser.value = null
    searchQuery.value = ''
    await refresh()
  } catch (e) {
    errMsg.value = e instanceof Error ? e.message : String(e)
  } finally {
    submitting.value = false
  }
}

async function onRoleChange(userId: string, value: string) {
  const role = Number(value)
  try {
    await membersApi.update(props.docId, userId, role)
    await refresh()
  } catch (e) {
    errMsg.value = e instanceof Error ? e.message : String(e)
  }
}

async function removeMember(userId: string) {
  if (!confirm('确定要移除该成员吗？')) return
  try {
    await membersApi.remove(props.docId, userId)
    await refresh()
  } catch (e) {
    errMsg.value = e instanceof Error ? e.message : String(e)
  }
}

function initials(name: string) {
  return (name || '?').trim().slice(0, 2).toUpperCase()
}
</script>

<style scoped>
.member-panel {
  position: absolute;
  top: calc(100% + 8px);
  right: 0;
  z-index: 200;
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 16px;
  min-width: 480px;
  max-width: 520px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
}
.mp-arrow {
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
.mp-title {
  margin: 0 0 16px;
  font-size: 16px;
  font-weight: 600;
}
.add-row {
  display: flex;
  gap: 8px;
  margin-bottom: 12px;
}
.user-search-wrap {
  position: relative;
  flex: 1;
}
.user-search-wrap input {
  width: 100%;
  padding: 8px 10px;
  border: 1px solid #d0d0d0;
  border-radius: 4px;
  font-size: 14px;
  outline: none;
  box-sizing: border-box;
}
.user-search-wrap input:focus {
  border-color: #1565c0;
}
.selected-user {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 4px 8px;
  background: #e3f2fd;
  border-radius: 4px;
  margin-top: 4px;
}
.sel-avatar {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  object-fit: cover;
}
.sel-avatar-fallback {
  display: flex;
  align-items: center;
  justify-content: center;
  background: #bbdefb;
  color: #1565c0;
  font-size: 11px;
  font-weight: 600;
}
.sel-name {
  font-size: 13px;
  color: #1565c0;
  flex: 1;
}
.sel-clear {
  background: none;
  border: none;
  cursor: pointer;
  color: #999;
  font-size: 12px;
  padding: 0 2px;
}
.sel-clear:hover {
  color: #333;
}
.search-suggestions {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  margin-top: 4px;
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
  z-index: 210;
  max-height: 240px;
  overflow-y: auto;
  padding: 4px;
}
.suggestion-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  border-radius: 6px;
  cursor: pointer;
}
.suggestion-item:hover,
.suggestion-item.active {
  background: #f0f0f0;
}
.suggestion-avatar {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  object-fit: cover;
}
.suggestion-avatar-fallback {
  display: flex;
  align-items: center;
  justify-content: center;
  background: #e3f2fd;
  color: #1565c0;
  font-size: 12px;
  font-weight: 600;
}
.suggestion-info {
  flex: 1;
}
.suggestion-name {
  font-size: 13px;
  color: #333;
}
.no-results,
.search-loading {
  padding: 12px;
  text-align: center;
  color: #999;
  font-size: 13px;
}
.add-row select {
  padding: 8px 10px;
  border: 1px solid #d0d0d0;
  border-radius: 4px;
  font-size: 14px;
  background: #fff;
}
.err {
  color: #d32f2f;
  font-size: 12px;
  margin-bottom: 8px;
}
.loading {
  padding: 16px;
  text-align: center;
  color: #888;
  font-size: 13px;
}
.member-list {
  list-style: none;
  padding: 0;
  margin: 0;
  max-height: 340px;
  overflow-y: auto;
}
.member-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid #f0f0f0;
}
.member-info {
  display: flex;
  align-items: center;
  gap: 10px;
}
.avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  object-fit: cover;
}
.avatar-fallback {
  display: flex;
  align-items: center;
  justify-content: center;
  background: #e3f2fd;
  color: #1565c0;
  font-size: 12px;
  font-weight: 600;
}
.name {
  font-size: 14px;
  color: #333;
}
.uid {
  font-size: 11px;
  color: #999;
}
.member-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}
.member-actions select {
  padding: 4px 8px;
  border: 1px solid #d0d0d0;
  border-radius: 4px;
  font-size: 13px;
  background: #fff;
}
.owner-tag {
  padding: 4px 8px;
  background: #ede7f6;
  color: #5e35b1;
  border-radius: 4px;
  font-size: 12px;
}
.member-actions button,
.btn-primary {
  padding: 6px 16px;
  border: none;
  border-radius: 4px;
  font-size: 13px;
  cursor: pointer;
  transition: background 0.15s;
}
.btn-primary {
  background: #1565c0;
  color: #fff;
}
.btn-primary:hover:not(:disabled) {
  background: #0d47a1;
}
.btn-primary:disabled {
  background: #90caf9;
  cursor: not-allowed;
}
.btn-remove {
  background: transparent;
  color: #d32f2f;
}
.btn-remove:hover {
  background: #ffebee;
}
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.15s ease;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}
</style>
