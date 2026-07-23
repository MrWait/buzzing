<template>
  <Teleport to="body">
    <div
      v-if="show"
      class="mention-overlay"
      @click.stop="close"
    />
    <div
      v-if="show"
      class="mention-dropdown"
      :style="{ top: `${top}px`, left: `${left}px` }"
    >
      <div
        v-for="user in filtered"
        :key="user.id"
        class="mention-item"
        :class="{ active: user.id === highlightedId }"
        @click="select(user)"
        @mouseenter="highlightedId = user.id"
      >
        <span class="mention-name">{{ user.name }}</span>
        <span class="mention-id">@{{ user.name }}</span>
      </div>
      <div v-if="filtered.length === 0" class="mention-empty">无匹配成员</div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useImStore } from '@/stores/im'

const props = defineProps<{
  chatId: number
  show: boolean
  query: string
  top: number
  left: number
}>()
const emit = defineEmits<{
  (e: 'select', user: { id: number; name: string }): void
  (e: 'close'): void
}>()

const im = useImStore()
const highlightedId = ref(0)

const members = computed(() => {
  const chat = im.chats.get(props.chatId)
  if (!chat) return []
  return chat.memberIds
    .map((id) => im.users.get(id))
    .filter((u): u is NonNullable<typeof u> => u != null)
})

const filtered = computed(() => {
  if (!props.query) return members.value
  const q = props.query.toLowerCase()
  return members.value.filter((u) => u.name.toLowerCase().includes(q))
})

watch(() => props.show, (v) => {
  if (v && filtered.value.length > 0) {
    highlightedId.value = filtered.value[0].id
  }
})

function select(user: { id: number; name: string }) {
  emit('select', user)
  emit('close')
}

function close() {
  emit('close')
}

function onKeydown(e: KeyboardEvent): boolean {
  if (!props.show) return false
  if (e.key === 'ArrowDown') {
    e.preventDefault()
    const idx = filtered.value.findIndex((u) => u.id === highlightedId.value)
    const next = (idx + 1) % filtered.value.length
    highlightedId.value = filtered.value[next]?.id || 0
    return true
  }
  if (e.key === 'ArrowUp') {
    e.preventDefault()
    const idx = filtered.value.findIndex((u) => u.id === highlightedId.value)
    const prev = (idx - 1 + filtered.value.length) % filtered.value.length
    highlightedId.value = filtered.value[prev]?.id || 0
    return true
  }
  if (e.key === 'Enter' || e.key === 'Tab') {
    e.preventDefault()
    const user = filtered.value.find((u) => u.id === highlightedId.value)
    if (user) select(user)
    return true
  }
  if (e.key === 'Escape') {
    close()
    return true
  }
  return false
}

defineExpose({ onKeydown })
</script>

<style scoped>
.mention-overlay {
  position: fixed;
  inset: 0;
  z-index: 8000;
}
.mention-dropdown {
  position: fixed;
  z-index: 8001;
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  box-shadow: 0 4px 16px rgba(0,0,0,0.12);
  max-height: 200px;
  overflow-y: auto;
  min-width: 160px;
  padding: 4px;
}
.mention-item {
  display: flex;
  justify-content: space-between;
  padding: 8px 12px;
  border-radius: 6px;
  cursor: pointer;
}
.mention-item.active {
  background: #e3f2fd;
}
.mention-item:hover {
  background: #f0f0f0;
}
.mention-name {
  font-weight: 500;
  font-size: 13px;
}
.mention-id {
  font-size: 11px;
  color: #999;
}
.mention-empty {
  text-align: center;
  color: #999;
  padding: 12px;
  font-size: 13px;
}
</style>
