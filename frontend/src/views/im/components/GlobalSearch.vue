<template>
  <Teleport to="body">
    <div v-if="visible" class="search-overlay" @click.self="$emit('close')">
      <div class="search-dialog">
        <div class="search-header">
          <div class="search-input-wrap">
            <svg class="search-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#999" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <input
              ref="inputRef"
              v-model="keyword"
              class="search-input"
              placeholder="搜索"
              @input="onInput"
              @keydown.esc="$emit('close')"
            />
          </div>
          <button class="close-btn" @click="$emit('close')">✕</button>
        </div>
        <div class="search-tabs">
          <button
            v-for="tab in tabs"
            :key="tab.key"
            :class="['tab', { active: activeTab === tab.key }]"
            @click="activeTab = tab.key"
          >
            {{ tab.label }}
          </button>
        </div>
        <div class="search-results">
          <div v-if="!keyword.trim()" class="search-hint">输入关键词搜索</div>
          <div v-else-if="loading" class="search-status">搜索中...</div>
          <div v-else class="result-list">
            <!-- 综合 tab -->
            <template v-if="activeTab === 'all'">
              <div v-if="results.users.length" class="result-section">
                <div class="section-title">联系人</div>
                <div v-for="u in results.users" :key="u.id" class="result-item" @click="onSelectUser(u)">
                  <div class="result-avatar">{{ u.name?.charAt(0) }}</div>
                  <div class="result-info">
                    <div class="result-name" v-html="u.highlight || u.name"></div>
                  </div>
                </div>
              </div>
              <div v-if="results.chats.length" class="result-section">
                <div class="section-title">会话</div>
                <div v-for="c in results.chats" :key="c.id" class="result-item" @click="onSelectChat(c)">
                  <div class="result-avatar">{{ c.name?.charAt(0) }}</div>
                  <div class="result-info">
                    <div class="result-name" v-html="c.highlight || c.name"></div>
                  </div>
                </div>
              </div>
              <div v-if="results.messages.length" class="result-section">
                <div class="section-title">消息</div>
                <div v-for="m in results.messages" :key="m.id" class="result-item" @click="onSelectMessage(m)">
                  <div class="result-info">
                    <div class="result-name">{{ m.chatName || '消息' }}</div>
                    <div class="result-preview" v-html="m.highlight || m.content"></div>
                  </div>
                </div>
              </div>
              <div v-if="!results.users.length && !results.chats.length && !results.messages.length && !loading" class="search-status">无结果</div>
            </template>
            <!-- 其他 tab: 只显示对应类型 -->
            <template v-if="activeTab === 'chats'">
              <div v-if="results.chats.length">
                <div v-for="c in results.chats" :key="c.id" class="result-item" @click="onSelectChat(c)">
                  <div class="result-avatar">{{ c.name?.charAt(0) }}</div>
                  <div class="result-info">
                    <div class="result-name" v-html="c.highlight || c.name"></div>
                  </div>
                </div>
              </div>
              <div v-else class="search-status">无结果</div>
            </template>
            <template v-if="activeTab === 'messages'">
              <div v-if="results.messages.length">
                <div v-for="m in results.messages" :key="m.id" class="result-item" @click="onSelectMessage(m)">
                  <div class="result-info">
                    <div class="result-name">{{ m.chatName || '消息' }}</div>
                    <div class="result-preview" v-html="m.highlight || m.content"></div>
                  </div>
                </div>
              </div>
              <div v-else class="search-status">无结果</div>
            </template>
            <template v-if="activeTab === 'contacts'">
              <div v-if="results.users.length">
                <div v-for="u in results.users" :key="u.id" class="result-item" @click="onSelectUser(u)">
                  <div class="result-avatar">{{ u.name?.charAt(0) }}</div>
                  <div class="result-info">
                    <div class="result-name" v-html="u.highlight || u.name"></div>
                  </div>
                </div>
              </div>
              <div v-else class="search-status">无结果</div>
            </template>
            <template v-if="activeTab === 'docs'">
              <div class="search-status">文档搜索尚未实现</div>
            </template>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, nextTick, watch } from 'vue'
import { useRouter } from 'vue-router'

const props = defineProps<{ visible: boolean }>()
const emit = defineEmits<{ close: [] }>()

const router = useRouter()
const inputRef = ref<HTMLInputElement | null>(null)
const keyword = ref('')
const activeTab = ref('all')
const loading = ref(false)

interface SearchUser { id: number; name: string; highlight?: string }
interface SearchChat { id: string; name: string; highlight?: string }
interface SearchMessage { id: number; content: string; highlight?: string; chatId?: number; chatName?: string }

const results = ref<{ users: SearchUser[]; chats: SearchChat[]; messages: SearchMessage[] }>({
  users: [], chats: [], messages: [],
})

const tabs = [
  { key: 'all', label: '综合' },
  { key: 'chats', label: '会话' },
  { key: 'messages', label: '消息' },
  { key: 'contacts', label: '联系人' },
  { key: 'docs', label: '文档' },
]

watch(() => props.visible, (v) => {
  if (v) {
    nextTick(() => inputRef.value?.focus())
    keyword.value = ''
    results.value = { users: [], chats: [], messages: [] }
  }
})

let debounceTimer: ReturnType<typeof setTimeout> | null = null

function onInput() {
  if (debounceTimer) clearTimeout(debounceTimer)
  debounceTimer = setTimeout(() => doSearch(), 300)
}

async function doSearch() {
  const q = keyword.value.trim()
  if (!q) {
    results.value = { users: [], chats: [], messages: [] }
    return
  }
  loading.value = true
  try {
    // 优先服务端全局搜索（GLOBAL_SEARCH=1406），失败回退客户端内存搜索
    const { globalSearch } = await import('@/services/im/api')
    const { useImStore } = await import('@/stores/im')
    const im = useImStore()
    const feedName = (chatId: string) => im.feedList.find((f) => f.chatId === chatId)?.name || '消息'

    const types: string[] = []
    if (activeTab.value === 'all') types.push('message', 'chat', 'user')
    else if (activeTab.value === 'messages') types.push('message')
    else if (activeTab.value === 'chats') types.push('chat')
    else if (activeTab.value === 'contacts') types.push('user')

    try {
      const resp = await globalSearch(q, types, 1, 20)
      results.value = {
        users: (resp.users || []).map((u: any) => ({
          id: Number(u.user?.id || 0),
          name: u.user?.name || '',
          highlight: u.highlight || u.user?.name || '',
        })),
        chats: (resp.chats || []).map((c: any) => ({
          id: String(c.chat?.id || '0'),
          name: c.chat?.name || '',
          highlight: c.highlight || c.chat?.name || '',
        })),
        messages: (resp.messages || []).map((m: any) => {
          const msg = m.message || {}
          const chatId = String(msg.chat_id || '0')
          return {
            id: Number(msg.id || 0),
            content: msg.summary || '',
            highlight: m.highlight || msg.summary || '',
            chatId,
            chatName: feedName(chatId),
          }
        }),
      }
      loading.value = false
      return
    } catch (e) {
      console.warn('[search] server search failed, fallback to local:', e)
    }

    // 客户端回退：联系人和会话列表做简单内存搜索
    const kw = q.toLowerCase()
    const { getDeptById } = await import('@/services/im/contacts')

    const matchedUsers: SearchUser[] = []
    const matchedChats: SearchChat[] = []
    const matchedMessages: SearchMessage[] = []

    if (activeTab.value === 'all' || activeTab.value === 'contacts') {
      try {
        const data = await getDeptById(0)
        data.users.forEach((u: { name: string; id: number }) => {
          if (u.name.toLowerCase().includes(kw)) {
            matchedUsers.push({ id: u.id, name: u.name })
          }
        })
      } catch {}
    }

    if (activeTab.value === 'all' || activeTab.value === 'chats') {
      im.feedList.forEach((f) => {
        if (f.name.toLowerCase().includes(kw)) {
          matchedChats.push({ id: f.chatId, name: f.name })
        }
      })
    }

    results.value = { users: matchedUsers, chats: matchedChats, messages: matchedMessages }
  } catch (e) {
    console.error('[search] error:', e)
  }
  loading.value = false
}

function onSelectUser(_u: SearchUser) {
  emit('close')
}

function onSelectChat(c: SearchChat) {
  emit('close')
  router.push(`/im/chat/${c.id}`)
}

function onSelectMessage(m: SearchMessage) {
  emit('close')
  if (m.chatId) {
    router.push(`/im/chat/${m.chatId}`)
  }
}
</script>

<style scoped>
.search-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.3);
  z-index: 10000;
  display: flex;
  justify-content: center;
  padding-top: 80px;
}
.search-dialog {
  width: 580px;
  max-height: 70vh;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 8px 40px rgba(0,0,0,0.2);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.search-header {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  border-bottom: 1px solid #e8e8e8;
  gap: 8px;
}
.search-input-wrap {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 8px;
  background: #f5f5f5;
  border-radius: 8px;
  padding: 0 12px;
}
.search-icon {
  flex-shrink: 0;
}
.search-input {
  flex: 1;
  border: none;
  background: transparent;
  padding: 10px 0;
  font-size: 14px;
  outline: none;
}
.close-btn {
  border: none;
  background: transparent;
  font-size: 18px;
  color: #999;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 6px;
}
.close-btn:hover {
  background: #f0f0f0;
}
.search-tabs {
  display: flex;
  gap: 0;
  border-bottom: 1px solid #e8e8e8;
  padding: 0 12px;
}
.tab {
  padding: 10px 14px;
  font-size: 13px;
  border: none;
  background: transparent;
  color: #666;
  cursor: pointer;
  border-bottom: 2px solid transparent;
  transition: all 0.15s;
}
.tab:hover {
  color: #333;
}
.tab.active {
  color: #4a6cf7;
  border-bottom-color: #4a6cf7;
}
.search-results {
  flex: 1;
  overflow-y: auto;
  min-height: 200px;
}
.search-hint {
  padding: 60px 20px;
  text-align: center;
  color: #999;
  font-size: 14px;
}
.search-status {
  padding: 40px 20px;
  text-align: center;
  color: #999;
  font-size: 13px;
}
.result-section {
  padding: 8px 0;
}
.section-title {
  padding: 6px 16px;
  font-size: 12px;
  color: #999;
  font-weight: 500;
}
.result-item {
  display: flex;
  align-items: center;
  padding: 8px 16px;
  cursor: pointer;
  transition: background 0.15s;
  gap: 10px;
}
.result-item:hover {
  background: #f5f5f5;
}
.result-avatar {
  width: 32px;
  height: 32px;
  border-radius: 6px;
  background: #4a6cf7;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 13px;
  font-weight: 600;
  flex-shrink: 0;
}
.result-info {
  flex: 1;
  min-width: 0;
}
.result-name {
  font-size: 14px;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.result-preview {
  font-size: 12px;
  color: #888;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  margin-top: 2px;
}
</style>
