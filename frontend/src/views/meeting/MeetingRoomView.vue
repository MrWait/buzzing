<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useMeetingStore } from '@/stores/meeting'
import * as meetingApi from '@/services/meeting/meetingApi'

const route = useRoute()
const router = useRouter()
const meeting = useMeetingStore()

const isSharing = ref(false)
const chatInput = ref('')
const chatListRef = ref<HTMLDivElement | null>(null)
const cameraMenuOpen = ref(false)
const micMenuOpen = ref(false)
const showParticipants = ref(false)
const meetingInfo = ref<meetingApi.MeetingItem | null>(null)

const roomId = computed(() => route.params.roomId as string)

const remotePeerIds = computed(() =>
  meeting.peers
    .filter((p: any) => p.id !== meeting.uid)
    .map((p: any) => p.id)
)

// grid 中包含本地，本地始终为第一个条目
const gridPeerIds = computed(() => {
  return meeting.uid ? [meeting.uid, ...remotePeerIds.value] : [...remotePeerIds.value]
})

const speakerMainId = computed(() => {
  if (remotePeerIds.value.length === 0) return meeting.uid
  return remotePeerIds.value[0]
})

const speakerThumbIds = computed(() => {
  const ids = remotePeerIds.value.filter(id => id !== speakerMainId.value)
  // 本地也加入底部缩略图（演讲者视图下，本地不占主画面时显示在缩略图）
  return meeting.uid && speakerMainId.value !== meeting.uid ? [meeting.uid, ...ids] : ids
})

const gridCols = computed(() => {
  const n = gridPeerIds.value.length
  if (n <= 1) return 1
  if (n <= 2) return 2
  if (n <= 4) return 2
  return 3
})

const gridRows = computed(() => {
  const n = gridPeerIds.value.length
  if (n === 0) return 1
  return Math.ceil(n / gridCols.value)
})

const isHost = computed(() => {
  const uid = meeting.uid
  return uid ? meetingInfo.value?.hostId === uid : false
})

async function loadMeetingInfo() {
  try {
    meetingInfo.value = await meetingApi.getMeetingInfo(roomId.value)
  } catch (e) {
    console.error('load meeting info error:', e)
  }
}

async function handleKick(targetId: string) {
  try {
    await meetingApi.kickMember(roomId.value, targetId)
    await loadMeetingInfo()
  } catch (e) {
    console.error('kick error:', e)
  }
}

async function handleEndMeeting() {
  if (!confirm('确定结束会议？')) return
  try {
    await meetingApi.endMeeting(roomId.value)
    router.push({ name: 'Hub' })
  } catch (e) {
    console.error('end meeting error:', e)
  }
}

onMounted(async () => {
  meeting.init()
  await meeting.signaling?.startLocalStream()
  console.log('[view] localStream after startLocalStream:', meeting.localStream, 'tracks=', meeting.localStream?.getTracks().map(t => `${t.kind}:${t.enabled}:${t.readyState}`))
  await meeting.refreshDevices()
  meeting.connect()
  await new Promise(r => setTimeout(r, 1000))
  console.log('[view] before join, uid=', meeting.uid, 'peers=', meeting.peers)
  meeting.joinMeeting(roomId.value)
  await loadMeetingInfo()
  // 等 joinMeeting 后再看一次状态
  setTimeout(() => {
    console.log('[view] after join, uid=', meeting.uid, 'peers=', meeting.peers, 'localStream=', meeting.localStream)
  }, 1500)

  document.addEventListener('click', closeMenus)
})

function closeMenus() {
  cameraMenuOpen.value = false
  micMenuOpen.value = false
}

onUnmounted(() => {
  document.removeEventListener('click', closeMenus)
  meeting.leaveMeeting()
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
  router.push({ name: 'MeetingHome' })
}

function sendChat() {
  if (!chatInput.value.trim()) return
  meeting.sendMessage(chatInput.value)
  chatInput.value = ''
}

watch(() => meeting.chatMessages.length, () => {
  setTimeout(() => {
    if (chatListRef.value) {
      chatListRef.value.scrollTop = chatListRef.value.scrollHeight
    }
  }, 50)
})

function getPeerName(pid: string): string {
  if (pid === meeting.uid) return '我'
  const peer = meeting.peers.find((p: any) => p.id === pid)
  return (peer as any)?.name || pid.slice(0, 8)
}

// video 元素挂载后，强制将 stream 绑上去并 play。
// Vue 对 srcObject 的响应式 patch 在某些情况下不触发播放（特别是 stream 已就绪但元素后挂载）。
function bindVideo(el: any, stream: MediaStream | null) {
  if (!el || !(el instanceof HTMLVideoElement)) return
  console.log('[view] bindVideo called:', { el, stream, currentSrcObject: el.srcObject })
  if (stream && el.srcObject !== stream) {
    el.srcObject = stream
  }
  el.play().then(() => {
    console.log('[view] video play OK, videoWidth=', el.videoWidth, 'videoHeight=', el.videoHeight)
  }).catch((e: unknown) => { console.warn('[view] video play failed:', e) })
}
</script>

<template>
  <div class="meeting-room" :class="{ 'chat-active': meeting.chatOpen }">
    <!-- Chat overlay -->
    <Transition name="slide">
      <div v-if="meeting.chatOpen" class="chat-panel">
        <div class="chat-header">
          <span>会议聊天</span>
          <button class="chat-close" @click="meeting.toggleChat()">✕</button>
        </div>
        <div class="chat-messages" ref="chatListRef">
          <div
            v-for="(msg, i) in meeting.chatMessages"
            :key="i"
            class="chat-msg"
            :class="{ 'chat-msg-self': msg.from === meeting.uid }"
          >
            <div class="chat-msg-name">{{ msg.type === 'system' ? '系统' : (msg.name || msg.from?.slice(0, 8) || '未知') }}</div>
            <div class="chat-msg-text">{{ msg.text }}</div>
          </div>
          <div v-if="meeting.chatMessages.length === 0" class="chat-empty">暂无消息</div>
        </div>
        <div class="chat-input-row">
          <input
            v-model="chatInput"
            class="chat-input"
            placeholder="发送消息..."
            @keydown.enter="sendChat"
          />
          <button class="chat-send" @click="sendChat">发送</button>
        </div>
      </div>
    </Transition>

    <!-- Video area -->
    <div class="video-area">
      <!-- Grid layout -->
      <div v-if="meeting.layoutMode === 'grid'" class="grid-container" :style="{ gridTemplateColumns: `repeat(${gridCols}, 1fr)`, gridTemplateRows: `repeat(${gridRows}, 1fr)` }">
        <div
          v-for="pid in gridPeerIds"
          :key="pid"
          class="grid-video-wrapper"
          :class="{ 'grid-local': pid === meeting.uid }"
        >
          <!-- 本地视频：用函数 ref + watch 手动绑定 srcObject，避免 Vue patch 不触发播放 -->
          <video
            v-if="pid === meeting.uid"
            :ref="(el: any) => bindVideo(el, meeting.localStream)"
            autoplay
            playsinline
            muted
            class="grid-video"
          />
          <video
            v-else
            :ref="(el: any) => bindVideo(el, meeting.remoteStreams.get(pid) || null)"
            autoplay
            playsinline
            class="grid-video"
          />
          <div class="video-label">{{ getPeerName(pid) }}</div>
          <div v-if="pid !== meeting.uid && !meeting.remoteStreams.get(pid)" class="video-placeholder">
            <div class="placeholder-avatar">{{ getPeerName(pid)[0] }}</div>
            <div class="placeholder-name">{{ getPeerName(pid) }}</div>
          </div>
        </div>
      </div>

      <!-- Speaker layout -->
      <div v-else class="speaker-container">
        <div class="speaker-main">
          <video
            v-if="remotePeerIds.length > 0 && meeting.remoteStreams.get(speakerMainId)"
            :ref="(el: any) => bindVideo(el, meeting.remoteStreams.get(speakerMainId) || null)"
            autoplay
            playsinline
            class="speaker-video"
          />
          <div v-else class="speaker-placeholder">
            <div class="placeholder-avatar">{{ remotePeerIds.length > 0 ? getPeerName(speakerMainId)[0] : '?' }}</div>
            <div class="placeholder-name">{{ remotePeerIds.length > 0 ? getPeerName(speakerMainId) : '等待加入...' }}</div>
          </div>
          <div class="speaker-label">{{ remotePeerIds.length > 0 ? getPeerName(speakerMainId) : '' }}</div>
        </div>
        <div class="speaker-thumbs">
          <div
            v-for="pid in speakerThumbIds"
            :key="pid"
            class="thumb-wrapper"
          >
            <video
              :ref="(el: any) => bindVideo(el, meeting.remoteStreams.get(pid) || null)"
              autoplay
              playsinline
              class="thumb-video"
            />
            <div v-if="!meeting.remoteStreams.has(pid)" class="thumb-placeholder">
              {{ getPeerName(pid)[0] }}
            </div>
          </div>
        </div>
      </div>

      <!-- Local PiP: 仅在 speaker 视图下显示，grid 视图已包含本地条目 -->
      <div v-if="meeting.layoutMode === 'speaker'" class="local-pip">
        <video
          autoplay
          playsinline
          muted
          class="local-video"
          :ref="(el: any) => bindVideo(el, meeting.localStream)"
        />
      </div>
    </div>

    <!-- Participant panel -->
    <Transition name="slide">
      <div v-if="showParticipants" class="participant-panel">
        <div class="participant-header">
          <span>参会者 ({{ meeting.peers.length }})</span>
          <button class="participant-close" @click="showParticipants = false">✕</button>
        </div>
        <div class="participant-list">
          <div
            v-for="p in meeting.peers"
            :key="(p as any).id"
            class="participant-item"
          >
            <div class="participant-avatar">{{ ((p as any).name || (p as any).id || '?')[0] }}</div>
            <div class="participant-name">{{ (p as any).name || (p as any).id?.slice(0, 8) || '未知' }}</div>
            <div v-if="(p as any).id === meetingInfo?.hostId" class="participant-role">主持人</div>
            <button
              v-if="isHost && (p as any).id !== meeting.uid"
              class="participant-kick"
              title="移出会议"
              @click="handleKick((p as any).id)"
            >
              ✕
            </button>
          </div>
        </div>
        <div v-if="isHost" class="participant-footer">
          <button class="btn-end" @click="handleEndMeeting">结束会议</button>
        </div>
      </div>
    </Transition>

    <!-- Control bar -->
    <div class="control-bar">
      <div class="ctrl-group">
        <!-- Layout toggle -->
        <button class="ctrl-btn" :title="meeting.layoutMode === 'grid' ? '演讲者视图' : '网格视图'" @click="meeting.toggleLayout()">
          <svg v-if="meeting.layoutMode === 'grid'" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/></svg>
          <svg v-else width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="4" y="4" width="16" height="10" rx="2"/><rect x="6" y="16" width="5" height="4" rx="1"/><rect x="13" y="16" width="5" height="4" rx="1"/></svg>
        </button>

        <!-- Mic group: 静音主按钮 + 设备下拉 -->
        <div class="device-group">
          <button
            class="ctrl-btn ctrl-btn-text"
            :class="{ 'ctrl-btn-off': !meeting.micEnabled }"
            :title="meeting.micEnabled ? '点击静音' : '点击取消静音'"
            @click="meeting.muteMic()"
          >
            <!-- 启用：麦克风 -->
            <svg v-if="meeting.micEnabled" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="2" width="6" height="11" rx="3"/><path d="M5 10a7 7 0 0 0 14 0"/><line x1="12" y1="19" x2="12" y2="22"/></svg>
            <!-- 禁用：麦克风（带斜杠） -->
            <svg v-else width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="1" y1="23" x2="23" y2="1"/><path d="M9 9v3a3 3 0 0 0 5.12 2.12M15 9.34V4a3 3 0 0 0-5.94-.6"/><path d="M17 16.95A7 7 0 0 1 5 12v-2m14 0v2a7 7 0 0 1-.11 1.23"/><line x1="12" y1="19" x2="12" y2="22"/></svg>
            <span class="btn-text">麦克风</span>
          </button>
          <button
            class="ctrl-btn ctrl-btn-dropdown"
            title="麦克风设备"
            @click.stop="micMenuOpen = !micMenuOpen; cameraMenuOpen = false"
          >
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="6 9 12 15 18 9"/></svg>
          </button>
          <div v-if="micMenuOpen" class="device-menu" @click.stop>
            <div class="device-menu-title">麦克风</div>
            <div
              v-for="d in meeting.micDevices"
              :key="d.deviceId"
              class="device-menu-item"
              :class="{ 'device-menu-item-active': d.deviceId === meeting.activeMicId }"
              @click="meeting.switchMicrophoneDevice(d.deviceId); micMenuOpen = false"
            >
              <span class="device-menu-check">{{ d.deviceId === meeting.activeMicId ? '✓' : '' }}</span>
              {{ d.label || `麦克风 ${d.deviceId.slice(0, 8)}` }}
            </div>
          </div>
        </div>

        <!-- Camera group: 摄像头开关主按钮 + 设备下拉 -->
        <div class="device-group">
          <button
            class="ctrl-btn ctrl-btn-text"
            :class="{ 'ctrl-btn-off': !meeting.cameraEnabled }"
            :title="meeting.cameraEnabled ? '点击关闭摄像头' : '点击开启摄像头'"
            @click="meeting.toggleCamera()"
          >
            <!-- 启用：摄像头 -->
            <svg v-if="meeting.cameraEnabled" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M23 7l-7 5 7 5V7z"/><rect x="1" y="5" width="15" height="14" rx="2"/></svg>
            <!-- 禁用：摄像头（带斜杠） -->
            <svg v-else width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="1" y1="23" x2="23" y2="1"/><path d="M23 7l-7 5 7 5V7z"/><rect x="1" y="5" width="15" height="14" rx="2"/></svg>
            <span class="btn-text">摄像头</span>
          </button>
          <button
            class="ctrl-btn ctrl-btn-dropdown"
            title="摄像头设备"
            @click.stop="cameraMenuOpen = !cameraMenuOpen; micMenuOpen = false"
          >
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="6 9 12 15 18 9"/></svg>
          </button>
          <div v-if="cameraMenuOpen" class="device-menu" @click.stop>
            <div class="device-menu-title">摄像头</div>
            <div
              v-for="d in meeting.cameraDevices"
              :key="d.deviceId"
              class="device-menu-item"
              :class="{ 'device-menu-item-active': d.deviceId === meeting.activeCameraId }"
              @click="meeting.switchCameraDevice(d.deviceId); cameraMenuOpen = false"
            >
              <span class="device-menu-check">{{ d.deviceId === meeting.activeCameraId ? '✓' : '' }}</span>
              {{ d.label || `摄像头 ${d.deviceId.slice(0, 8)}` }}
            </div>
          </div>
        </div>

        <!-- 分隔符：设备类按钮与会议功能类按钮之间 -->
        <div class="ctrl-divider"></div>

        <!-- Screen share -->
        <button class="ctrl-btn" :title="isSharing ? '停止共享' : '屏幕共享'" @click="handleScreenShare">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
        </button>

        <!-- Participants -->
        <button class="ctrl-btn" title="参会者" @click="showParticipants = !showParticipants; if (showParticipants) meeting.chatOpen = false">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
        </button>

        <!-- Chat -->
        <button class="ctrl-btn ctrl-chat" title="聊天" @click="meeting.toggleChat(); if (meeting.chatOpen) showParticipants = false">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
          <span v-if="meeting.chatUnread > 0" class="chat-badge">{{ meeting.chatUnread }}</span>
        </button>
      </div>

      <div class="ctrl-group ctrl-right">
        <!-- Hangup -->
        <button class="ctrl-btn ctrl-hangup" title="挂断" @click="handleHangUp">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor"><path d="M12 9c-1.6 0-3.15.25-4.6.72v3.1c0 .39-.23.74-.56.9-.98.49-1.87 1.12-2.66 1.85-.18.18-.43.28-.7.28-.28 0-.53-.11-.71-.29L.29 13.08a1.003 1.003 0 0 1 0-1.42 16.03 16.03 0 0 1 22.6 0c.39.39.39 1.03 0 1.42l-2.48 2.48c-.18.18-.43.29-.71.29-.27 0-.52-.11-.7-.28a11.25 11.25 0 0 0-2.67-1.85.996.996 0 0 1-.56-.9v-3.1C15.15 9.25 13.6 9 12 9z"/></svg>
        </button>
      </div>
    </div>
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
  overflow: hidden;
}

/* ---- Video area ---- */
.video-area {
  flex: 1;
  position: relative;
  overflow: hidden;
}

/* Grid layout */
.grid-container {
  display: grid;
  gap: 4px;
  height: 100%;
  padding: 4px;
}

.grid-video-wrapper {
  position: relative;
  background: #222;
  border-radius: 8px;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
}

.grid-video {
  width: 100%;
  height: 100%;
  object-fit: contain;
  background: #000;
}

.video-label {
  position: absolute;
  bottom: 8px;
  left: 8px;
  font-size: 12px;
  background: rgba(0,0,0,0.5);
  padding: 2px 8px;
  border-radius: 4px;
}

.video-placeholder {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  background: #2a2a2a;
}

.placeholder-avatar {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  background: #444;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  font-weight: 600;
}

.placeholder-name {
  font-size: 14px;
  color: #999;
}

/* Speaker layout */
.speaker-container {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.speaker-main {
  flex: 1;
  position: relative;
  background: #111;
  display: flex;
  align-items: center;
  justify-content: center;
}

.speaker-video {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.speaker-label {
  position: absolute;
  bottom: 12px;
  left: 12px;
  font-size: 14px;
  background: rgba(0,0,0,0.5);
  padding: 4px 12px;
  border-radius: 4px;
}

.speaker-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.speaker-thumbs {
  height: 120px;
  display: flex;
  gap: 8px;
  padding: 8px;
  background: #1a1a1a;
  overflow-x: auto;
}

.thumb-wrapper {
  width: 160px;
  height: 104px;
  flex-shrink: 0;
  background: #222;
  border-radius: 6px;
  overflow: hidden;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.thumb-video {
  width: 100%;
  height: 100%;
  object-fit: contain;
  background: #000;
}

.thumb-placeholder {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: #444;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  font-weight: 600;
}

/* Local PiP */
.local-pip {
  position: absolute;
  right: 16px;
  bottom: 16px;
  width: 180px;
  height: 120px;
  border-radius: 8px;
  overflow: hidden;
  border: 2px solid rgba(255,255,255,0.3);
  box-shadow: 0 4px 12px rgba(0,0,0,0.4);
  z-index: 10;
}

.local-video {
  width: 100%;
  height: 100%;
  object-fit: contain;
  background: #000;
}

/* ---- Controls ---- */
.control-bar {
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  background: #2a2a2a;
  border-top: 1px solid #333;
  z-index: 20;
}

.ctrl-group {
  display: flex;
  align-items: center;
  gap: 12px;
}

/* 设备类按钮与会议功能类按钮之间的垂直分隔线 */
.ctrl-divider {
  width: 1px;
  height: 24px;
  background: #444;
  margin: 0 4px;
}

.ctrl-right {
  gap: 8px;
}

.ctrl-btn {
  width: 40px;
  height: 40px;
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
  position: relative;
}

.ctrl-btn:hover {
  background: #555;
}

/* 按钮组：主按钮（图标+文本）+ 下拉按钮 */
.device-group {
  display: flex;
  align-items: center;
  position: relative;
}

.ctrl-btn-text {
  width: auto;
  min-width: 40px;
  height: 36px;
  padding: 0 12px;
  border-radius: 18px 0 0 18px;
  gap: 6px;
  font-size: 13px;
}

.ctrl-btn-text .btn-text {
  max-width: 110px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.ctrl-btn-dropdown {
  width: 24px;
  height: 36px;
  border-radius: 0 18px 18px 0;
  border-left: 1px solid rgba(0,0,0,0.25);
  background: #3a3a3a;
  font-size: 14px;
}

.ctrl-btn-dropdown:hover {
  background: #4a4a4a;
}

/* 关闭状态：图标+文本变红，提示用户已静音/已关闭摄像头 */
.ctrl-btn-off {
  background: #5a2a2a !important;
  color: #ff6b6b !important;
}

.ctrl-btn-off:hover {
  background: #6a3030 !important;
}

/* 设备菜单中的勾选标记 */
.device-menu-item {
  display: flex;
  align-items: center;
}

.device-menu-check {
  display: inline-block;
  width: 18px;
  color: #4caf50;
  font-weight: 700;
}

.device-menu-item-active {
  color: #fff;
  font-weight: 500;
}

.ctrl-hangup {
  background: #d32f2f;
  width: 48px;
  height: 48px;
}

.ctrl-hangup:hover {
  background: #b71c1c;
}

.ctrl-chat {
  position: relative;
}

.chat-badge {
  position: absolute;
  top: -4px;
  right: -4px;
  min-width: 18px;
  height: 18px;
  border-radius: 9px;
  background: #d32f2f;
  color: #fff;
  font-size: 11px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 4px;
}

/* ---- Device menu ---- */
.device-menu-wrapper {
  position: relative;
}

.device-menu {
  position: absolute;
  bottom: 100%;
  left: 50%;
  transform: translateX(-50%);
  background: #333;
  border-radius: 8px;
  padding: 8px 0;
  min-width: 200px;
  box-shadow: 0 -4px 12px rgba(0,0,0,0.4);
  margin-bottom: 8px;
  z-index: 100;
}

.device-menu-title {
  padding: 4px 12px;
  font-size: 11px;
  color: #999;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.device-menu-item {
  padding: 8px 12px;
  cursor: pointer;
  font-size: 13px;
  transition: background 0.15s;
}

.device-menu-item:hover {
  background: #444;
}

/* ---- Chat ---- */
.chat-panel {
  position: absolute;
  top: 0;
  right: 0;
  width: 280px;
  height: 100%;
  background: #242424;
  display: flex;
  flex-direction: column;
  z-index: 30;
  border-left: 1px solid #333;
}

.chat-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  font-size: 14px;
  font-weight: 600;
  border-bottom: 1px solid #333;
}

.chat-close {
  background: none;
  border: none;
  color: #999;
  cursor: pointer;
  font-size: 16px;
  padding: 4px;
}

.chat-close:hover {
  color: #fff;
}

.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 12px 16px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.chat-empty {
  text-align: center;
  color: #666;
  font-size: 13px;
  margin-top: 40px;
}

.chat-msg {
  padding: 8px 10px;
  background: #2e2e2e;
  border-radius: 8px;
  max-width: 100%;
}

.chat-msg-self {
  background: #1a3a5c;
}

.chat-msg-name {
  font-size: 11px;
  color: #888;
  margin-bottom: 2px;
}

.chat-msg-text {
  font-size: 13px;
  line-height: 1.4;
  word-break: break-word;
}

.chat-input-row {
  display: flex;
  padding: 12px 16px;
  gap: 8px;
  border-top: 1px solid #333;
}

.chat-input {
  flex: 1;
  padding: 8px 12px;
  border: 1px solid #444;
  border-radius: 6px;
  background: #2a2a2a;
  color: #fff;
  font-size: 13px;
  outline: none;
}

.chat-input:focus {
  border-color: #1976d2;
}

.chat-send {
  padding: 8px 14px;
  border: none;
  border-radius: 6px;
  background: #1976d2;
  color: #fff;
  font-size: 13px;
  cursor: pointer;
  transition: background 0.2s;
}

.chat-send:hover {
  background: #1565c0;
}

/* Chat slide transition */
.slide-enter-active, .slide-leave-active {
  transition: transform 0.2s ease;
}
.slide-enter-from, .slide-leave-to {
  transform: translateX(100%);
}

/* Participant panel */
.participant-panel {
  position: absolute;
  top: 0;
  right: 0;
  width: 280px;
  height: 100%;
  background: #242424;
  display: flex;
  flex-direction: column;
  z-index: 30;
  border-left: 1px solid #333;
}
.participant-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  font-size: 14px;
  font-weight: 600;
  border-bottom: 1px solid #333;
}
.participant-close {
  background: none;
  border: none;
  color: #999;
  cursor: pointer;
  font-size: 16px;
  padding: 4px;
}
.participant-list {
  flex: 1;
  overflow-y: auto;
  padding: 8px 0;
}
.participant-item {
  display: flex;
  align-items: center;
  padding: 8px 16px;
  gap: 8px;
}
.participant-item:hover {
  background: #2e2e2e;
}
.participant-avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #444;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 600;
  flex-shrink: 0;
}
.participant-name {
  flex: 1;
  font-size: 13px;
}
.participant-role {
  font-size: 10px;
  color: #1976d2;
  background: rgba(25,118,210,0.15);
  padding: 2px 6px;
  border-radius: 4px;
}
.participant-kick {
  background: none;
  border: none;
  color: #d32f2f;
  cursor: pointer;
  font-size: 14px;
  padding: 4px;
  opacity: 0;
  transition: opacity 0.15s;
}
.participant-item:hover .participant-kick {
  opacity: 1;
}
.participant-footer {
  padding: 12px 16px;
  border-top: 1px solid #333;
}
.btn-end {
  width: 100%;
  padding: 8px;
  border: none;
  border-radius: 6px;
  background: #d32f2f;
  color: #fff;
  font-size: 13px;
  cursor: pointer;
}
.btn-end:hover {
  background: #b71c1c;
}

/* Responsive: chat-active or participant-active reduces video area */
.meeting-room.chat-active .video-area {
  margin-right: 280px;
}
.meeting-room.chat-active .control-bar {
  padding-right: 296px;
}
.meeting-room:has(.participant-panel) .video-area {
  margin-right: 280px;
}
.meeting-room:has(.participant-panel) .control-bar {
  padding-right: 296px;
}
</style>
