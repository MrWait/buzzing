<template>
  <div class="file-uploader">
    <input
      ref="fileInput"
      type="file"
      :accept="accept"
      :multiple="multiple"
      style="display:none"
      @change="onFileChange"
    />
    <slot name="trigger" :open="open">
      <button class="upload-btn" @click="open">
        {{ label }}
      </button>
    </slot>
    <div v-if="uploading" class="upload-progress">
      <div class="progress-bar">
        <div class="progress-fill" :style="{ width: progress + '%' }" />
      </div>
      <span class="progress-text">{{ progress }}%</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import api from '@/services/api'

const props = withDefaults(defineProps<{
  accept?: string
  multiple?: boolean
  label?: string
}>(), {
  accept: '*/*',
  multiple: false,
  label: '上传文件',
})

const emit = defineEmits<{
  (e: 'success', files: Array<{ id: number; url: string; name: string; mimeType: string; size: number }>): void
  (e: 'error', err: Error): void
}>()

const fileInput = ref<HTMLInputElement>()
const uploading = ref(false)
const progress = ref(0)

function open() {
  fileInput.value?.click()
}

async function onFileChange(e: Event) {
  const input = e.target as HTMLInputElement
  if (!input.files || input.files.length === 0) return
  uploading.value = true
  progress.value = 0
  try {
    const results: Array<{ id: number; url: string; name: string; mimeType: string; size: number }> = []
    for (const file of Array.from(input.files)) {
      const formData = new FormData()
      formData.append('file', file)
      const res = await api.post('/files/upload', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
        onUploadProgress: (e) => {
          if (e.total) progress.value = Math.round((e.loaded / e.total) * 100)
        },
      })
      const data = res.data
      results.push({
        id: data.id,
        url: data.url || `/api/files/${data.id}`,
        name: data.name || file.name,
        mimeType: data.mime_type || file.type,
        size: data.size || file.size,
      })
    }
    emit('success', results)
    input.value = ''
  } catch (err: any) {
    emit('error', err)
  } finally {
    uploading.value = false
    progress.value = 0
  }
}
</script>

<style scoped>
.upload-btn {
  padding: 6px 12px;
  background: #f0f0f0;
  border: 1px solid #e0e0e0;
  border-radius: 6px;
  font-size: 13px;
  cursor: pointer;
}
.upload-btn:hover { background: #e0e0e0; }
.upload-progress {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 4px 0;
}
.progress-bar {
  flex: 1;
  height: 4px;
  background: #e0e0e0;
  border-radius: 2px;
  overflow: hidden;
}
.progress-fill {
  height: 100%;
  background: #1976d2;
  transition: width 0.2s;
}
.progress-text {
  font-size: 11px;
  color: #999;
  min-width: 36px;
}
</style>
