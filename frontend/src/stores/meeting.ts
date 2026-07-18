import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { Signaling, type ChatMessage } from '@/services/meeting/signaling'
import * as meetingApi from '@/services/meeting/meetingApi'

export type LayoutMode = 'grid' | 'speaker'

export const useMeetingStore = defineStore('meeting', () => {
  const signaling = ref<Signaling | null>(null)
  const inCalling = ref(false)
  const uid = ref('')
  const peers = ref<unknown[]>([])
  const networkQuality = ref<'good' | 'fair' | 'poor'>('good')
  const roomId = ref<string | null>(null)
  const layoutMode = ref<LayoutMode>('grid')
  const chatMessages = ref<ChatMessage[]>([])
  const chatOpen = ref(false)
  const chatUnread = ref(0)
  const localStream = ref<MediaStream | null>(null)
  const remoteStreams = ref<Map<string, MediaStream>>(new Map())
  const cameraDevices = ref<MediaDeviceInfo[]>([])
  const micDevices = ref<MediaDeviceInfo[]>([])
  // 麦克风/摄像头启用状态，反映 track.enabled，用于 UI 显示两种状态
  const micEnabled = ref(true)
  const cameraEnabled = ref(true)
  // 当前选中的设备 id（用于下拉菜单勾选标记）
  const activeMicId = ref<string>('')
  const activeCameraId = ref<string>('')

  const activeMeetings = ref<meetingApi.MeetingItem[]>([])
  const scheduledMeetings = ref<meetingApi.MeetingItem[]>([])
  const historyMeetings = ref<meetingApi.MeetingItem[]>([])
  const listLoading = ref(false)

  const peerList = computed(() => peers.value as { id: string; name?: string }[])

  const showChat = computed({
    get: () => chatOpen.value,
    set: (v: boolean) => { chatOpen.value = v; if (v) chatUnread.value = 0 },
  })

  function init() {
    const sig = new Signaling()
    signaling.value = sig

    let prevPeerIds = new Set<string>()

    sig.onRoomUpdate = (data) => {
      uid.value = data.self
      roomId.value = data.room_id
      const newPeers = data.peers as { id: string; name?: string }[]
      console.log('[meeting] onRoomUpdate:', { self: data.self, roomId: data.room_id, peers: newPeers })
      const newIds = new Set(newPeers.map(p => p.id))

      for (const p of newPeers) {
        if (p.id !== data.self && !prevPeerIds.has(p.id)) {
          chatMessages.value.push({
            type: 'system',
            text: `${p.name || p.id.slice(0, 8)} 加入了会议`,
            ts: Date.now(),
          })
        }
      }
      for (const pid of prevPeerIds) {
        if (pid !== data.self && !newIds.has(pid)) {
          const peer = peers.value.find((p: any) => p.id === pid) as { id: string; name?: string } | undefined
          chatMessages.value.push({
            type: 'system',
            text: `${peer?.name || pid.slice(0, 8)} 离开了会议`,
            ts: Date.now(),
          })
        }
      }

      prevPeerIds = newIds
      peers.value = data.peers
      inCalling.value = true
    }

    sig.onCallStateChange = (_sid, state) => {
      if (state === 'bye') {
        inCalling.value = false
      }
    }

    sig.onReconnect = () => {
      if (inCalling.value && sig.roomId) {
        sig.join(sig.roomId)
      }
    }

    sig.onChatMessage = (msg: ChatMessage) => {
      chatMessages.value.push(msg)
      if (!chatOpen.value) chatUnread.value++
    }

    sig.onLocalStream = (s: MediaStream) => {
      console.log('[meeting] onLocalStream:', s, 'tracks=', s.getTracks().map(t => `${t.kind}:${t.enabled}:${t.readyState}`))
      localStream.value = s
    }

    sig.onRemoteStream = (peerId: string, s: MediaStream) => {
      console.log('[meeting] onRemoteStream:', peerId, 'tracks=', s.getTracks().map(t => `${t.kind}:${t.enabled}:${t.readyState}`))
      // Map.set 不触发 ref 响应式，必须重新赋值整个 Map
      const newMap = new Map(remoteStreams.value)
      newMap.set(peerId, s)
      remoteStreams.value = newMap
    }
  }

  function connect() {
    signaling.value?.connect()
  }

  function joinMeeting(rid: string) {
    const sig = signaling.value
    if (!sig) return
    roomId.value = rid
    sig.join(rid)
  }

  function leaveMeeting() {
    const sig = signaling.value
    sig?.leave()
    roomId.value = null
    inCalling.value = false
    remoteStreams.value = new Map()
    localStream.value = null
    chatMessages.value = []
    chatOpen.value = false
    chatUnread.value = 0
  }

  function toggleLayout() {
    layoutMode.value = layoutMode.value === 'grid' ? 'speaker' : 'grid'
  }

  function toggleChat() {
    chatOpen.value = !chatOpen.value
    if (chatOpen.value) chatUnread.value = 0
  }

  function sendMessage(text: string) {
    signaling.value?.sendChatMessage(text)
    chatMessages.value.push({
      type: 'chat',
      from: uid.value,
      name: signaling.value?.userName || 'web',
      text,
      ts: Date.now(),
    })
  }

  async function refreshDevices() {
    const sig = signaling.value
    if (!sig) return
    const devices = await sig.enumerateDevices()
    cameraDevices.value = devices.videoinput
    micDevices.value = devices.audioinput
    // 同步当前选中设备的 id（用于下拉菜单勾选标记）
    const audioTrack = localStream.value?.getAudioTracks()[0]
    const videoTrack = localStream.value?.getVideoTracks()[0]
    activeMicId.value = audioTrack?.getSettings?.()?.deviceId || ''
    activeCameraId.value = videoTrack?.getSettings?.()?.deviceId || ''
  }

  function muteMic() {
    signaling.value?.muteMic()
    const t = localStream.value?.getAudioTracks()[0]
    if (t) micEnabled.value = t.enabled
  }

  function toggleCamera() {
    const tracks = localStream.value?.getVideoTracks() || []
    tracks.forEach(t => { t.enabled = !t.enabled })
    if (tracks[0]) cameraEnabled.value = tracks[0].enabled
  }

  // 切换设备后同步当前选中 id 与启用状态
  async function switchMicrophoneDevice(deviceId: string) {
    await signaling.value?.switchMicrophoneDevice(deviceId)
    activeMicId.value = deviceId
    const t = localStream.value?.getAudioTracks()[0]
    if (t) micEnabled.value = t.enabled
  }

  async function switchCameraDevice(deviceId: string) {
    await signaling.value?.switchCameraDevice(deviceId)
    activeCameraId.value = deviceId
    const t = localStream.value?.getVideoTracks()[0]
    if (t) cameraEnabled.value = t.enabled
  }

  async function startScreenShare() {
    await signaling.value?.startScreenShare()
  }

  async function stopScreenShare() {
    await signaling.value?.stopScreenShare()
  }

  function hangUp() {
    leaveMeeting()
  }

  function dispose() {
    signaling.value?.close()
    signaling.value = null
    inCalling.value = false
    peers.value = []
    roomId.value = null
    remoteStreams.value = new Map()
    localStream.value = null
    chatMessages.value = []
    chatOpen.value = false
    chatUnread.value = 0
  }

  async function loadMeetings() {
    listLoading.value = true
    try {
      // proto 中 MeetingListFilter: ACTIVE=1, HISTORY=2, SCHEDULED=3
      const [active, history, scheduled] = await Promise.all([
        meetingApi.getMeetingList(1),
        meetingApi.getMeetingList(2),
        meetingApi.getMeetingList(3),
      ])
      activeMeetings.value = active.meetings
      scheduledMeetings.value = scheduled.meetings
      historyMeetings.value = history.meetings
    } catch (e) {
      console.error('load meetings error:', e)
    }
    listLoading.value = false
  }

  async function createMeetingApi(title: string, password?: string) {
    await meetingApi.createMeeting(title, password)
    await loadMeetings()
  }

  async function scheduleMeetingApi(title: string, scheduledAt: number, password?: string) {
    await meetingApi.createMeeting(title, password, scheduledAt)
    await loadMeetings()
  }

  async function joinMeetingApi(roomId: string, password?: string): Promise<boolean> {
    try {
      await meetingApi.joinMeetingApi(roomId, password)
      return true
    } catch (e) {
      console.error('join meeting error:', e)
      return false
    }
  }

  async function endMeetingApi(roomId: string) {
    try {
      await meetingApi.endMeeting(roomId)
      await loadMeetings()
    } catch (e) {
      console.error('end meeting error:', e)
    }
  }

  return {
    signaling, inCalling, uid, peers, peerList, networkQuality,
    roomId, layoutMode, chatMessages, chatOpen, chatUnread, showChat,
    localStream, remoteStreams,
    cameraDevices, micDevices,
    activeMeetings, scheduledMeetings, historyMeetings, listLoading,
    init, connect, joinMeeting, leaveMeeting, hangUp,
    toggleLayout, toggleChat, sendMessage,
    refreshDevices, switchCameraDevice, switchMicrophoneDevice,
    muteMic, toggleCamera, startScreenShare, stopScreenShare, dispose,
    micEnabled, cameraEnabled, activeMicId, activeCameraId,
    loadMeetings, createMeetingApi, scheduleMeetingApi, joinMeetingApi, endMeetingApi,
  }
})
