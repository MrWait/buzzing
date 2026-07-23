import { ref, watch, type Ref } from 'vue'
import type { EditorView } from 'prosemirror-view'
import { TextSelection } from 'prosemirror-state'

export interface OutlineItem {
  id: string
  level: number
  text: string
  pos: number
}

let _idCounter = 0

function nextId(): string {
  return 'outline-' + (++_idCounter)
}

export function useOutline(editorView: Ref<EditorView | null>) {
  const items = ref<OutlineItem[]>([])

  function scan(view: EditorView) {
    const headings: OutlineItem[] = []
    view.state.doc.forEach((node, offset) => {
      if (node.type.name === 'heading') {
        headings.push({
          id: nextId(),
          level: node.attrs.level,
          text: node.textContent,
          pos: offset,
        })
      }
    })
    items.value = headings
  }

  function scrollTo(pos: number) {
    const view = editorView.value
    if (!view) return
    const coords = view.coordsAtPos(pos)
    if (!coords) return
    const editorRect = view.dom.getBoundingClientRect()
    const scrollTop = view.dom.scrollTop + (coords.top - editorRect.top) - 60
    view.dom.scrollTo({ top: scrollTop, behavior: 'smooth' })
    const $pos = view.state.doc.resolve(pos + 1)
    const sel = TextSelection.near($pos)
    view.dispatch(view.state.tr.setSelection(sel))
    view.focus()
  }

  watch(editorView, (view) => {
    if (!view) return
    scan(view)
  })

  return { items, scrollTo, scan }
}
