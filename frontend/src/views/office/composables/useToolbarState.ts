import { Plugin, PluginKey } from 'prosemirror-state'
import type { EditorView } from 'prosemirror-view'
import { ref, watch, type Ref } from 'vue'

export const toolbarPluginKey = new PluginKey('toolbar-state')

let _onUpdate: ((view: EditorView) => void) | null = null

export function createToolbarPlugin(): Plugin {
  return new Plugin({
    key: toolbarPluginKey,
    view: () => ({
      update: (view: EditorView) => { _onUpdate?.(view) },
    }),
  })
}

export function useToolbarState(editorView: Ref<EditorView | null>) {
  const activeMarks = ref<Set<string>>(new Set())
  const activeNode = ref<string>('paragraph')
  const headingLevel = ref<number>(0)
  const showFloating = ref(false)
  const floatingLeft = ref(0)
  const floatingTop = ref(0)

  function updateFromState(view: EditorView) {
    const { selection, storedMarks, schema } = view.state
    const marks = new Set<string>()
    if (storedMarks) {
      storedMarks.forEach(m => marks.add(m.type.name))
    } else {
      const { $from } = selection
      const markTypes = schema.marks as Record<string, { name: string }>
      for (const name in markTypes) {
        if ($from.marks().some(rm => rm.type.name === name)) marks.add(name)
      }
    }
    activeMarks.value = marks

    const $head = selection.$head
    for (let d = $head.depth; d >= 0; d--) {
      const node = $head.node(d)
      if (node.type.isBlock) {
        activeNode.value = node.type.name
        if (node.type.name === 'heading') {
          headingLevel.value = node.attrs.level
        } else {
          headingLevel.value = 0
        }
        break
      }
    }

    const { empty, from, to } = selection
    showFloating.value = !empty
    if (!empty) {
      const start = view.coordsAtPos(from)
      const end = view.coordsAtPos(to)
      if (start && end) {
        const centerX = (start.left + end.left) / 2
        estFloatPos(centerX, start.top)
      }
    }
  }

  function estFloatPos(centerX: number, anchorTop: number) {
    const w = 420
    const pad = 12
    const top = Math.max(pad, anchorTop - 48)
    const left = Math.max(pad, Math.min(window.innerWidth - w - pad, centerX - w / 2))
    floatingLeft.value = Math.round(left)
    floatingTop.value = Math.round(top)
  }

  _onUpdate = updateFromState

  watch(editorView, (view) => {
    if (!view) return
    updateFromState(view)
  })

  return { activeMarks, activeNode, headingLevel, showFloating, floatingLeft, floatingTop }
}
