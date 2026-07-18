import { useAuthStore } from '@/stores/auth'

export type SignalingState = 'open' | 'closed' | 'error'
export type CallState = 'new' | 'ringing' | 'invite' | 'connected' | 'bye'

interface Session {
  sid: string
  pid: string
  pc: RTCPeerConnection | null
  media: string
  remoteCandidates: RTCIceCandidateInit[]
}

export class Signaling {
  uid = ''
  private ws: WebSocket | null = null
  private host: string
  private port: number
  private token: string
  private sessions = new Map<string, Session>()
  private reconnectAttempts = 0
  private reconnectTimer: ReturnType<typeof setTimeout> | null = null
  private keepaliveTimer: ReturnType<typeof setInterval> | null = null
  private keepaliveTimeout: ReturnType<typeof setTimeout> | null = null
  private intentionalClose = false
  private connected = false
  private _localStream: MediaStream | null = null
  private _remoteStream: MediaStream | null = null

  onSignalingStateChange: ((s: SignalingState) => void) | null = null
  onCallStateChange: ((sid: string, s: CallState) => void) | null = null
  onLocalStream: ((s: MediaStream) => void) | null = null
  onRemoteStream: ((s: MediaStream) => void) | null = null
  onPeerUpdate: ((data: { self: string; peers: unknown[] }) => void) | null = null
  onReconnect: (() => void) | null = null

  get localStream() { return this._localStream }
  get remoteStream() { return this._remoteStream }

  constructor() {
    const auth = useAuthStore()
    this.host = window.location.hostname
    this.port = 5150
    this.token = auth.token || ''
  }

  private wsUrl() {
    return `wss://${this.host}:${this.port}/ws`
  }

  async getTurnCredential(): Promise<RTCIceServer[] | null> {
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
      this.send('new', { token: this.token, name: 'web', user_agent: navigator.userAgent })
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
      case 'peers': {
        const peers = msg.data as unknown[]
        const self = this.uid
        this.onPeerUpdate?.({ self, peers })
        break
      }
      case 'offer': {
        const data = msg.data as Record<string, unknown>
        const peerId = data['from'] as string
        const description = data['description'] as RTCSessionDescriptionInit
        const media = data['media'] as string
        const sessionId = data['session_id'] as string
        let session = this.sessions.get(sessionId)
        session = await this.createSession(session, peerId, sessionId, media)
        this.sessions.set(sessionId, session)
        await session.pc!.setRemoteDescription(new RTCSessionDescription(description))
        for (const c of session.remoteCandidates) {
          await session.pc!.addIceCandidate(new RTCIceCandidate(c))
        }
        session.remoteCandidates = []
        this.onCallStateChange?.(sessionId, 'new')
        this.onCallStateChange?.(sessionId, 'ringing')
        break
      }
      case 'answer': {
        const data = msg.data as Record<string, unknown>
        const description = data['description'] as RTCSessionDescriptionInit
        const sessionId = data['session_id'] as string
        const session = this.sessions.get(sessionId)
        await session?.pc?.setRemoteDescription(new RTCSessionDescription(description))
        this.onCallStateChange?.(sessionId, 'connected')
        break
      }
      case 'candidate': {
        const data = msg.data as Record<string, unknown>
        const candidateMap = data['candidate'] as RTCIceCandidateInit
        const sessionId = data['session_id'] as string
        let session = this.sessions.get(sessionId)
        const candidate = new RTCIceCandidate(candidateMap)
        if (session) {
          if (session.pc) {
            await session.pc.addIceCandidate(candidate)
          } else {
            session.remoteCandidates.push(candidateMap)
          }
        } else {
          session = { sid: sessionId, pid: '', pc: null, media: '', remoteCandidates: [candidateMap] }
          this.sessions.set(sessionId, session)
        }
        break
      }
      case 'bye': {
        const data = msg.data as { session_id: string }
        const sessionId = data.session_id
        this.sessions.delete(sessionId)
        this.onCallStateChange?.(sessionId, 'bye')
        break
      }
      case 'keepalive':
        if (this.keepaliveTimeout) clearTimeout(this.keepaliveTimeout)
        break
    }
  }

  private async createSession(existing: Session | undefined, peerId: string, sessionId: string, media: string): Promise<Session> {
    const session = existing || { sid: sessionId, pid: peerId, pc: null, media, remoteCandidates: [] as RTCIceCandidateInit[] }
    const turnServers = await this.getTurnCredential()
    const iceServers: RTCIceServer[] = turnServers || [{ urls: 'stun:stun.l.google.com:19302' }]

    const pc = new RTCPeerConnection({ iceServers })

    pc.onicecandidate = (e) => {
      if (e.candidate) {
        setTimeout(() => {
          this.send('candidate', {
            to: peerId,
            from: this.uid,
            candidate: e.candidate!.toJSON(),
            session_id: sessionId,
          })
        }, 1000)
      }
    }

    pc.ontrack = (e) => {
      if (e.streams[0]) {
        this._remoteStream = e.streams[0]
        this.onRemoteStream?.(e.streams[0])
      }
    }

    pc.oniceconnectionstatechange = () => {
      this.onIceConnectionState(pc.iceConnectionState)
    }

    pc.ondatachannel = () => { /* not used in Web MVP */ }

    session.pc = pc
    return session
  }

  private onIceConnectionState(state: RTCIceConnectionState) {
    const videoSender = (this._localStream?.getVideoTracks().length ?? 0) > 0
    if (!videoSender) return
    switch (state) {
      case 'connected':
      case 'completed':
        this._localStream?.getVideoTracks().forEach(t => t.enabled = true)
        break
      case 'disconnected':
      case 'failed':
        this._localStream?.getVideoTracks().forEach(t => t.enabled = false)
        break
    }
  }

  async startLocalStream() {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: { width: { min: 640 }, height: { min: 480 }, frameRate: { min: 30 } },
        audio: { echoCancellation: true, noiseSuppression: true, autoGainControl: true },
      })
      this._localStream = stream
      this.onLocalStream?.(stream)
      return stream
    } catch { return null }
  }

  async startScreenShare() {
    try {
      const stream = await navigator.mediaDevices.getDisplayMedia({ video: true })
      const sender = this.pc?.getSenders().find(s => s.track?.kind === 'video')
      if (sender) await sender.replaceTrack(stream.getVideoTracks()[0])
      stream.getVideoTracks()[0].onended = () => this.stopScreenShare()
      return stream
    } catch { return null }
  }

  async stopScreenShare() {
    const stream = await this.startLocalStream()
    if (stream) {
      const sender = this.pc?.getSenders().find(s => s.track?.kind === 'video')
      if (sender) await sender.replaceTrack(stream.getVideoTracks()[0])
    }
  }

  invite(peerId: string) {
    const sessionId = `${this.uid}-${peerId}`
    this.createSession(undefined, peerId, sessionId, 'video').then(async (session) => {
      this.sessions.set(sessionId, session)
      if (this._localStream) {
        for (const track of this._localStream.getTracks()) {
          session.pc!.addTrack(track, this._localStream!)
        }
      }
      const offer = await session.pc!.createOffer()
      await session.pc!.setLocalDescription(offer)
      this.send('offer', {
        to: peerId,
        from: this.uid,
        description: { sdp: offer.sdp, type: offer.type },
        session_id: sessionId,
        media: 'video',
      })
      this.onCallStateChange?.(sessionId, 'new')
      this.onCallStateChange?.(sessionId, 'invite')
    })
  }

  async accept(sessionId: string) {
    const session = this.sessions.get(sessionId)
    if (!session || !session.pc) return
    if (this._localStream) {
      for (const track of this._localStream.getTracks()) {
        session.pc.addTrack(track, this._localStream)
      }
    }
    const answer = await session.pc.createAnswer()
    await session.pc.setLocalDescription(answer)
    this.send('answer', {
      to: session.pid,
      from: this.uid,
      description: { sdp: answer.sdp, type: answer.type },
      session_id: sessionId,
    })
    this.onCallStateChange?.(sessionId, 'connected')
  }

  reject(sessionId: string) {
    this.bye(sessionId)
  }

  bye(sessionId: string) {
    this.send('bye', { session_id: sessionId, from: this.uid })
    const session = this.sessions.get(sessionId)
    if (session?.pc) { session.pc.close(); this.sessions.delete(sessionId) }
  }

  iceRestart(sessionId: string) {
    const session = this.sessions.get(sessionId)
    if (!session?.pc) return Promise.resolve()
    return session.pc.createOffer({ iceRestart: true }).then((offer) => {
      return session.pc!.setLocalDescription(offer)
    }).then(() => {
      const desc = session.pc!.localDescription!
      this.send('offer', {
        to: session.pid,
        from: this.uid,
        description: { sdp: desc.sdp, type: desc.type },
        session_id: sessionId,
        media: session.media,
      })
    })
  }

  muteMic() {
    const audioTrack = this._localStream?.getAudioTracks()[0]
    if (audioTrack) audioTrack.enabled = !audioTrack.enabled
  }

  switchCamera() {
    // basic switch — rotate facingMode in real usage
    this.startLocalStream()
  }

  private get pc(): RTCPeerConnection | null {
    return this.sessions.values().next().value?.pc || null
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
    if (this._remoteStream) {
      this._remoteStream.getTracks().forEach(t => t.stop())
      this._remoteStream = null
    }
    this.sessions.forEach(s => s.pc?.close())
    this.sessions.clear()
  }
}
