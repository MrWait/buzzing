<template>
  <div class="prose-editor">
    <div ref="editorContainer" class="editor-container"></div>
  </div>
</template>

<script setup lang="ts">
import { ref, inject, onMounted, onUnmounted } from 'vue'
import { EditorState } from 'prosemirror-state'
import { EditorView } from 'prosemirror-view'
import { Schema } from 'prosemirror-model'
import { schema as basicSchema } from 'prosemirror-schema-basic'
import { addListNodes } from 'prosemirror-schema-list'
import { exampleSetup } from 'prosemirror-example-setup'
import { keymap } from 'prosemirror-keymap'
import { ySyncPlugin, yCursorPlugin, yUndoPlugin, undo, redo } from 'y-prosemirror'
import type { XmlFragment } from 'yjs'
import type { WebsocketProvider } from 'y-websocket'

const editorContainer = ref<HTMLDivElement>()
let view: EditorView | null = null

const type = inject<XmlFragment>('yjs-type')!
const provider = inject<WebsocketProvider>('yjs-provider')!

onMounted(() => {
  if (!editorContainer.value) return

  const schema = new Schema({
    nodes: addListNodes(basicSchema.spec.nodes, 'paragraph block*', 'block'),
    marks: basicSchema.spec.marks,
  })

  const plugins = [
    ySyncPlugin(type),
    yCursorPlugin(provider.awareness),
    yUndoPlugin(),
    keymap({ 'Mod-z': undo, 'Mod-y': redo, 'Shift-Mod-z': redo }),
    ...exampleSetup({ schema, history: false, menuBar: false }),
  ]

  const state = EditorState.create({ schema, plugins })
  view = new EditorView(editorContainer.value, { state })
})

onUnmounted(() => {
  view?.destroy()
})
</script>

<style scoped>
.prose-editor {
  flex: 1;
  display: flex;
  flex-direction: column;
}
.editor-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  max-width: 800px;
  width: 100%;
  margin: 0 auto;
  padding: 24px;
  outline: none;
}
.editor-container :deep(.ProseMirror) {
  flex: 1;
  outline: none;
}
.editor-container :deep(.ProseMirror p) {
  margin: 0;
}
</style>
