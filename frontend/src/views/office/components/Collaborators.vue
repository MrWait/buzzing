<template>
  <div class="collaborators">
    <div
      v-for="(state, clientId) in cursorStates"
      :key="clientId"
      class="collaborator-avatar"
      :style="{ backgroundColor: state.user?.color ?? '#999' }"
      :title="state.user?.name ?? 'Unknown'"
    >
      {{ (state.user?.name ?? '?')[0] }}
    </div>
  </div>
</template>

<script setup lang="ts">
import { inject, ref, onMounted, onUnmounted } from 'vue'
import type { WebsocketProvider } from 'y-websocket'

interface AwarenessState {
  user?: { name: string; color: string }
}

const provider = inject<WebsocketProvider>('yjs-provider')!
const cursorStates = ref<Record<number, AwarenessState>>({})

let unsub: (() => void) | null = null

onMounted(() => {
  const update = () => {
    const states: Record<number, AwarenessState> = {}
    provider.awareness.getStates().forEach((state: AwarenessState, id: number) => {
      const localId = provider.awareness.clientID
      if (id !== localId && state.user) {
        states[id] = state
      }
    })
    cursorStates.value = states
  }
  provider.awareness.on('change', update)
  unsub = () => provider.awareness.off('change', update)
})

onUnmounted(() => {
  unsub?.()
})
</script>

<style scoped>
.collaborators {
  position: fixed;
  top: 56px;
  right: 16px;
  display: flex;
  gap: 4px;
}
.collaborator-avatar {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 12px;
  font-weight: 600;
}
</style>
