import { useAuthStore } from '@/stores/auth'

export type SignalingState = 'open' | 'closed' | 'error'
export type CallState = 'new' | 'ringing' | 'invite' | 'connected' | 'bye'

interface Session {
  pid: string
  sid: string
  pc: RTCPeerConnection | null
  media: string
  remoteCandidates: RTCIceCandidateInit[]
  dc: RTCDataChannel | null
}

export class Signaling {
  uid = ''
  private ws: WebSocket | null = null
  private host: string
  private port: number
  private token: string
  // 当前登录用户名，用于入会上报、聊天消息显示；未登录时回退为 'web'
  userName: string
  readonly sessions = new Map<string, Session>()
  private reconnectAttempts = 0
  private reconnectTimer: ReturnType<typeof setTimeout> | null = null
  private keepaliveTimer: ReturnType<typeof setInterval> | null = null
  private keepaliveTimeout: ReturnType<typeof setTimeout> | null = null
  private intentionalClose = false
  private connected = false
  private _localStream: MediaStream | null = null
  roomId: string | null = null
  readonly remoteStreams = new Map<string, MediaStream>()
  readonly dcMap = new Map<string, RTCDataChannel>()
  readonly chatMessages: ChatMessage[] = []

  onSignalingStateChange: ((s: SignalingState) => void) | null = null
  onCallStateChange: ((sid: string, s: CallState) => void) | null = null
  onLocalStream: ((s: MediaStream) => void) | null = null
  onRemoteStream: ((peerId: string, s: MediaStream) => void) | null = null
  onRoomUpdate: ((data: { self: string; room_id: string; peers: unknown[] }) => void) | null = null
  onReconnect: (() => void) | null = null
  onChatMessage: ((data: ChatMessage) => void) | null = null

  get localStream() { return this._localStream }

  constructor() {
    const auth = useAuthStore()
    this.host = window.location.hostname
    this.port = 5150
    this.token = auth.token || ''
    // 用户名以服务端从 user 模块查询结果为准，客户端不再上报 name 字段
    this.userName = auth.user?.name || 'web'
  }

  private wsUrl() {
    return `wss://${this.host}:${this.port}/ws`
  }

  private async getTurnCredential(): Promise<RTCIceServer[] | null> {
    try {
      const res = await fetch(`https://${this.host}:${this.port}/api/turn?token=${this.token}`)
      const data = await res.json()
      if (data.urls) {
        return [{
          urls: data.urls,
          username: data.username,
          credential: data.credential,
        }]
      }
    } catch { /* ignore */ }
    return null
  }

  connect() {
    this.intentionalClose = false
    this.reconnectAttempts = 0
    if (this.reconnectTimer) { clearTimeout(this.reconnectTimer); this.reconnectTimer = null }
    if (this.ws) { this.ws.onclose = null; this.ws.close() }

    this.ws = new WebSocket(this.wsUrl())
    this.ws.onopen = () => {
      this.connected = true
      this.reconnectAttempts = 0
      this.onSignalingStateChange?.('open')
      this.send('new', { token: this.token, name: this.userName, user_agent: navigator.userAgent })
      this.startKeepalive()
    }
    this.ws.onmessage = (e) => {
      try {
        const msg = JSON.parse(e.data)
        this.onMessage(msg)
      } catch { /* ignore */ }
    }
    this.ws.onclose = () => {
      this.connected = false
      this.stopKeepalive()
      this.onSignalingStateChange?.('closed')
      if (!this.intentionalClose) this.reconnect()
    }
    this.ws.onerror = () => {
      this.onSignalingStateChange?.('error')
    }
  }

  close() {
    this.intentionalClose = true
    if (this.reconnectTimer) { clearTimeout(this.reconnectTimer); this.reconnectTimer = null }
    this.stopKeepalive()
    this.cleanSessions()
    if (this.ws) { this.ws.onclose = null; this.ws.close(); this.ws = null }
  }

  join(roomId: string) {
    this.roomId = roomId
    this.ensureLocalStream()
    this.send('join', { room_id: roomId })
  }

  leave() {
    if (this.roomId) {
      this.send('leave', { room_id: this.roomId })
    }
    this.cleanSessions()
    this.roomId = null
  }

  private async ensureLocalStream() {
    if (this._localStream) return
    // 浏览器在非 HTTPS / 自签证书未信任 / file:// 等场景下 navigator.mediaDevices 为 undefined
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      console.error('[signaling] navigator.mediaDevices 不可用。可能原因：页面非 HTTPS、自签证书未受信任、浏览器权限被禁用。当前 URL:', window.location.href)
      throw new Error('mediaDevices unavailable')
    }

    // 先列出可用设备，便于诊断 NotFoundError 的原因
    try {
      const devices = await navigator.mediaDevices.enumerateDevices()
      console.log('[signaling] enumerateDevices:', devices.map(d => `${d.kind}:${d.label || '(no-label)'}/${d.deviceId.slice(0, 8)}`))
    } catch (e) {
      console.warn('[signaling] enumerateDevices failed:', e)
    }

    console.log('[signaling] getUserMedia start, URL:', window.location.href, 'isSecureContext:', window.isSecureContext)
    try {
      // 先用宽松约束尝试，避免某些设备不支持 640x480@30fps 的严格 min 约束
      this._localStream = await navigator.mediaDevices.getUserMedia({
        video: true,
        audio: { echoCancellation: true, noiseSuppression: true, autoGainControl: true },
      })
    } catch (e: unknown) {
      const err = e as DOMException
      console.warn('[signaling] getUserMedia(video+audio) failed:', err.name, err.message, '尝试降级：仅音频')
      // 仅音频降级（无摄像头设备）
      try {
        this._localStream = await navigator.mediaDevices.getUserMedia({ audio: true, video: false })
        console.log('[signaling] 降级成功：仅音频')
      } catch (e2: unknown) {
        const err2 = e2 as DOMException
        console.warn('[signaling] getUserMedia(audio) failed:', err2.name, err2.message, '尝试降级：仅视频')
        // 仅视频降级（无麦克风设备）
        try {
          this._localStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: false })
          console.log('[signaling] 降级成功：仅视频')
        } catch (e3: unknown) {
          const err3 = e3 as DOMException
          console.error('[signaling] getUserMedia 全部失败。设备无可用摄像头/麦克风，或权限被禁用。', {
            videoErr: err.name,
            audioErr: err2.name,
            videoOnlyErr: err3.name,
            isSecureContext: window.isSecureContext,
            protocol: window.location.protocol,
            host: window.location.host,
          })
          throw err3
        }
      }
    }
    console.log('[signaling] getUserMedia OK, tracks=', this._localStream.getTracks().map(t => `${t.kind}:${t.label}:${t.enabled}`))
    this.onLocalStream?.(this._localStream)
  }

  private reconnect() {
    if (this.intentionalClose) return
    if (this.reconnectTimer) clearTimeout(this.reconnectTimer)
    const delay = Math.min(1000 * Math.pow(2, this.reconnectAttempts), 16000)
    this.reconnectAttempts++
    this.reconnectTimer = setTimeout(() => {
      this.onSignalingStateChange?.('error')
      this.connect()
    }, delay)
  }

  private startKeepalive() {
    this.stopKeepalive()
    this.keepaliveTimer = setInterval(() => {
      if (!this.connected) return
      this.send('keepalive', {})
      this.keepaliveTimeout = setTimeout(() => {
        this.connected = false
        this.ws?.close()
      }, 5000)
    }, 3000)
  }

  private stopKeepalive() {
    if (this.keepaliveTimer) { clearInterval(this.keepaliveTimer); this.keepaliveTimer = null }
    if (this.keepaliveTimeout) { clearTimeout(this.keepaliveTimeout); this.keepaliveTimeout = null }
  }

  private async onMessage(msg: { type: string; data: unknown }) {
    switch (msg.type) {
      case 'new_ack': {
        // 服务端确认 new 后下发当前客户端的 peer_id，设置 uid
        const data = msg.data as { peer_id: string }
        this.uid = data.peer_id
        console.log('[signaling] uid set:', this.uid)
        break
      }
      case 'peers': {
        const peers = msg.data as unknown[]
        this.onRoomUpdate?.({ self: this.uid, room_id: this.roomId ?? '', peers })
        break
      }
      case 'room_info':
        this._handleRoomInfo(msg.data as Record<string, unknown>)
        break
      case 'offer': {
        const data = msg.data as Record<string, unknown>
        const from = data['from'] as string
        const description = data['description'] as RTCSessionDescriptionInit
        const media = data['media'] as string
        const sessionId = data['session_id'] as string
        const pid = from || sessionId
        let session = this.sessions.get(pid)
        if (!session) {
          session = await this._createSession(pid, sessionId, media)
          this.sessions.set(pid, session)
        }
        await session.pc!.setRemoteDescription(new RTCSessionDescription(description))
        for (const c of session.remoteCandidates) {
          await session.pc!.addIceCandidate(new RTCIceCandidate(c))
        }
        session.remoteCandidates = []
        // 之前缺失的关键环节：收到 offer 后必须创建 answer、设置 localDescription 并回送，
        // 否则对端的 PC 永远没有 remoteDescription，ICE 协商无法完成，视频流无法互通
        const answer = await session.pc!.createAnswer()
        await session.pc!.setLocalDescription(answer)
        this.send('answer', {
          to: pid,
          from: this.uid,
          description: { sdp: answer.sdp, type: answer.type },
          session_id: sessionId,
        })
        this.onCallStateChange?.(sessionId, 'new')
        this.onCallStateChange?.(sessionId, 'ringing')
        break
      }
      case 'answer': {
        const data = msg.data as Record<string, unknown>
        const description = data['description'] as RTCSessionDescriptionInit
        const from = data['from'] as string
        const sessionId = data['session_id'] as string
        const session = (from ? this.sessions.get(from) : null) ?? this._sessionBySid(sessionId)
        await session?.pc?.setRemoteDescription(new RTCSessionDescription(description))
        if (session) this.onCallStateChange?.(session.sid, 'connected')
        break
      }
      case 'candidate': {
        const data = msg.data as Record<string, unknown>
        const from = data['from'] as string
        const candidateMap = data['candidate'] as RTCIceCandidateInit
        const sessionId = data['session_id'] as string
        const session = (from ? this.sessions.get(from) : null) ?? this._sessionBySid(sessionId)
        if (!session) break
        // pc 已创建但 remoteDescription 尚未 setRemoteDescription（offer/answer 未到达）时，
        // 直接 addIceCandidate 会抛 InvalidStateError；缓冲到 remoteCandidates，由 offer/answer 处理分支 flush
        if (session.pc && session.pc.remoteDescription) {
          try {
            await session.pc.addIceCandidate(new RTCIceCandidate(candidateMap))
          } catch (e) {
            console.warn('addIceCandidate failed:', e)
          }
        } else {
          session.remoteCandidates.push(candidateMap)
        }
        break
      }
      case 'leave': {
        const pid = msg.data as string
        this._removePeer(pid)
        break
      }
      case 'bye': {
        const data = msg.data as { session_id: string; from?: string }
        const sid = data.session_id
        const session = this._sessionBySid(sid)
        if (session) {
          this.sessions.delete(session.pid)
          this.remoteStreams.delete(session.pid)
          this.dcMap.delete(session.pid)
          session.pc?.close()
          this.onCallStateChange?.(sid, 'bye')
        }
        break
      }
      case 'keepalive': {
        if (this.keepaliveTimeout) clearTimeout(this.keepaliveTimeout)
        break
      }
    }
  }

  private _handleRoomInfo(data: Record<string, unknown>) {
    const roomId = data['room_id'] as string
    const peers = data['peers'] as unknown[] ?? []
    this.roomId = roomId
    this.onRoomUpdate?.({ self: this.uid, room_id: roomId, peers })

    const remoteIds = new Set<string>()
    for (const peer of peers) {
      const pid = (peer as Record<string, unknown>)['id'] as string
      if (pid && pid !== this.uid) remoteIds.add(pid)
    }

    if (remoteIds.size > 0) this.ensureLocalStream()

    for (const pid of remoteIds) {
      if (!this.sessions.has(pid)) {
        // 避免双方同时发起 offer 导致 glare / SCTP transport 冲突：
        // 只有 uid 字典序小于 pid 的一方主动发起，另一方等待对方 offer 后再 answer
        if (this.uid && this.uid < pid) {
          this._connectToPeer(pid)
        }
      }
    }

    for (const [pid] of this.sessions) {
      if (pid !== this.uid && !remoteIds.has(pid)) {
        this._removePeer(pid)
      }
    }
  }

  private _removePeer(pid: string) {
    const session = this.sessions.get(pid)
    if (session) {
      this.sessions.delete(pid)
      this.remoteStreams.delete(pid)
      this.dcMap.delete(pid)
      session.pc?.close()
      this.onCallStateChange?.(session.sid, 'bye')
    }
  }

  private async _connectToPeer(peerId: string) {
    if (this.sessions.has(peerId)) return
    const sessionId = `${this.uid}-${peerId}`
    const session = await this._createSession(peerId, sessionId, 'video')
    this.sessions.set(peerId, session)
    await this._createChatDC(session)
    const offer = await session.pc!.createOffer()
    await session.pc!.setLocalDescription(offer)
    this.send('offer', {
      to: peerId,
      from: this.uid,
      description: { sdp: offer.sdp, type: offer.type },
      session_id: sessionId,
      media: 'video',
    })
  }

  private async _createSession(peerId: string, sessionId: string, media: string): Promise<Session> {
    const session: Session = { pid: peerId, sid: sessionId, pc: null, media, remoteCandidates: [], dc: null }
    const turnServers = await this.getTurnCredential()
    const iceServers: RTCIceServer[] = turnServers || [{ urls: 'stun:stun.l.google.com:19302' }]
    const pc = new RTCPeerConnection({ iceServers })

    pc.onicecandidate = (e) => {
      if (e.candidate) {
        console.log('[signaling] ICE candidate:', { peer: peerId, candidate: e.candidate.candidate.slice(0, 50) })
        setTimeout(() => {
          this.send('candidate', {
            to: peerId,
            from: this.uid,
            candidate: e.candidate!.toJSON(),
            session_id: sessionId,
          })
        }, 1000)
      } else {
        console.log('[signaling] ICE gathering complete for', peerId)
      }
    }

    pc.ontrack = (e) => {
      console.log('[signaling] ontrack:', { peer: peerId, kind: e.track.kind, streams: e.streams.length, streamId: e.streams[0]?.id })
      if (e.streams[0]) {
        this.remoteStreams.set(peerId, e.streams[0])
        this.onRemoteStream?.(peerId, e.streams[0])
      }
    }

    pc.oniceconnectionstatechange = () => {
      console.log('[signaling] ICE state:', { peer: peerId, state: pc.iceConnectionState })
    }

    pc.onconnectionstatechange = () => {
      console.log('[signaling] PC state:', { peer: peerId, state: pc.connectionState })
    }

    pc.ondatachannel = (e) => {
      if (e.channel.label === 'chat') {
        this._setupChatDC(peerId, e.channel)
      }
    }

    if (this._localStream) {
      for (const track of this._localStream.getTracks()) {
        pc.addTrack(track, this._localStream)
      }
    }

    session.pc = pc
    return session
  }

  private async _createChatDC(session: Session) {
    if (!session.pc) return
    const dc = session.pc.createDataChannel('chat', { ordered: true })
    this._setupChatDC(session.pid, dc)
  }

  private _setupChatDC(pid: string, dc: RTCDataChannel) {
    dc.onmessage = (e) => {
      try {
        const parsed = JSON.parse(e.data)
        const msg: ChatMessage = {
          type: parsed.type || 'chat',
          from: parsed.data?.from,
          name: parsed.data?.name,
          text: parsed.data?.text || '',
          ts: parsed.data?.ts || Date.now(),
        }
        if (msg.from !== this.uid) {
          this.chatMessages.push(msg)
          this.onChatMessage?.(msg)
        }
      } catch { /* ignore */ }
    }
    this.dcMap.set(pid, dc)
    sessionStorage.setItem(pid, 'chat')
  }

  private _sessionBySid(sid: string): Session | null {
    for (const s of this.sessions.values()) {
      if (s.sid === sid) return s
    }
    return null
  }

  // --- Public API ---

  async startLocalStream() {
    try {
      await this.ensureLocalStream()
      return this._localStream
    } catch (e) {
      console.error('[signaling] startLocalStream failed:', e)
      return null
    }
  }

  sendChatMessage(text: string) {
    if (!text.trim()) return
    const data = {
      type: 'chat',
      data: {
        from: this.uid,
        name: this.userName,
        text: text.trim(),
        ts: Math.round(Date.now() / 1000),
      },
    }
    const json = JSON.stringify(data)
    for (const dc of this.dcMap.values()) {
      try { dc.send(json) } catch { /* ignore */ }
    }
    this.chatMessages.push({
      type: 'chat',
      from: this.uid,
      name: this.userName,
      text: text.trim(),
      ts: Date.now(),
    })
  }

  async enumerateDevices() {
    const devices = await navigator.mediaDevices.enumerateDevices()
    return {
      videoinput: devices.filter(d => d.kind === 'videoinput'),
      audioinput: devices.filter(d => d.kind === 'audioinput'),
      audiooutput: devices.filter(d => d.kind === 'audiooutput'),
    }
  }

  async switchCameraDevice(deviceId: string) {
    if (!this._localStream) return
    const oldTracks = this._localStream.getVideoTracks()
    const stream = await navigator.mediaDevices.getUserMedia({
      video: { deviceId: { exact: deviceId }, width: { min: 640 }, height: { min: 480 }, frameRate: { min: 30 } },
      audio: false,
    })
    const newTrack = stream.getVideoTracks()[0]
    for (const session of this.sessions.values()) {
      const sender = session.pc?.getSenders().find(s => s.track?.kind === 'video')
      if (sender) await sender.replaceTrack(newTrack)
    }
    for (const t of oldTracks) {
      this._localStream.removeTrack(t)
      t.stop()
    }
    this._localStream.addTrack(newTrack)
    stream.getTracks().forEach(t => t.stop())
    this.onLocalStream?.(this._localStream)
  }

  async switchMicrophoneDevice(deviceId: string) {
    if (!this._localStream) return
    const oldTracks = this._localStream.getAudioTracks()
    const stream = await navigator.mediaDevices.getUserMedia({
      video: false,
      audio: { deviceId: { exact: deviceId }, echoCancellation: true, noiseSuppression: true },
    })
    const newTrack = stream.getAudioTracks()[0]
    for (const session of this.sessions.values()) {
      const sender = session.pc?.getSenders().find(s => s.track?.kind === 'audio')
      if (sender) await sender.replaceTrack(newTrack)
    }
    for (const t of oldTracks) {
      this._localStream.removeTrack(t)
      t.stop()
    }
    this._localStream.addTrack(newTrack)
    stream.getTracks().forEach(t => t.stop())
    this.onLocalStream?.(this._localStream)
  }

  muteMic() {
    const t = this._localStream?.getAudioTracks()[0]
    if (t) t.enabled = !t.enabled
  }

  async startScreenShare() {
    try {
      const stream = await navigator.mediaDevices.getDisplayMedia({ video: true })
      for (const session of this.sessions.values()) {
        const sender = session.pc?.getSenders().find(s => s.track?.kind === 'video')
        if (sender) await sender.replaceTrack(stream.getVideoTracks()[0])
      }
      stream.getVideoTracks()[0].onended = () => this.stopScreenShare()
      return stream
    } catch { return null }
  }

  async stopScreenShare() {
    const stream = await navigator.mediaDevices.getUserMedia({
      video: { width: { min: 640 }, height: { min: 480 }, frameRate: { min: 30 } },
      audio: false,
    })
    const track = stream.getVideoTracks()[0]
    for (const session of this.sessions.values()) {
      const sender = session.pc?.getSenders().find(s => s.track?.kind === 'video')
      if (sender) await sender.replaceTrack(track)
    }
    stream.getTracks().forEach(t => t.stop())
  }

  private send(type: string, data: unknown) {
    if (this.ws?.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify({ type, data }))
    }
  }

  private cleanSessions() {
    if (this._localStream) {
      this._localStream.getTracks().forEach(t => t.stop())
      this._localStream = null
    }
    this.remoteStreams.forEach((s) => s.getTracks().forEach(t => t.stop()))
    this.remoteStreams.clear()
    this.sessions.forEach(s => s.pc?.close())
    this.sessions.clear()
    this.dcMap.clear()
    this.chatMessages.length = 0
  }
}

export interface ChatMessage {
  type: string
  from?: string
  name?: string
  text: string
  ts: number
}
