<template>
  <div class="forward-msg">
    <div class="forward-label">转发消息</div>
    <div class="forward-summary">{{ summary || '查看转发内容' }}</div>
  </div>
</template>

<script setup lang="ts">
defineProps<{ content: Uint8Array; summary?: string }>()
</script>

<style scoped>
.forward-msg {
  border-left: 3px solid #1976d2;
  padding-left: 8px;
}
.forward-label {
  font-size: 11px;
  color: #1976d2;
  margin-bottom: 2px;
}
.forward-summary {
  font-size: 13px;
  color: #666;
}
</style>
