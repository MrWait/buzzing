<template>
  <div class="ge-panel">
    <div class="ge-body">
      <div class="ge-avatar" @click="pickAvatar">
        <img v-if="editAvatar" :src="editAvatar" alt="" />
        <span v-else>{{ (editName || chat?.name || 'G').charAt(0) }}</span>
        <div class="ge-avatar-hint">更换头像</div>
      </div>
      <input ref="avatarInput" type="file" accept="image/*" style="display:none" @change="onAvatarSelected" />

      <label class="ge-field">
        <span class="ge-label">群名称</span>
        <input v-model="editName" class="ge-input" placeholder="群名称" />
      </label>
      <label class="ge-field">
        <span class="ge-label">群简介</span>
        <textarea v-model="editDesc" class="ge-input ge-textarea" placeholder="群简介" rows="3"></textarea>
      </label>

      <div class="ge-actions">
        <button class="btn btn-primary ge-save" :disabled="saving" @click="saveEdit">保存</button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useImStore } from '@/stores/im'
import api from '@/services/api'

const props = defineProps<{ chatId: string }>()

const im = useImStore()
const chat = computed(() => im.chats.get(props.chatId))

const avatarInput = ref<HTMLInputElement>()
const editName = ref('')
const editDesc = ref('')
const editAvatar = ref('')
const saving = ref(false)

onMounted(() => {
  editName.value = chat.value?.name || ''
  editDesc.value = chat.value?.description || ''
  editAvatar.value = chat.value?.avatar || ''
})

function pickAvatar() {
  avatarInput.value?.click()
}

async function onAvatarSelected(e: Event) {
  const input = e.target as HTMLInputElement
  const file = input?.files?.[0]
  if (!file) return
  const formData = new FormData()
  formData.append('file', file)
  try {
    const res = await api.post('/files/upload', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    editAvatar.value = res.data.url
  } catch (err) {
    console.error('[im] avatar upload error:', err)
  }
  input.value = ''
}

async function saveEdit() {
  if (saving.value) return
  const name = editName.value.trim()
  if (!name) return
  saving.value = true
  await im.updateChat(props.chatId, {
    name,
    description: editDesc.value.trim(),
    ...(editAvatar.value && editAvatar.value !== chat.value?.avatar ? { avatar: editAvatar.value } : {}),
  })
  saving.value = false
}
</script>

<style scoped>
.ge-panel { flex: 1; overflow-y: auto; background: #fff; }
.ge-body { padding: 24px 20px; }
.ge-avatar {
  width: 72px;
  height: 72px;
  border-radius: 50%;
  background: #1976d2;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 26px;
  margin: 0 auto 20px;
  overflow: hidden;
  position: relative;
  cursor: pointer;
}
.ge-avatar img { width: 100%; height: 100%; object-fit: cover; }
.ge-avatar-hint {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: rgba(0, 0, 0, 0.5);
  color: #fff;
  font-size: 10px;
  text-align: center;
  padding: 2px 0;
}
.ge-field { display: flex; flex-direction: column; gap: 6px; margin-bottom: 14px; }
.ge-label { font-size: 13px; color: #666; }
.ge-input {
  border: 1px solid #ddd;
  border-radius: 6px;
  padding: 8px 10px;
  font-size: 14px;
  outline: none;
  resize: none;
}
.ge-input:focus { border-color: #2b5ced; }
.ge-textarea { line-height: 1.5; }
.ge-actions { display: flex; justify-content: flex-end; margin-top: 8px; }
.btn { padding: 8px 24px; border-radius: 6px; font-size: 13px; cursor: pointer; border: 1px solid transparent; transition: all 0.15s; }
.btn-primary { background: #2b5ced; color: #fff; border-color: #2b5ced; }
.btn-primary:hover { background: #1a4ed8; }
.btn-primary:disabled { opacity: 0.6; cursor: not-allowed; }
</style>