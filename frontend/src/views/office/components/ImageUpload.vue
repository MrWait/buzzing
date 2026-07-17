<template>
  <div v-if="uploading" class="upload-overlay">
    <div class="upload-progress">
      <div class="upload-spinner" />
      <span>{{ uploadPercent > 0 ? `${uploadPercent}%` : '上传中...' }}</span>
    </div>
  </div>
  <input
    ref="fileInput"
    type="file"
    accept="image/*"
    style="display:none"
    @change="onFileSelected"
  />
</template>

<script setup lang="ts">
import { ref, inject, type Ref } from 'vue'
import type { EditorView } from 'prosemirror-view'
import api from '@/services/api'

const MAX_SIZE = 10 * 1024 * 1024
const ALLOWED_TYPES = ['image/png', 'image/jpeg', 'image/webp', 'image/gif']

const editorView = inject<Ref<EditorView | null>>('editorView')!

const fileInput = ref<HTMLInputElement | null>(null)
const uploading = ref(false)
const uploadPercent = ref(0)

function trigger() {
  fileInput.value?.click()
}

function onFileSelected(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (file) uploadFile(file)
  if (fileInput.value) fileInput.value.value = ''
}

async function uploadFile(file: File) {
  if (!ALLOWED_TYPES.includes(file.type)) {
    alert('不支持的图片格式，仅支持 PNG/JPEG/WebP/GIF')
    return
  }
  if (file.size > MAX_SIZE) {
    alert('图片大小超过 10MB 限制')
    return
  }

  uploading.value = true
  uploadPercent.value = 0

  try {
    const form = new FormData()
    form.append('file', file)

    const res = await api.post('/files/upload', form, {
      headers: { 'Content-Type': 'multipart/form-data' },
      onUploadProgress: (e) => {
        if (e.total) uploadPercent.value = Math.round((e.loaded / e.total) * 100)
      },
    })

    const url = res.data.url as string
    insertImage(url)
  } catch {
    alert('图片上传失败')
  } finally {
    uploading.value = false
    uploadPercent.value = 0
  }
}

function insertImage(src: string) {
  const view = editorView.value
  if (!view) return
  const { state, dispatch } = view
  const img = state.schema.nodes.image.create({ src })
  dispatch(state.tr.replaceSelectionWith(img))
  view.focus()
}

defineExpose({ trigger, uploadFile })
</script>

<style scoped>
.upload-overlay {
  position: fixed;
  bottom: 24px;
  right: 24px;
  background: #333;
  color: #fff;
  padding: 10px 18px;
  border-radius: 8px;
  font-size: 14px;
  z-index: 300;
  display: flex;
  align-items: center;
  gap: 10px;
}
.upload-progress {
  display: flex;
  align-items: center;
  gap: 8px;
}
.upload-spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: #fff;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}
@keyframes spin {
  to { transform: rotate(360deg); }
}
</style>
