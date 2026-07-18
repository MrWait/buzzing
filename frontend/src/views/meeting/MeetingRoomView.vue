<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useMeetingStore } from '@/stores/meeting'

const router = useRouter()
const meeting = useMeetingStore()

const localVideo = ref<HTMLVideoElement | null>(null)
const remoteVideo = ref<HTMLVideoElement | null>(null)
const isSharing = ref(false)

const otherPeers = computed(() =>
  meeting.peers.filter((p: any) => p.id !== meeting.uid)
)

onMounted(async () => {
  meeting.init()
  const sig = meeting.signaling
  if (!sig) return

  meeting.connect()

  sig.onLocalStream = (stream) => {
    if (localVideo.value) localVideo.value.srcObject = stream
  }
  sig.onRemoteStream = (stream) => {
    if (remoteVideo.value) remoteVideo.value.srcObject = stream
  }
  sig.onCallStateChange = (sid, state) => {
    if (state === 'ringing') {
      meeting.accept(sid)
    }
  }

  await sig.startLocalStream()
})

onUnmounted(() => {
  meeting.dispose()
})

function handleScreenShare() {
  if (isSharing.value) {
    meeting.stopScreenShare()
    isSharing.value = false
  } else {
    meeting.startScreenShare()
    isSharing.value = true
  }
}

function handleHangUp() {
  meeting.hangUp()
  router.push({ name: 'Hub' })
}

function invitePeer(peerId: string) {
  meeting.invite(peerId)
}
</script>

<template>
  <div class="meeting-room">
    <!-- 未通话 → 显示在线同事列表 -->
    <template v-if="!meeting.inCalling">
      <div class="lobby">
        <div class="lobby-header">
          <h2>视频会议</h2>
          <span class="lobby-status">
            {{ meeting.peers.length > 0 ? `${meeting.peers.length} 人在线` : '连接中...' }}
          </span>
        </div>
        <div v-if="otherPeers.length === 0" class="lobby-empty">
          <div class="lobby-empty-icon">📹</div>
          <p>暂无其他在线成员</p>
          <p class="lobby-empty-hint">等待同事加入或邀请他们</p>
        </div>
        <div v-else class="peer-list">
          <div
            v-for="peer in otherPeers"
            :key="(peer as any).id"
            class="peer-item"
          >
            <div class="peer-avatar">{{ ((peer as any).name || '?')[0] }}</div>
            <div class="peer-info">
              <div class="peer-name">{{ (peer as any).name || '未知' }}</div>
              <div class="peer-id">ID: {{ (peer as any).id }}</div>
            </div>
            <button class="invite-btn" @click="invitePeer((peer as any).id)">
              呼叫
            </button>
          </div>
        </div>
        <div class="local-preview">
          <video ref="localVideo" autoplay playsinline muted class="preview-video" />
        </div>
        <button class="leave-btn" @click="router.push({ name: 'Hub' })">离开</button>
      </div>
    </template>

    <!-- 通话中 → 视频画面 -->
    <template v-else>
      <div class="remote-container">
        <video ref="remoteVideo" autoplay playsinline class="remote-video" />
      </div>
      <div class="local-pip">
        <video ref="localVideo" autoplay playsinline muted class="local-video" />
      </div>
      <div class="control-bar">
        <button class="ctrl-btn" title="切换摄像头" @click="meeting.switchCamera()">
          <span>📷</span>
        </button>
        <button class="ctrl-btn" title="屏幕共享" @click="handleScreenShare">
          <span>{{ isSharing ? '🖥️' : '🖵' }}</span>
        </button>
        <button class="ctrl-btn ctrl-hangup" title="挂断" @click="handleHangUp">
          <span>📞</span>
        </button>
        <button class="ctrl-btn" title="静音" @click="meeting.muteMic()">
          <span>🎤</span>
        </button>
      </div>
    </template>
  </div>
</template>

<style scoped>
.meeting-room {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: #1a1a1a;
  color: #fff;
  position: relative;
}

/* --- Lobby --- */
.lobby {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 40px 16px 16px;
  gap: 20px;
}

.lobby-header {
  text-align: center;
}

.lobby-header h2 {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
}

.lobby-status {
  font-size: 13px;
  color: #999;
  margin-top: 4px;
  display: block;
}

.lobby-empty {
  text-align: center;
  color: #999;
}

.lobby-empty-icon {
  font-size: 48px;
  margin-bottom: 12px;
}

.lobby-empty-hint {
  font-size: 12px;
  color: #666;
}

.peer-list {
  width: 100%;
  max-width: 400px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.peer-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: #2a2a2a;
  border-radius: 8px;
}

.peer-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: #444;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  font-weight: 600;
  flex-shrink: 0;
}

.peer-info {
  flex: 1;
  min-width: 0;
}

.peer-name {
  font-size: 14px;
  font-weight: 500;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.peer-id {
  font-size: 11px;
  color: #888;
  margin-top: 2px;
}

.invite-btn {
  padding: 6px 16px;
  border: none;
  border-radius: 6px;
  background: #1976d2;
  color: #fff;
  font-size: 13px;
  cursor: pointer;
  flex-shrink: 0;
  transition: background 0.2s;
}

.invite-btn:hover {
  background: #1565c0;
}

.local-preview {
  width: 200px;
  height: 150px;
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid #444;
}

.preview-video {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.leave-btn {
  padding: 8px 32px;
  border: 1px solid #666;
  border-radius: 6px;
  background: transparent;
  color: #ccc;
  cursor: pointer;
  font-size: 14px;
  transition: background 0.2s;
}

.leave-btn:hover {
  background: #333;
}

/* --- In-call --- */
.remote-container {
  flex: 1;
  position: relative;
  overflow: hidden;
}

.remote-video {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.local-pip {
  position: absolute;
  right: 20px;
  bottom: 80px;
  width: 200px;
  height: 150px;
  border-radius: 8px;
  overflow: hidden;
  border: 2px solid rgba(255,255,255,0.3);
  box-shadow: 0 4px 12px rgba(0,0,0,0.4);
}

.local-video {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.control-bar {
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 20px;
  background: #2a2a2a;
  border-top: 1px solid #333;
}

.ctrl-btn {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  border: none;
  background: #444;
  color: #fff;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  transition: background 0.2s;
}

.ctrl-btn:hover {
  background: #555;
}

.ctrl-hangup {
  background: #d32f2f;
}

.ctrl-hangup:hover {
  background: #b71c1c;
}
</style>
