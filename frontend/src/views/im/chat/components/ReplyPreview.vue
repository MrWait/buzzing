<template>
  <div v-if="replyTarget" class="reply-preview-bar">
    <div class="reply-info">
      <span class="reply-label">回复</span>
      <span class="reply-name">{{ getUserName(replyTarget.fromId) }}: </span>
      <span class="reply-text">{{ replyTarget.summary || '[消息]' }}</span>
    </div>
    <button class="reply-close" @click="cancel">✕</button>
  </div>
</template>

<script setup lang="ts">
import { useImStore } from '@/stores/im'

const im = useImStore()
const replyTarget = im.replyTarget

function getUserName(userId: string): string {
  return im.users.get(userId)?.name || `用户${userId}`
}

function cancel() {
  im.setReplyTarget(null)
}
</script>

<style scoped>
.reply-preview-bar {
  display: flex;
  align-items: center;
  padding: 6px 12px;
  background: #f5f5f5;
  border-top: 1px solid #e0e0e0;
  border-bottom: 1px solid #e0e0e0;
}
.reply-info {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 12px;
}
.reply-label {
  color: #1976d2;
  font-weight: 500;
  margin-right: 4px;
}
.reply-name {
  color: #666;
}
.reply-text {
  color: #999;
}
.reply-close {
  background: none;
  border: none;
  cursor: pointer;
  color: #999;
  padding: 2px 6px;
  font-size: 14px;
}
.reply-close:hover { color: #333; }
</style>
