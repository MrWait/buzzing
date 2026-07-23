<template>
  <div class="reaction-bar" v-if="Object.keys(reactions).length > 0">
    <button
      v-for="(r, emoji) in localReactions"
      :key="emoji"
      class="reaction-btn"
      :class="{ active: r.me }"
      @click.stop="toggle(Number(emoji))"
    >
      {{ getEmoji(Number(emoji)) }} {{ r.total }}
    </button>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useImStore } from '@/stores/im'

const props = defineProps<{ messageId: number; reactions: Record<number, { total: number; me: boolean }> }>()
const im = useImStore()

const localReactions = computed(() => props.reactions || {})

const EMOJI_MAP: Record<number, string> = {
  1: '👍', 2: '👎', 3: '😄', 4: '😢', 5: '😮', 6: '❤️', 7: '🎉',
}

function getEmoji(r: number): string {
  return EMOJI_MAP[r] || `:${r}:`
}

async function toggle(reaction: number) {
  const r = props.reactions[reaction]
  try {
    await im.setReaction(props.messageId, reaction, !r?.me)
  } catch (e) {
    console.error('reaction error:', e)
  }
}
</script>

<style scoped>
.reaction-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 2px;
  margin-top: 2px;
}
.reaction-btn {
  display: inline-flex;
  align-items: center;
  gap: 2px;
  padding: 1px 6px;
  border: 1px solid #e0e0e0;
  border-radius: 10px;
  background: #fff;
  font-size: 12px;
  cursor: pointer;
  line-height: 1.4;
}
.reaction-btn.active {
  background: #e3f2fd;
  border-color: #90caf9;
}
.reaction-btn:hover { border-color: #999; }
</style>
