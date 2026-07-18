import { defineStore } from 'pinia'
import { ref } from 'vue'
import { Signaling } from '@/services/meeting/signaling'

export const useMeetingStore = defineStore('meeting', () => {
  const signaling = ref<Signaling | null>(null)
  const inCalling = ref(false)
  const uid = ref('')
  const peers = ref<unknown[]>([])
  const networkQuality = ref<'good' | 'fair' | 'poor'>('good')

  function init() {
    const sig = new Signaling()
    signaling.value = sig

    sig.onPeerUpdate = (data) => {
      uid.value = data.self
      peers.value = data.peers
    }
    sig.onCallStateChange = (_sid, state) => {
      if (state === 'connected') {
        inCalling.value = true
      } else if (state === 'bye') {
        inCalling.value = false
      }
    }
    sig.onReconnect = () => {
      if (inCalling.value) {
        const sids = Object.keys(sig['sessions'])
        sids.forEach(sid => sig.iceRestart(sid))
      }
    }
  }

  function connect() {
    signaling.value?.connect()
  }

  function invite(peerId: string) {
    signaling.value?.invite(peerId)
  }

  function accept(sessionId: string) {
    signaling.value?.accept(sessionId)
  }

  function reject(sessionId: string) {
    signaling.value?.reject(sessionId)
  }

  function hangUp() {
    signaling.value?.close()
    inCalling.value = false
  }

  function muteMic() {
    signaling.value?.muteMic()
  }

  function switchCamera() {
    signaling.value?.switchCamera()
  }

  function startScreenShare() {
    signaling.value?.startScreenShare()
  }

  function stopScreenShare() {
    signaling.value?.stopScreenShare()
  }

  function dispose() {
    signaling.value?.close()
    signaling.value = null
    inCalling.value = false
    peers.value = []
  }

  return {
    signaling, inCalling, uid, peers, networkQuality,
    init, connect, invite, accept, reject, hangUp,
    muteMic, switchCamera, startScreenShare, stopScreenShare, dispose,
  }
})
