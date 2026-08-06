<template>
  <div class="jr-panel">
    <div v-if="loading" class="jr-state">
      <div class="jr-spinner"></div>
      <span>加载中...</span>
    </div>
    <div v-else-if="requests.length === 0" class="jr-state jr-empty">
      暂无待处理的申请
    </div>
    <div v-else class="jr-list">
      <div v-for="(req, i) in requests" :key="req.id" class="jr-item">
        <div class="jr-avatar" :style="{ background: avatarColor(req.user_name || String(req.user_id)) }">
          {{ (req.user_name || '用').charAt(0) }}
        </div>
        <div class="jr-info">
          <div class="jr-name">{{ req.user_name || `用户 ${req.user_id}` }}</div>
          <div v-if="req.user_name" class="jr-id">ID: {{ req.user_id }}</div>
        </div>
        <div class="jr-actions">
          <button class="jr-btn jr-approve" @click="handleApprove(req, i)">通过</button>
          <button class="jr-btn jr-reject" @click="handleReject(req, i)">拒绝</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useImStore } from '@/stores/im'

const props = defineProps<{ chatId: string }>()

const im = useImStore()

const loading = ref(true)
const requests = ref<any[]>([])

onMounted(async () => {
  await load()
})

async function load() {
  loading.value = true
  const resp = await im.listJoinRequests(props.chatId, 0)
  requests.value = resp?.requests || []
  loading.value = false
}

async function handleApprove(req: any, i: number) {
  await im.approveJoinRequest(req.id)
  requests.value = requests.value.filter((r) => r.id !== req.id)
}

async function handleReject(req: any, i: number) {
  await im.rejectJoinRequest(req.id)
  requests.value = requests.value.filter((r) => r.id !== req.id)
}

function avatarColor(name: string): string {
  const colors = ['#4a6cf7', '#f56c6c', '#67c23a', '#e6a23c', '#909399', '#409eff']
  let hash = 0
  for (let i = 0; i < name.length; i++) hash = name.charCodeAt(i) + ((hash << 5) - hash)
  return colors[Math.abs(hash) % colors.length]
}
</script>

<style scoped>
.jr-panel { flex: 1; overflow-y: auto; background: #fff; }
.jr-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 60px 16px;
  color: #8f959e;
  font-size: 13px;
}
.jr-empty { color: #999; }
.jr-spinner {
  width: 22px;
  height: 22px;
  border: 2px solid #e0e0e0;
  border-top-color: #2b5ced;
  border-radius: 50%;
  animation: jr-rotate 0.8s linear infinite;
}
@keyframes jr-rotate { to { transform: rotate(360deg); } }
.jr-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px 16px;
  border-bottom: 1px solid #f0f0f0;
}
.jr-avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 13px;
  font-weight: 600;
  flex-shrink: 0;
}
.jr-info { flex: 1; min-width: 0; }
.jr-name { font-size: 14px; color: #333; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.jr-id { font-size: 11px; color: #999; margin-top: 2px; }
.jr-actions { display: flex; gap: 6px; flex-shrink: 0; }
.jr-btn {
  border: none;
  border-radius: 6px;
  padding: 5px 14px;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.15s;
}
.jr-approve { background: #2b5ced; color: #fff; }
.jr-approve:hover { background: #1a4ed8; }
.jr-reject { background: #fff; color: #f44336; border: 1px solid #f44336; }
.jr-reject:hover { background: #fef0ef; }
</style>