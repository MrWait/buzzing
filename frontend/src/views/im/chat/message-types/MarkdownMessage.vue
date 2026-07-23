<template>
  <div class="markdown-body" v-html="rendered" />
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'

const props = defineProps<{ content: Uint8Array; summary?: string }>()
const rendered = ref('')

onMounted(() => {
  const raw = props.summary || new TextDecoder().decode(props.content) || ''
  // 简单的 Markdown → HTML 转换（仅支持基础语法）
  rendered.value = renderMarkdown(raw)
})

function renderMarkdown(text: string): string {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/### (.+)/g, '<h3>$1</h3>')
    .replace(/## (.+)/g, '<h2>$1</h2>')
    .replace(/# (.+)/g, '<h1>$1</h1>')
    .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.+?)\*/g, '<em>$1</em>')
    .replace(/`(.+?)`/g, '<code>$1</code>')
    .replace(/```([\s\S]*?)```/g, '<pre><code>$1</code></pre>')
    .replace(/^- (.+)/gm, '<li>$1</li>')
    .replace(/\n\n/g, '</p><p>')
    .replace(/\n/g, '<br>')
}
</script>

<style scoped>
.markdown-body {
  line-height: 1.5;
}
.markdown-body :deep(h1),
.markdown-body :deep(h2),
.markdown-body :deep(h3) {
  margin: 4px 0;
  font-size: inherit;
}
.markdown-body :deep(code) {
  background: rgba(0,0,0,0.08);
  padding: 1px 4px;
  border-radius: 3px;
  font-size: 12px;
}
.markdown-body :deep(pre) {
  background: rgba(0,0,0,0.06);
  padding: 8px;
  border-radius: 6px;
  overflow-x: auto;
}
</style>
