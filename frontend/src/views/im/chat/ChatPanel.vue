<template>
  <div class="chat-panel">
    <div class="chat-header">
      <button class="back-btn" @click="goBack">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
      </button>
      <div class="chat-header-left" @click="goProfile">
        <div class="chat-avatar">
          <span>{{ chatNameFirstChar }}</span>
          <span v-if="isP2p" :class="['presence-dot', { online: presenceStatus === 1 }]" />
        </div>
        <div class="chat-header-info">
          <div class="chat-name">{{ im.currentChat?.name || '...' }}</div>
          <div class="chat-subtitle">{{ headerSubtitle }}</div>
        </div>
      </div>
      <div class="chat-header-actions">
        <button class="header-btn" title="搜索" @click="toggleChatSearch">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        </button>
        <button v-if="isGroup" class="header-btn" title="群设置" @click="goProfile">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="1"/><circle cx="12" cy="5" r="1"/><circle cx="12" cy="19" r="1"/></svg>
        </button>
      </div>
    </div>

    <!-- 群公告横幅 -->
    <div v-if="announcement" class="banner announcement-banner" @click="showAnnouncement">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
      <span class="banner-text">{{ announcement.text }}</span>
    </div>

    <!-- 置顶消息横幅 -->
    <div v-if="pinnedMessages.length > 0" class="banner pinned-banner" @click="showPinned">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="17" x2="12" y2="22"/><path d="M5 17h14v-1.76a2 2 0 0 0-1.11-1.79l-1.78-.9A2 2 0 0 1 15 10.76V6h1a2 2 0 0 0 0-4H8a2 2 0 0 0 0 4h1v4.76a2 2 0 0 1-1.11 1.79l-1.78.9A2 2 0 0 0 5 15.24Z"/></svg>
      <span class="banner-text">{{ pinnedMessages[0]?.summary || '置顶消息' }}</span>
    </div>

    <!-- 聊天内搜索 -->
    <div v-if="chatSearchVisible" class="chat-search-bar">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#999" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
      <input
        v-model="chatSearchQuery"
        class="chat-search-input"
        placeholder="搜索聊天记录..."
        @keydown.enter="doChatSearch"
      />
      <button class="header-btn" @click="chatSearchVisible = false">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
      </button>
    </div>

    <div class="chat-messages" ref="msgListRef" @scroll="onScroll">
      <div v-if="im.loadingMessages" class="msg-loading">加载中...</div>
      <div v-else-if="im.currentMessages.length === 0" class="msg-empty">暂无消息，发送第一条消息吧</div>
      <template v-else>
        <div v-for="(msg, idx) in im.currentMessages" :key="msg.id">
          <div v-if="showDateSeparator(msg, idx)" class="date-separator">{{ formatDate(msg.createTimeMs) }}</div>
          <div
            v-if="msg.tpy === 15 || msg.tpy === 16"
            class="msg-item msg-system"
            @click.right.prevent="showMsgMenu($event, msg)"
          >
            <SystemMessage :content="msg.content" :summary="msg.summary" />
          </div>
          <div
            v-else
            class="msg-item"
            :class="{ 'same-sender': !showSenderInfo(msg, idx) }"
            @click.right.prevent="showMsgMenu($event, msg)"
          >
            <div class="msg-avatar">
              <span v-if="showSenderInfo(msg, idx)">{{ getSenderFirstChar(msg.fromId) }}</span>
            </div>
            <div class="msg-body">
              <div v-if="showSenderInfo(msg, idx)" class="msg-meta">
                <span class="msg-name">{{ getSenderName(msg.fromId) }}</span>
                <span class="msg-time">{{ formatTime(msg.createTimeMs) }}</span>
              </div>
              <div v-if="msg.refMessageId !== '0'" class="reply-preview" @click="scrollToMessage(msg.refMessageId)">
                {{ msg.summary ? '回复: ' + msg.summary : '回复了一条消息' }}
              </div>
              <div class="msg-bubble" :class="'tpy-' + msg.tpy">
                <TextMessage v-if="msg.tpy === 1" :content="msg.content" />
                <ImageMessage v-else-if="msg.tpy === 2" :content="msg.content" />
                <FileMessage v-else-if="msg.tpy === 3" :content="msg.content" />
                <MarkdownMessage v-else-if="msg.tpy === 13" :content="msg.content" :summary="msg.summary" />
                <ForwardMessage v-else-if="msg.tpy === 14" :content="msg.content" :summary="msg.summary" />
                <span v-else>{{ msg.summary || `[类型 ${msg.tpy}]` }}</span>
              </div>
              <ReactionBar :message-id="msg.id" :reactions="msg.reactions" />
              <div class="msg-foot">
                <span v-if="msg.sendStatus === 'sending'" class="msg-status sending">发送中...</span>
                <span v-if="msg.sendStatus === 'failed'" class="msg-status failed" @click.stop="retry(msg)">发送失败，点击重试</span>
                <span v-if="msg.sendStatus === 'sent' && msg.fromId === myId" class="msg-read-status">已读</span>
              </div>
            </div>
          </div>
        </div>
      </template>
    </div>

    <!-- 回复预览 -->
    <ReplyPreview />
    <TypingIndicator :chat-id="chatId!" />

    <div class="chat-actions">
      <input
        ref="fileInput"
        type="file"
        accept="image/*"
        style="display:none"
        @change="onImageSelected"
      />
      <button class="action-btn" title="图片" @click="fileInput?.click()">🖼</button>
      <input
        ref="docInput"
        type="file"
        style="display:none"
        @change="onFileSelected"
      />
      <button class="action-btn" title="文件" @click="docInput?.click()">📎</button>
    </div>
    <div class="chat-input">
      <input
        ref="textInputRef"
        v-model="inputText"
        class="text-input"
        placeholder="输入消息..."
        @keydown.enter="handleEnter"
        @keydown="handleKeydown"
        @input="onInputChanged"
      />
      <MentionPicker
        ref="mentionPickerRef"
        :chat-id="chatId!"
        :show="mention.show"
        :query="mention.query"
        :top="mention.top"
        :left="mention.left"
        @select="onMentionSelect"
        @close="mention.show = false"
      />
      <button class="send-btn" @click="send" :disabled="!inputText.trim()">发送</button>
    </div>

    <!-- 消息右键菜单 -->
    <Teleport to="body">
      <div v-if="msgMenu.show" class="context-menu" :style="{ top: msgMenu.y + 'px', left: msgMenu.x + 'px' }" @click.stop @contextmenu.prevent>
        <div class="menu-item" @click="replyMessage(msgMenu.msg!)">回复</div>
        <div class="menu-item" @click="copyMessage(msgMenu.msg!)">复制</div>
        <div class="menu-item" @click="forwardMsg(msgMenu.msg!)">转发</div>
        <div class="menu-item" @click="openThread(msgMenu.msg!)">查看话题</div>
        <div v-if="msgMenu.msg?.fromId === myId" class="menu-item" @click="recall(msgMenu.msg!)">撤回</div>
        <div v-if="msgMenu.msg?.fromId === myId || isAdmin" class="menu-item danger" @click="del(msgMenu.msg!)">删除</div>
      </div>
    </Teleport>

    <!-- 转发选择器 -->
    <ForwardPicker
      :show="forwardPicker.show"
      :source-chat-id="forwardPicker.sourceChatId"
      :message-ids="forwardPicker.messageIds"
      @close="forwardPicker.show = false"
    />

    <div class="slide-overlay">
      <Transition name="slide">
        <GroupProfile
          v-if="showGroupProfile"
          :chat-id="chatId!"
          @close="showGroupProfile = false"
        />
      </Transition>

      <Transition name="slide">
        <ThreadPanel
          v-if="threadMsgId"
          :chat-id="chatId!"
          :root-message-id="threadMsgId!"
          @close="threadMsgId = null"
        />
      </Transition>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useImStore } from '@/stores/im'
import { useAuthStore } from '@/stores/auth'
import type { MessageItem } from '@/stores/im'
import TextMessage from './message-types/TextMessage.vue'
import ImageMessage from './message-types/ImageMessage.vue'
import FileMessage from './message-types/FileMessage.vue'
import MarkdownMessage from './message-types/MarkdownMessage.vue'
import SystemMessage from './message-types/SystemMessage.vue'
import ForwardMessage from './message-types/ForwardMessage.vue'
import ReplyPreview from './components/ReplyPreview.vue'
import ReactionBar from './components/ReactionBar.vue'
import ForwardPicker from './components/ForwardPicker.vue'
import TypingIndicator from './components/TypingIndicator.vue'
import ThreadPanel from './ThreadPanel.vue'
import GroupProfile from './GroupProfile.vue'
import MentionPicker from './components/MentionPicker.vue'
import api from '@/services/api'

const route = useRoute()
const router = useRouter()
const im = useImStore()
const auth = useAuthStore()
const inputText = ref('')
const msgListRef = ref<HTMLElement | null>(null)
const fileInput = ref<HTMLInputElement>()
const docInput = ref<HTMLInputElement>()
const textInputRef = ref<HTMLInputElement>()
const mentionPickerRef = ref<InstanceType<typeof MentionPicker>>()
const myId = ref(String(auth.user?.id ?? ''))
const autoScroll = ref(true)

const _now = ref(Date.now())
let _tick: ReturnType<typeof setInterval>

const mention = ref({ show: false, query: '', top: 0, left: 0, startPos: -1 })

const chatSearchVisible = ref(false)
const chatSearchQuery = ref('')

const isP2p = computed(() => im.currentChat?.chatType === 1)
const isGroup = computed(() => im.currentChat?.chatType === 2)
const chatNameFirstChar = computed(() => (im.currentChat?.name || '?')[0])

const presenceStatus = computed(() => {
  return 0
})

const headerSubtitle = computed(() => {
  if (!im.currentChat || !chatId.value) return ''
  const cid = chatId.value
  if (isGroup.value) {
    return `${im.currentChat.memberIds?.length || 0} 人`
  }
  const list = im.typingUsers.get(cid)
  if (list && list.some((t) => t.expireAt > _now.value)) {
    return '正在输入...'
  }
  const presence = presenceStatus.value
  if (presence === 1) return '在线'
  return '离线'
})

const announcement = computed(() => {
  if (!isGroup.value || !im.currentChat) return null
  return (im.currentChat as any).announcement ?? null
})

const pinnedMessages = computed(() => {
  const cid = chatId.value
  if (!cid) return []
  const chat = im.chats.get(cid)
  return (chat as any)?.pinnedMessages ?? []
})

const msgMenu = ref<{ show: boolean; x: number; y: number; msg: MessageItem | null }>({
  show: false, x: 0, y: 0, msg: null,
})
const forwardPicker = ref<{ show: boolean; sourceChatId: string; messageIds: string[] }>({
  show: false, sourceChatId: '', messageIds: [],
})
const showGroupProfile = ref(false)
const threadMsgId = ref<string | null>(null)
const typingTimer = ref<ReturnType<typeof setTimeout> | null>(null)

function onInputChanged() {
  const cid = chatId.value
  if (!cid) return
  checkMention()
  if (typingTimer.value) return
  typingTimer.value = setTimeout(() => {
    im.sendTyping(cid)
    typingTimer.value = null
  }, 1000)
}

function toggleChatSearch() {
  chatSearchVisible.value = !chatSearchVisible.value
  if (!chatSearchVisible.value) chatSearchQuery.value = ''
}

function doChatSearch() {
  console.log('chat search:', chatSearchQuery.value)
  // TODO: implement chat-local search
}

function showAnnouncement() {
  console.log('show announcement')
  // TODO: show announcement detail dialog
}

function showPinned() {
  console.log('show pinned messages')
  // TODO: show pinned messages list
}

function checkMention() {
  const el = textInputRef.value
  if (!el) return
  const text = inputText.value
  const cursorPos = el.selectionStart ?? text.length

  if (mention.value.show) {
    if (cursorPos <= mention.value.startPos) {
      mention.value.show = false
      return
    }
    mention.value.query = text.slice(mention.value.startPos + 1, cursorPos)
    return
  }

  // Check if we just typed @
  if (cursorPos > 0 && text[cursorPos - 1] === '@') {
    // Look back to find the start of the mention
    const beforeAt = cursorPos - 1
    // Only trigger if preceded by space or start of string
    if (beforeAt === 0 || text[beforeAt - 1] === ' ' || text[beforeAt - 1] === '\n') {
      mention.value = {
        show: true,
        query: '',
        top: 0,
        left: 0,
        startPos: cursorPos - 1,
      }
      positionMention(cursorPos)
    }
  }
}

function positionMention(cursorPos: number) {
  if (!textInputRef.value) return
  const rect = textInputRef.value.getBoundingClientRect()
  // Show above the input
  mention.value.top = rect.top - 220
  mention.value.left = rect.left + Math.min(cursorPos * 8, rect.width - 200)
}

function handleEnter(e: KeyboardEvent) {
  if (mention.value.show) {
    if (mentionPickerRef.value?.onKeydown(e)) return
  }
  send()
}

function handleKeydown(e: KeyboardEvent) {
  if (mention.value.show) {
    if (mentionPickerRef.value?.onKeydown(e)) return
  }
}

function onMentionSelect(user: { id: string; name: string }) {
  const text = inputText.value
  const start = mention.value.startPos
  if (start < 0) return
  const before = text.slice(0, start)
  const after = text.slice(start + 1 + mention.value.query.length)
  inputText.value = before + '@' + user.name + ' ' + after
  mention.value.show = false
  nextTick(() => {
    textInputRef.value?.focus()
  })
}

const chatId = computed<string | null>(() => {
  const p = route.params.chatId
  return Array.isArray(p) ? (p[0] ?? null) : (p ?? null)
})
const isAdmin = computed(() => {
  const chat = im.currentChat
  return chat ? chat.adminIds.includes(myId.value) || chat.ownerId === myId.value : false
})

watch(chatId, (id) => {
  if (id) {
    im.selectChat(id)
    im.loadMessages(id)
    autoScroll.value = true
  }
}, { immediate: true })

onMounted(() => {
  document.addEventListener('click', closeMsgMenu)
  _tick = setInterval(() => { _now.value = Date.now() }, 1000)
  const cid = chatId.value
  if (cid) {
    im.selectChat(cid)
    im.loadMessages(cid)
  }
})

onUnmounted(() => {
  document.removeEventListener('click', closeMsgMenu)
  clearInterval(_tick)
})

function goBack() {
  im.selectChat(null)
  router.push({ name: 'ImFeed' })
}

function goProfile() {
  if (im.currentChat?.chatType === 2) {
    showGroupProfile.value = true
  }
}

async function send() {
  const cid = chatId.value
  if (!cid) return
  const text = inputText.value.trim()
  if (!text) return
  try {
    const refMsg = im.replyTarget
    const refId = refMsg?.id || ''
    await im.sendTextMessage(cid, text, refId)
    im.setReplyTarget(null)
    inputText.value = ''
    autoScroll.value = true
    nextTick(() => scrollToBottom())
  } catch (e) {
    console.error('send error:', e)
  }
}

async function uploadAndSend(file: File, tpy: number) {
  const cid = chatId.value
  if (!cid) return
  const formData = new FormData()
  formData.append('file', file)
  try {
    const res = await api.post('/files/upload', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    const data = res.data
    if (tpy === 2) {
      const thumbUrl = data.thumbnail_url || data.url
      await im.sendImageMessage(cid, data.id, data.url, file.name, file.type, file.size, thumbUrl)
    } else {
      await im.sendFileMessage(cid, data.id, data.url, file.name, file.type, file.size)
    }
    im.setReplyTarget(null)
  } catch (e) {
    console.error('upload error:', e)
  }
}

async function retry(msg: MessageItem) {
  const cid = chatId.value
  if (!cid) return
  try {
    await im.retrySendMessage(cid, msg)
  } catch (e) {
    console.error('retry error:', e)
  }
}

async function onImageSelected(e: Event) {
  const input = e.target as HTMLInputElement
  const file = input?.files?.[0]
  if (!file) return
  await uploadAndSend(file, 2)
  input.value = ''
}

async function onFileSelected(e: Event) {
  const input = e.target as HTMLInputElement
  const file = input?.files?.[0]
  if (!file) return
  await uploadAndSend(file, 3)
  input.value = ''
}

function scrollToBottom() {
  if (msgListRef.value) {
    msgListRef.value.scrollTop = msgListRef.value.scrollHeight
  }
}

function onScroll() {
  const el = msgListRef.value
  const cid = chatId.value
  if (!el || !cid) return
  autoScroll.value = el.scrollHeight - el.scrollTop - el.clientHeight < 100
  if (el.scrollTop < 50 && im.hasMoreMessages && !im.loadingMessages) {
    im.loadMoreMessages(cid)
  }
}

function showDateSeparator(msg: MessageItem, idx: number): boolean {
  if (idx === 0) return true
  const prev = im.currentMessages[idx - 1]
  if (!prev) return true
  return !isSameDay(prev.createTimeMs, msg.createTimeMs)
}

function isSameDay(a: number, b: number): boolean {
  return new Date(a).toDateString() === new Date(b).toDateString()
}

function formatDate(ms: number): string {
  const d = new Date(ms)
  const now = new Date()
  if (d.toDateString() === now.toDateString()) return '今天'
  const yesterday = new Date(now); yesterday.setDate(yesterday.getDate() - 1)
  if (d.toDateString() === yesterday.toDateString()) return '昨天'
  return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`
}

function formatTime(ms: number): string {
  if (!ms) return ''
  const d = new Date(ms)
  return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`
}

function showSenderInfo(msg: MessageItem, idx: number): boolean {
  if (idx === 0) return true
  const prev = im.currentMessages[idx - 1]
  return !prev || prev.fromId !== msg.fromId
}

function getSenderFirstChar(fromId: string): string {
  const user = im.users.get(fromId)
  return (user?.name || '?')[0]
}

function getSenderName(fromId: string): string {
  const user = im.users.get(fromId)
  return user?.name || '未知用户'
}

function scrollToMessage(msgId: string) {
  const el = document.getElementById('msg-' + msgId)
  el?.scrollIntoView({ behavior: 'smooth', block: 'center' })
}

// 右键菜单
function showMsgMenu(e: MouseEvent, msg: MessageItem) {
  msgMenu.value = { show: true, x: e.clientX, y: e.clientY, msg }
}
function closeMsgMenu() {
  msgMenu.value = { show: false, x: 0, y: 0, msg: null }
}

function replyMessage(msg: MessageItem) {
  im.setReplyTarget(msg)
  closeMsgMenu()
  // 聚焦输入框
}

function copyMessage(msg: MessageItem) {
  navigator.clipboard.writeText(msg.summary || '')
  closeMsgMenu()
}

async function recall(msg: MessageItem) {
  try {
    await im.recallMessage(msg.id)
  } catch (e) {
    console.error('recall error:', e)
  }
  closeMsgMenu()
}

async function del(msg: MessageItem) {
  try {
    await im.deleteMessage(msg.id)
  } catch (e) {
    console.error('delete error:', e)
  }
  closeMsgMenu()
}

function forwardMsg(msg: MessageItem) {
  forwardPicker.value = {
    show: true,
    sourceChatId: chatId.value || '',
    messageIds: [msg.id],
  }
  closeMsgMenu()
}

function openThread(msg: MessageItem) {
  threadMsgId.value = msg.id
  closeMsgMenu()
}
</script>

<style scoped>
.chat-panel {
  display: flex;
  flex-direction: column;
  height: 100%;
  position: relative;
}
.slide-overlay {
  position: absolute;
  top: 0;
  right: 0;
  bottom: 0;
  z-index: 10;
  pointer-events: none;
}
.slide-overlay > * {
  pointer-events: auto;
}
.chat-header {
  display: flex;
  align-items: center;
  padding: 8px 16px;
  border-bottom: 1px solid #e0e0e0;
  background: #fff;
  flex-shrink: 0;
  height: 52px;
}
.back-btn {
  background: none;
  border: none;
  font-size: 18px;
  cursor: pointer;
  padding: 4px 8px 4px 0;
  margin-right: 8px;
  color: #666;
  display: flex;
  align-items: center;
}
.back-btn:hover { color: #333; }
.chat-header-left {
  display: flex;
  align-items: center;
  gap: 10px;
  flex: 1;
  min-width: 0;
  cursor: pointer;
}
.chat-avatar {
  width: 32px;
  height: 32px;
  border-radius: 6px;
  background: #1976d2;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 500;
  flex-shrink: 0;
  position: relative;
}
.presence-dot {
  position: absolute;
  bottom: -1px;
  right: -1px;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  border: 2px solid #fff;
  background: #ccc;
}
.presence-dot.online { background: #4caf50; }
.chat-header-info {
  min-width: 0;
}
.chat-name {
  font-size: 14px;
  font-weight: 600;
  line-height: 1.3;
}
.chat-subtitle {
  font-size: 11px;
  color: #999;
  line-height: 1.3;
}
.chat-header-actions {
  display: flex;
  align-items: center;
  gap: 4px;
  margin-left: 8px;
  flex-shrink: 0;
}
.header-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 6px;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #666;
}
.header-btn:hover { background: #f0f0f0; color: #333; }
.banner {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  font-size: 12px;
  cursor: pointer;
  flex-shrink: 0;
  border-bottom: 1px solid #f0f0f0;
}
.announcement-banner {
  background: #fffbe6;
  color: #b8860b;
}
.announcement-banner:hover { background: #fff3cc; }
.pinned-banner {
  background: #f5f5ff;
  color: #666;
}
.pinned-banner:hover { background: #ebebff; }
.banner-text {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.chat-search-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  border-bottom: 1px solid #e0e0e0;
  background: #fafafa;
  flex-shrink: 0;
}
.chat-search-input {
  flex: 1;
  border: none;
  background: transparent;
  outline: none;
  font-size: 13px;
}
.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
}
.msg-loading, .msg-empty {
  text-align: center;
  color: #999;
  padding: 40px 0;
  font-size: 13px;
}
.date-separator {
  text-align: center;
  font-size: 12px;
  color: #999;
  padding: 12px 0 8px;
}
.msg-item {
  display: flex;
  gap: 8px;
  margin-bottom: 8px;
  padding-left: 0;
}
.msg-item.msg-system {
  display: block;
  text-align: center;
  padding: 4px 0;
}
.msg-avatar {
  width: 32px;
  height: 32px;
  flex-shrink: 0;
  border-radius: 4px;
  background: #1976d2;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 13px;
  font-weight: 500;
  margin-top: 2px;
}
.same-sender .msg-avatar {
  visibility: hidden;
}
.msg-body {
  flex: 1;
  min-width: 0;
}
.msg-meta {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 2px;
  line-height: 1.4;
}
.same-sender .msg-meta {
  display: none;
}
.msg-name {
  font-size: 12px;
  color: #666;
  font-weight: 500;
}
.reply-preview {
  font-size: 12px;
  color: #1976d2;
  padding: 4px 8px;
  margin-bottom: 2px;
  border-left: 2px solid #1976d2;
  cursor: pointer;
  max-width: 70%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.msg-bubble {
  display: inline-block;
  max-width: 70%;
  padding: 8px 12px;
  border-radius: 8px;
  background: #e9ecef;
  color: #333;
  font-size: 14px;
  line-height: 1.4;
  word-break: break-word;
  text-align: left;
}
.msg-foot {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-top: 2px;
}
.msg-status.sending {
  font-size: 10px;
  color: #999;
  animation: pulse 1.2s infinite;
}
.msg-status.failed {
  font-size: 10px;
  color: #f44336;
  cursor: pointer;
  text-decoration: underline;
}
.msg-read-status {
  font-size: 10px;
  color: #1976d2;
}
.msg-time {
  font-size: 11px;
  color: #bbb;
}
@keyframes pulse {
  0%, 100% { opacity: 0.5; }
  50% { opacity: 1; }
}
.chat-actions {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 6px 12px 0;
  background: #fff;
  flex-shrink: 0;
}
.action-btn {
  background: none;
  border: 1px solid #e0e0e0;
  border-radius: 6px;
  padding: 4px 8px;
  font-size: 16px;
  cursor: pointer;
  line-height: 1;
}
.action-btn:hover { background: #f0f0f0; }

.chat-input {
  display: flex;
  align-items: center;
  padding: 10px 12px;
  border-top: 1px solid #e0e0e0;
  background: #fff;
  flex-shrink: 0;
}
.text-input {
  flex: 1;
  padding: 8px 12px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  font-size: 14px;
  outline: none;
}
.text-input:focus { border-color: #1976d2; }
.send-btn {
  margin-left: 8px;
  padding: 8px 16px;
  background: #1976d2;
  color: #fff;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  cursor: pointer;
}
.send-btn:disabled { opacity: 0.5; cursor: not-allowed; }
.send-btn:hover:not(:disabled) { background: #1565c0; }

.context-menu {
  position: fixed;
  z-index: 9999;
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  box-shadow: 0 4px 16px rgba(0,0,0,0.12);
  min-width: 120px;
  padding: 4px;
}
.menu-item {
  padding: 8px 12px;
  border-radius: 6px;
  font-size: 13px;
  cursor: pointer;
  white-space: nowrap;
}
.menu-item:hover { background: #f0f0f0; }
.menu-item.danger { color: #f44336; }

.slide-enter-active, .slide-leave-active {
  transition: all 0.2s ease;
}
.slide-enter-from { transform: translateX(100%); }
.slide-leave-to { transform: translateX(100%); }
</style>