<template>
  <Teleport to="body">
    <div
      v-if="open"
      class="ctx-overlay"
      @click.self="close"
      @contextmenu.prevent="close"
    >
      <ul
        class="ctx-menu"
        :style="{ left: `${x}px`, top: `${y}px` }"
      >
        <template v-for="(item, idx) in items" :key="item.key ?? idx">
          <li v-if="item.divider" class="divider" />
          <li
            v-else
            :class="['menu-item', { danger: item.danger, disabled: item.disabled }]"
            @click="onClick(item)"
          >
            <span v-if="item.icon" class="menu-icon">{{ item.icon }}</span>
            <span class="menu-label">{{ item.label }}</span>
          </li>
        </template>
      </ul>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
export interface ContextMenuItem {
  key?: string
  label?: string
  icon?: string
  danger?: boolean
  disabled?: boolean
  divider?: boolean
  action?: () => void | Promise<void>
}

const props = defineProps<{
  open: boolean
  x: number
  y: number
  items: ContextMenuItem[]
}>()
const emit = defineEmits<{ (e: 'update:open', v: boolean): void }>()

function close() {
  emit('update:open', false)
}

async function onClick(item: ContextMenuItem) {
  if (item.disabled || item.divider) return
  try {
    await item.action?.()
  } finally {
    close()
  }
}

// 消除未使用 props 警告
void props
</script>

<style scoped>
.ctx-overlay {
  position: fixed;
  inset: 0;
  z-index: 1050;
}
.ctx-menu {
  position: absolute;
  min-width: 160px;
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  padding: 4px 0;
  list-style: none;
  margin: 0;
}
.menu-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 12px;
  cursor: pointer;
  font-size: 13px;
  color: #1f2937;
}
.menu-item:hover {
  background: #f3f4f6;
}
.menu-item.danger {
  color: #b91c1c;
}
.menu-item.disabled {
  color: #9ca3af;
  cursor: not-allowed;
}
.menu-icon {
  font-size: 14px;
  width: 16px;
  text-align: center;
}
.divider {
  height: 1px;
  background: #eee;
  margin: 4px 0;
}
</style>
