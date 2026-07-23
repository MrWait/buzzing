<template>
  <div class="feed-panel">
    <div class="feed-header">
      <h3>消息</h3>
      <div class="ws-status" :class="{ connected: im.connected }" :title="im.connected ? '已连接' : '未连接'" />
    </div>
    <div class="feed-search">
      <input v-model="searchText" class="search-input" placeholder="搜索会话" @input="onSearch" />
    </div>
    <div v-if="im.loadingFeeds && filteredList.length === 0" class="feed-loading">加载中...</div>
    <div v-else-if="filteredList.length === 0" class="feed-empty">暂无会话</div>
    <div v-else class="feed-list">
      <div
        v-for="feed in filteredList"
        :key="feed.id"
        class="feed-item"
        :class="{ active: feed.chatId === im.currentChatId }"
        @click="selectFeed(feed)"
        @contextmenu.prevent="showContextMenu($event, feed)"
      >
        <div class="feed-avatar" :style="{ background: feed.isMute ? '#999' : '#1976d2' }">
          {{ feed.name.charAt(0).toUpperCase() }}
        </div>
        <div class="feed-body">
          <div class="feed-top">
            <span class="feed-name">{{ feed.name }}</span>
            <span class="feed-time">{{ formatTime(feed.updateTimeMs) }}</span>
          </div>
          <div class="feed-bottom">
            <span class="feed-msg">{{ feed.lastMsg || '...' }}</span>
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
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { useImStore } from '@/stores/im'
import type { FeedItem } from '@/stores/im'

const router = useRouter()
const im = useImStore()
const searchText = ref('')

const contextMenu = ref<{ show: boolean; x: number; y: number; feed: FeedItem | null }>({
  show: false,
  x: 0,
  y: 0,
  feed: null,
})

const filteredList = computed(() => {
  const q = searchText.value.trim().toLowerCase()
  if (!q) return im.feedList
  return im.feedList.filter((f) => f.name.toLowerCase().includes(q))
})

onMounted(() => {
  document.addEventListener('click', closeContextMenu)
})

onUnmounted(() => {
  document.removeEventListener('click', closeContextMenu)
})

function selectFeed(feed: FeedItem) {
  im.selectChat(feed.chatId)
  closeContextMenu()
  router.push({ name: 'ImChat', params: { chatId: feed.chatId } })
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
  im.activeFeed(feed.id)
  closeContextMenu()
}

function remove(feed: FeedItem) {
  im.removeFeed(feed.id)
  closeContextMenu()
}

function onSearch() {
  // 搜索逻辑由 computed filteredList 自动处理
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
.feed-search {
  padding: 0 12px 8px;
}
.search-input {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  font-size: 13px;
  outline: none;
  box-sizing: border-box;
  background: #fff;
}
.search-input:focus {
  border-color: #1976d2;
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
  border-radius: 8px;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  font-weight: 600;
  flex-shrink: 0;
  margin-right: 10px;
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
