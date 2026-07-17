<template>
  <Teleport to="body">
    <div v-if="open" class="picker-overlay" @click.self="close">
      <div class="picker">
        <div class="tabs">
          <button
            v-for="cat in categories"
            :key="cat.key"
            :class="{ active: activeCat === cat.key }"
            @click="activeCat = cat.key"
          >{{ cat.label }}</button>
        </div>
        <div class="grid">
          <button
            v-for="emoji in currentEmojis"
            :key="emoji"
            class="cell"
            @click="pick(emoji)"
          >{{ emoji }}</button>
        </div>
        <div class="footer">
          <button class="clear" @click="pick('')">清除图标</button>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'

const props = defineProps<{ open: boolean }>()
const emit = defineEmits<{
  (e: 'update:open', v: boolean): void
  (e: 'pick', value: string): void
}>()

interface Category {
  key: string
  label: string
  emojis: string[]
}

const categories: Category[] = [
  { key: 'common', label: '常用', emojis: [
    '📄', '📝', '📌', '⭐', '❤️', '🔥', '✨', '💡', '🎯', '🚀', '✅', '📊', '📈', '📚', '🗂', '🧠', '💼', '🎨',
  ]},
  { key: 'work', label: '工作', emojis: [
    '📅', '🗓', '⏰', '⏳', '📋', '📇', '📁', '📂', '🗒', '🖊', '🖋', '✒️', '📎', '🔖', '📑', '🧾',
  ]},
  { key: 'symbol', label: '符号', emojis: [
    '⚡', '🔒', '🔓', '🔑', '🛠', '⚙️', '🧩', '🧪', '🔬', '🔭', '📡', '💻', '🖥', '⌨️', '🖱', '🖨',
  ]},
  { key: 'life', label: '生活', emojis: [
    '🏠', '🍎', '☕', '🌱', '🌿', '🌸', '🌟', '🌈', '☀️', '🌙', '☁️', '⛄', '🎂', '🎁', '🎉', '🎈',
  ]},
]

const activeCat = ref('common')
const currentEmojis = computed(() => categories.find(c => c.key === activeCat.value)?.emojis ?? [])

function pick(v: string) {
  emit('pick', v)
  close()
}
function close() {
  emit('update:open', false)
}

// suppress unused warning if props is only used via v-if
void props
</script>

<style scoped>
.picker-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.2);
  z-index: 1100;
  display: flex;
  justify-content: center;
  align-items: center;
}
.picker {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15);
  width: 320px;
  max-height: 400px;
  display: flex;
  flex-direction: column;
}
.tabs {
  display: flex;
  border-bottom: 1px solid #eee;
}
.tabs button {
  flex: 1;
  padding: 8px 4px;
  border: none;
  background: transparent;
  cursor: pointer;
  font-size: 12px;
  color: #6b7280;
  border-bottom: 2px solid transparent;
}
.tabs button.active {
  color: #2563eb;
  border-bottom-color: #2563eb;
}
.grid {
  flex: 1;
  overflow-y: auto;
  padding: 8px;
  display: grid;
  grid-template-columns: repeat(8, 1fr);
  gap: 4px;
}
.cell {
  padding: 4px;
  border: none;
  background: transparent;
  border-radius: 4px;
  cursor: pointer;
  font-size: 18px;
  line-height: 1;
}
.cell:hover {
  background: #f3f4f6;
}
.footer {
  padding: 8px 12px;
  border-top: 1px solid #eee;
  display: flex;
  justify-content: flex-end;
}
.clear {
  padding: 4px 12px;
  border: 1px solid #d1d5db;
  background: #fff;
  border-radius: 4px;
  cursor: pointer;
  font-size: 12px;
  color: #6b7280;
}
.clear:hover {
  background: #f3f4f6;
}
</style>
