<template>
  <span>{{ text }}</span>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { lookup } from '@/services/im/proto'

const props = defineProps<{ content: Uint8Array }>()
const text = ref('')

onMounted(() => {
  try {
    const decoded = lookup('entity.MessageText').decode(props.content) as any
    text.value = decoded.text || ''
  } catch {
    text.value = new TextDecoder().decode(props.content) || ''
  }
})
</script>
