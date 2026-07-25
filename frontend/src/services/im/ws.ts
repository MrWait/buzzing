import { useAuthStore } from '@/stores/auth'
import { lookup, encode, nextRid } from './proto'

const RECONNECT_BASE_MS = 1000
const RECONNECT_MAX_MS = 16000

export type PushHandler = (cmd: number, payload: Uint8Array) => void

export class ImWsClient {
  private ws: WebSocket | null = null
  private reconnectTimer: ReturnType<typeof setTimeout> | null = null
  private reconnectAttempt = 0
  private pendingRequests = new Map<string, {
    resolve: (value: Uint8Array) => void
    reject: (reason: any) => void
    timer: ReturnType<typeof setTimeout>
  }>()
  private onPush: PushHandler | null = null
  private onStatusChange: ((connected: boolean) => void) | null = null
  private destroyed = false

  constructor() {
  }

  setOnPush(handler: PushHandler) {
    this.onPush = handler
  }

  setOnStatusChange(handler: (connected: boolean) => void) {
    this.onStatusChange = handler
  }

  connect() {
    if (this.ws?.readyState === WebSocket.OPEN || this.ws?.readyState === WebSocket.CONNECTING) return
    this.destroyed = false
    const auth = useAuthStore()
    if (!auth.token) {
      console.warn('[im-ws] no token, skip connect')
      return
    }
    // 浏览器 WebSocket 无法设置自定义 header，通过 query param 传递 token
    // 后端需在 gateway WebSocket 握手时同时支持 header 和 query param 两种鉴权方式
    const wsProtocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'
    const url = `${wsProtocol}//${window.location.host}/ws?token=${encodeURIComponent(auth.token)}`
    console.log('[im-ws] connecting...', url.replace(/token=.*/, 'token=***'))
    try {
      this.ws = new WebSocket(url)
    } catch (e) {
      console.error('[im-ws] connect failed:', e)
      this.scheduleReconnect()
      return
    }
    this.ws.binaryType = 'arraybuffer'
    this.ws.onopen = () => {
      console.log('[im-ws] connected')
      this.reconnectAttempt = 0
      this.onStatusChange?.(true)
    }
    this.ws.onmessage = (e) => {
      const data = new Uint8Array(e.data)
      this.handleMessage(data)
    }
    this.ws.onclose = (e) => {
      console.log('[im-ws] closed:', e.code, e.reason)
      this.onStatusChange?.(false)
      this.ws = null
      if (!this.destroyed) this.scheduleReconnect()
    }
    this.ws.onerror = (e) => {
      console.error('[im-ws] error:', e)
    }
  }

  disconnect() {
    this.destroyed = true
    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer)
      this.reconnectTimer = null
    }
    // Reject all pending
    for (const [, entry] of this.pendingRequests) {
      clearTimeout(entry.timer)
      entry.reject(new Error('disconnected'))
    }
    this.pendingRequests.clear()
    this.ws?.close()
    this.ws = null
    this.onStatusChange?.(false)
  }

  async request(cmd: number, reqMsg: string, reqData: Record<string, any>, respMsg: string): Promise<any> {
    if (!this.ws || this.ws.readyState !== WebSocket.OPEN) {
      throw new Error('ws not connected')
    }
    const packetType = lookup('entity.Packet')
    const respType = lookup(respMsg)
    const payload = encode(reqMsg, reqData)
    const rid = nextRid()
    const packet = packetType.create({ rid, cmd, payload })
      const bytes = packetType.encode(packet).finish() as Uint8Array

    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        this.pendingRequests.delete(rid)
        reject(new Error(`request timeout: cmd=${cmd} rid=${rid}`))
      }, 15000)
      this.pendingRequests.set(rid, {
        resolve: (raw: Uint8Array) => {
          resolve(respType.decode(raw))
        },
        reject,
        timer,
      })
      this.ws?.send(bytes.slice().buffer as ArrayBuffer)
    })
  }

  private handleMessage(data: Uint8Array) {
    try {
      const packetType = lookup('entity.Packet')
      const packet = packetType.decode(data) as unknown as {
        rid?: { toString(): string }
        cmd: number
        code: number
        payload: Uint8Array
      }
      const cmd = packet.cmd
      // ACK = 1 表示请求响应
      if (cmd === 1) {
        const rid = packet.rid?.toString()
        if (rid) {
          const entry = this.pendingRequests.get(rid)
          if (entry) {
            clearTimeout(entry.timer)
            this.pendingRequests.delete(rid)
            if (packet.code === 0) {
              entry.resolve(packet.payload)
            } else {
              entry.reject(new Error(`cmd failed code=${packet.code}`))
            }
          }
        }
        return
      }
      // 推送给 handler
      const sid = packet.rid?.toString() || ''
      const time = new Date().toISOString()
      console.log(`[im-ws] push: sid=${sid} cmd=${cmd} time=${time}`)
      this.onPush?.(cmd, packet.payload)
    } catch (e) {
      console.error('[im-ws] handle message error:', e)
    }
  }

  private scheduleReconnect() {
    if (this.destroyed) return
    const delay = Math.min(RECONNECT_BASE_MS * Math.pow(2, this.reconnectAttempt), RECONNECT_MAX_MS)
    this.reconnectAttempt++
    console.log(`[im-ws] reconnect in ${delay}ms (attempt ${this.reconnectAttempt})`)
    this.reconnectTimer = setTimeout(() => this.connect(), delay)
  }
}
