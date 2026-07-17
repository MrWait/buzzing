<template>
  <div class="collaborators">
    <div
      v-for="user in users"
      :key="user.clientId"
      class="collaborator-avatar"
      :style="{ backgroundColor: user.color }"
      :title="user.name"
    >
      <span class="initial">{{ initial(user.name) }}</span>
      <span class="name-tag">{{ user.name }}</span>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  users: Array<{ clientId: number; name: string; color: string }>
}>()

function initial(name: string): string {
  const trimmed = (name ?? '').trim()
  return trimmed ? trimmed[0].toUpperCase() : '?'
}
</script>

<style scoped>
.collaborators {
  display: flex;
  gap: 4px;
  align-items: center;
}
.collaborator-avatar {
  position: relative;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 12px;
  font-weight: 600;
  box-shadow: 0 0 0 2px #fff;
  cursor: default;
}
.collaborator-avatar .name-tag {
  position: absolute;
  top: 32px;
  right: 0;
  padding: 4px 8px;
  border-radius: 6px;
  background: rgba(0, 0, 0, 0.75);
  color: #fff;
  font-size: 12px;
  font-weight: 500;
  white-space: nowrap;
  opacity: 0;
  pointer-events: none;
  transform: translateY(-4px);
  transition: opacity 0.15s, transform 0.15s;
  z-index: 20;
}
.collaborator-avatar:hover .name-tag {
  opacity: 1;
  transform: translateY(0);
}
</style>
