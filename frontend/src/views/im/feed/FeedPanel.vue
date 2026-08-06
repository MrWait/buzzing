<template>
  <div class="feed-panel">
    <div class="feed-header">
      <h3>消息</h3>
      <div class="ws-status" :class="{ connected: im.connected }" :title="im.connected ? '已连接' : '未连接'" />
    </div>
    <div v-if="im.loadingFeeds && filteredList.length === 0" class="feed-loading">加载中...</div>
    <div v-else-if="filteredList.length === 0" class="feed-empty">暂无会话</div>
    <div v-else class="feed-list">
      <div
        v-for="feed in filteredList"
        :key="feed.id"
        class="feed-item"
        :class="{ active: feed.id === im.currentFeedId }"
        @click="selectFeed(feed)"
        @contextmenu.prevent="showContextMenu($event, feed)"
      >
        <div class="feed-avatar" :style="{ background: feed.isMute ? '#999' : '#1976d2' }">
          <img v-if="feedAvatar(feed)" class="feed-avatar-img" :src="feedAvatar(feed)" alt="" />
          <template v-else>{{ feedName(feed).charAt(0).toUpperCase() || '?' }}</template>
          <span v-if="isPeerOnline(feed)" class="feed-online-dot" />
        </div>
        <div class="feed-body">
          <div class="feed-top">
            <span class="feed-name">{{ feedName(feed) }}</span>
            <span class="feed-time">{{ formatTime(feed.updateTimeMs) }}</span>
          </div>
          <div class="feed-bottom">
            <span class="feed-msg">
              <span v-if="feedPreview(feed).showRead" class="feed-read-mark">
                <svg width="14" height="14" viewBox="0 0 14 14">
                  <circle cx="7" cy="7" r="6" fill="none" stroke="#4ADE80" stroke-opacity="0.8" stroke-width="1.5" />
                  <circle
                    v-if="feedPreview(feed).readPercent > 0"
                    cx="7" cy="7" r="6" fill="none" stroke="#4ADE80" stroke-width="1.5"
                    stroke-linecap="round"
                    :stroke-dasharray="feedRingDash(feedPreview(feed).readPercent)"
                    transform="rotate(-90 7 7)"
                  />
                  <text
                    v-if="feedPreview(feed).readPercent >= 100"
                    x="7" y="7" text-anchor="middle"
                    dominant-baseline="central"
                    fill="#4ADE80" font-size="9" font-weight="700"
                  >✓</text>
                </svg>
              </span>{{ feedPreview(feed).text }}
            </span>
            <span v-if="feed.badge > 0" class="feed-badge">{{ feed.badge > 99 ? '99+' : feed.badge }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 右键菜单 -->
    <Teleport to="body">
      <div v-if="contextMenu.show" class="context-menu" :style="{ top: contextMenu.y + 'px', left: contextMenu.x + 'px' }" @click.stop @contextmenu.prevent>
        <div class="menu-item" @click="toggleTop(contextMenu.feed!)">
          {{ contextMenu.feed?.isTop ? '取消置顶' : '置顶' }}
        </div>
        <div class="menu-item" @click="toggleMute(contextMenu.feed!)">
          {{ contextMenu.feed?.isMute ? '取消免打扰' : '消息免打扰' }}
        </div>
        <div class="menu-item" @click="markRead(contextMenu.feed!)">标记已读</div>
        <div class="menu-item danger" @click="remove(contextMenu.feed!)">删除会话</div>
      </div>
    </Teleport>

    <!-- 用户资料浮层保留给其他场景，不在此使用 -->
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { useImStore } from '@/stores/im'
import { useAuthStore } from '@/stores/auth'
import type { FeedItem } from '@/stores/im'

const router = useRouter()
const im = useImStore()
const auth = useAuthStore()

const contextMenu = ref<{ show: boolean; x: number; y: number; feed: FeedItem | null }>({
  show: false,
  x: 0,
  y: 0,
  feed: null,
})

const filteredList = computed(() => im.feedList)

// W5-1: P2P 会话头像在线圆点（peer 状态来自 PUSH_PRESENCE 1352 更新的 users）
function isPeerOnline(feed: FeedItem): boolean {
  if (feed.type !== 1) return false
  const chat = im.chats.get(feed.chatId)
  if (!chat) return false
  const peer = chat.memberIds.find((id) => id !== myId.value)
  if (!peer) return false
  return (im.users.get(peer)?.status || 0) === 1
}

const myId = computed(() => String(auth.user?.id ?? ''))

// P2P 会话无 name：展示名/头像取自对方用户（群聊用群名）
function feedName(feed: FeedItem): string {
  const chat = im.chats.get(feed.chatId)
  const name = im.chatDisplayName(chat)
  return name || '...'
}

function feedAvatar(feed: FeedItem): string {
  const chat = im.chats.get(feed.chatId)
  return im.chatDisplayAvatar(chat)
}

// 消息预览：群聊展示「发送人: 摘要」；单聊展示摘要。
// 是否展示已读状态标记仅取决于是否自己发送的消息，与已读状态数据、会话类型无关。
// 有已读数据则按比例填充绿环、满格 ✓；无数据（total<=0）时展示空心环（对齐客户端 _ReadCircle）。
function feedPreview(feed: FeedItem): { text: string; showRead: boolean; readPercent: number } {
  const chat = im.chats.get(feed.chatId)
  const isGroup = chat?.chatType === 2
  const senderId = feed.lastMsgFromId || ''
  const senderName = im.users.get(senderId)?.name || ''
  const isSelf = senderId !== '' && senderId === myId.value
  const text = isGroup
    ? senderName ? `${senderName}: ${feed.lastMsg || ''}` : feed.lastMsg || '...'
    : feed.lastMsg || '...'
  return { text, showRead: isSelf, readPercent: feedReadPercent(feed) }
}

// 会话最后一条消息的已读进度（0~100）：对齐客户端 _ReadStateIndicator/_readPercent
function feedReadPercent(feed: FeedItem): number {
  if (!feed.referId || feed.referId === '0') return 0
  const msgs = im.messages.get(feed.chatId) || []
  const last = msgs.find((m) => m.id === feed.referId)
  const rs = last?.readState
  if (!rs || rs.total <= 0) return 0
  const pct = Math.round((rs.readCount / rs.total) * 100)
  if (pct >= 100) return 100
  const stepped = Math.floor(pct / 10) * 10
  return Math.max(10, Math.min(90, stepped))
}

// 已读进度环 SVG dash 值：周长为 2π*6（r=6），进度按百分比显示（对齐客户端 _ReadCirclePainter）
function feedRingDash(percent: number): string {
  const circum = 2 * Math.PI * 6
  return `${(percent / 100) * circum} ${circum}`
}

onMounted(() => {
  document.addEventListener('click', closeContextMenu)
})

onUnmounted(() => {
  document.removeEventListener('click', closeContextMenu)
})

function selectFeed(feed: FeedItem) {
  im.currentFeedId = feed.id
  im.selectChat(feed.chatId)
  closeContextMenu()
  // 已停留在 /im/chat 时无需重复跳转（会话切换只改 store 状态，URL 不变）
  if (router.currentRoute.value.path !== '/im/chat') {
    router.push({ name: 'ImChatMain' })
  }
}

function showContextMenu(e: MouseEvent, feed: FeedItem) {
  contextMenu.value = { show: true, x: e.clientX, y: e.clientY, feed }
}

function closeContextMenu() {
  contextMenu.value = { show: false, x: 0, y: 0, feed: null }
}

function toggleTop(feed: FeedItem) {
  im.setFeedTop(feed.id, !feed.isTop)
  closeContextMenu()
}

function toggleMute(feed: FeedItem) {
  im.setFeedMute(feed.id, !feed.isMute)
  closeContextMenu()
}

function markRead(feed: FeedItem) {
  im.markFeedRead(feed.chatId)
  closeContextMenu()
}

function remove(feed: FeedItem) {
  im.removeFeed(feed.id)
  closeContextMenu()
}

function formatTime(ms: number): string {
  if (!ms) return ''
  const d = new Date(ms)
  const now = new Date()
  const isToday = d.toDateString() === now.toDateString()
  if (isToday) {
    return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`
  }
  const yesterday = new Date(now)
  yesterday.setDate(yesterday.getDate() - 1)
  if (d.toDateString() === yesterday.toDateString()) return '昨天'
  return `${String(d.getMonth() + 1).padStart(2, '0')}/${String(d.getDate()).padStart(2, '0')}`
}
</script>

<style scoped>
.feed-panel {
  display: flex;
  flex-direction: column;
  height: 100%;
  width: 300px;
  min-width: 300px;
  border-right: 1px solid #e0e0e0;
}
.feed-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px 8px;
}
.feed-header h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
}
.ws-status {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #f44336;
  transition: background 0.3s;
}
.ws-status.connected {
  background: #4caf50;
}
.feed-loading,
.feed-empty {
  padding: 40px 16px;
  text-align: center;
  color: #999;
  font-size: 13px;
}
.feed-list {
  flex: 1;
  overflow-y: auto;
}
.feed-item {
  display: flex;
  padding: 10px 12px;
  cursor: pointer;
  transition: background 0.15s;
}
.feed-item:hover {
  background: #e9ecef;
}
.feed-item.active {
  background: #d0ebff;
}
.feed-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  font-weight: 600;
  flex-shrink: 0;
  margin-right: 10px;
  position: relative;
  overflow: hidden;
}
.feed-avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.feed-online-dot {
  position: absolute;
  right: -2px;
  bottom: -2px;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: #4caf50;
  border: 2px solid #fff;
}
.feed-body {
  flex: 1;
  min-width: 0;
}
.feed-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.feed-name {
  font-size: 14px;
  font-weight: 500;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.feed-time {
  font-size: 11px;
  color: #999;
  flex-shrink: 0;
  margin-left: 8px;
}
.feed-bottom {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 2px;
}
.feed-msg {
  font-size: 12px;
  color: #888;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.feed-read-mark {
  display: inline-flex;
  vertical-align: middle;
  margin-right: 4px;
}
.feed-badge {
  background: #f44336;
  color: #fff;
  font-size: 11px;
  min-width: 18px;
  height: 18px;
  border-radius: 9px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 5px;
  flex-shrink: 0;
  margin-left: 6px;
}

.context-menu {
  position: fixed;
  z-index: 9999;
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  box-shadow: 0 4px 16px rgba(0,0,0,0.12);
  min-width: 140px;
  padding: 4px;
}
.menu-item {
  padding: 8px 12px;
  border-radius: 6px;
  font-size: 13px;
  cursor: pointer;
  white-space: nowrap;
}
.menu-item:hover {
  background: #f0f0f0;
}
.menu-item.danger {
  color: #f44336;
}
</style>
