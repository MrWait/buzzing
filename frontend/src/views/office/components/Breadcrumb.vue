<template>
  <nav v-if="items.length > 0" class="breadcrumb">
    <template v-for="(item, idx) in items" :key="item.id ?? idx">
      <span
        class="crumb"
        :class="{ link: !!item.route }"
        @click="item.route && $router.push(item.route)"
      >
        <span v-if="item.icon" class="crumb-icon">{{ item.icon }}</span>
        <span>{{ item.label }}</span>
      </span>
      <span v-if="idx < items.length - 1" class="sep">/</span>
    </template>
  </nav>
</template>

<script setup lang="ts">
import type { RouteLocationRaw } from 'vue-router'

export interface BreadcrumbItem {
  id?: string
  label: string
  icon?: string | null
  route?: RouteLocationRaw
}

defineProps<{ items: BreadcrumbItem[] }>()
</script>

<style scoped>
.breadcrumb {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: #6b7280;
  padding: 4px 0;
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
}
.crumb {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 2px 4px;
  border-radius: 4px;
}
.crumb.link {
  cursor: pointer;
  color: #374151;
}
.crumb.link:hover {
  background: #f3f4f6;
  color: #111827;
}
.crumb-icon {
  font-size: 13px;
}
.sep {
  color: #d1d5db;
}
</style>
