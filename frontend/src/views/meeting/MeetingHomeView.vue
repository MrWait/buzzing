<script setup lang="ts">
import { onMounted, ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useMeetingStore } from '@/stores/meeting'
import ScheduleMeetingDialog from './components/ScheduleMeetingDialog.vue'
import JoinMeetingDialog from './components/JoinMeetingDialog.vue'

const router = useRouter()
const meeting = useMeetingStore()
const currentTab = ref(0)
const showCreateDialog = ref(false)
const showJoinDialog = ref(false)
const isSchedule = ref(false)

onMounted(() => {
  meeting.loadMeetings()
})

const tabs = ['进行中', '已预定', '历史记录']

const currentList = computed(() => {
  switch (currentTab.value) {
    case 0: return meeting.activeMeetings
    case 1: return meeting.scheduledMeetings
    case 2: return meeting.historyMeetings
    default: return []
  }
})

function formatTime(ms: number): string {
  if (!ms) return ''
  const d = new Date(ms)
  return `${String(d.getMonth() + 1).padStart(2, '0')}/${String(d.getDate()).padStart(2, '0')} ${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`
}

async function handleJoin(roomId: string) {
  const ok = await meeting.joinMeetingApi(roomId)
  if (ok) {
    router.push({ name: 'MeetingRoom', params: { roomId } })
  }
}

function openCreate() {
  isSchedule.value = false
  showCreateDialog.value = true
}

function openSchedule() {
  isSchedule.value = true
  showCreateDialog.value = true
}

function openJoin() {
  showJoinDialog.value = true
}
</script>

<template>
  <div class="meeting-home">
    <div class="home-header">
      <div class="header-left">
        <h2>视频会议</h2>
      </div>
      <div class="header-actions">
        <button class="btn btn-primary" @click="openCreate">创建会议</button>
        <button class="btn btn-outline" @click="openJoin">加入会议</button>
        <button class="btn btn-outline" @click="openSchedule">预定会议</button>
      </div>
    </div>

    <div class="home-tabs">
      <button
        v-for="(tab, i) in tabs"
        :key="i"
        class="tab-btn"
        :class="{ active: currentTab === i }"
        @click="currentTab = i"
      >
        {{ tab }}
        <span v-if="i === 0 && meeting.activeMeetings.length > 0" class="tab-count">{{ meeting.activeMeetings.length }}</span>
      </button>
    </div>

    <div class="home-content">
      <div v-if="meeting.listLoading" class="loading">加载中...</div>
      <div v-else-if="currentList.length === 0" class="empty">
        <div class="empty-icon">📹</div>
        <div class="empty-text">暂无{{ tabs[currentTab] }}会议</div>
      </div>
      <div v-else class="meeting-list">
        <div
          v-for="m in currentList"
          :key="m.roomId"
          class="meeting-card"
        >
          <div class="card-body">
            <div class="card-title">{{ m.title || '未命名会议' }}</div>
            <div class="card-info">会议号: {{ m.roomId }}</div>
            <div v-if="m.createdAt" class="card-info">{{ formatTime(m.createdAt) }}</div>
            <div v-if="m.members.length > 0" class="card-info">参与者: {{ m.members.length }} 人</div>
          </div>
          <div class="card-actions">
            <button
              v-if="currentTab === 0"
              class="btn btn-primary btn-sm"
              @click="handleJoin(m.roomId)"
            >
              加入
            </button>
          </div>
        </div>
      </div>
    </div>

    <ScheduleMeetingDialog
      v-if="showCreateDialog"
      :is-schedule="isSchedule"
      @confirm="(title: string, _password?: string, scheduledAt?: number) => {
        if (isSchedule) {
          meeting.scheduleMeetingApi(title, scheduledAt || Date.now(), _password)
        } else {
          meeting.createMeetingApi(title, _password)
        }
        showCreateDialog = false
      }"
      @close="showCreateDialog = false"
    />
    <JoinMeetingDialog
      v-if="showJoinDialog"
      @confirm="async (roomId: string, _password?: string) => {
        await handleJoin(roomId)
        showJoinDialog = false
      }"
      @close="showJoinDialog = false"
    />
  </div>
</template>

<style scoped>
.meeting-home {
  padding: 24px;
  max-width: 800px;
  margin: 0 auto;
}
.home-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 24px;
}
.header-left h2 {
  margin: 0;
  font-size: 22px;
  font-weight: 600;
}
.header-actions {
  display: flex;
  gap: 8px;
}
.btn {
  padding: 8px 16px;
  border-radius: 6px;
  font-size: 13px;
  cursor: pointer;
  border: 1px solid transparent;
  transition: all 0.2s;
}
.btn-primary {
  background: #1976d2;
  color: #fff;
  border-color: #1976d2;
}
.btn-primary:hover {
  background: #1565c0;
}
.btn-outline {
  background: #fff;
  color: #333;
  border-color: #ccc;
}
.btn-outline:hover {
  border-color: #1976d2;
  color: #1976d2;
}
.btn-sm {
  padding: 6px 14px;
  font-size: 12px;
}
.home-tabs {
  display: flex;
  gap: 4px;
  border-bottom: 1px solid #e0e0e0;
  margin-bottom: 16px;
}
.tab-btn {
  padding: 10px 20px;
  font-size: 14px;
  background: none;
  border: none;
  border-bottom: 2px solid transparent;
  cursor: pointer;
  color: #666;
  position: relative;
}
.tab-btn.active {
  color: #1976d2;
  border-bottom-color: #1976d2;
  font-weight: 500;
}
.tab-count {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 18px;
  height: 18px;
  border-radius: 9px;
  background: #1976d2;
  color: #fff;
  font-size: 11px;
  margin-left: 6px;
  padding: 0 5px;
}
.home-content {
  min-height: 200px;
}
.loading {
  text-align: center;
  padding: 60px 0;
  color: #999;
  font-size: 14px;
}
.empty {
  text-align: center;
  padding: 60px 0;
  color: #999;
}
.empty-icon {
  font-size: 48px;
  margin-bottom: 12px;
}
.empty-text {
  font-size: 14px;
}
.meeting-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.meeting-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px;
  border: 1px solid #e8e8e8;
  border-radius: 8px;
  transition: border-color 0.2s;
}
.meeting-card:hover {
  border-color: #1976d2;
}
.card-body {
  flex: 1;
}
.card-title {
  font-size: 15px;
  font-weight: 500;
  margin-bottom: 4px;
}
.card-info {
  font-size: 12px;
  color: #999;
  margin-top: 2px;
}
.card-actions {
  margin-left: 16px;
}
</style>