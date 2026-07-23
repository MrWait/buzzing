<template>
  <Teleport to="body">
    <div v-if="open" class="restore-overlay" @click.self="$emit('cancel')">
      <div class="restore-modal">
        <h3>确认回滚</h3>
        <p v-if="version">
          确定将文档回滚至 <strong>v{{ version.version_number }} — {{ version.title }}</strong>？
        </p>
        <p class="restore-hint">回滚操作会创建一个新的版本记录，当前内容不会被覆盖。回滚后协作者将看到恢复后的内容。</p>
        <div class="restore-actions">
          <button class="btn-cancel" @click="$emit('cancel')">取消</button>
          <button class="btn-danger" @click="$emit('confirm')">确认回滚</button>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import type { VersionDto } from '@/services/office/versions'

defineProps<{
  open: boolean
  version: VersionDto | null
}>()
defineEmits<{
  (e: 'confirm'): void
  (e: 'cancel'): void
}>()
</script>

<style scoped>
.restore-overlay {
  position: fixed;
  inset: 0;
  z-index: 1001;
  background: rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
}
.restore-modal {
  background: #fff;
  border-radius: 10px;
  padding: 24px;
  max-width: 420px;
  width: 90vw;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
}
.restore-modal h3 {
  margin: 0 0 12px;
  font-size: 16px;
  font-weight: 600;
}
.restore-modal p {
  margin: 0 0 8px;
  font-size: 14px;
  color: #333;
  line-height: 1.5;
}
.restore-hint {
  color: #888;
  font-size: 12px;
}
.restore-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 16px;
}
.btn-cancel {
  padding: 8px 16px;
  border: 1px solid #d0d0d0;
  background: #fff;
  color: #333;
  border-radius: 6px;
  font-size: 13px;
  cursor: pointer;
}
.btn-cancel:hover {
  background: #f5f5f5;
}
.btn-danger {
  padding: 8px 16px;
  border: none;
  background: #d32f2f;
  color: #fff;
  border-radius: 6px;
  font-size: 13px;
  cursor: pointer;
}
.btn-danger:hover {
  background: #b71c1c;
}
</style>
