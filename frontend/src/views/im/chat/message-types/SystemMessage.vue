<template>
  <div class="system-msg">{{ summary || '[系统消息]' }}</div>
</template>

<script setup lang="ts">
defineProps<{ content: Uint8Array; summary?: string }>()
</script>

<style scoped>
.system-msg {
  text-align: center;
  font-size: 12px;
  color: #999;
  padding: 4px 0;
}
</style>
