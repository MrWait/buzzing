<template>
  <div class="hub">
    <h2 class="hub-title">应用中心</h2>
    <div class="module-grid">
      <div class="module-card" @click="goOffice">
        <div class="card-icon" style="background:#e3f2fd; color:#1565c0">📄</div>
        <div class="card-name">办公文档</div>
        <div class="card-desc">在线协作文档</div>
      </div>
      <div class="module-card" @click="goCalendar">
        <div class="card-icon" style="background:#fff3e0; color:#e65100">📅</div>
        <div class="card-name">日历</div>
        <div class="card-desc">日程管理</div>
      </div>
      <div class="module-card" @click="goTodo">
        <div class="card-icon" style="background:#e8f5e9; color:#2e7d32">✓</div>
        <div class="card-name">任务</div>
        <div class="card-desc">任务管理</div>
      </div>
      <div class="module-card" @click="goIm">
        <div class="card-icon" style="background:#f3e5f5; color:#7b1fa2">💬</div>
        <div class="card-name">即时通讯</div>
        <div class="card-desc">聊天与消息推送</div>
      </div>
      <div class="module-card" @click="goOpenapp">
        <div class="card-icon" style="background:#e0f7fa; color:#00695c">🔌</div>
        <div class="card-name">开放平台</div>
        <div class="card-desc">应用管理与集成</div>
      </div>
      <div class="module-card" @click="goMeeting">
        <div class="card-icon" style="background:#fce4ec; color:#c62828">📹</div>
        <div class="card-name">视频会议</div>
        <div class="card-desc">音视频通话</div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'

const router = useRouter()

function goOffice() {
  router.push({ name: 'OfficeHome' })
}

function goCalendar() {
  // TODO: navigate to calendar module when available
}

function goTodo() {
  // TODO: navigate to todo module when available
}

function goMeeting() {
  router.push({ name: 'MeetingHome' })
}

function goIm() {
  router.push({ name: 'ImFeed' })
}

function goOpenapp() {
  router.push({ name: 'AppList' })
}
</script>

<style scoped>
.hub {
  max-width: 640px;
  margin: 60px auto;
  padding: 0 16px;
}
.hub-title {
  text-align: center;
  margin-bottom: 32px;
  font-weight: 600;
}
.module-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 16px;
}
.module-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 24px 16px;
  border: 1px solid #e0e0e0;
  border-radius: 12px;
  cursor: pointer;
  transition: border-color 0.2s, box-shadow 0.2s;
}
.module-card:hover {
  border-color: #1a1a2e;
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
}
.card-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  margin-bottom: 12px;
}
.card-name {
  font-size: 15px;
  font-weight: 500;
  color: #333;
}
.card-desc {
  font-size: 12px;
  color: #999;
  margin-top: 4px;
}
</style>
