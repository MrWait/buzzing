import { onUnmounted, ref, shallowRef } from 'vue'
import type { Ref, ShallowRef } from 'vue'
import * as Y from 'yjs'
import { WebsocketProvider } from 'y-websocket'
import { IndexeddbPersistence } from 'y-indexeddb'
import * as decoding from 'lib0/decoding'
import { useAuthStore } from '@/stores/auth'

// 后端自定义 Yjs 消息类型：与 backend/office/src/ws.rs 保持一致
const MSG_CUSTOM_SAVED = 100
const MSG_CUSTOM_SYNCING = 101

/**
 * 协同编辑状态。
 * - connected: WebSocket 是否已连接
 * - synced: 与服务端首轮 sync 完成
 * - saveState: 保存状态 (saved | syncing | offline)
 * - lastSavedAt: 上次成功保存时间 (毫秒)
 */
export type SaveState = 'saved' | 'syncing' | 'offline'

export interface UseYjsReturn {
  ydoc: Y.Doc
  provider: WebsocketProvider
  persistence: IndexeddbPersistence
  type: Y.XmlFragment
  connected: Ref<boolean>
  synced: Ref<boolean>
  saveState: Ref<SaveState>
  lastSavedAt: Ref<number | null>
  localLoaded: Ref<boolean>
  editingUsers: ShallowRef<Array<{ clientId: number; name: string; color: string }>>
}

export function useYjs(docId: string, options: { token?: string; enableIndexedDb?: boolean } = {}): UseYjsReturn {
  const auth = useAuthStore()
  const ydoc = new Y.Doc()
  const type = ydoc.getXmlFragment('prosemirror')
  const enableIndexedDb = options.enableIndexedDb !== false
  const wsToken = options.token ?? auth.token

  // ---- IndexedDB 本地缓存 (断线可读) ----
  const persistence = enableIndexedDb
    ? new IndexeddbPersistence(`buzzing-office-${docId}`, ydoc)
    : (null as unknown as IndexeddbPersistence)
  const localLoaded = ref(false)
  if (persistence) {
    persistence.once('synced', () => {
      localLoaded.value = true
    })
  } else {
    localLoaded.value = true
  }

  // ---- WebSocket Provider ----
  const host = window.location.host
  const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'
  const url = `${protocol}//${host}/office/ws`
  const provider = new WebsocketProvider(url, docId, ydoc, {
    protocols: [wsToken],
  })

  // ---- 用户 awareness ----
  const userId = Number(auth.user?.id ?? 0) || 0
  const userColor = pickUserColor(userId)
  provider.awareness.setLocalStateField('user', {
    id: userId,
    name: auth.user?.name ?? 'Anonymous',
    color: userColor,
  })

  // ---- 状态 ----
  const connected = ref(false)
  const synced = ref(false)
  const saveState = ref<SaveState>('syncing')
  const lastSavedAt = ref<number | null>(null)
  const editingUsers = shallowRef<Array<{ clientId: number; name: string; color: string }>>([])

  provider.on('status', (event: { status: string }) => {
    connected.value = event.status === 'connected'
    if (!connected.value) {
      saveState.value = 'offline'
    }
  })

  provider.on('sync', (isSynced: boolean) => {
    synced.value = isSynced
    if (isSynced) {
      // 服务端已认可当前状态，进入 saved 直到下次改动。
      saveState.value = 'saved'
      lastSavedAt.value = Date.now()
    }
  })

  // ---- awareness 变化 → 在线用户列表 ----
  const updateEditingUsers = () => {
    const states = provider.awareness.getStates()
    const localId = provider.awareness.clientID
    const list: Array<{ clientId: number; name: string; color: string }> = []
    states.forEach((state, clientId) => {
      if (clientId === localId) return
      const user = (state as any)?.user
      if (user) {
        list.push({
          clientId,
          name: user.name ?? 'Anonymous',
          color: user.color ?? '#4080ff',
        })
      }
    })
    editingUsers.value = list
  }
  provider.awareness.on('change', updateEditingUsers)
  updateEditingUsers()

  // ---- 注册自定义 saved / syncing 消息处理器 ----
  provider.messageHandlers[MSG_CUSTOM_SAVED] = (
    _encoder: unknown,
    decoder: decoding.Decoder,
  ) => {
    const ts = decoding.readVarUint(decoder)
    lastSavedAt.value = ts || Date.now()
    saveState.value = 'saved'
  }
  provider.messageHandlers[MSG_CUSTOM_SYNCING] = (
    _encoder: unknown,
    _decoder: decoding.Decoder,
  ) => {
    if (saveState.value !== 'offline') {
      saveState.value = 'syncing'
    }
  }

  // 本地编辑立即置为 syncing（不必等服务端反馈）
  const localUpdateHandler = (_update: Uint8Array, origin: unknown) => {
    if (origin === provider) return
    if (connected.value) {
      saveState.value = 'syncing'
    } else {
      saveState.value = 'offline'
    }
  }
  ydoc.on('update', localUpdateHandler)

  onUnmounted(async () => {
    ydoc.off('update', localUpdateHandler)
    provider.awareness.off('change', updateEditingUsers)
    provider.destroy()
    if (persistence) {
      await persistence.destroy()
    }
    ydoc.destroy()
  })

  return {
    ydoc,
    provider,
    persistence,
    type,
    connected,
    synced,
    saveState,
    lastSavedAt,
    localLoaded,
    editingUsers,
  }
}

/**
 * 依据用户 ID 从固定色板挑颜色，保证同一用户跨端一致。
 * 与后端设计文档 §5.3 光标调色板保持一致。
 */
const USER_COLORS = [
  '#F87171', // red-400
  '#FB923C', // orange-400
  '#FBBF24', // amber-400
  '#34D399', // emerald-400
  '#22D3EE', // cyan-400
  '#60A5FA', // blue-400
  '#A78BFA', // violet-400
  '#F472B6', // pink-400
]
function pickUserColor(uid: number): string {
  const idx = Math.abs(Number(uid) | 0) % USER_COLORS.length
  return USER_COLORS[idx]
}
