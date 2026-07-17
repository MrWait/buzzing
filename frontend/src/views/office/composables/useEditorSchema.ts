import type { MarkSpec, NodeSpec } from 'prosemirror-model'
import { Schema, Fragment } from 'prosemirror-model'
import { EditorState, Plugin } from 'prosemirror-state'
import type { Plugin as PluginType } from 'prosemirror-state'
import { EditorView } from 'prosemirror-view'
import { keymap } from 'prosemirror-keymap'
import { setBlockType, toggleMark } from 'prosemirror-commands'
import { sinkListItem, liftListItem } from 'prosemirror-schema-list'
import { isInTable } from 'prosemirror-tables'
import { exampleSetup } from 'prosemirror-example-setup'
import { inputRules, InputRule } from 'prosemirror-inputrules'
import { ySyncPlugin, yCursorPlugin, yUndoPlugin, undo, redo } from 'y-prosemirror'
import { tableNodes, tableEditing, columnResizing, goToNextCell } from 'prosemirror-tables'
import type { XmlFragment } from 'yjs'
import type { WebsocketProvider } from 'y-websocket'
import { ref, type Ref } from 'vue'
import { createToolbarPlugin } from './useToolbarState'
import { createBlockMenuPlugin } from './useBlockMenu'

function buildSchema(): Schema {
  const customNodes: Record<string, NodeSpec> = {
    doc: { content: 'block+' },
    paragraph: {
      content: 'inline*', group: 'block',
      toDOM: () => ['p', 0],
      parseDOM: [{ tag: 'p' }],
    },
    blockquote: {
      content: 'block+', group: 'block',
      toDOM: () => ['blockquote', 0],
      parseDOM: [{ tag: 'blockquote' }],
    },
    horizontalRule: {
      group: 'block',
      toDOM: () => ['hr'],
      parseDOM: [{ tag: 'hr' }],
    },
    heading: {
      attrs: { level: { default: 1 } }, content: 'inline*', group: 'block',
      toDOM: node => ['h' + node.attrs.level, 0],
      parseDOM: [
        { tag: 'h1', attrs: { level: 1 } },
        { tag: 'h2', attrs: { level: 2 } },
        { tag: 'h3', attrs: { level: 3 } },
        { tag: 'h4', attrs: { level: 4 } },
        { tag: 'h5', attrs: { level: 5 } },
        { tag: 'h6', attrs: { level: 6 } },
      ],
    },
    codeBlock: {
      content: 'text*', marks: '', group: 'block', code: true,
      attrs: { language: { default: '' } },
      toDOM: node => ['pre', ['code', { class: node.attrs.language ? 'language-' + node.attrs.language : null }, 0]],
      parseDOM: [{ tag: 'pre', preserveWhitespace: 'full' as const }],
    },
    text: { group: 'inline' },
    image: {
      inline: true, group: 'inline',
      attrs: { src: {}, alt: { default: null }, title: { default: null } },
      toDOM: node => ['img', node.attrs],
      parseDOM: [{ tag: 'img[src]', getAttrs: (dom: unknown) => ({
        src: (dom as HTMLElement).getAttribute('src'),
        alt: (dom as HTMLElement).getAttribute('alt'),
        title: (dom as HTMLElement).getAttribute('title'),
      })}],
    },
    hardBreak: {
      inline: true, group: 'inline',
      toDOM: () => ['br'],
      parseDOM: [{ tag: 'br' }],
    },
    bulletList: {
      content: 'listItem+', group: 'block',
      toDOM: () => ['ul', 0],
      parseDOM: [{ tag: 'ul' }],
    },
    orderedList: {
      content: 'listItem+', group: 'block', attrs: { order: { default: 1 } },
      toDOM: node => ['ol', { start: node.attrs.order === 1 ? null : node.attrs.order }, 0],
      parseDOM: [{ tag: 'ol', getAttrs: (dom: unknown) => ({
        order: (dom as HTMLElement).hasAttribute('start') ? +(dom as HTMLElement).getAttribute('start')! : 1,
      })}],
    },
    listItem: {
      content: 'paragraph block*',
      toDOM: () => ['li', 0],
      parseDOM: [{ tag: 'li' }],
    },
    taskList: {
      group: 'block', content: 'taskItem+',
      toDOM: () => ['ul', { 'data-type': 'taskList' }, 0],
    },
    taskItem: {
      content: 'paragraph block*', attrs: { checked: { default: false } }, defining: true,
      toDOM: node => ['li', { 'data-type': 'taskItem', 'data-checked': node.attrs.checked ? 'true' : null }, 0],
    },
    ...tableNodes({ tableGroup: 'block', cellContent: 'block+', cellAttributes: {} }),
  }

  const marks: Record<string, MarkSpec> = {
    link: {
      attrs: { href: {}, title: { default: null } },
      toDOM: mark => ['a', { href: mark.attrs.href, title: mark.attrs.title }, 0],
      parseDOM: [{ tag: 'a[href]', getAttrs: (dom: unknown) => ({
        href: (dom as HTMLElement).getAttribute('href'),
        title: (dom as HTMLElement).getAttribute('title'),
      })}],
    },
    em: {
      toDOM: () => ['em', 0],
      parseDOM: [{ tag: 'i' }, { tag: 'em' }, { style: 'font-style=italic' }],
    },
    strong: {
      toDOM: () => ['strong', 0],
      parseDOM: [{ tag: 'strong' }, { tag: 'b' }, { style: 'font-weight=600' }, { style: 'font-weight=bold' }],
    },
    code: {
      toDOM: () => ['code', 0],
      parseDOM: [{ tag: 'code' }],
    },
    underline: {
      toDOM: () => ['u', 0],
      parseDOM: [{ tag: 'u' }, { style: 'text-decoration=underline' }],
    },
    strike: {
      toDOM: () => ['s', 0],
      parseDOM: [{ tag: 's' }, { tag: 'del' }, { style: 'text-decoration=line-through' }],
    },
  }

  return new Schema({ nodes: customNodes, marks })
}

function taskListInputRules(schema: Schema): Plugin {
  return inputRules({
    rules: [
      new InputRule(/^\[\]\s$/, (state, _match, start, end) => {
        const { taskList, taskItem, paragraph } = schema.nodes
        const p = paragraph.create()
        const item = taskItem.create({ checked: false }, p)
        const list = taskList.create(undefined, Fragment.from(item))
        return state.tr.replaceRangeWith(start, end, list)
      }),
      new InputRule(/^\[x\]\s$/i, (state, _match, start, end) => {
        const { taskList, taskItem, paragraph } = schema.nodes
        const p = paragraph.create()
        const item = taskItem.create({ checked: true }, p)
        const list = taskList.create(undefined, Fragment.from(item))
        return state.tr.replaceRangeWith(start, end, list)
      }),
    ],
  })
}

function taskItemClickHandler(): Plugin {
  return new Plugin({
    props: {
      handleDOMEvents: {
        click: (view, event) => {
          const target = event.target as HTMLElement
          const li = target.closest('li[data-type="taskItem"]') as HTMLElement | null
          if (!li) return false

          const rect = li.getBoundingClientRect()
          const x = event.clientX - rect.left
          if (x > 28) return false

          const coords = view.posAtCoords({ left: event.clientX, top: event.clientY })
          if (!coords) return false

          const resolved = view.state.doc.resolve(coords.pos)
          for (let d = resolved.depth; d >= 0; d--) {
            const node = resolved.node(d)
            if (node.type.name === 'taskItem') {
              const tr = view.state.tr.setNodeMarkup(resolved.before(d), undefined, {
                checked: !node.attrs.checked,
              })
              view.dispatch(tr)
              return true
            }
          }
          return false
        },
      },
    },
  })
}

function buildPlugins(
  schema: Schema,
  type: XmlFragment,
  provider: WebsocketProvider,
  callbacks: EditorCallbacks,
): PluginType[] {
  const { marks, nodes } = schema
  return [
    ySyncPlugin(type),
    yCursorPlugin(provider.awareness),
    yUndoPlugin(),
    keymap({ 'Mod-z': undo, 'Mod-y': redo, 'Shift-Mod-z': redo }),
    keymap({
      'Mod-u': toggleMark(marks.underline),
      'Mod-Shift-s': toggleMark(marks.strike),
      'Mod-Shift-c': setBlockType(nodes.codeBlock),
      'Mod-k': () => {
        callbacks.onLinkShortcut?.()
        return true
      },
    }),
    keymap({
      Tab: (state, dispatch) => {
        if (isInTable(state)) return goToNextCell(1)(state, dispatch)
        if (sinkListItem(nodes.listItem)(state, dispatch)) return true
        if (sinkListItem(nodes.taskItem)(state, dispatch)) return true
        return false
      },
      'Shift-Tab': (state, dispatch) => {
        if (isInTable(state)) return goToNextCell(-1)(state, dispatch)
        if (liftListItem(nodes.listItem)(state, dispatch)) return true
        if (liftListItem(nodes.taskItem)(state, dispatch)) return true
        return false
      },
    }),
    keymap({
      Enter: (state, dispatch) => {
        const { $head } = state.selection
        for (let d = $head.depth; d >= 0; d--) {
          const node = $head.node(d)
          if (node.type.name === 'taskItem' && node.childCount === 1 && node.firstChild?.childCount === 0) {
            if (dispatch) {
              const after = $head.after(d)
              dispatch(state.tr.replaceRangeWith(after, after, nodes.paragraph.create()))
            }
            return true
          }
        }
        return false
      },
    }),
    tableEditing(),
    columnResizing(),
    taskListInputRules(schema),
    taskItemClickHandler(),
    createToolbarPlugin(),
    createBlockMenuPlugin(),
    ...exampleSetup({ schema, history: false, menuBar: false }),
  ]
}

export interface EditorCallbacks {
  onImagePaste?: (file: File) => void
  onLinkShortcut?: () => void
}

export function useEditorSchema(
  type: XmlFragment,
  provider: WebsocketProvider,
  editorContainer: Ref<HTMLDivElement | null>,
  callbacks: EditorCallbacks = {},
  options: { editable?: Ref<boolean> } = {},
) {
  const editorView = ref<EditorView | null>(null)
  const schema = buildSchema()

  const ALLOWED_IMAGE_TYPES = ['image/png', 'image/jpeg', 'image/webp', 'image/gif']

  function mount() {
    if (!editorContainer.value || editorView.value) return
    const plugins = buildPlugins(schema, type, provider, callbacks)
    const state = EditorState.create({ schema, plugins })
    editorView.value = new EditorView(editorContainer.value, {
      state,
      editable: () => options.editable?.value ?? true,
      handlePaste: (_view, event) => {
        const file = event.clipboardData?.files?.[0]
        if (file && ALLOWED_IMAGE_TYPES.includes(file.type)) {
          event.preventDefault()
          callbacks.onImagePaste?.(file)
          return true
        }
        return false
      },
      handleDrop: (_view, event) => {
        const file = event.dataTransfer?.files?.[0]
        if (file && ALLOWED_IMAGE_TYPES.includes(file.type)) {
          event.preventDefault()
          callbacks.onImagePaste?.(file)
          return true
        }
        return false
      },
    })
  }

  function destroy() {
    editorView.value?.destroy()
    editorView.value = null
  }

  return { editorView, schema, mount, destroy }
}
