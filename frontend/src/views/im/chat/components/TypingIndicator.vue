<template>
  <div v-if="typingInfo" class="typing-indicator">
    <span v-for="(t, i) in typingInfo" :key="t.userId">
      {{ i > 0 ? '、' : '' }}{{ t.userName }}
    </span>
    <span> 正在输入...</span>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useImStore } from '@/stores/im'

const props = defineProps<{ chatId: number }>()
const im = useImStore()

const typingInfo = computed(() => {
  const list = im.typingUsers.get(props.chatId) || []
  const now = Date.now()
  return list.filter((t) => t.expireAt > now)
})
</script>

<style scoped>
.typing-indicator {
  font-size: 12px;
  color: #999;
  padding: 2px 12px 4px;
}
</style>
