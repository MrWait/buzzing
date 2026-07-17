<template>
  <div class="toolbar-dropdown" ref="containerRef">
      <button class="dropdown-trigger" :title="tooltip" @mousedown.prevent="toggleOpen">
      <span class="dropdown-label">{{ label }}</span>
      <ChevronDown :size="14" />
    </button>
    <div v-if="open" class="dropdown-menu">
      <button
        v-for="opt in options"
        :key="opt.value"
        class="dropdown-item"
        :class="{ selected: opt.value === modelValue }"
        @mousedown.prevent="select(opt.value)"
      >
        {{ opt.label }}
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { ChevronDown } from '@lucide/vue'

interface DropdownOption {
  label: string
  value: string | number
}

defineProps<{
  modelValue: string | number
  options: DropdownOption[]
  label: string
  tooltip?: string
}>()

const emit = defineEmits<{
  'update:modelValue': [value: string | number]
}>()

const open = ref(false)
const containerRef = ref<HTMLElement | null>(null)

function toggleOpen() {
  open.value = !open.value
}

function onDocumentClick(e: MouseEvent) {
  if (containerRef.value && !containerRef.value.contains(e.target as Node)) {
    open.value = false
  }
}

onMounted(() => document.addEventListener('click', onDocumentClick))
onUnmounted(() => document.removeEventListener('click', onDocumentClick))

function select(value: string | number) {
  emit('update:modelValue', value)
  open.value = false
}
</script>

<style scoped>
.toolbar-dropdown {
  position: relative;
  display: inline-flex;
}
.dropdown-trigger {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  height: 32px;
  padding: 0 8px;
  border: none;
  border-radius: 4px;
  background: transparent;
  color: #424242;
  cursor: pointer;
  font-size: 13px;
  transition: background 0.15s;
}
.dropdown-trigger:hover {
  background: #f0f0f0;
}
.dropdown-label {
  white-space: nowrap;
}
.dropdown-menu {
  position: absolute;
  top: 100%;
  left: 0;
  margin-top: 4px;
  min-width: 140px;
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 6px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
  z-index: 100;
  padding: 4px;
}
.dropdown-item {
  display: block;
  width: 100%;
  padding: 6px 12px;
  border: none;
  border-radius: 4px;
  background: transparent;
  color: #333;
  cursor: pointer;
  font-size: 13px;
  text-align: left;
  transition: background 0.1s;
}
.dropdown-item:hover {
  background: #f0f0f0;
}
.dropdown-item.selected {
  background: #e3f2fd;
  color: #1565c0;
}
</style>
