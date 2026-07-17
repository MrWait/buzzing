import { Plugin, PluginKey } from 'prosemirror-state'
import type { EditorView } from 'prosemirror-view'
import { ref, watch, type Ref } from 'vue'

const blockMenuPluginKey = new PluginKey('block-menu')

let _onUpdate: ((view: EditorView) => void) | null = null

export function createBlockMenuPlugin(): Plugin {
  return new Plugin({
    key: blockMenuPluginKey,
    view: () => ({
      update: (view: EditorView) => { _onUpdate?.(view) },
    }),
  })
}

export function useBlockMenu(editorView: Ref<EditorView | null>) {
  const show = ref(false)
  const top = ref(0)
  const left = ref(-9999)

  function updateFromState(view: EditorView) {
    const { selection } = view.state
    const { empty, $head } = selection

    if (!empty) {
      show.value = false
      return
    }

    const parentNode = $head.parent
    const isAtStart = $head.parentOffset === 0
    const isEmptyBlock = parentNode.type.name === 'paragraph' && parentNode.content.size === 0

    if (isAtStart && isEmptyBlock) {
      const coords = view.coordsAtPos($head.pos)
      if (coords) {
        show.value = true
        top.value = coords.top - 3
        left.value = coords.left - 33
      } else {
        show.value = false
      }
    } else {
      show.value = false
    }
  }

  _onUpdate = updateFromState

  let ro: ResizeObserver | null = null

  watch(editorView, (view) => {
    if (!view) return
    updateFromState(view)
    if (ro) ro.disconnect()
    ro = new ResizeObserver(() => {
      if (!show.value) return
      updateFromState(view)
    })
    const el = view.dom?.parentElement
    if (el) ro.observe(el)
  })

  return { show, top, left }
}
