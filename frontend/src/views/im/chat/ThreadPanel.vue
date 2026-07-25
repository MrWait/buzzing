<template>
  <div class="thread-panel">
    <div class="thread-header">
      <button class="back-btn" @click="$emit('close')">←</button>
      <span class="thread-title">话题</span>
    </div>

    <div class="thread-root">
      <div class="root-author">{{ getUserName(rootMsg?.fromId) }}</div>
      <div class="root-text">{{ rootMsg?.summary || '' }}</div>
    </div>

    <div class="thread-messages">
      <div v-for="msg in replies" :key="msg.id" class="thread-msg">
        <div class="thread-msg-author">{{ getUserName(msg.fromId) }}</div>
        <div class="thread-msg-text">{{ msg.summary || `[类型 ${msg.tpy}]` }}</div>
      </div>
      <div v-if="replies.length === 0" class="empty-text">暂无回复</div>
    </div>

    <div class="thread-input">
      <input
        v-model="inputText"
        placeholder="回复..."
        @keydown.enter="sendReply"
      />
      <button @click="sendReply" :disabled="!inputText.trim()">发送</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useImStore } from '@/stores/im'

const props = defineProps<{ chatId: string; rootMessageId: string }>()
const emit = defineEmits<{ (e: 'close'): void }>()
const im = useImStore()
const inputText = ref('')

const rootMsg = computed(() => {
  const msgs = im.messages.get(props.chatId) || []
  return msgs.find((m) => m.id === props.rootMessageId)
})

const replies = computed(() => {
  const msgs = im.messages.get(props.chatId) || []
  return msgs.filter((m) => m.refMessageId === props.rootMessageId && m.id !== props.rootMessageId)
})

function getUserName(userId: string | undefined): string {
  if (userId == null) return '未知'
  return im.users.get(userId)?.name || `用户${userId}`
}

async function sendReply() {
  const text = inputText.value.trim()
  if (!text) return
  try {
    await im.sendTextMessage(props.chatId, text, props.rootMessageId)
    inputText.value = ''
  } catch (e) {
    console.error('thread reply error:', e)
  }
}
</script>

<style scoped>
.thread-panel {
  display: flex;
  flex-direction: column;
  height: 100%;
  border-left: 1px solid #e0e0e0;
  background: #fafafa;
  width: 340px;
  flex-shrink: 0;
}
.thread-header {
  display: flex;
  align-items: center;
  padding: 10px 12px;
  border-bottom: 1px solid #e0e0e0;
  background: #fff;
  gap: 8px;
}
.thread-title {
  font-weight: 500;
}
.back-btn {
  background: none;
  border: none;
  font-size: 18px;
  cursor: pointer;
  padding: 2px 6px;
  color: #666;
}
.thread-root {
  padding: 16px;
  background: #fff;
  border-bottom: 1px solid #e0e0e0;
}
.root-author {
  font-size: 12px;
  color: #1976d2;
  margin-bottom: 4px;
}
.root-text {
  font-size: 14px;
  line-height: 1.4;
}
.thread-messages {
  flex: 1;
  overflow-y: auto;
  padding: 8px;
}
.thread-msg {
  padding: 8px;
  margin-bottom: 4px;
  background: #fff;
  border-radius: 8px;
}
.thread-msg-author {
  font-size: 12px;
  color: #1976d2;
  margin-bottom: 2px;
}
.thread-msg-text {
  font-size: 13px;
  line-height: 1.4;
}
.empty-text {
  text-align: center;
  color: #999;
  padding: 20px;
  font-size: 13px;
}
.thread-input {
  display: flex;
  padding: 10px 12px;
  border-top: 1px solid #e0e0e0;
  background: #fff;
  gap: 8px;
}
.thread-input input {
  flex: 1;
  padding: 8px 12px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  font-size: 13px;
  outline: none;
}
.thread-input input:focus { border-color: #1976d2; }
.thread-input button {
  padding: 8px 12px;
  background: #1976d2;
  color: #fff;
  border: none;
  border-radius: 8px;
  font-size: 13px;
  cursor: pointer;
}
.thread-input button:disabled { opacity: 0.5; }
</style>
