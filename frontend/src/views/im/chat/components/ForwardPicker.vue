<template>
  <Teleport to="body">
    <div v-if="show" class="forward-overlay" @click.self="cancel">
      <div class="forward-dialog">
        <div class="forward-header">
          <span>转发消息</span>
          <button class="close-btn" @click="cancel">✕</button>
        </div>
        <div class="search-box">
          <input v-model="searchText" placeholder="搜索会话..." class="search-input" />
        </div>
        <div class="forward-list">
          <div
            v-for="feed in filteredFeeds"
            :key="feed.id"
            class="forward-item"
            :class="{ selected: selectedId === feed.chatId }"
            @click="selectedId = feed.chatId"
          >
            <span class="forward-name">{{ feed.name }}</span>
            <span class="forward-type">{{ feed.type === 2 ? '群组' : '单聊' }}</span>
          </div>
          <div v-if="filteredFeeds.length === 0" class="empty-text">暂无会话</div>
        </div>
        <div class="forward-actions">
          <button class="btn-cancel" @click="cancel">取消</button>
          <button class="btn-confirm" :disabled="!selectedId" @click="confirm">发送</button>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useImStore } from '@/stores/im'

const props = defineProps<{
  show: boolean
  sourceChatId?: string
  messageIds?: string[]
}>()
const emit = defineEmits<{ (e: 'close'): void }>()
const im = useImStore()
const searchText = ref('')
const selectedId = ref<string | null>(null)

const filteredFeeds = computed(() => {
  const list = im.feedList
  if (searchText.value) {
    const q = searchText.value.toLowerCase()
    return list.filter((f) => f.name.toLowerCase().includes(q))
  }
  return list
})

function cancel() {
  selectedId.value = null
  searchText.value = ''
  emit('close')
}

async function confirm() {
  if (!selectedId.value || !props.messageIds?.length) return
  try {
    await im.forwardMessages(selectedId.value, props.sourceChatId!, props.messageIds)
  } catch (e) {
    console.error('forward error:', e)
  }
  cancel()
}
</script>

<style scoped>
.forward-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.4);
  z-index: 9000;
  display: flex;
  align-items: center;
  justify-content: center;
}
.forward-dialog {
  background: #fff;
  border-radius: 12px;
  width: 400px;
  max-height: 500px;
  display: flex;
  flex-direction: column;
  box-shadow: 0 8px 32px rgba(0,0,0,0.16);
}
.forward-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px 16px;
  border-bottom: 1px solid #e0e0e0;
  font-weight: 500;
}
.close-btn {
  background: none;
  border: none;
  font-size: 16px;
  cursor: pointer;
  color: #999;
}
.search-box {
  padding: 8px 16px;
}
.search-input {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  font-size: 13px;
  outline: none;
  box-sizing: border-box;
}
.search-input:focus { border-color: #1976d2; }
.forward-list {
  flex: 1;
  overflow-y: auto;
  padding: 4px 8px;
}
.forward-item {
  display: flex;
  justify-content: space-between;
  padding: 10px 12px;
  border-radius: 8px;
  cursor: pointer;
}
.forward-item:hover { background: #f5f5f5; }
.forward-item.selected { background: #e3f2fd; }
.forward-name { font-weight: 500; font-size: 14px; }
.forward-type { font-size: 12px; color: #999; }
.empty-text { text-align: center; color: #999; padding: 20px; }
.forward-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  padding: 12px 16px;
  border-top: 1px solid #e0e0e0;
}
.btn-cancel, .btn-confirm {
  padding: 8px 16px;
  border-radius: 8px;
  font-size: 13px;
  cursor: pointer;
}
.btn-cancel {
  background: #fff;
  border: 1px solid #e0e0e0;
  color: #666;
}
.btn-confirm {
  background: #1976d2;
  border: none;
  color: #fff;
}
.btn-confirm:disabled { opacity: 0.5; cursor: not-allowed; }
</style>
