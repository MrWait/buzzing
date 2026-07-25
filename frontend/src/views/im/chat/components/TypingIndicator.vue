<template>
  <div v-if="typingInfo" class="typing-indicator">
    <span v-for="(t, i) in typingInfo" :key="t.userId">
      {{ i > 0 ? '、' : '' }}{{ t.userName }}
    </span>
    <span> 正在输入...</span>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, onMounted, onUnmounted } from 'vue'
import { useImStore } from '@/stores/im'

const props = defineProps<{ chatId: string }>()
const im = useImStore()

const now = ref(Date.now())
let tick: ReturnType<typeof setInterval>
onMounted(() => {
  tick = setInterval(() => { now.value = Date.now() }, 1000)
})
onUnmounted(() => {
  clearInterval(tick)
})

const typingInfo = computed(() => {
  const list = im.typingUsers.get(props.chatId) || []
  return list.filter((t) => t.expireAt > now.value)
})
</script>

<style scoped>
.typing-indicator {
  font-size: 12px;
  color: #999;
  padding: 2px 12px 4px;
}
</style>
