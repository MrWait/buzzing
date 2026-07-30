<template>
  <div
    class="prose-editor"
    @mouseenter="mouseInEditor = true"
    @mouseleave="mouseInEditor = false"
  >
    <div class="prose-editor-body">
      <div ref="editorContainer" class="editor-container"></div>
      <Outline />
    </div>
    <FloatingToolbar @link="showLinkDialog = true" />
    <SlashMenu />
    <LinkDialog :open="showLinkDialog" @close="showLinkDialog = false" />
    <ImageUpload ref="imageUploadRef" />
    <BlockMenuTrigger />
    <TableMenu />
    <MentionPopup :state="mentionState" :on-insert="onMentionInsert" />
  </div>
</template>

<script setup lang="ts">
import { ref, inject, onMounted, onUnmounted, provide, computed, watch } from 'vue'
import { useEditorSchema } from '../composables/useEditorSchema'
import { createMentionPlugin, createMentionState, type MentionSuggestion } from '../composables/useMention'
import { customNodeSpecs, buildNodeViews } from '../nodes'
import FloatingToolbar from './FloatingToolbar.vue'
import SlashMenu from './SlashMenu.vue'
import LinkDialog from './LinkDialog.vue'
import ImageUpload from './ImageUpload.vue'
import BlockMenuTrigger from './BlockMenuTrigger.vue'
import TableMenu from './TableMenu.vue'
import MentionPopup from './MentionPopup.vue'
import Outline from './Outline.vue'
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

const mentionState = createMentionState()
const { plugin: mentionPlugin, insertMention } = createMentionPlugin(mentionState, props.docId)

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
  {
    editable,
    extraPlugins: [mentionPlugin],
    extraNodes: customNodeSpecs,
    nodeViews: buildNodeViews(),
  },
)

function onMentionInsert(item: MentionSuggestion) {
  if (editorView.value) {
    insertMention(editorView.value, item)
  }
}

provide('editorView', editorView)
provide('schema', schema)
provide('triggerImageUpload', () => imageUploadRef.value?.trigger())
provide('triggerLinkDialog', () => { if (!props.readonly) showLinkDialog.value = true })
provide('mouseInEditor', mouseInEditor)

// editable 变化时同步 ProseMirror DOM contentEditable，并刷新远端光标显示
watch(editable, (val) => {
  if (editorView.value) {
    editorView.value.dom.contentEditable = val ? 'true' : 'false'
    const tr = editorView.value.state.tr
    editorView.value.dispatch(tr)
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
  overflow: hidden;
}
.prose-editor-body {
  flex: 1 1 auto;
  display: flex;
  flex-direction: row;
  overflow: hidden;
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
  overflow-y: auto;
}
.editor-container :deep(.ProseMirror) {
  flex: 1 1 auto;
  outline: none;
}
.editor-container :deep(.ProseMirror p) {
  margin: 0;
}
</style>
