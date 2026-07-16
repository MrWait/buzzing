<template>
  <ul class="space-list">
    <li
      v-for="space in store.spaces"
      :key="space.id"
      :class="{ active: space.id === store.currentSpaceId }"
      @click="store.loadDocuments(space.id)"
    >
      {{ space.name }}
    </li>
  </ul>
</template>

<script setup lang="ts">
import { useDocumentStore } from '@/stores/document'

const store = useDocumentStore()
</script>

<style scoped>
.space-list {
  list-style: none;
  padding: 0;
  margin: 0;
}
.space-list li {
  padding: 8px 12px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  color: #333;
}
.space-list li:hover {
  background: #f0f0f0;
}
.space-list li.active {
  background: #e3f2fd;
  color: #1565c0;
  font-weight: 500;
}
</style>
