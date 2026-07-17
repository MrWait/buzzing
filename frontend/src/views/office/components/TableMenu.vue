<template>
  <Teleport to="body">
    <div
      v-if="corner.visible"
      class="tm-corner-menu"
      :style="{ left: corner.left + 'px', top: corner.top + 'px' }"
      @mousedown.prevent.stop
    >
      <button class="tm-btn" @click="deleteTable">Delete table</button>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { inject, onMounted, onUnmounted } from 'vue'
import type { Ref } from 'vue'
import type { EditorView } from 'prosemirror-view'
import {
  addRowAfter as pmAddRowAfter,
  addColumnAfter as pmAddColumnAfter,
  deleteRow as pmDeleteRow,
  deleteColumn as pmDeleteColumn,
  deleteTable as pmDeleteTable,
} from 'prosemirror-tables'

const editorView = inject<Ref<EditorView | null>>('editorView')!

const EDGE = 10
const CORNER = 20

type ZoneType = 'corner' | 'row-del' | 'col-del' | 'row-ins' | 'col-ins'
let activeType: ZoneType | null = null
let corner = { visible: false, left: 0, top: 0 }

function exec(fn: (state: any, dispatch: any) => boolean) {
  const view = editorView.value
  if (!view) return
  fn(view.state, (tr: any) => view.dispatch(tr))
  view.focus()
}

function deleteTable() {
  exec(pmDeleteTable)
}

function handleClick() {
  if (!activeType) return
  switch (activeType) {
    case 'row-del':
      exec(pmDeleteRow)
      break
    case 'col-del':
      exec(pmDeleteColumn)
      break
    case 'row-ins':
      exec(pmAddRowAfter)
      break
    case 'col-ins':
      exec(pmAddColumnAfter)
      break
    default:
      return
  }
  clearHighlights()
  corner.visible = false
  activeType = null
}

function clearHighlights() {
  document.querySelectorAll('.tm-red-row, .tm-red-col, .tm-blue-row, .tm-blue-col')
    .forEach(el => el.classList.remove('tm-red-row', 'tm-red-col', 'tm-blue-row', 'tm-blue-col'))
}

function onMouseMove(e: MouseEvent) {
  const view = editorView.value
  if (!view) return
  const editorEl = view.dom
  if (!editorEl) return
  const table = findClosestTable(e.target as HTMLElement)
  if (!table) {
    clearHighlights()
    corner.visible = false
    activeType = null
    return
  }

  const tableRect = table.getBoundingClientRect()
  const mx = e.clientX
  const my = e.clientY

  // 1. 左上角
  if (mx - tableRect.left < CORNER && my - tableRect.top < CORNER) {
    clearHighlights()
    corner.visible = true
    corner.left = tableRect.left + 2
    corner.top = tableRect.top + 2
    activeType = 'corner'
    return
  }
  corner.visible = false

  // 构建单元格矩阵
  const rows = table.querySelectorAll('tr')
  const cellRects: { row: number; col: number; rect: DOMRect; el: Element }[] = []
  rows.forEach((tr, ri) => {
    tr.querySelectorAll('td, th').forEach((cell, ci) => {
      cellRects.push({ row: ri, col: ci, rect: (cell as HTMLElement).getBoundingClientRect(), el: cell })
    })
  })
  if (cellRects.length === 0) return

  const nRows = rows.length
  const nCols = cellRects.length > 0 ? Math.max(...cellRects.map(c => c.col)) + 1 : 0

  clearHighlights()
  activeType = null

  // 优先级：row-del > col-del > row-ins > col-ins
  for (const { row, rect } of cellRects) {
    if (row < nRows && my >= rect.top - EDGE && my <= rect.bottom + EDGE && mx >= rect.left - EDGE && mx <= rect.left + EDGE) {
      rows[row].classList.add('tm-red-row')
      activeType = 'row-del'
      return
    }
  }

  for (const { col, rect } of cellRects) {
    if (col < nCols && mx >= rect.left - EDGE && mx <= rect.right + EDGE && my >= rect.top - EDGE && my <= rect.top + EDGE) {
      for (const cr of cellRects) {
        if (cr.col === col) cr.el.classList.add('tm-red-col')
      }
      activeType = 'col-del'
      return
    }
  }

  for (const { row, rect, el } of cellRects) {
    if (row < nRows - 1 && mx >= rect.left && mx <= rect.right && my >= rect.bottom - EDGE && my <= rect.bottom + EDGE) {
      el.classList.add('tm-blue-row')
      activeType = 'row-ins'
      return
    }
  }

  for (const { col, rect, el } of cellRects) {
    if (col < nCols - 1 && my >= rect.top && my <= rect.bottom && mx >= rect.right - EDGE && mx <= rect.right + EDGE) {
      el.classList.add('tm-blue-col')
      activeType = 'col-ins'
      return
    }
  }
}

function findClosestTable(el: HTMLElement | null): HTMLTableElement | null {
  while (el) {
    if (el.tagName === 'TABLE') return el as HTMLTableElement
    el = el.parentElement
  }
  return null
}

onMounted(() => {
  document.addEventListener('mousemove', onMouseMove)
  document.addEventListener('click', handleClick)
})

onUnmounted(() => {
  document.removeEventListener('mousemove', onMouseMove)
  document.removeEventListener('click', handleClick)
  clearHighlights()
})
</script>

<style>
.tm-corner-menu {
  position: fixed;
  z-index: 1001;
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 6px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.12);
  padding: 4px;
}
.tm-btn {
  display: block;
  width: 100%;
  padding: 6px 14px;
  border: none;
  background: transparent;
  cursor: pointer;
  font-size: 13px;
  color: #333;
  border-radius: 4px;
  white-space: nowrap;
  text-align: left;
}
.tm-btn:hover {
  background: #f0f0f0;
}

/* 行删除 — 红色左边框阴影 */
.ProseMirror tr.tm-red-row td,
.ProseMirror tr.tm-red-row th {
  background: rgba(220, 38, 38, 0.06) !important;
}
.ProseMirror tr.tm-red-row td:first-child,
.ProseMirror tr.tm-red-row th:first-child {
  box-shadow: -4px 0 6px rgba(220, 38, 38, 0.35);
}

/* 列删除 — 红色上边框阴影 */
.ProseMirror td.tm-red-col,
.ProseMirror th.tm-red-col {
  background: rgba(220, 38, 38, 0.06) !important;
  box-shadow: 0 -4px 6px rgba(220, 38, 38, 0.35);
}

/* 行间插入 — 蓝色下边框阴影 */
.ProseMirror td.tm-blue-row,
.ProseMirror th.tm-blue-row {
  box-shadow: 0 4px 6px -2px rgba(37, 99, 235, 0.5);
}

/* 列间插入 — 蓝色右边框阴影 */
.ProseMirror td.tm-blue-col,
.ProseMirror th.tm-blue-col {
  box-shadow: 4px 0 6px -2px rgba(37, 99, 235, 0.5);
}
</style>
