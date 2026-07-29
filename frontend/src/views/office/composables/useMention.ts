import { type EditorView } from 'prosemirror-view'
import { Plugin, PluginKey } from 'prosemirror-state'
import { reactive } from 'vue'
import { apiV1, encodeReq } from '@/services/api_v1'
import { CMD } from '@/services/office/cmd'
import { useDocumentStore } from '@/stores/document'

export interface MentionSuggestion {
  id: string
  type: 'user' | 'doc'
  label: string
  avatar?: string
}

export interface MentionState {
  open: boolean
  top: number
  left: number
  items: MentionSuggestion[]
  loading: boolean
  selectedIndex: number
  active: boolean
  startPos: number
  query: string
}

export function createMentionState() {
  return reactive<MentionState>({
    open: false,
    top: 0,
    left: 0,
    items: [],
    loading: false,
    selectedIndex: 0,
    active: false,
    startPos: -1,
    query: '',
  })
}

export function createMentionPlugin(state: MentionState, docId?: string) {
  let debounceTimer: ReturnType<typeof setTimeout> | null = null

  function searchUsers(q: string) {
    apiV1(CMD.MENTION_USERS, encodeReq('office.MentionUsersRequest', { q }), 'office.MentionUsersResponse')
      .then(({ data }) => {
        state.items = (data.items ?? []).map((u: any) => ({
          id: u.id?.toString() ?? '',
          type: 'user' as const,
          label: u.name ?? '',
          avatar: u.avatar || undefined,
        }))
        state.loading = false
        state.selectedIndex = 0
      })
      .catch(() => { state.loading = false })
  }

  function searchDocs(q: string) {
    const req: any = { q }
    const wikiId = docId ? useDocumentStore().currentWikiId ?? undefined : undefined
    if (wikiId) req.wiki_id = wikiId
    apiV1(CMD.MENTION_DOCS, encodeReq('office.MentionDocsRequest', req), 'office.MentionDocsResponse')
      .then(({ data }) => {
        state.items = (data.items ?? []).map((d: any) => ({
          id: d.id?.toString() ?? '',
          type: 'doc' as const,
          label: d.title || '未命名',
          avatar: d.icon || undefined,
        }))
        state.loading = false
        state.selectedIndex = 0
      })
      .catch(() => { state.loading = false })
  }

  function doSearch(q: string) {
    state.loading = true
    if (debounceTimer) clearTimeout(debounceTimer)
    debounceTimer = setTimeout(() => {
      if (q.startsWith('#')) {
        searchDocs(q.slice(1))
      } else {
        searchUsers(q)
      }
    }, 200)
  }

  function updatePopupPosition(view: EditorView) {
    const coords = view.coordsAtPos(view.state.selection.from)
    if (coords) {
      const editorRect = (view.dom as HTMLElement).getBoundingClientRect()
      state.top = coords.bottom - editorRect.top + 4
      state.left = coords.left - editorRect.left
      state.open = true
    }
  }

  function insertMention(view: EditorView, item: MentionSuggestion) {
    const { schema } = view.state
    const mention = schema.nodes.mention
    if (!mention) return
    const node = mention.create({
      id: item.id,
      mention_type: item.type,
      label: item.label,
    })
    const tr = view.state.tr.replaceRangeWith(state.startPos, view.state.selection.from, node)
    state.active = false
    state.startPos = -1
    state.query = ''
    state.open = false
    view.dispatch(tr)
    view.focus()
  }

  function close() {
    state.active = false
    state.open = false
    state.startPos = -1
    state.query = ''
  }

  const plugin = new Plugin({
    key: new PluginKey('mention'),
    props: {
      handleTextInput(view, _from, _to, text) {
        if (text === '@' || text === '#') {
          const { $from } = view.state.selection
          const before = $from.nodeBefore
          if (before && before.isText && !/\s$/.test(before.textContent ?? '')) return false
          state.active = true
          state.startPos = $from.pos
          state.query = text
          doSearch(text === '@' ? '' : text)
          updatePopupPosition(view)
          return false
        }
        if (state.active) {
          state.query += text
          doSearch(state.query)
          updatePopupPosition(view)
        }
        return false
      },
      handleKeyDown(view, event) {
        if (!state.active && !state.open) return false
        if (event.key === 'Escape') {
          close()
          return true
        }
        if (event.key === 'Backspace' && state.query.length === 1) {
          close()
          return false
        }
        if (event.key === 'ArrowDown') {
          event.preventDefault()
          state.selectedIndex = Math.min(state.selectedIndex + 1, state.items.length - 1)
          return true
        }
        if (event.key === 'ArrowUp') {
          event.preventDefault()
          state.selectedIndex = Math.max(state.selectedIndex - 1, 0)
          return true
        }
        if (event.key === 'Enter' || event.key === 'Tab') {
          event.preventDefault()
          if (state.items.length > 0 && state.selectedIndex >= 0) {
            insertMention(view, state.items[state.selectedIndex])
          } else {
            close()
          }
          return true
        }
        // 单击空格后不做特殊处理，让编辑器正常输入
        return false
      },
    },
  })

  return { plugin, insertMention, close }
}
