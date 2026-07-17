<template>
  <button
    class="toolbar-btn"
    :class="{ active, disabled }"
    :disabled="disabled"
    :title="tooltip"
    @mousedown.prevent="handleClick"
  >
    <slot />
  </button>
</template>

<script setup lang="ts">
const props = defineProps<{
  command?: () => void
  active?: boolean
  disabled?: boolean
  tooltip?: string
}>()

const emit = defineEmits<{
  click: []
}>()

function handleClick() {
  if (props.disabled) return
  emit('click')
}
</script>

<style scoped>
.toolbar-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  padding: 0;
  border: none;
  border-radius: 4px;
  background: transparent;
  color: #424242;
  cursor: pointer;
  font-size: 16px;
  transition: background 0.15s, color 0.15s;
}
.toolbar-btn:hover {
  background: #f0f0f0;
}
.toolbar-btn.active {
  background: #e3f2fd;
  color: #1565c0;
}
.toolbar-btn.disabled {
  opacity: 0.35;
  cursor: not-allowed;
}
.toolbar-btn.disabled:hover {
  background: transparent;
}
</style>
