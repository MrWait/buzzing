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
      <span class="banner-text">{{ announcement.title || announcement.summary }}</span>
      <span v-if="isAdmin" class="banner-del" title="删除公告" @click.stop="deleteAnnouncement">✕</span>
    </div>

    <!-- 置顶消息横幅 -->
    <div v-if="pinnedMessages.length > 0" class="banner pinned-banner" @click="showPinned">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="17" x2="12" y2="22"/><path d="M5 17h14v-1.76a2 2 0 0 0-1.11-1.79l-1.78-.9A2 2 0 0 1 15 10.76V6h1a2 2 0 0 0 0-4H8a2 2 0 0 0 0 4h1v4.76a2 2 0 0 1-1.11 1.79l-1.78.9A2 2 0 0 0 5 15.24Z"/></svg>
      <span class="banner-text">置顶 {{ pinnedMessages.length }} 条消息 · {{ pinnedMessages[0]?.summary || '查看置顶' }}</span>
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
      <button class="header-btn" @click="closeChatSearch">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
      </button>
    </div>
    <!-- 聊天内搜索结果 (W4-6) -->
    <div v-if="chatSearchVisible && chatSearchResults.length > 0" class="chat-search-results">
      <div
        v-for="r in chatSearchResults"
        :key="r.id"
        class="chat-search-result"
        @click="openSearchResult(r)"
      >
        <div class="chat-search-result-preview" v-html="r.highlight || r.summary"></div>
        <div class="chat-search-result-time">{{ formatTime(r.createTimeMs) }}</div>
      </div>
      <div v-if="chatSearchLoading" class="chat-search-status">搜索中...</div>
      <div v-else-if="!chatSearchResults.length && chatSearchQuery.trim() && chatSearchDone" class="chat-search-status">无结果</div>
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
            :data-msg-id="msg.id"
            @click.right.prevent="showMsgMenu($event, msg)"
          >
            <div class="msg-avatar">
              <img v-if="showSenderInfo(msg, idx) && getSenderAvatar(msg.fromId)" class="msg-avatar-img" :src="getSenderAvatar(msg.fromId)" />
              <span v-else-if="showSenderInfo(msg, idx)">{{ getSenderFirstChar(msg.fromId) }}</span>
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
                <TextMessage v-if="msg.tpy === 1" :content="msg.content" :translation="msg.translation?.translatedText" />
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
                <span
                  v-if="msg.sendStatus === 'sent' && msg.fromId === myId"
                  class="msg-read-status"
                  :class="{ clickable: isGroup }"
                  @click.stop="openReadDialog(msg)"
                >{{ readStatusText(msg) }}</span>
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
    <div v-if="muted" class="chat-muted-hint">群聊已开启全员禁言</div>
    <div class="chat-input">
      <input
        ref="textInputRef"
        v-model="inputText"
        class="text-input"
        placeholder="输入消息..."
        :disabled="muted"
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
      <button class="send-btn" @click="send" :disabled="!inputText.trim() || muted">发送</button>
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
        <div v-if="msgMenu.msg?.tpy === 1" class="menu-item" @click="toggleTranslate(msgMenu.msg!)">{{ msgMenu.msg?.translation ? '取消翻译' : '翻译' }}</div>
        <div v-if="isAdmin" class="menu-item" @click="togglePin(msgMenu.msg!)">{{ isPinned(msgMenu.msg!) ? '取消置顶' : '置顶' }}</div>
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

    <!-- 已读详情弹窗 -->
    <Teleport to="body">
      <div v-if="readDialog.show" class="read-dialog-overlay" @click.self="closeReadDialog">
        <div class="read-dialog">
          <div class="read-dialog-header">
            <span>已读详情</span>
            <button class="header-btn" title="刷新" @click="refreshReadDialog">刷新</button>
            <button class="header-btn" title="关闭" @click="closeReadDialog">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            </button>
          </div>
          <div v-if="readDialog.loading" class="read-dialog-loading">加载中...</div>
          <div v-else class="read-dialog-body">
            <div v-if="readDialog.members.length === 0" class="read-dialog-empty">暂无成员</div>
            <template v-else>
              <div class="read-column">
                <div class="read-column-title">已读 ({{ readDialog.members.filter((m: any) => m.is_read).length }})</div>
                <div
                  v-for="m in readDialog.members.filter((x: any) => x.is_read)"
                  :key="m.user_id"
                  class="read-member"
                >
                  <span class="read-member-avatar">{{ (m.name || '?')[0] }}</span>
                  <span class="read-member-name">{{ m.name || '未知用户' }}</span>
                </div>
              </div>
              <div class="read-column">
                <div class="read-column-title">未读 ({{ readDialog.members.filter((m: any) => !m.is_read).length }})</div>
                <div
                  v-for="m in readDialog.members.filter((x: any) => !x.is_read)"
                  :key="m.user_id"
                  class="read-member"
                >
                  <span class="read-member-avatar">{{ (m.name || '?')[0] }}</span>
                  <span class="read-member-name">{{ m.name || '未知用户' }}</span>
                </div>
              </div>
            </template>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- 群公告详情/编辑弹窗 -->
    <Teleport to="body">
      <div v-if="announceDialog.show" class="read-dialog-overlay" @click.self="closeAnnounceDialog">
        <div class="read-dialog">
          <div class="read-dialog-header">
            <span>{{ announceDialog.mode === 'edit' ? '编辑群公告' : '群公告' }}</span>
            <button class="header-btn" title="关闭" @click="closeAnnounceDialog">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            </button>
          </div>
          <template v-if="announceDialog.mode !== 'edit'">
            <div v-if="announceDialog.announcement" class="announce-view">
              <div class="announce-title">{{ announceDialog.announcement.title || '群公告' }}</div>
              <div class="announce-meta">
                {{ publisherName }}<span v-if="announceTime"> · {{ announceTime }}</span>
              </div>
              <div class="announce-body">{{ announceDialog.announcement.bodyText || announceDialog.announcement.summary }}</div>
              <div class="announce-actions" v-if="isAdmin">
                <button class="confirm-btn primary small" @click="editAnnounce()">编辑</button>
                <button class="confirm-btn danger small" @click="deleteAnnouncement()">删除</button>
              </div>
            </div>
          </template>
          <template v-else>
            <label class="announce-field"><span>标题</span><input v-model="announceTitle" placeholder="公告标题" /></label>
            <label class="announce-field"><span>内容</span><textarea v-model="announceBody" rows="5" placeholder="公告内容"></textarea></label>
            <div class="announce-actions">
              <button class="confirm-btn cancel small" @click="announceDialog.mode = 'view'">取消</button>
              <button class="confirm-btn primary small" :disabled="announceSaving" @click="saveAnnounce()">保存</button>
            </div>
          </template>
        </div>
      </div>
    </Teleport>

    <!-- 置顶消息列表弹窗 (W4-1) -->
    <Teleport to="body">
      <div v-if="pinnedDialog.show" class="read-dialog-overlay" @click.self="pinnedDialog.show = false">
        <div class="read-dialog">
          <div class="read-dialog-header">
            <span>置顶消息</span>
            <button class="header-btn" title="关闭" @click="pinnedDialog.show = false">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            </button>
          </div>
          <div v-if="pinnedMessages.length === 0" class="read-empty">暂无置顶消息</div>
          <div v-else class="pinned-list">
            <div v-for="msg in pinnedMessages" :key="msg.id" class="pinned-item" @click="jumpToMessage(msg)">
              <div class="pinned-item-top">
                <span class="pinned-item-name">{{ userName(msg.fromId) }}</span>
                <span class="pinned-item-time">{{ formatTime(msg.createTimeMs) }}</span>
                <button v-if="isAdmin" class="header-btn" title="取消置顶" @click.stop="unpin(msg.id)">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="17" x2="12" y2="22"/><path d="M5 17h14v-1.76a2 2 0 0 0-1.11-1.79l-1.78-.9A2 2 0 0 1 15 10.76V6h1a2 2 0 0 0 0-4H8a2 2 0 0 0 0 4h1v4.76a2 2 0 0 1-1.11 1.79l-1.78.9A2 2 0 0 0 5 15.24Z"/></svg>
                </button>
              </div>
              <div class="pinned-item-body">{{ msg.summary }}</div>
            </div>
          </div>
        </div>
      </div>
    </Teleport>
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
// W4-3: 待发送的结构化 @提及（发送时解析 offset/length）
const pendingMentions = ref<{ userId: string; name: string }[]>([])
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

// W5-1: P2P 对方用户（memberIds 中非自己的那个）
const peerUserId = computed(() => {
  const chat = im.currentChat
  if (!chat || chat.chatType !== 1) return ''
  return chat.memberIds.find((id) => id !== myId.value) || ''
})

const presenceStatus = computed(() => {
  const uid = peerUserId.value
  if (!uid) return 0
  return im.users.get(uid)?.status || 0
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

// 群处于全员禁言时禁用输入（与客户端 message_input 一致：仅基于 globalMuteUntil）
const muted = computed(() => {
  const until = im.currentChat?.globalMuteUntil || 0
  return isGroup.value && until > 0 && until > Date.now()
})

// ─── 群公告详情/编辑（W3-3）─────────────────────────────────────
const announceDialog = ref<{ show: boolean; mode: 'view' | 'edit'; announcement: any }>({
  show: false,
  mode: 'view',
  announcement: null,
})
const announceTitle = ref('')
const announceBody = ref('')
const announceSaving = ref(false)

const publisherName = computed(() => {
  const fromId = announceDialog.value.announcement?.fromId
  return fromId ? im.users.get(fromId)?.name || '未知用户' : ''
})
const announceTime = computed(() => {
  const ms = announceDialog.value.announcement?.createTimeMs
  return ms ? formatTime(ms) : ''
})

function showAnnouncement() {
  announceDialog.value = { show: true, mode: 'view', announcement: announcement.value }
}

function editAnnounce() {
  const a = announceDialog.value.announcement
  announceTitle.value = a?.title || ''
  announceBody.value = a?.bodyText || a?.summary || ''
  announceDialog.value.mode = 'edit'
}

function closeAnnounceDialog() {
  announceDialog.value.show = false
}

async function saveAnnounce() {
  const cid = chatId.value
  if (!cid || announceSaving.value) return
  announceSaving.value = true
  try {
    await im.setAnnouncement(cid, announceTitle.value.trim(), announceBody.value)
    announceDialog.value.mode = 'view'
  } catch (e) {
    console.error('save announcement error:', e)
  } finally {
    announceSaving.value = false
  }
}

async function deleteAnnouncement() {
  const cid = chatId.value
  if (!cid) return
  if (announceDialog.value.show) announceDialog.value.show = false
  await im.deleteAnnouncement(cid)
}

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

// ─── 已读回执（W1）─────────────────────────────────────────────
const readDialog = ref<{ show: boolean; msg: MessageItem | null; members: any[]; loading: boolean }>({
  show: false, msg: null, members: [], loading: false,
})
let seenTimer: ReturnType<typeof setTimeout> | null = null

// id → message 索引，用于上屏已读可见区判定
const msgById = computed(() => {
  const m = new Map<string, MessageItem>()
  for (const msg of im.currentMessages) m.set(msg.id, msg)
  return m
})

// 已读标记文案：有 read_state 则按真实值（群显示 x/y），否则乐观显示「已读」
function readStatusText(msg: MessageItem): string {
  const rs = msg.readState
  if (rs && rs.total > 0 && rs.unreadCount > 0) {
    return `${rs.readCount}/${rs.total}`
  }
  return '已读'
}

function openReadDialog(msg: MessageItem) {
  if (!isGroup.value) return
  readDialog.value = { show: true, msg, members: [], loading: true }
  refreshReadDialog()
}

async function refreshReadDialog() {
  const cid = chatId.value
  const msg = readDialog.value.msg
  if (!cid || !msg) return
  readDialog.value.loading = true
  readDialog.value.members = await im.getReadMembers(cid, msg.id)
  readDialog.value.loading = false
}

function closeReadDialog() {
  readDialog.value.show = false
}

// 防抖上屏已读上报：可见非本人消息精确 id + 可见最大 pos/badge_count → MESSAGE_READ
function scheduleReportSeen() {
  if (seenTimer) return
  seenTimer = setTimeout(() => {
    seenTimer = null
    doReportSeen()
  }, 300)
}

function doReportSeen() {
  const el = msgListRef.value
  const cid = chatId.value
  if (!el || !cid) return
  const container = el.getBoundingClientRect()
  const items = el.querySelectorAll<HTMLElement>('[data-msg-id]')
  const seenIds: string[] = []
  let maxPos = 0
  let maxBadge = 0
  for (const it of items) {
    const id = it.getAttribute('data-msg-id')!
    const msg = msgById.value.get(id)
    if (!msg || msg.fromId === myId.value) continue
    const r = it.getBoundingClientRect()
    // 只要与可见区相交即视为已读（部分可见也算）
    if (r.bottom < container.top || r.top > container.bottom) continue
    if (msg.pos > maxPos) {
      maxPos = msg.pos
      maxBadge = msg.badgeCount
    }
    seenIds.push(id)
  }
  if (seenIds.length > 0 || maxPos > 0) {
    im.reportSeen(cid, seenIds, maxPos, maxBadge)
  }
}

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
  if (!chatSearchVisible.value) {
    chatSearchQuery.value = ''
    chatSearchResults.value = []
  }
}

function closeChatSearch() {
  chatSearchVisible.value = false
  chatSearchQuery.value = ''
  chatSearchResults.value = []
}

interface ChatSearchResult {
  id: string
  summary: string
  highlight: string
  pos: number
  createTimeMs: number
}

const chatSearchResults = ref<ChatSearchResult[]>([])
const chatSearchLoading = ref(false)
const chatSearchDone = ref(false)

async function doChatSearch() {
  const q = chatSearchQuery.value.trim()
  const cid = chatId.value
  if (!q || !cid) return
  chatSearchLoading.value = true
  chatSearchDone.value = false
  try {
    const { searchMessages } = await import('@/services/im/api')
    const resp = await searchMessages(q, { chat_id: cid }, 1, 20)
    chatSearchResults.value = ((resp.results || []) as any[]).map((r) => {
      const msg = r.message || {}
      return {
        id: String(msg.id || '0'),
        summary: msg.summary || '',
        highlight: r.highlight || msg.summary || '',
        pos: Number(msg.pos || 0),
        createTimeMs: Number(msg.create_time_ms || 0),
      }
    })
  } catch (e) {
    console.error('chat search error:', e)
    chatSearchResults.value = []
  }
  chatSearchLoading.value = false
  chatSearchDone.value = true
}

// 跳转到搜索结果：已加载则滚动高亮，否则按 pos 拉取附近消息后滚动
async function openSearchResult(r: ChatSearchResult) {
  const cid = chatId.value
  if (!cid) return
  const highlight = async () => {
    await nextTick()
    const el = msgListRef.value?.querySelector<HTMLElement>(`[data-msg-id="${r.id}"]`)
    if (el) {
      el.scrollIntoView({ behavior: 'smooth', block: 'center' })
      el.classList.add('msg-highlight')
      setTimeout(() => el.classList.remove('msg-highlight'), 2000)
      return true
    }
    return false
  }
  if (await highlight()) return
  // 未加载：按 pos 拉取一段消息后再定位
  await im.loadMessages(cid, r.pos, 20)
  await highlight()
}

// ─── W4-1: 置顶消息 ──────────────────────────────────────────────
const pinnedDialog = ref({ show: false })

function showPinned() {
  pinnedDialog.value.show = true
}

function isPinned(msg: MessageItem): boolean {
  return pinnedMessages.value.some((p: MessageItem) => p.id === msg.id)
}

async function togglePin(msg: MessageItem) {
  const cid = chatId.value
  if (!cid) return
  try {
    if (isPinned(msg)) await im.unpinMessage(cid, msg.id)
    else await im.pinMessage(cid, msg.id)
  } catch (e) {
    console.error('toggle pin error:', e)
  }
}

// W4-4: 翻译（目标语言默认 zh，参照客户端 im.dart translateMessage）
async function toggleTranslate(msg: MessageItem) {
  const cid = chatId.value
  if (!cid) return
  if (msg.translation) {
    im.clearTranslation(msg.id, cid)
    return
  }
  try {
    await im.translateMessage(msg.id, cid, 'zh')
  } catch (e) {
    console.error('translate error:', e)
  }
}

async function unpin(messageId: string) {
  const cid = chatId.value
  if (!cid) return
  try {
    await im.unpinMessage(cid, messageId)
  } catch (e) {
    console.error('unpin error:', e)
  }
}

// 跳转到被置顶的消息：查找该消息所在会话并滚动定位
function jumpToMessage(msg: MessageItem) {
  pinnedDialog.value.show = false
  const cid = chatId.value
  if (!cid) return
  const target = msg.id
  nextTick(() => {
    const el = msgListRef.value?.querySelector<HTMLElement>(`[data-msg-id="${target}"]`)
    el?.scrollIntoView({ behavior: 'smooth', block: 'center' })
    if (el) {
      el.classList.add('msg-highlight')
      setTimeout(() => el.classList.remove('msg-highlight'), 2000)
    }
  })
}

function userName(uid: string): string {
  return im.users.get(uid)?.name || '未知用户'
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
  // W4-3: 记录待发送的结构化提及（user_id 用于后端 @ 通知）
  pendingMentions.value.push({ userId: user.id, name: user.name })
  mention.value.show = false
  nextTick(() => {
    textInputRef.value?.focus()
  })
}

// W4-3: 发送时把已选择的 @成员 按最终文本位置解析为 Mention{user_id,name,offset,length}
function buildMentions(text: string) {
  const out: { userId: string; name: string; offset: number; length: number }[] = []
  let searchFrom = 0
  for (const m of pendingMentions.value) {
    const token = '@' + m.name
    const idx = text.indexOf(token, searchFrom)
    if (idx < 0) continue
    out.push({ userId: m.userId, name: m.name, offset: idx, length: token.length })
    searchFrom = idx + token.length
  }
  return out
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
    im.loadPinnedMessages(id)
    autoScroll.value = true
    nextTick(() => scheduleReportSeen())
  }
}, { immediate: true })

// 新消息到达/翻页后，重新计算上屏已读
watch(() => im.currentMessages.length, () => {
  scheduleReportSeen()
})

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
    // W4-3: 携带结构化 mentions（user_id + offset/length）
    const mentions = buildMentions(text)
    await im.sendTextMessage(cid, text, refId, mentions)
    pendingMentions.value = []
    im.setReplyTarget(null)
    inputText.value = ''
    autoScroll.value = true
    nextTick(() => { scrollToBottom(); scheduleReportSeen() })
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
  scheduleReportSeen()
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

function getSenderAvatar(fromId: string): string {
  const user = im.users.get(fromId)
  return user?.avatar || ''
}

function getSenderName(fromId: string): string {
  const user = im.users.get(fromId)
  return user?.name || '未知用户'
}

async function scrollToMessage(msgId: string) {
  const el = msgListRef.value?.querySelector<HTMLElement>(`[data-msg-id="${msgId}"]`)
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
.read-empty {
  padding: 32px 0;
  text-align: center;
  color: #999;
  font-size: 13px;
}
.pinned-list {
  max-height: 360px;
  overflow-y: auto;
}
.pinned-item {
  padding: 10px 12px;
  border-bottom: 1px solid #f0f0f0;
  cursor: pointer;
}
.pinned-item:hover { background: #f7f7f7; }
.pinned-item-top {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 4px;
}
.pinned-item-name { font-size: 13px; font-weight: 600; color: #333; }
.pinned-item-time { font-size: 12px; color: #999; flex: 1; }
.pinned-item-body {
  font-size: 13px;
  color: #666;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.msg-highlight {
  animation: msg-highlight-flash 2s ease;
}
@keyframes msg-highlight-flash {
  0%, 60% { background-color: #fffbe6; }
  100% { background-color: transparent; }
}
.banner-text {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.banner-del {
  margin-left: auto;
  padding: 0 4px;
  color: #999;
  font-size: 12px;
  cursor: pointer;
}
.banner-del:hover { color: #333; }
.chat-muted-hint {
  padding: 6px 16px;
  text-align: center;
  font-size: 12px;
  color: #999;
  background: #fff7e6;
  border-top: 1px solid #ffe7ba;
  flex-shrink: 0;
}
.chat-search-results {
  flex-shrink: 0;
  max-height: 220px;
  overflow-y: auto;
  border-bottom: 1px solid #f0f0f0;
  background: #fff;
}
.chat-search-result {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px 16px;
  cursor: pointer;
}
.chat-search-result:hover { background: #f5f5f5; }
.chat-search-result-preview {
  flex: 1;
  min-width: 0;
  font-size: 13px;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.chat-search-result-preview :deep(mark) { color: #e6a23c; background: transparent; font-weight: 600; }
.chat-search-result-time {
  font-size: 12px;
  color: #999;
  flex-shrink: 0;
}
.chat-search-status {
  padding: 16px;
  text-align: center;
  font-size: 12px;
  color: #999;
}
.announce-view { padding: 8px 4px; }
.announce-title { font-size: 16px; font-weight: 600; margin-bottom: 6px; }
.announce-meta { font-size: 12px; color: #999; margin-bottom: 12px; }
.announce-body {
  font-size: 14px;
  color: #333;
  white-space: pre-wrap;
  word-break: break-word;
}
.announce-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 16px;
}
.announce-field {
  display: flex;
  flex-direction: column;
  gap: 4px;
  margin-bottom: 12px;
  font-size: 13px;
  color: #666;
}
.announce-field input,
.announce-field textarea {
  border: 1px solid #ddd;
  border-radius: 6px;
  padding: 8px;
  font-size: 14px;
  outline: none;
  resize: none;
}
.announce-field input:focus,
.announce-field textarea:focus { border-color: #1976d2; }
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
  overflow: hidden;
}
.msg-avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
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
.msg-read-status.clickable {
  cursor: pointer;
  text-decoration: underline;
}
.read-dialog-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0,0,0,0.35);
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
}
.read-dialog {
  background: #fff;
  border-radius: 10px;
  width: 360px;
  max-height: 70vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.read-dialog-header {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  border-bottom: 1px solid #eee;
  font-size: 14px;
  font-weight: 600;
}
.read-dialog-header .header-btn {
  margin-left: auto;
}
.read-dialog-loading,
.read-dialog-empty {
  padding: 30px 16px;
  text-align: center;
  color: #999;
  font-size: 13px;
}
.read-dialog-body {
  flex: 1;
  overflow-y: auto;
  display: flex;
  gap: 16px;
  padding: 12px 16px;
}
.read-column {
  flex: 1;
  min-width: 0;
}
.read-column-title {
  font-size: 12px;
  color: #999;
  margin-bottom: 8px;
}
.read-member {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 0;
}
.read-member-avatar {
  width: 26px;
  height: 26px;
  border-radius: 50%;
  background: #1976d2;
  color: #fff;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  flex-shrink: 0;
}
.read-member-name {
  font-size: 13px;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
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