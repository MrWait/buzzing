import { Plugin, PluginKey } from 'prosemirror-state'
import type { EditorState } from 'prosemirror-state'
import type { EditorView } from 'prosemirror-view'
import { Fragment } from 'prosemirror-model'
import type { Schema } from 'prosemirror-model'
import { setBlockType, wrapIn } from 'prosemirror-commands'
import { wrapInList } from 'prosemirror-schema-list'
import { ref, watch, computed, type Ref } from 'vue'

export interface SlashMenuItem {
  label: string
  description: string
  icon: string
  execute: (state: EditorState, dispatch: (tr: import('prosemirror-state').Transaction) => void) => boolean
}

export function buildSlashItems(schema: Schema, triggerImageUpload?: () => void): SlashMenuItem[] {
  const { nodes } = schema
  const canInsert = (name: string) => !!nodes[name]
  return [
    { label: '正文', description: '普通文本', icon: 'Aa', execute: (state, d) => setBlockType(nodes.paragraph)(state, d) },
    { label: '标题 1', description: '大标题', icon: 'H1', execute: (state, d) => setBlockType(nodes.heading, { level: 1 })(state, d) },
    { label: '标题 2', description: '中标题', icon: 'H2', execute: (state, d) => setBlockType(nodes.heading, { level: 2 })(state, d) },
    { label: '标题 3', description: '小标题', icon: 'H3', execute: (state, d) => setBlockType(nodes.heading, { level: 3 })(state, d) },
    { label: '引用', description: '引用文本', icon: '❝', execute: (state, d) => wrapIn(nodes.blockquote)(state, d) },
    { label: '分割线', description: '插入分割线', icon: '—', execute: (state, d) => { d(state.tr.replaceSelectionWith(nodes.horizontalRule.create())); return true } },
    { label: '有序列表', description: '编号列表', icon: '1.', execute: (state, d) => wrapInList(nodes.orderedList)(state, d) },
    { label: '无序列表', description: '项目列表', icon: '•', execute: (state, d) => wrapInList(nodes.bulletList)(state, d) },
    { label: '任务列表', description: '带复选框的列表', icon: '☑', execute: (state, d) => {
      const { taskList, taskItem, paragraph } = nodes
      const p = paragraph.create()
      const item = taskItem.create({ checked: false }, p)
      const list = taskList.create(undefined, Fragment.from(item))
      d(state.tr.replaceRangeWith(state.selection.$from.before(), state.selection.$to.after(), list))
      return true
    }},
    { label: '代码块', description: '代码片段', icon: '</>', execute: (state, d) => setBlockType(nodes.codeBlock)(state, d) },
    { label: '表格', description: '插入表格', icon: '⊞', execute: (state, d) => {
      const { table, table_row, table_cell } = nodes
      let rows = Fragment.empty
      for (let r = 0; r < 3; r++) {
        let cells = Fragment.empty
        for (let c = 0; c < 3; c++) cells = cells.append(Fragment.from(table_cell.createAndFill()!))
        rows = rows.append(Fragment.from(table_row.createAndFill(undefined, cells)!))
      }
      d(state.tr.replaceSelectionWith(table.createAndFill(undefined, rows)!))
      return true
    }},
    { label: '图片', description: '上传图片', icon: '🖼', execute: () => {
      triggerImageUpload?.()
      return true
    }},
    ...(canInsert('toggle') ? [{
      label: '折叠块', description: '可折叠展开的内容块', icon: '▶', execute: (state: EditorState, d: (tr: import('prosemirror-state').Transaction) => void) => {
        const p = nodes.paragraph.create()
        const toggleNode = nodes.toggle.create({ collapsed: false }, Fragment.from(p))
        d(state.tr.replaceSelectionWith(toggleNode))
        return true
      },
    }] : []),
    ...(canInsert('callout') ? [{
      label: '标注', description: '信息/警告/错误/成功', icon: '💬', execute: (state: EditorState, d: (tr: import('prosemirror-state').Transaction) => void) => {
        const p = nodes.paragraph.create()
        const calloutNode = nodes.callout.create({ calloutType: 'info' }, Fragment.from(p))
        d(state.tr.replaceSelectionWith(calloutNode))
        return true
      },
    }] : []),
    ...(canInsert('columns') ? [{
      label: '分栏', description: '2 栏布局', icon: '▮▮', execute: (state: EditorState, d: (tr: import('prosemirror-state').Transaction) => void) => {
        const { columns, column, paragraph } = nodes
        const col1 = column.create(undefined, Fragment.from(paragraph.create()))
        const col2 = column.create(undefined, Fragment.from(paragraph.create()))
        const colsNode = columns.create({ count: 2 }, Fragment.from([col1, col2]))
        d(state.tr.replaceSelectionWith(colsNode))
        return true
      },
    }] : []),
  ]
}

const slashMenuKey = new PluginKey('slash-menu')

interface SlashMenuState {
  active: boolean
  filter: string
  selectedIndex: number
}

export function useSlashMenu(
  editorView: Ref<EditorView | null>,
  items: Ref<SlashMenuItem[]>,
) {
  const visible = ref(false)
  const filter = ref('')
  const selectedIndex = ref(0)
  const position = ref({ left: 0, top: 0 })

  const filteredItems = computed(() => {
    if (!filter.value) return items.value
    const lower = filter.value.toLowerCase()
    return items.value.filter(
      item => item.label.toLowerCase().includes(lower) || item.description.toLowerCase().includes(lower),
    )
  })

  function updatePosition(view: EditorView) {
    const coords = view.coordsAtPos(view.state.selection.from)
    if (coords) {
      const editorRect = view.dom.getBoundingClientRect()
      position.value = {
        left: coords.left - editorRect.left,
        top: coords.bottom - editorRect.top + 4,
      }
    }
  }

  const plugin = new Plugin<SlashMenuState>({
    key: slashMenuKey,
    state: {
      init() {
        return { active: false, filter: '', selectedIndex: 0 }
      },
      apply(tr, prev) {
        const meta = tr.getMeta(slashMenuKey)
        if (meta) return { ...prev, ...meta }
        if (!tr.docChanged && !tr.selectionSet) return prev
        return { active: false, filter: '', selectedIndex: 0 }
      },
    },
    props: {
      handleTextInput(view, _from, _to, text) {
        const plState = plugin.getState(view.state)
        if (!plState) return false
        if (plState.active) {
          const newFilter = plState.filter + text
          view.dispatch(view.state.tr.setMeta(slashMenuKey, { filter: newFilter, selectedIndex: 0 }))
          return true
        }
        if (text === '/') {
          const $from = view.state.selection.$from
          if ($from.parentOffset === 0 && $from.parent.type.isBlock) {
            view.dispatch(view.state.tr.setMeta(slashMenuKey, { active: true, filter: '', selectedIndex: 0 }))
            return true
          }
        }
        return false
      },
      handleKeyDown(view, event) {
        const plState = plugin.getState(view.state)
        if (!plState || !plState.active) return false

        if (event.key === 'Escape') {
          view.dispatch(view.state.tr.setMeta(slashMenuKey, { active: false }))
          return true
        }
        if (event.key === 'Backspace' && plState.filter === '') {
          view.dispatch(view.state.tr.setMeta(slashMenuKey, { active: false }))
          return true
        }
        return false
      },
    },
    view: (v: EditorView) => ({
      update: () => {
        const plState = plugin.getState(v.state)
        if (!plState) return
        visible.value = plState.active
        filter.value = plState.filter
        selectedIndex.value = Math.min(plState.selectedIndex, filteredItems.value.length - 1)
        if (plState.active) {
          updatePosition(v)
        }
      },
    }),
  })

  function execute(index: number) {
    const view = editorView.value
    if (!view) return
    const item = filteredItems.value[index]
    if (!item) return
    const { state, dispatch } = view
    item.execute(state, (tr) => dispatch(tr))
    view.focus()
    view.dispatch(view.state.tr.setMeta(slashMenuKey, { active: false }))
  }

  watch(editorView, (view, _, onCleanup) => {
    if (!view) return
    view.updateState(view.state.reconfigure({
      plugins: view.state.plugins.concat([plugin]),
    }))
    onCleanup(() => {
      if (editorView.value) {
        const without = editorView.value.state.plugins.filter((p: Plugin) => (p as any).key !== slashMenuKey)
        editorView.value.updateState(editorView.value.state.reconfigure({ plugins: without }))
      }
    })
  })

  return { visible, filter, selectedIndex, filteredItems, position, execute }
}
