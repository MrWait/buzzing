import type { NodeSpec } from 'prosemirror-model'
import type { NodeViewConstructor } from 'prosemirror-view'
import { toggleSpec, createToggleView } from './toggle'
import { calloutSpec, createCalloutView } from './callout'
import { columnsSpec, columnSpec, createColumnsView, createColumnView } from './columns'
import { createCodeBlockView } from './codeBlock'

export const customNodeSpecs: Record<string, NodeSpec> = {
  toggle: toggleSpec,
  callout: calloutSpec,
  columns: columnsSpec,
  column: columnSpec,
}

export function buildNodeViews(): Record<string, NodeViewConstructor> {
  return {
    toggle: createToggleView(),
    callout: createCalloutView(),
    columns: createColumnsView(),
    column: createColumnView(),
    codeBlock: createCodeBlockView(),
  }
}
