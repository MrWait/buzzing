<template>
  <Teleport to="body">
    <div
      v-if="showFloating"
      class="floating-toolbar"
      :style="{ left: floatingLeft + 'px', top: floatingTop + 'px' }"
      @mousedown.prevent.stop
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
import { inject } from 'vue'
import type { Ref } from 'vue'
import type { EditorView } from 'prosemirror-view'
import { setBlockType, wrapIn } from 'prosemirror-commands'
import { useToolbarState } from '../composables/useToolbarState'

defineEmits<{ link: [] }>()

const editorView = inject<Ref<EditorView | null>>('editorView')!

const { activeMarks, headingLevel, showFloating, floatingLeft, floatingTop } = useToolbarState(editorView)

// 注意：浮动菜单外层与所有按钮都使用 @mousedown.prevent.stop，
// 阻止了编辑器 blur，因此 view.state.selection 会保持在原选区，
// 不需要额外保存/恢复选区。
function currentView(): EditorView | null {
  return editorView.value
}

function toggleMark(name: string) {
  const view = currentView()
  if (!view) return
  const { state } = view
  const markType = state.schema.marks[name]
  if (!markType) return
  const { $from, $to, empty } = state.selection
  const tr = state.tr

  if (empty) {
    const stored = state.storedMarks ?? $from.marks()
    const has = stored.some((m) => m.type === markType)
    if (has) tr.removeStoredMark(markType)
    else tr.addStoredMark(markType.create())
  } else {
    let allHas = true
    let sawText = false
    state.doc.nodesBetween($from.pos, $to.pos, (node) => {
      if (node.isText) {
        sawText = true
        if (!node.marks.some((m) => m.type === markType)) allHas = false
      }
    })
    if (!sawText) return
    if (allHas) tr.removeMark($from.pos, $to.pos, markType)
    else tr.addMark($from.pos, $to.pos, markType.create())
  }
  view.dispatch(tr)
  view.focus()
}

function setHeading(level: number) {
  const view = currentView()
  if (!view) return
  const { state, dispatch } = view
  const cmd = level === 0
    ? setBlockType(state.schema.nodes.paragraph)
    : setBlockType(state.schema.nodes.heading, { level })
  cmd(state, dispatch)
  view.focus()
}

function wrapInBlockquote() {
  const view = currentView()
  if (!view) return
  const { state, dispatch } = view
  wrapIn(state.schema.nodes.blockquote)(state, dispatch)
  view.focus()
}

function clearFormatting() {
  const view = currentView()
  if (!view) return
  const { state } = view
  const { $from, $to, empty } = state.selection
  if (empty) return
  const tr = state.tr
  const names = ['strong', 'em', 'underline', 'strike', 'code', 'link']
  for (const name of names) {
    const m = state.schema.marks[name]
    if (m) tr.removeMark($from.pos, $to.pos, m)
  }
  if (tr.steps.length === 0) return
  view.dispatch(tr)
  view.focus()
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
