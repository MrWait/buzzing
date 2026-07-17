<template>
  <div v-if="open" class="dialog-overlay" @mousedown.self="close">
    <div class="dialog-card">
      <h3 class="dialog-title">{{ isEdit ? '编辑链接' : '插入链接' }}</h3>

      <label class="dialog-field">
        <span>文本</span>
        <input v-model="text" placeholder="显示文本" />
      </label>
      <label class="dialog-field">
        <span>链接</span>
        <input v-model="href" placeholder="https://..." @keydown.enter="confirm" />
      </label>

      <div class="dialog-actions">
        <button v-if="isEdit" class="btn-remove" @click="removeLink">移除链接</button>
        <button class="btn-cancel" @click="close">取消</button>
        <button class="btn-confirm" :disabled="!href" @click="confirm">确认</button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, inject, watch, type Ref } from 'vue'
import type { EditorView } from 'prosemirror-view'

const props = defineProps<{ open: boolean }>()
const emit = defineEmits<{ close: [] }>()

const editorView = inject<Ref<EditorView | null>>('editorView')!

const href = ref('')
const text = ref('')
const isEdit = ref(false)

watch(() => props.open, (val) => {
  if (!val) return
  const view = editorView.value
  if (!view) return

  const { state } = view
  const { selection, schema } = state
  const linkType = schema.marks.link
  let linkAttrs = { href: '' }

  let linkFound = false
  const { $from, $to } = selection
  state.doc.nodesBetween($from.pos, $to.pos, (node) => {
    if (linkFound) return false
    if (node.marks) {
      const linkMark = node.marks.find(m => m.type === linkType)
      if (linkMark) {
        linkAttrs = linkMark.attrs as { href: string }
        text.value = node.textContent
        linkFound = true
        return false
      }
    }
  })

  if (linkFound) {
    href.value = linkAttrs.href
    isEdit.value = true
  } else {
    href.value = ''
    text.value = selection.empty ? '' : state.doc.textBetween($from.pos, $to.pos)
    isEdit.value = false
  }
})

function confirm() {
  if (!href.value) return
  const view = editorView.value
  if (!view) return

  const { state, dispatch } = view
  const linkType = state.schema.marks.link

  if (state.selection.empty) {
    const { from } = state.selection
    const tr = state.tr
      .insertText(href.value)
      .addMark(from, from + href.value.length, linkType.create({ href: href.value }))
    dispatch(tr)
  } else {
    const tr = state.tr
      .removeMark(state.selection.from, state.selection.to, linkType)
      .addMark(state.selection.from, state.selection.to, linkType.create({ href: href.value }))
    dispatch(tr)
  }
  view.focus()
  close()
}

function removeLink() {
  const view = editorView.value
  if (!view) return
  const { state, dispatch } = view
  const linkType = state.schema.marks.link
  const { from, to } = state.selection
  dispatch(state.tr.removeMark(from, to, linkType))
  view.focus()
  close()
}

function close() {
  href.value = ''
  text.value = ''
  isEdit.value = false
  emit('close')
}
</script>

<style scoped>
.dialog-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.35);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 200;
}
.dialog-card {
  background: #fff;
  border-radius: 8px;
  padding: 20px;
  min-width: 360px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.18);
}
.dialog-title {
  margin: 0 0 16px;
  font-size: 16px;
  font-weight: 600;
}
.dialog-field {
  display: flex;
  flex-direction: column;
  gap: 4px;
  margin-bottom: 12px;
}
.dialog-field span {
  font-size: 13px;
  color: #666;
}
.dialog-field input {
  padding: 8px 10px;
  border: 1px solid #d0d0d0;
  border-radius: 4px;
  font-size: 14px;
  outline: none;
  transition: border-color 0.15s;
}
.dialog-field input:focus {
  border-color: #1565c0;
}
.dialog-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 16px;
}
.dialog-actions button {
  padding: 6px 16px;
  border: none;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
  transition: background 0.15s;
}
.btn-confirm {
  background: #1565c0;
  color: #fff;
}
.btn-confirm:hover {
  background: #0d47a1;
}
.btn-confirm:disabled {
  background: #90caf9;
  cursor: not-allowed;
}
.btn-cancel {
  background: #f0f0f0;
  color: #333;
}
.btn-cancel:hover {
  background: #e0e0e0;
}
.btn-remove {
  margin-right: auto;
  background: transparent;
  color: #d32f2f;
}
.btn-remove:hover {
  background: #ffebee;
}
</style>
