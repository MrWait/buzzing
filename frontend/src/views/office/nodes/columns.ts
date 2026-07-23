import type { NodeSpec } from 'prosemirror-model'
import type { NodeViewConstructor } from 'prosemirror-view'

export const columnsSpec: NodeSpec = {
  group: 'block',
  content: 'column+',
  attrs: { count: { default: 2 } },
  toDOM: () => ['div', { 'data-node-type': 'columns', class: 'columns' }, 0],
  parseDOM: [{
    tag: 'div[data-node-type="columns"]',
  }],
}

export const columnSpec: NodeSpec = {
  group: 'block',
  content: 'block+',
  toDOM: () => ['div', { 'data-node-type': 'column', class: 'column' }, 0],
  parseDOM: [{
    tag: 'div[data-node-type="column"]',
  }],
}

export function createColumnsView(): NodeViewConstructor {
  return () => {
    const dom = document.createElement('div')
    dom.className = 'columns'
    dom.setAttribute('data-node-type', 'columns')
    return { dom, contentDOM: dom }
  }
}

export function createColumnView(): NodeViewConstructor {
  return () => {
    const dom = document.createElement('div')
    dom.className = 'column'
    dom.setAttribute('data-node-type', 'column')
    return { dom, contentDOM: dom }
  }
}
