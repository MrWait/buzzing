import { onUnmounted } from 'vue'
import * as Y from 'yjs'
import { WebsocketProvider } from 'y-websocket'
import { useAuthStore } from '@/stores/auth'

export function useYjs(docId: string) {
  const auth = useAuthStore()
  const ydoc = new Y.Doc()
  const type = ydoc.getXmlFragment('prosemirror')

  const host = window.location.host
  const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'
  const url = `${protocol}//${host}/office/ws`
  const provider = new WebsocketProvider(url, docId, ydoc, {
    protocols: [auth.token],
  })

  provider.awareness.setLocalStateField('user', {
    name: auth.user?.name ?? 'Anonymous',
    color: '#4080ff',
  })

  onUnmounted(() => {
    provider.destroy()
    ydoc.destroy()
  })

  return { ydoc, provider, type }
}
