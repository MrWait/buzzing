<template>
  <Teleport to="body">
    <div
      v-if="showFloating"
      class="floating-toolbar"
      :style="{ left: floatingLeft + 'px', top: floatingTop + 'px' }"
      @mousedown.stop
    >
      <div class="ft-group">
        <button class="ft-btn" :class="{ active: activeMarks.has('strong') }" title="加粗" @mousedown.prevent="toggleMark('strong')"><b>B</b></button>
        <button class="ft-btn" :class="{ active: activeMarks.has('em') }" title="斜体" @mousedown.prevent="toggleMark('em')"><i>I</i></button>
        <button class="ft-btn" :class="{ active: activeMarks.has('underline') }" title="下划线" @mousedown.prevent="toggleMark('underline')"><u>U</u></button>
        <button class="ft-btn" :class="{ active: activeMarks.has('strike') }" title="删除线" @mousedown.prevent="toggleMark('strike')"><s>S</s></button>
        <button class="ft-btn" :class="{ active: activeMarks.has('code') }" title="行内代码" @mousedown.prevent="toggleMark('code')">&lt;/&gt;</button>
      </div>
      <div class="ft-sep" />
      <div class="ft-group">
        <button class="ft-btn" :class="{ active: headingLevel === 0 }" title="正文" @mousedown.prevent="setHeading(0)">T</button>
        <button class="ft-btn" :class="{ active: headingLevel === 1 }" title="标题 1" @mousedown.prevent="setHeading(1)">H1</button>
        <button class="ft-btn" :class="{ active: headingLevel === 2 }" title="标题 2" @mousedown.prevent="setHeading(2)">H2</button>
        <button class="ft-btn" :class="{ active: headingLevel === 3 }" title="标题 3" @mousedown.prevent="setHeading(3)">H3</button>
      </div>
      <div class="ft-sep" />
      <div class="ft-group">
        <button class="ft-btn" title="引用" @mousedown.prevent="wrapInBlockquote">"</button>
        <button class="ft-btn" title="链接" @mousedown.prevent="$emit('link')">🔗</button>
        <button class="ft-btn" title="清除格式" @mousedown.prevent="clearFormatting">⌫</button>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import type { Node as ProseNode } from 'prosemirror-model'
import { Fragment, Slice } from 'prosemirror-model'
import { inject } from 'vue'
import type { Ref } from 'vue'
import type { EditorState, Transaction, TextSelection } from 'prosemirror-state'
import type { EditorView } from 'prosemirror-view'
import { setBlockType, wrapIn } from 'prosemirror-commands'
import { useToolbarState } from '../composables/useToolbarState'

defineEmits<{ link: [] }>()

const editorView = inject<Ref<EditorView | null>>('editorView')!

const { activeMarks, headingLevel, showFloating, floatingLeft, floatingTop } = useToolbarState(editorView)

function exec(fn: (state: EditorState, dispatch: (tr: Transaction) => void) => boolean) {
  const view = editorView.value
  if (!view) return
  fn(view.state, (tr: Transaction) => view.dispatch(tr))
  view.focus()
}

function toggleMark(name: string) {
  const view = editorView.value
  if (!view) return
  const { state, dispatch } = view
  const markType = state.schema.marks[name]
  if (!markType) return
  const { tr, selection } = state
  const { $from, $to } = selection

  if ($from.pos === $to.pos) {
    const sel = selection as TextSelection
    const has = !!sel.$cursor?.marks().some(m => m.type === markType)
      || !!state.storedMarks?.some(m => m.type === markType)
    if (has) {
      tr.removeStoredMark(markType)
    } else {
      tr.addStoredMark(markType.create())
    }
    dispatch(tr)
  } else {
    const has = $from.marksAcross($to)?.some(m => m.type === markType) ?? false
    const slice = selection.content()
    const nodes: ProseNode[] = []
    slice.content.forEach((node: ProseNode) => {
      if (node.isText) {
        if (has) {
          nodes.push(node.mark(node.marks.filter(m => m.type !== markType)))
        } else {
          nodes.push(node.mark([...node.marks, markType.create()]))
        }
      } else {
        nodes.push(node)
      }
    })
    const modifiedSlice = new Slice(Fragment.fromArray(nodes), slice.openStart, slice.openEnd)
    dispatch(tr.replaceRange($from.pos, $to.pos, modifiedSlice))
  }
  view.focus()
}

function setHeading(level: number) {
  exec((state, d) => {
    if (level === 0) return setBlockType(state.schema.nodes.paragraph)(state, d)
    return setBlockType(state.schema.nodes.heading, { level })(state, d)
  })
}

function wrapInBlockquote() {
  exec((state, d) => wrapIn(state.schema.nodes.blockquote)(state, d))
}

function clearFormatting() {
  exec((state, d) => {
    const { tr, selection, schema } = state
    const { $from, $to } = selection
    d(tr
      .removeMark($from.pos, $to.pos, schema.marks.strong)
      .removeMark($from.pos, $to.pos, schema.marks.em)
      .removeMark($from.pos, $to.pos, schema.marks.underline)
      .removeMark($from.pos, $to.pos, schema.marks.strike)
      .removeMark($from.pos, $to.pos, schema.marks.code))
    return true
  })
}
</script>

<style scoped>
.floating-toolbar {
  position: fixed;
  z-index: 1000;
  display: flex;
  align-items: center;
  gap: 2px;
  padding: 4px 6px;
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  box-shadow: 0 4px 16px rgba(0,0,0,0.15);
  font-size: 13px;
  user-select: none;
  pointer-events: auto;
}
.ft-group {
  display: inline-flex;
  align-items: center;
  gap: 1px;
}
.ft-sep {
  width: 1px;
  height: 20px;
  background: #e0e0e0;
  margin: 0 3px;
}
.ft-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 28px;
  height: 28px;
  padding: 0 5px;
  border: none;
  border-radius: 4px;
  background: transparent;
  color: #424242;
  cursor: pointer;
  font-size: 13px;
  font-family: inherit;
  transition: background 0.1s;
}
.ft-btn:hover {
  background: #f0f0f0;
}
.ft-btn.active {
  background: #e3f2fd;
  color: #1565c0;
}
.ft-btn b, .ft-btn i, .ft-btn u, .ft-btn s {
  font-family: inherit;
}
</style>
