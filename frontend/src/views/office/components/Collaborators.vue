<template>
  <div class="collaborators" ref="elRef">
    <div
      v-for="user in visibleUsers"
      :key="user.clientId"
      class="collaborator-avatar"
      :style="{ backgroundColor: user.color }"
      :title="user.name"
    >
      <span class="initial">{{ initial(user.name) }}</span>
      <span class="name-tag">{{ user.name }}</span>
    </div>
    <button v-if="moreCount > 0" ref="moreRef" class="more-collab-btn" @click="toggleMore" :title="`还有 ${moreCount} 人`">
      +{{ moreCount }}
    </button>
    <Teleport to="body">
      <div v-if="showMore" class="cm-overlay" @click.self="showMore = false">
        <div class="cm-dropdown" :style="dropdownStyle">
          <div v-for="user in extraUsers" :key="user.clientId" class="cm-user">
            <span class="cm-dot" :style="{ backgroundColor: user.color }"></span>
            <span>{{ user.name }}</span>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { computed, nextTick, ref } from 'vue'

const props = defineProps<{
  users: Array<{ clientId: number; name: string; color: string }>
}>()

const MAX_VISIBLE = 5

const visibleUsers = computed(() => props.users.slice(0, MAX_VISIBLE))
const extraUsers = computed(() => props.users.slice(MAX_VISIBLE))
const moreCount = computed(() => extraUsers.value.length)

const elRef = ref<HTMLElement | null>(null)
const moreRef = ref<HTMLElement | null>(null)
const showMore = ref(false)
const dropdownStyle = ref({})

function initial(name: string): string {
  const trimmed = (name ?? '').trim()
  return trimmed ? trimmed[0].toUpperCase() : '?'
}

async function toggleMore() {
  if (showMore.value) {
    showMore.value = false
    return
  }
  if (moreRef.value) {
    const r = moreRef.value.getBoundingClientRect()
    dropdownStyle.value = {
      position: 'fixed',
      top: `${r.bottom + 4}px`,
      right: `${Math.max(8, window.innerWidth - r.right)}px`,
      zIndex: 1050,
    }
  }
  showMore.value = true
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
  box-shadow: 0 0 0 2px #f0f0f0;
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
.more-collab-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  border: 1px solid #d0d0d0;
  background: #fff;
  color: #666;
  font-size: 11px;
  font-weight: 600;
  cursor: pointer;
  padding: 0;
  line-height: 1;
}
.more-collab-btn:hover {
  background: #f5f5f5;
  border-color: #bbb;
}
.cm-overlay {
  position: fixed;
  inset: 0;
  z-index: 1050;
}
.cm-dropdown {
  position: absolute;
  min-width: 140px;
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  padding: 4px 0;
}
.cm-user {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 14px;
  font-size: 13px;
  color: #1f2937;
}
.cm-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}
</style>
