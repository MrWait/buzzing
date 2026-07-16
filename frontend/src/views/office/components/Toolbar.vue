<template>
  <div class="toolbar">
    <span class="toolbar-title">{{ title }}</span>
    <div class="toolbar-actions">
      <button @click="$emit('save')">保存</button>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{ title: string }>()
defineEmits<{ save: [] }>()
</script>

<style scoped>
.toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 40px;
  padding: 0 16px;
  border-bottom: 1px solid #e0e0e0;
  background: #fafafa;
}
.toolbar-title {
  font-weight: 500;
  font-size: 14px;
}
.toolbar-actions button {
  padding: 4px 12px;
  background: #1a1a2e;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
</style>
