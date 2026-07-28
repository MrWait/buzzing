<template>
  <div class="editor-header">
    <div class="header-row">
      <div class="header-left">
        <Breadcrumb :items="crumbs" />
        <div class="info-row">
          <SyncStatus
            :state="saveState"
            :last-saved-at="lastSavedAt"
            :connected="connected"
          />
          <Collaborators :users="editingUsers" />
        </div>
      </div>
      <div class="header-actions">
        <slot />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import Breadcrumb, { type BreadcrumbItem } from './Breadcrumb.vue'
import SyncStatus from './SyncStatus.vue'
import Collaborators from './Collaborators.vue'
import type { SaveState } from '@/composables/useYjs'

defineProps<{
  crumbs: BreadcrumbItem[]
  saveState: SaveState
  lastSavedAt: number | null
  connected: boolean
  editingUsers: Array<{ clientId: number; name: string; color: string }>
}>()
</script>

<style scoped>
.editor-header {
  max-width: 1024px;
  width: 100%;
  margin: 0 auto;
  padding: 0 24px;
}
.header-row {
  display: flex;
  align-items: stretch;
  gap: 16px;
  min-height: 48px;
}
.header-left {
  display: flex;
  flex-direction: column;
  justify-content: center;
  flex: 1;
  min-width: 0;
}
.header-left :deep(.breadcrumb) {
  padding: 2px 0;
}
.info-row {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 2px 0;
}
.header-actions {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-shrink: 0;
}
</style>
