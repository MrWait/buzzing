<template>
  <Teleport to="body">
    <div v-if="open" class="cm-overlay" @click.self="close">
      <div class="cm-menu" :style="menuStyle">
        <div class="cm-item" @click="createDoc">
          <span class="cm-icon">📄</span>
          <span>文档</span>
        </div>
        <div class="cm-item cm-disabled" title="暂未实现">
          <span class="cm-icon">⊞</span>
          <span>多维表格</span>
          <span class="cm-badge">即将推出</span>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { docsApi } from '@/services/office/docs'

const props = withDefaults(defineProps<{
  open: boolean
  docId: string
  parentId: string | null
  wikiId: string | null
  triggerRect: { top: number; bottom: number; left: number; right: number; width: number; height: number }
}>(), {
  parentId: null,
  wikiId: null,
  triggerRect: () => ({ top: 0, bottom: 0, left: 0, right: 0, width: 0, height: 0 }),
})
const emit = defineEmits<{ (e: 'update:open', v: boolean): void }>()

const router = useRouter()

const menuStyle = computed(() => {
  const r = props.triggerRect
  return {
    position: 'fixed',
    top: `${r.bottom + 4}px`,
    right: `${Math.max(8, window.innerWidth - r.right)}px`,
    zIndex: 1050,
  }
})

function close() {
  emit('update:open', false)
}

async function createDoc() {
  try {
    const payload: any = { title: '未命名' }
    if (props.parentId) payload.parent_id = props.parentId
    if (props.wikiId) payload.wiki_id = props.wikiId
    const { data } = props.wikiId
      ? await docsApi.create(payload)
      : await docsApi.createPersonal(payload)
    close()
    router.push({ name: 'OfficeEditor', params: { docId: data.id } })
  } catch { /* ignore */ }
}
</script>

<style scoped>
.cm-overlay {
  position: fixed;
  inset: 0;
  z-index: 1050;
}
.cm-menu {
  position: absolute;
  min-width: 160px;
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  padding: 4px 0;
}
.cm-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 14px;
  cursor: pointer;
  font-size: 13px;
  color: #1f2937;
}
.cm-item:hover { background: #f3f4f6; }
.cm-item.cm-disabled {
  color: #9ca3af;
  cursor: not-allowed;
}
.cm-item.cm-disabled:hover { background: transparent; }
.cm-icon {
  width: 18px;
  text-align: center;
  font-size: 14px;
  flex-shrink: 0;
}
.cm-badge {
  margin-left: auto;
  font-size: 10px;
  padding: 1px 5px;
  border-radius: 3px;
  background: #f3f4f6;
  color: #9ca3af;
}
</style>
