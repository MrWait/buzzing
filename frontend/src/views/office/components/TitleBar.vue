<template>
  <div class="title-bar-wrap">
    <input
      class="title-bar"
      v-model="title"
      placeholder="无标题"
      :readonly="readonly"
      @input="onInput"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import { docsApi } from '@/services/office/docs'

const props = defineProps<{ docId: string; modelValue?: string; readonly?: boolean }>()

const title = ref(props.modelValue ?? '')
let debounceTimer: ReturnType<typeof setTimeout> | null = null

watch(() => props.modelValue, (v) => {
  if (v !== undefined) title.value = v
})

function onInput() {
  if (props.readonly) return
  if (debounceTimer) clearTimeout(debounceTimer)
  debounceTimer = setTimeout(async () => {
    try {
      await docsApi.update(props.docId, { title: title.value })
    } catch {
      // silently fail; title will be refetched on next mount
    }
  }, 500)
}
</script>

<style scoped>
.title-bar-wrap {
  max-width: 800px;
  width: 100%;
  margin: 0 auto;
  padding: 0 24px;
  background: #fff;
}
.title-bar {
  width: 100%;
  font-size: 24px;
  font-weight: 600;
  border: 1px solid transparent;
  border-radius: 4px;
  padding: 8px 0;
  margin: 4px 0;
  outline: none;
  background: transparent;
  transition: border-color 0.15s;
}
.title-bar:hover {
  border-bottom-color: #e0e0e0;
}
.title-bar:focus {
  border-bottom-color: #1565c0;
}
.title-bar::placeholder {
  color: #9e9e9e;
}
</style>
