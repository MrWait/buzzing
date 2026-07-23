import type { NodeSpec } from 'prosemirror-model'
import type { NodeViewConstructor } from 'prosemirror-view'

export const toggleSpec: NodeSpec = {
  group: 'block',
  content: 'paragraph block*',
  attrs: { collapsed: { default: false } },
  toDOM: node => ['div', { 'data-node-type': 'toggle', class: node.attrs.collapsed ? 'toggle collapsed' : 'toggle' }, 0],
  parseDOM: [{
    tag: 'div[data-node-type="toggle"]',
    getAttrs: dom => ({ collapsed: (dom as HTMLElement).classList.contains('collapsed') }),
  }],
}

export function createToggleView(): NodeViewConstructor {
  return (node, view, getPos) => {
    const dom = document.createElement('div')
    dom.className = 'toggle'
    dom.setAttribute('data-node-type', 'toggle')
    if (node.attrs.collapsed) dom.classList.add('collapsed')

    const icon = document.createElement('span')
    icon.className = 'toggle-icon'
    icon.textContent = node.attrs.collapsed ? '\u25B6' : '\u25BC'

    const body = document.createElement('div')
    body.className = 'toggle-body'

    icon.addEventListener('mousedown', (e) => {
      e.preventDefault()
      const pos = getPos()
      if (typeof pos !== 'number') return
      const collapsed = !node.attrs.collapsed
      view.dispatch(view.state.tr.setNodeMarkup(pos, undefined, { collapsed }))
    })

    dom.appendChild(icon)
    dom.appendChild(body)
    dom.addEventListener('click', (e) => {
      if (e.target === icon) return
    })

    return {
      dom,
      contentDOM: body,
      update: (updatedNode) => {
        if (updatedNode.type.name !== 'toggle') return false
        const collapsed = updatedNode.attrs.collapsed
        dom.classList.toggle('collapsed', collapsed)
        icon.textContent = collapsed ? '\u25B6' : '\u25BC'
        return true
      },
    }
  }
}
