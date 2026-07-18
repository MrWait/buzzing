<script setup lang="ts">
import { ref } from 'vue'

const emit = defineEmits<{
  confirm: [roomId: string, password?: string]
  close: []
}>()

const roomId = ref('')
const password = ref('')

function handleConfirm() {
  if (!roomId.value.trim()) return
  emit('confirm', roomId.value.trim(), password.value || undefined)
}
</script>

<template>
  <div class="dialog-overlay" @click.self="emit('close')">
    <div class="dialog">
      <div class="dialog-header">
        <h3>加入会议</h3>
        <button class="dialog-close" @click="emit('close')">✕</button>
      </div>
      <div class="dialog-body">
        <div class="field">
          <label>会议号</label>
          <input v-model="roomId" class="input" placeholder="输入会议号" @keydown.enter="handleConfirm" />
        </div>
        <div class="field">
          <label>密码（可选）</label>
          <input v-model="password" class="input" type="password" placeholder="留空表示无需密码" @keydown.enter="handleConfirm" />
        </div>
      </div>
      <div class="dialog-footer">
        <button class="btn btn-outline" @click="emit('close')">取消</button>
        <button class="btn btn-primary" @click="handleConfirm" :disabled="!roomId.trim()">加入</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.dialog-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}
.dialog {
  background: #fff;
  border-radius: 12px;
  width: 400px;
  max-width: 90vw;
  box-shadow: 0 8px 32px rgba(0,0,0,0.15);
}
.dialog-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 20px;
  border-bottom: 1px solid #eee;
}
.dialog-header h3 {
  margin: 0;
  font-size: 16px;
}
.dialog-close {
  background: none;
  border: none;
  font-size: 18px;
  cursor: pointer;
  color: #999;
  padding: 4px;
}
.dialog-body {
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.field {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.field label {
  font-size: 13px;
  color: #666;
}
.input {
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 14px;
  outline: none;
}
.input:focus {
  border-color: #1976d2;
}
.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  padding: 12px 20px;
  border-top: 1px solid #eee;
}
.btn {
  padding: 8px 20px;
  border-radius: 6px;
  font-size: 13px;
  cursor: pointer;
  border: 1px solid transparent;
  transition: all 0.2s;
}
.btn-primary {
  background: #1976d2;
  color: #fff;
  border-color: #1976d2;
}
.btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
.btn-outline {
  background: #fff;
  color: #333;
  border-color: #ccc;
}
</style>