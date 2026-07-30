<template>
  <Teleport to="body">
    <div v-if="open" class="ws-overlay" @mousedown.self="$emit('close')">
      <div class="ws-dialog">
        <header class="ws-header">
          <h3>知识库设置</h3>
          <button class="ws-close" @click="$emit('close')">✕</button>
        </header>

        <div class="ws-layout">
          <!-- Tab nav -->
          <nav class="ws-tabs">
            <button
              v-for="tab in tabs"
              :key="tab.key"
              class="ws-tab"
              :class="{ active: activeTab === tab.key }"
              @click="activeTab = tab.key"
            >
              <span class="ws-tab-icon">{{ tab.icon }}</span>
              <span>{{ tab.label }}</span>
            </button>
          </nav>

          <!-- Content panels -->
          <div class="ws-panels">
            <!-- ======== Tab: 基础信息 ======== -->
            <div v-if="activeTab === 'basic'" class="ws-panel">
              <div class="ws-field">
                <label>图标</label>
                <div class="ws-icon-row">
                  <span class="ws-icon-preview">{{ basicForm.icon || '📚' }}</span>
                  <input v-model="basicForm.icon" placeholder="📚" maxlength="2" class="ws-icon-input" />
                </div>
              </div>
              <div class="ws-field">
                <label>名称</label>
                <input v-model="basicForm.name" placeholder="知识库名称" class="ws-input" />
              </div>
              <div class="ws-field">
                <label>简介</label>
                <textarea v-model="basicForm.description" placeholder="知识库简介（可选）" class="ws-textarea" rows="3" />
              </div>
              <div class="ws-field">
                <label>封面</label>
                <div class="ws-cover-row">
                  <div v-if="basicForm.cover" class="ws-cover-preview" :style="{ backgroundImage: `url(${basicForm.cover})` }">
                    <button class="ws-cover-remove" @click="basicForm.cover = ''">✕</button>
                  </div>
                  <button v-else class="ws-cover-btn" @click="onPickCover">选择封面</button>
                </div>
              </div>
              <div class="ws-actions">
                <span v-if="basicDirty" class="ws-dirty-hint">有未保存的修改</span>
                <button class="btn-cancel" @click="resetBasicForm">取消</button>
                <button class="btn-save" :disabled="savingBasic || !basicForm.name.trim()" @click="handleSaveBasic">
                  {{ savingBasic ? '保存中…' : '保存' }}
                </button>
              </div>
              <div v-if="basicErr" class="ws-error">{{ basicErr }}</div>
            </div>

            <!-- ======== Tab: 成员 ======== -->
            <div v-if="activeTab === 'members'" class="ws-panel">
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
                      <div v-if="searchQuery && !searching && searchResults.length === 0" class="no-results">无匹配用户</div>
                      <div v-if="searching" class="search-loading">搜索中…</div>
                    </div>
                  </Transition>
                </div>
                <select v-model.number="newMemberRole">
                  <option :value="4">管理员</option>
                  <option :value="2">可编辑</option>
                  <option :value="1">可阅读</option>
                </select>
                <button class="btn-add" :disabled="!selectedUser || addingMember" @click="handleAddMember">
                  添加
                </button>
              </div>
              <div v-if="memberErr" class="ws-error">{{ memberErr }}</div>

              <div v-if="memberLoading" class="loading">加载中…</div>
              <template v-else>
                <div v-for="group in memberGroups" :key="group.role" class="member-group">
                  <div class="member-group-title">{{ group.label }}</div>
                  <div v-if="group.members.length === 0" class="member-group-empty">暂无</div>
                  <div v-for="m in group.members" :key="m.user_id" class="member-row">
                    <img v-if="m.avatar" :src="m.avatar" class="member-avatar" />
                    <div v-else class="member-avatar member-avatar-fallback">{{ (m.name || m.user_id).charAt(0) }}</div>
                    <div class="member-info">
                      <div class="member-name">{{ m.name || '未知用户' }}</div>
                      <div v-if="m.role === 4 && isOwner(m.user_id)" class="member-owner-tag">所有者</div>
                    </div>
                    <button
                      v-if="!isOwner(m.user_id)"
                      class="member-remove-btn"
                      :disabled="removingMemberId === m.user_id"
                      @click="handleRemoveMember(m.user_id)"
                    >{{ removingMemberId === m.user_id ? '…' : '移除' }}</button>
                  </div>
                </div>
              </template>
            </div>

            <!-- ======== Tab: 安全 ======== -->
            <div v-if="activeTab === 'security'" class="ws-panel">
              <div class="ws-field">
                <label>可见范围</label>
                <div class="ws-radio-group">
                  <label class="ws-radio" @click="updateSecurity('visibility', 0)">
                    <input type="radio" name="visibility" :checked="securityForm.visibility === 0" />
                    <span>仅成员可见</span>
                  </label>
                  <label class="ws-radio" @click="updateSecurity('visibility', 1)">
                    <input type="radio" name="visibility" :checked="securityForm.visibility === 1" />
                    <span>组织内全员可见</span>
                  </label>
                </div>
              </div>
              <div class="ws-field">
                <label>外部共享</label>
                <div class="ws-radio-group">
                  <label class="ws-radio" @click="updateSecurity('allow_external_share', true)">
                    <input type="radio" name="external" :checked="securityForm.allow_external_share === true" />
                    <span>允许通过链接分享到组织外</span>
                  </label>
                  <label class="ws-radio" @click="updateSecurity('allow_external_share', false)">
                    <input type="radio" name="external" :checked="securityForm.allow_external_share === false" />
                    <span>仅组织内共享</span>
                  </label>
                </div>
              </div>
              <div class="ws-field">
                <label>阅读者权限</label>
                <div class="ws-radio-group">
                  <label class="ws-radio" @click="updateSecurity('reader_permission', 0)">
                    <input type="radio" name="reader_perm" :checked="securityForm.reader_permission === 0" />
                    <span>仅可查看</span>
                  </label>
                  <label class="ws-radio" @click="updateSecurity('reader_permission', 1)">
                    <input type="radio" name="reader_perm" :checked="securityForm.reader_permission === 1" />
                    <span>可查看和评论</span>
                  </label>
                  <label class="ws-radio" @click="updateSecurity('reader_permission', 2)">
                    <input type="radio" name="reader_perm" :checked="securityForm.reader_permission === 2" />
                    <span>可查看、评论和复制</span>
                  </label>
                </div>
              </div>
              <div v-if="securitySaving" class="ws-security-saving">保存中…</div>
              <div v-if="securityErr" class="ws-error">{{ securityErr }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { wikisApi, type WikiDto, type WikiMemberDto } from '@/services/office/wikis'
import { apiV1, encodeReq } from '@/services/api_v1'
import { CMD } from '@/services/office/cmd'
import { useWikiStore } from '@/stores/wiki'

const props = defineProps<{
  open: boolean
  wiki: WikiDto | null
}>()

const emit = defineEmits<{
  close: []
  saved: [wiki: WikiDto]
}>()

const wikiStore = useWikiStore()
const activeTab = ref('basic')

const tabs = [
  { key: 'basic', icon: '📝', label: '基础信息' },
  { key: 'members', icon: '👥', label: '成员' },
  { key: 'security', icon: '🔒', label: '安全' },
]

// ======== Basic Info ========
const basicForm = reactive({ name: '', description: '', icon: '', cover: '' })
const basicDirty = ref(false)
const savingBasic = ref(false)
const basicErr = ref('')

watch(() => props.wiki, (wiki) => {
  if (wiki) {
    basicForm.name = wiki.name
    basicForm.description = wiki.description ?? ''
    basicForm.icon = wiki.icon ?? ''
    basicForm.cover = wiki.cover ?? ''
    basicDirty.value = false
    basicErr.value = ''
  }
}, { immediate: true })

watch(basicForm, () => {
  if (props.wiki) {
    basicDirty.value = true
  }
}, { deep: true })

function resetBasicForm() {
  if (props.wiki) {
    basicForm.name = props.wiki.name
    basicForm.description = props.wiki.description ?? ''
    basicForm.icon = props.wiki.icon ?? ''
    basicForm.cover = props.wiki.cover ?? ''
    basicDirty.value = false
    basicErr.value = ''
  }
}

async function handleSaveBasic() {
  if (!props.wiki || !basicForm.name.trim()) return
  savingBasic.value = true
  basicErr.value = ''
  try {
    const { data } = await wikisApi.update(props.wiki.id, {
      name: basicForm.name.trim(),
      description: basicForm.description.trim() || undefined,
      icon: basicForm.icon || undefined,
      cover: basicForm.cover || undefined,
    })
    const idx = wikiStore.wikis.findIndex(w => w.id === props.wiki!.id)
    if (idx >= 0) wikiStore.wikis[idx] = data
    basicDirty.value = false
    emit('saved', data)
  } catch (e: any) {
    basicErr.value = e?.response?.data?.msg || e?.message || '保存失败'
  } finally {
    savingBasic.value = false
  }
}

function onPickCover() {
  // TODO: 图片上传组件
}

// ======== Members ========
const searchQuery = ref('')
const selectedUser = ref<{ id: string; name: string; avatar: string | null } | null>(null)
const searchResults = ref<{ id: string; name: string; avatar: string | null }[]>([])
const searchSelectedIndex = ref(0)
const searching = ref(false)
const searchFocused = ref(false)
const showSuggestions = ref(false)
const searchWrapRef = ref<HTMLElement>()
const newMemberRole = ref(2)
const addingMember = ref(false)
const memberErr = ref('')
const memberLoading = ref(false)
const members = ref<WikiMemberDto[]>([])
const removingMemberId = ref<string | null>(null)
let searchDebounce: ReturnType<typeof setTimeout> | null = null

const memberGroups = computed(() => {
  const groups = [
    { role: 4, label: '管理员', members: [] as WikiMemberDto[] },
    { role: 2, label: '可编辑', members: [] as WikiMemberDto[] },
    { role: 1, label: '可阅读', members: [] as WikiMemberDto[] },
  ]
  for (const m of members.value) {
    const g = groups.find(g => g.role === m.role)
    if (g) g.members.push(m)
  }
  return groups
})

function isOwner(userId: string) {
  return props.wiki?.creator_id === userId
}

async function loadMembers() {
  if (!props.wiki) return
  memberLoading.value = true
  try {
    const { data } = await wikisApi.listMembers(props.wiki.id)
    members.value = data
  } catch (e: any) {
    memberErr.value = e?.message || '加载成员失败'
  } finally {
    memberLoading.value = false
  }
}

watch(() => props.open, (open) => {
  if (open && props.wiki) {
    loadMembers()
  }
})

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
  if (selectedUser.value) selectedUser.value = null
  if (searchDebounce) clearTimeout(searchDebounce)
  searchDebounce = setTimeout(() => doSearch(searchQuery.value), 200)
}

function selectUser(u: { id: string; name: string; avatar: string | null }) {
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

async function handleAddMember() {
  if (!selectedUser.value || !props.wiki) return
  addingMember.value = true
  memberErr.value = ''
  try {
    await wikisApi.addMember(props.wiki.id, selectedUser.value.id, newMemberRole.value)
    selectedUser.value = null
    searchQuery.value = ''
    await loadMembers()
  } catch (e: any) {
    memberErr.value = e?.response?.data?.msg || e?.message || '添加失败'
  } finally {
    addingMember.value = false
  }
}

async function handleRemoveMember(userId: string) {
  if (!props.wiki) return
  removingMemberId.value = userId
  memberErr.value = ''
  try {
    await wikisApi.removeMember(props.wiki.id, userId)
    await loadMembers()
  } catch (e: any) {
    memberErr.value = e?.response?.data?.msg || e?.message || '移除失败'
  } finally {
    removingMemberId.value = null
  }
}

// ======== Security ========
const securityForm = reactive({
  visibility: 0,
  allow_external_share: true,
  reader_permission: 0,
})
const securitySaving = ref(false)
const securityErr = ref('')

let securityTimer: ReturnType<typeof setTimeout> | null = null

function updateSecurity(field: string, value: any) {
  ;(securityForm as any)[field] = value
  if (securityTimer) clearTimeout(securityTimer)
  securityTimer = setTimeout(() => saveSecurity(), 300)
}

async function saveSecurity() {
  if (!props.wiki) return
  securitySaving.value = true
  securityErr.value = ''
  try {
    const { data } = await wikisApi.updateSecurity(props.wiki.id, {
      visibility: securityForm.visibility,
      allow_external_share: securityForm.allow_external_share,
      reader_permission: securityForm.reader_permission,
    })
    const idx = wikiStore.wikis.findIndex(w => w.id === props.wiki!.id)
    if (idx >= 0) wikiStore.wikis[idx] = data
  } catch (e: any) {
    securityErr.value = e?.response?.data?.msg || e?.message || '保存失败'
  } finally {
    securitySaving.value = false
  }
}

// 点击外部关闭搜索下拉
function onDocClick(e: MouseEvent) {
  if (searchWrapRef.value && !searchWrapRef.value.contains(e.target as Node)) {
    showSuggestions.value = false
  }
}
onMounted(() => {
  if (typeof window !== 'undefined') {
    window.addEventListener('click', onDocClick)
  }
})
</script>

<style scoped>
.ws-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.4);
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
}
.ws-dialog {
  background: #fff;
  border-radius: 12px;
  width: 640px;
  max-width: 92vw;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.18);
  overflow: hidden;
}
.ws-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 20px;
  border-bottom: 1px solid #eee;
}
.ws-header h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
}
.ws-close {
  background: none;
  border: none;
  font-size: 16px;
  cursor: pointer;
  color: #9ca3af;
  padding: 4px 8px;
  border-radius: 4px;
}
.ws-close:hover {
  background: #f3f4f6;
  color: #374151;
}
.ws-layout {
  display: flex;
  min-height: 360px;
}
.ws-tabs {
  width: 160px;
  flex-shrink: 0;
  border-right: 1px solid #eee;
  padding: 12px 0;
}
.ws-tab {
  display: flex;
  align-items: center;
  gap: 8px;
  width: 100%;
  padding: 10px 16px;
  border: none;
  background: transparent;
  cursor: pointer;
  font-size: 13px;
  color: #6b7280;
  text-align: left;
}
.ws-tab:hover {
  background: #f3f4f6;
  color: #374151;
}
.ws-tab.active {
  background: #e3f2fd;
  color: #1565c0;
  font-weight: 500;
}
.ws-tab-icon {
  font-size: 16px;
}
.ws-panels {
  flex: 1;
  padding: 20px;
  box-sizing: border-box;
  height: 420px;
  overflow-y: auto;
}
.ws-panel {
  max-width: 420px;
}
.ws-field {
  margin-bottom: 16px;
}
.ws-field label {
  display: block;
  font-size: 13px;
  font-weight: 500;
  color: #374151;
  margin-bottom: 6px;
}
.ws-icon-row {
  display: flex;
  align-items: center;
  gap: 8px;
}
.ws-icon-preview {
  font-size: 28px;
  width: 40px;
  text-align: center;
}
.ws-icon-input {
  width: 60px;
  padding: 6px 8px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 16px;
  text-align: center;
}
.ws-input, .ws-textarea {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 14px;
  color: #1f2937;
  box-sizing: border-box;
}
.ws-textarea {
  resize: vertical;
  min-height: 60px;
  font-family: inherit;
}
.ws-input:focus, .ws-textarea:focus, .ws-icon-input:focus {
  outline: none;
  border-color: #1565c0;
}
.ws-cover-row {
  display: flex;
  gap: 8px;
}
.ws-cover-preview {
  width: 200px;
  height: 100px;
  border-radius: 8px;
  background-size: cover;
  background-position: center;
  position: relative;
}
.ws-cover-remove {
  position: absolute;
  top: 4px;
  right: 4px;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  border: none;
  background: rgba(0,0,0,0.5);
  color: #fff;
  cursor: pointer;
  font-size: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.ws-cover-btn {
  width: 200px;
  height: 100px;
  border: 2px dashed #ddd;
  border-radius: 8px;
  background: #f9fafb;
  cursor: pointer;
  color: #6b7280;
  font-size: 13px;
}
.ws-cover-btn:hover {
  border-color: #1565c0;
  color: #1565c0;
}
.ws-actions {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 20px;
}
.ws-dirty-hint {
  font-size: 12px;
  color: #f59e0b;
  margin-right: auto;
}
.btn-cancel {
  padding: 8px 16px;
  border: 1px solid #ddd;
  background: #fff;
  border-radius: 6px;
  cursor: pointer;
  font-size: 13px;
  color: #374151;
}
.btn-cancel:hover { background: #f9fafb; }
.btn-save, .btn-add {
  padding: 8px 16px;
  border: none;
  background: #1565c0;
  color: #fff;
  border-radius: 6px;
  cursor: pointer;
  font-size: 13px;
  font-weight: 500;
}
.btn-save:hover:not(:disabled), .btn-add:hover:not(:disabled) { background: #0d47a1; }
.btn-save:disabled, .btn-add:disabled { opacity: 0.5; cursor: not-allowed; }
.ws-error {
  margin-top: 12px;
  padding: 8px 12px;
  background: #fef2f2;
  color: #dc2626;
  border-radius: 6px;
  font-size: 13px;
}

/* Member panel */
.add-row {
  display: flex;
  gap: 8px;
  margin-bottom: 16px;
}
.user-search-wrap {
  position: relative;
  flex: 1;
}
.user-search-wrap input {
  width: 100%;
  padding: 8px 10px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 13px;
  box-sizing: border-box;
}
.user-search-wrap input:focus {
  outline: none;
  border-color: #1565c0;
}
.search-suggestions {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  z-index: 10;
  max-height: 200px;
  overflow-y: auto;
}
.suggestion-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  cursor: pointer;
}
.suggestion-item:hover, .suggestion-item.active { background: #f3f4f6; }
.suggestion-avatar {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  object-fit: cover;
}
.suggestion-avatar-fallback {
  background: #e5e7eb;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  color: #6b7280;
}
.suggestion-info { flex: 1; }
.suggestion-name { font-size: 13px; color: #1f2937; }
.no-results, .search-loading {
  padding: 12px;
  color: #9ca3af;
  font-size: 12px;
  text-align: center;
}
select {
  padding: 8px 10px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 13px;
  background: #fff;
  color: #374151;
}
.member-group {
  margin-bottom: 16px;
}
.member-group-title {
  font-size: 12px;
  font-weight: 600;
  color: #9ca3af;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 8px;
  padding-bottom: 4px;
  border-bottom: 1px solid #f3f4f6;
}
.member-group-empty {
  color: #9ca3af;
  font-size: 12px;
  padding: 6px 0;
}
.member-row {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 4px;
}
.member-avatar {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  object-fit: cover;
}
.member-avatar-fallback {
  background: #e5e7eb;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  color: #6b7280;
}
.member-info {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 6px;
}
.member-name {
  font-size: 13px;
  color: #1f2937;
}
.member-owner-tag {
  font-size: 11px;
  color: #1565c0;
  background: #e3f2fd;
  padding: 1px 6px;
  border-radius: 4px;
}
.member-remove-btn {
  font-size: 12px;
  color: #ef4444;
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 4px;
  opacity: 0;
  transition: opacity 0.15s;
}
.member-row:hover .member-remove-btn {
  opacity: 1;
}
.member-remove-btn:hover {
  background: #fef2f2;
}
.member-remove-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}
.loading {
  text-align: center;
  color: #9ca3af;
  font-size: 13px;
  padding: 40px 0;
}

/* Security */
.ws-radio-group {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.ws-radio {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 10px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 13px;
  color: #374151;
}
.ws-radio:hover {
  background: #f3f4f6;
}
.ws-radio input[type="radio"] {
  accent-color: #1565c0;
}
.ws-security-saving {
  font-size: 12px;
  color: #9ca3af;
  margin-top: 8px;
}

.fade-enter-active, .fade-leave-active { transition: opacity 0.15s; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>
