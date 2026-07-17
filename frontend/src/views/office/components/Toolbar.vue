<template>
  <div class="toolbar">
    <div class="toolbar-inner">
    <div class="toolbar-group">
      <ToolbarButton
        :active="activeMarks.has('strong')"
        tooltip="加粗 (Ctrl+B)"
        @click="toggleMark('strong')"
      >
        <Bold :size="16" />
      </ToolbarButton>
      <ToolbarButton
        :active="activeMarks.has('em')"
        tooltip="斜体 (Ctrl+I)"
        @click="toggleMark('em')"
      >
        <Italic :size="16" />
      </ToolbarButton>
      <ToolbarButton
        :active="activeMarks.has('underline')"
        tooltip="下划线 (Ctrl+U)"
        @click="toggleMark('underline')"
      >
        <Underline :size="16" />
      </ToolbarButton>
      <ToolbarButton
        :active="activeMarks.has('strike')"
        tooltip="删除线 (Ctrl+Shift+S)"
        @click="toggleMark('strike')"
      >
        <Strikethrough :size="16" />
      </ToolbarButton>
      <ToolbarButton
        :active="activeMarks.has('code')"
        tooltip="行内代码"
        @click="toggleMark('code')"
      >
        <Code :size="16" />
      </ToolbarButton>
    </div>

    <ToolbarDivider />

    <div class="toolbar-group">
      <ToolbarDropdown
        :model-value="headingLabel"
        :options="headingOptions"
        :label="headingLabel"
        tooltip="标题"
        @update:model-value="setHeading"
      />
    </div>

    <ToolbarDivider />

    <div class="toolbar-group">
      <ToolbarButton
        :active="activeNode === 'blockquote'"
        tooltip="引用"
        @click="wrapInBlockquote"
      >
        <TextQuote :size="16" />
      </ToolbarButton>
      <ToolbarButton
        :active="activeNode === 'orderedList'"
        tooltip="有序列表"
        @click="wrapInOrderedList"
      >
        <ListOrdered :size="16" />
      </ToolbarButton>
      <ToolbarButton
        :active="activeNode === 'bulletList'"
        tooltip="无序列表"
        @click="wrapInBulletList"
      >
        <List :size="16" />
      </ToolbarButton>
      <ToolbarButton
        :active="activeNode === 'taskList'"
        tooltip="任务列表"
        @click="wrapInTaskList"
      >
        <ListChecks :size="16" />
      </ToolbarButton>
    </div>

    <ToolbarDivider />

    <div class="toolbar-group">
      <ToolbarButton
        :active="activeNode === 'codeBlock'"
        tooltip="代码块 (Ctrl+Shift+C)"
        @click="setCodeBlock"
      >
        <FileCode :size="16" />
      </ToolbarButton>
      <ToolbarButton
        tooltip="分割线"
        @click="insertHorizontalRule"
      >
        <Minus :size="16" />
      </ToolbarButton>
      <ToolbarButton
        tooltip="表格"
        @click="insertTable"
      >
        <Table :size="16" />
      </ToolbarButton>
    </div>

    <template v-if="inTable">
      <ToolbarDivider />

      <div class="toolbar-group">
        <ToolbarButton
          tooltip="在上方插入行"
          @click="addRowBefore"
        >
          <ArrowUpFromLine :size="16" />
        </ToolbarButton>
        <ToolbarButton
          tooltip="在下方插入行"
          @click="addRowAfter"
        >
          <ArrowDownToLine :size="16" />
        </ToolbarButton>
        <ToolbarButton
          tooltip="删除行"
          @click="deleteCurrentRow"
        >
          <Trash2 :size="16" />
        </ToolbarButton>
        <ToolbarButton
          tooltip="删除表格"
          @click="deleteCurrentTable"
        >
          <X :size="16" />
        </ToolbarButton>
      </div>
    </template>

    <ToolbarDivider />

    <div class="toolbar-group">
      <ToolbarButton
        tooltip="链接 (Ctrl+K)"
        @click="$emit('link')"
      >
        <Link :size="16" />
      </ToolbarButton>
      <ToolbarButton
        tooltip="图片"
        @click="$emit('image')"
      >
        <Image :size="16" />
      </ToolbarButton>
    </div>

    <ToolbarDivider />

    <div class="toolbar-group">
      <ToolbarButton
        tooltip="清除格式"
        @click="clearFormatting"
      >
        <RemoveFormatting :size="16" />
      </ToolbarButton>
    </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { inject, computed } from 'vue'
import type { Ref } from 'vue'
import type { EditorState, Transaction, TextSelection } from 'prosemirror-state'
import type { EditorView } from 'prosemirror-view'
import { setBlockType, wrapIn } from 'prosemirror-commands'
import { wrapInList } from 'prosemirror-schema-list'
import { Fragment } from 'prosemirror-model'
import type { Node } from 'prosemirror-model'
import {
  Bold, Italic, Underline, Strikethrough, Code,
  TextQuote, ListOrdered, List, ListChecks,
  FileCode, Minus, Table,
  Link, Image, RemoveFormatting,
  ArrowUpFromLine, ArrowDownToLine, Trash2, X,
} from '@lucide/vue'
import ToolbarButton from './ToolbarButton.vue'
import ToolbarDivider from './ToolbarDivider.vue'
import ToolbarDropdown from './ToolbarDropdown.vue'
import { useToolbarState } from '../composables/useToolbarState'

const emit = defineEmits<{
  link: []
  image: []
}>()

const editorView = inject<Ref<EditorView | null>>('editorView')!

import { addRowAfter as pmAddRowAfter, addRowBefore as pmAddRowBefore, deleteRow as pmDeleteRow, deleteTable as pmDeleteTable } from 'prosemirror-tables'

const { activeMarks, activeNode, headingLevel, inTable } = useToolbarState(editorView)

const headingOptions = [
  { label: '正文', value: 0 },
  { label: '标题 1', value: 1 },
  { label: '标题 2', value: 2 },
  { label: '标题 3', value: 3 },
  { label: '标题 4', value: 4 },
  { label: '标题 5', value: 5 },
  { label: '标题 6', value: 6 },
]

const headingLabel = computed(() => {
  const opt = headingOptions.find(o => o.value === headingLevel.value)
  return opt ? opt.label : '正文'
})

function exec(fn: (state: EditorState, dispatch: (tr: Transaction) => void) => boolean) {
  const view = editorView.value
  if (!view) return
  const { state } = view
  fn(state, (tr: Transaction) => view.dispatch(tr))
  view.focus()
}

function toggleMark(name: string) {
  exec((state, d) => {
    const markType = state.schema.marks[name]
    if (!markType) return false
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
    } else {
      const has = $from.marksAcross($to)?.some(m => m.type === markType) ?? false
      if (has) {
        tr.removeMark($from.pos, $to.pos, markType)
      } else {
        tr.addMark($from.pos, $to.pos, markType.create())
      }
    }
    d(tr)
    return true
  })
}

function setHeading(value: string | number) {
  const level = value as number
  exec((state, d) => {
    if (level === 0) {
      return setBlockType(state.schema.nodes.paragraph)(state, d)
    }
    return setBlockType(state.schema.nodes.heading, { level })(state, d)
  })
}

function wrapInBlockquote() {
  exec((state, d) => wrapIn(state.schema.nodes.blockquote)(state, d))
}

function wrapInOrderedList() {
  exec((state, d) => wrapInList(state.schema.nodes.orderedList)(state, d))
}

function wrapInBulletList() {
  exec((state, d) => wrapInList(state.schema.nodes.bulletList)(state, d))
}

function wrapInTaskList() {
  exec((state, d) => {
    const { taskList, taskItem, paragraph } = state.schema.nodes
    const { selection, tr } = state
    const { $from, $to } = selection
    if ($from.parent.type === taskItem) return false
    const list = taskList.createAndFill(undefined, taskItem.createAndFill(undefined, paragraph.create())!)!
    tr.replaceRangeWith($from.before(), $to.after(), list)
    d(tr)
    return true
  })
}

function setCodeBlock() {
  exec((state, d) => setBlockType(state.schema.nodes.codeBlock)(state, d))
}

function insertHorizontalRule() {
  exec((state, d) => {
    const hr = state.schema.nodes.horizontalRule.create()
    d(state.tr.replaceSelectionWith(hr))
    return true
  })
}

function insertTable() {
  exec((state, d) => {
    const { table, table_row, table_cell } = state.schema.nodes
    const rows: Node[] = []
    for (let r = 0; r < 3; r++) {
      const cells: Node[] = []
      for (let c = 0; c < 3; c++) {
        cells.push(table_cell.createAndFill()!)
      }
      rows.push(table_row.createAndFill(undefined, cells)!)
    }
    d(state.tr.replaceSelectionWith(table.createAndFill(undefined, Fragment.fromArray(rows))!))
    return true
  })
}

function addRowBefore() {
  exec((state, d) => pmAddRowBefore(state, d))
}

function addRowAfter() {
  exec((state, d) => pmAddRowAfter(state, d))
}

function deleteCurrentRow() {
  exec((state, d) => pmDeleteRow(state, d))
}

function deleteCurrentTable() {
  exec((state, d) => pmDeleteTable(state, d))
}

function clearFormatting() {
  exec((state, d) => {
    const { tr, selection, schema } = state
    const { $from, $to } = selection
    const tr2 = tr.removeMark($from.pos, $to.pos, schema.marks.strong)
      .removeMark($from.pos, $to.pos, schema.marks.em)
      .removeMark($from.pos, $to.pos, schema.marks.underline)
      .removeMark($from.pos, $to.pos, schema.marks.strike)
      .removeMark($from.pos, $to.pos, schema.marks.code)
    d(tr2)
    return true
  })
}
</script>

<style scoped>
.toolbar {
  display: flex;
  align-items: center;
  height: 40px;
  border-bottom: 1px solid #e0e0e0;
  background: #fafafa;
  flex-shrink: 0;
}
.toolbar-inner {
  display: flex;
  align-items: center;
  gap: 2px;
  max-width: 800px;
  width: 100%;
  margin: 0 auto;
  padding: 0 24px;
  overflow-x: auto;
}
.toolbar-group {
  display: inline-flex;
  align-items: center;
  gap: 1px;
}
</style>
