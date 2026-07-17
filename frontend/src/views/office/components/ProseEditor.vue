<template>
  <div
    class="prose-editor"
    @mouseenter="mouseInEditor = true"
    @mouseleave="mouseInEditor = false"
  >
    <div ref="editorContainer" class="editor-container"></div>
    <FloatingToolbar @link="showLinkDialog = true" />
    <SlashMenu />
    <LinkDialog :open="showLinkDialog" @close="showLinkDialog = false" />
    <ImageUpload ref="imageUploadRef" />
    <BlockMenuTrigger />
    <TableMenu />
  </div>
</template>

<script setup lang="ts">
import { ref, inject, onMounted, onUnmounted, provide, computed, watch } from 'vue'
import { useEditorSchema } from '../composables/useEditorSchema'
import FloatingToolbar from './FloatingToolbar.vue'
import SlashMenu from './SlashMenu.vue'
import LinkDialog from './LinkDialog.vue'
import ImageUpload from './ImageUpload.vue'
import BlockMenuTrigger from './BlockMenuTrigger.vue'
import TableMenu from './TableMenu.vue'
import type { XmlFragment } from 'yjs'
import type { WebsocketProvider } from 'y-websocket'

const props = defineProps<{ docId: string; readonly?: boolean }>()

const type = inject<XmlFragment>('yjs-type')!
const provider = inject<WebsocketProvider>('yjs-provider')!

const showLinkDialog = ref(false)
const imageUploadRef = ref<InstanceType<typeof ImageUpload> | null>(null)

const mouseInEditor = ref(true)
const editorContainer = ref<HTMLDivElement | null>(null)
const editable = computed(() => !props.readonly)

const { editorView, schema, mount, destroy } = useEditorSchema(
  type,
  provider,
  editorContainer,
  {
    onImagePaste: (file: File) => imageUploadRef.value?.uploadFile(file),
    onLinkShortcut: () => {
      if (!props.readonly) showLinkDialog.value = true
    },
  },
  { editable },
)
provide('editorView', editorView)
provide('schema', schema)
provide('triggerImageUpload', () => imageUploadRef.value?.trigger())
provide('triggerLinkDialog', () => { if (!props.readonly) showLinkDialog.value = true })
provide('mouseInEditor', mouseInEditor)

// editable 变化时同步 ProseMirror DOM contentEditable
watch(editable, (val) => {
  if (editorView.value) {
    editorView.value.dom.contentEditable = val ? 'true' : 'false'
  }
})

onMounted(() => {
  mount()
})
onUnmounted(destroy)
</script>

<style scoped>
.prose-editor {
  flex: 1 1 auto;
  display: flex;
  flex-direction: column;
}
.editor-container {
  flex: 1 1 auto;
  display: flex;
  flex-direction: column;
  max-width: 800px;
  width: 100%;
  margin: 0 auto;
  padding: 24px;
  outline: none;
  background: #fff;
}
.editor-container :deep(.ProseMirror) {
  flex: 1 1 auto;
  outline: none;
}
.editor-container :deep(.ProseMirror p) {
  margin: 0;
}
</style>
