<template>
  <span class="text-pre-wrap" v-html="rendered"></span><template v-if="translation">（{{ translation }}）</template>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { lookup } from '@/services/im/proto'

const props = defineProps<{ content: Uint8Array; translation?: string }>()
const text = ref('')
const mentions = ref<{ user_id: number; name: string; offset: number; length: number }[]>([])

// W4-3: 接收端按 MessageText.mentions 的 offset/length 对 @成员 高亮渲染
const rendered = computed(() => {
  if (mentions.value.length === 0) return escapeHtml(text.value)
  const parts: string[] = []
  let cursor = 0
  for (const m of mentions.value) {
    const start = m.offset
    const end = m.offset + m.length
    if (start < cursor) continue
    parts.push(escapeHtml(text.value.slice(cursor, start)))
    parts.push(`<span class="mention">${escapeHtml(text.value.slice(start, end) || '@' + m.name)}</span>`)
    cursor = end
  }
  parts.push(escapeHtml(text.value.slice(cursor)))
  return parts.join('')
})

function escapeHtml(s: string): string {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
}

onMounted(() => {
  try {
    const decoded = lookup('entity.MessageText').decode(props.content) as any
    text.value = decoded.text || ''
    mentions.value = decoded.mentions || []
    if (mentions.value.length === 0) {
      // 兼容旧消息：无 mentions 字段时降级为纯文本
      text.value = decoded.text || new TextDecoder().decode(props.content) || ''
    }
  } catch {
    text.value = new TextDecoder().decode(props.content) || ''
  }
})
</script>

<style scoped>
:deep(.mention) {
  color: #1976d2;
  background: rgba(25, 118, 210, 0.08);
  border-radius: 4px;
  padding: 0 2px;
  font-weight: 500;
}
</style>
