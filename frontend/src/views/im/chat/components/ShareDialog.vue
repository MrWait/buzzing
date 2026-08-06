<template>
  <Teleport to="body">
    <div v-if="show" class="share-overlay" @click.self="onClose">
      <div class="share-dialog">
        <div class="share-header">
          <span>分享</span>
          <button class="share-close" @click="onClose">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
          </button>
        </div>

        <div class="share-body">
          <div v-if="canEdit" class="share-section">
            <button class="share-link-btn" :disabled="creating" @click="handleCreateInvite">
              生成新邀请链接
            </button>
            <div v-if="currentCode" class="share-link-current">
              <div class="share-code">邀请码: {{ currentCode }}</div>
              <a :href="inviteUrl" target="_blank" rel="noopener" class="share-url">{{ inviteUrl }}</a>
              <button class="share-revoke" @click="handleRevokeInvite">撤销链接</button>
            </div>
          </div>
          <div v-else-if="!isMember" class="share-section">
            <button class="share-link-btn" @click="handleApplyJoin">申请加入该群聊</button>
          </div>
          <div v-if="!canEdit && isMember" class="share-hint">已加入该群聊，可通过邀请链接邀请他人</div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useImStore } from '@/stores/im'
import { useAuthStore } from '@/stores/auth'

const props = defineProps<{ show: boolean; chatId: string }>()
const emit = defineEmits<{ (e: 'close'): void }>()

const im = useImStore()
const auth = useAuthStore()

const chat = computed(() => im.chats.get(props.chatId))
const myId = computed(() => String(auth.user?.id ?? ''))
const isOwner = computed(() => chat.value?.ownerId === myId.value)
const isAdmin = computed(() => chat.value?.adminIds.includes(myId.value) ?? false)
const canEdit = computed(() => isOwner.value || isAdmin.value)
const isMember = computed(() => chat.value?.memberIds.includes(myId.value) ?? false)

const currentCode = ref('')
const creating = ref(false)

const inviteUrl = computed(() => {
  if (!currentCode.value) return ''
  return `${window.location.origin}/im/invite/${currentCode.value}`
})

watch(
  () => props.show,
  (val) => {
    if (val) currentCode.value = ''
  },
)

function onClose() {
  currentCode.value = ''
  emit('close')
}

async function handleCreateInvite() {
  if (creating.value) return
  creating.value = true
  const code = await im.createInviteLink(props.chatId)
  if (code) currentCode.value = code
  creating.value = false
}

async function handleRevokeInvite() {
  await im.revokeInviteLink(currentCode.value)
  currentCode.value = ''
}

async function handleApplyJoin() {
  await im.createJoinRequest(props.chatId)
  alert('已提交入群申请，请等待管理员审核')
  onClose()
}
</script>

<style scoped>
.share-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 20010;
}
.share-dialog {
  background: #fff;
  border-radius: 12px;
  width: 400px;
  max-height: 80vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
}
.share-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 20px;
  border-bottom: 1px solid #e8e8e8;
  font-size: 15px;
  font-weight: 600;
}
.share-close {
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  color: #999;
  display: flex;
  align-items: center;
}
.share-close:hover { background: #f0f0f0; color: #333; }
.share-body { padding: 20px; display: flex; flex-direction: column; gap: 12px; }
.share-section { display: flex; flex-direction: column; gap: 12px; }
.share-link-btn {
  padding: 10px;
  border: 1px solid #2b5ced;
  color: #2b5ced;
  background: #fff;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
}
.share-link-btn:hover { background: #f0f6ff; }
.share-link-btn:disabled { opacity: 0.5; cursor: not-allowed; }
.share-link-current {
  display: flex;
  flex-direction: column;
  gap: 6px;
  padding: 12px;
  background: #f7f9fc;
  border-radius: 8px;
}
.share-code { font-size: 14px; font-weight: 500; }
.share-url { font-size: 12px; color: #2b5ced; word-break: break-all; }
.share-revoke {
  align-self: flex-start;
  padding: 6px 14px;
  border: none;
  border-radius: 6px;
  background: #f44336;
  color: #fff;
  font-size: 12px;
  cursor: pointer;
}
.share-revoke:hover { background: #d32f2f; }
.share-hint { font-size: 13px; color: #999; text-align: center; padding: 12px 0; }
</style>