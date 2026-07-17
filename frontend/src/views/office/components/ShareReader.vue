<template>
  <div class="share-reader">
    <header class="share-header">
      <div class="doc-title">
        <span v-if="docIcon" class="doc-icon">{{ docIcon }}</span>
        <span>{{ docTitle }}</span>
      </div>
      <div class="share-tag">分享文档 · 只读</div>
    </header>
    <ProseEditor :doc-id="docId" readonly />
  </div>
</template>

<script setup lang="ts">
import { provide } from 'vue'
import { useYjs } from '@/composables/useYjs'
import ProseEditor from './ProseEditor.vue'

const props = defineProps<{
  docId: string
  docTitle: string
  docIcon: string | null
  shareToken: string
}>()

// 初始化 yjs（使用临时 share token；共享视图禁用 IndexedDB 避免污染本地缓存）
const yjs = useYjs(props.docId, {
  token: props.shareToken,
  enableIndexedDb: false,
})
provide('yjs-type', yjs.type)
provide('yjs-provider', yjs.provider)
</script>

<style scoped>
.share-reader {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background: #fff;
}
.share-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 24px;
  border-bottom: 1px solid #eee;
  max-width: 1024px;
  margin: 0 auto;
  width: 100%;
  box-sizing: border-box;
}
.doc-title {
  font-size: 16px;
  font-weight: 600;
  color: #333;
  display: flex;
  align-items: center;
  gap: 8px;
}
.doc-icon {
  font-size: 18px;
}
.share-tag {
  padding: 4px 10px;
  background: #fff3e0;
  color: #e65100;
  border-radius: 4px;
  font-size: 12px;
}
</style>
