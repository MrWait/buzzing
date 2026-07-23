import type { NodeSpec } from 'prosemirror-model'
import type { NodeViewConstructor } from 'prosemirror-view'

export const CALLOUT_TYPES = ['info', 'warn', 'error', 'success'] as const
export type CalloutType = typeof CALLOUT_TYPES[number]

export const CALLOUT_ICONS: Record<CalloutType, string> = {
  info: '\u2139\uFE0F',
  warn: '\u26A0\uFE0F',
  error: '\u274C',
  success: '\u2705',
}

export const calloutSpec: NodeSpec = {
  group: 'block',
  content: 'block+',
  attrs: { calloutType: { default: 'info' } },
  toDOM: node => ['div', {
    'data-node-type': 'callout',
    class: 'callout callout--' + node.attrs.calloutType,
  }, 0],
  parseDOM: [{
    tag: 'div[data-node-type="callout"]',
    getAttrs: dom => {
      const el = dom as HTMLElement
      const cls = el.className
      const t = CALLOUT_TYPES.find(t => cls.includes('callout--' + t)) || 'info'
      return { calloutType: t }
    },
  }],
}

export function createCalloutView(): NodeViewConstructor {
  return (node) => {
    const dom = document.createElement('div')
    dom.className = 'callout callout--' + node.attrs.calloutType
    dom.setAttribute('data-node-type', 'callout')

    const icon = document.createElement('span')
    icon.className = 'callout-icon'
    icon.textContent = CALLOUT_ICONS[node.attrs.calloutType as CalloutType] ?? CALLOUT_ICONS.info

    const body = document.createElement('div')
    body.className = 'callout-body'

    dom.appendChild(icon)
    dom.appendChild(body)

    return {
      dom,
      contentDOM: body,
      update: (updatedNode) => {
        if (updatedNode.type.name !== 'callout') return false
        const ct = updatedNode.attrs.calloutType as CalloutType
        dom.className = 'callout callout--' + ct
        icon.textContent = CALLOUT_ICONS[ct] ?? CALLOUT_ICONS.info
        return true
      },
    }
  }
}
