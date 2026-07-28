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
    if (!view.dom || !view.dom.isConnected) {
      show.value = false
      return
    }
    const { selection } = view.state
    const { empty, $head } = selection

    if (!empty) {
      show.value = false
      return
    }

    const parentNode = $head.parent
    const isAtStart = $head.parentOffset === 0
    const isEmptyBlock = parentNode.type.name === 'paragraph' && parentNode.content.size === 0

    // 不在空白段首，不显示
    if (!(isAtStart && isEmptyBlock)) {
      show.value = false
      return
    }

    // 检查祖先中是否有禁止嵌套的节点类型
    const disallowedAncestors = new Set(['blockquote', 'listItem', 'table_cell', 'table_header'])
    for (let d = 1; d <= $head.depth; d++) {
      if (disallowedAncestors.has($head.node(d).type.name)) {
        show.value = false
        return
      }
    }

    const coords = view.coordsAtPos($head.pos)
    if (coords) {
      show.value = true
      top.value = coords.top - 3
      left.value = coords.left - 33
    } else {
      show.value = false
    }
  }

  _onUpdate = updateFromState

  let ro: ResizeObserver | null = null

  watch(editorView, (view) => {
    if (ro) {
      ro.disconnect()
      ro = null
    }
    if (!view) return
    updateFromState(view)
    ro = new ResizeObserver(() => {
      if (!show.value) return
      updateFromState(view)
    })
    const el = view.dom?.parentElement
    if (el) ro.observe(el)
  })

  return { show, top, left }
}
