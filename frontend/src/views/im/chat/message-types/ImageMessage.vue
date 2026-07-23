<template>
  <div class="image-msg">
    <img v-if="src" :src="src" :style="{ maxWidth: width ? width + 'px' : '240px', maxHeight: '300px' }" class="image-preview" @click="preview" />
    <span v-else>[图片]</span>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { lookup } from '@/services/im/proto'

const props = defineProps<{ content: Uint8Array }>()
const src = ref('')
const width = ref(0)

onMounted(() => {
  try {
    const decoded = lookup('entity.MessageImage').decode(props.content) as any
    src.value = decoded.thumbnail_url || decoded.url || ''
    width.value = decoded.width || 0
  } catch {
    src.value = ''
  }
})

function preview() {
  if (src.value) window.open(src.value, '_blank')
}
</script>

<style scoped>
.image-msg {
  display: inline-block;
}
.image-preview {
  border-radius: 8px;
  cursor: pointer;
  object-fit: cover;
}
.image-preview:hover {
  opacity: 0.9;
}
</style>
