<template>
  <div class="bot-config">
    <header class="page-header">
      <router-link :to="{ name: 'AppList' }" class="back-link">&larr; 返回</router-link>
      <h1>Bot 配置</h1>
    </header>

    <div v-if="loading" class="loading">加载中...</div>

    <div v-else class="config-card">
      <div class="info-row">
        <span class="label">Webhook URL</span>
        <code>{{ store.botConfig?.webhook_url || '-' }}</code>
      </div>
      <div class="info-row">
        <span class="label">Token</span>
        <code class="secret">{{ maskedToken }}</code>
      </div>
      <div class="info-row">
        <span class="label">自动回复</span>
        <label class="switch">
          <input type="checkbox" v-model="autoReply" @change="onToggleAutoReply" />
          <span class="slider"></span>
        </label>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import { useOpenAppStore } from '@/stores/openapp'

const route = useRoute()
const store = useOpenAppStore()
const appId = computed(() => route.params.id as string)
const loading = ref(true)
const autoReply = ref(false)

const maskedToken = computed(() => {
  const t = store.botConfig?.token || ''
  if (t.length <= 8) return t
  return t.slice(0, 4) + '****' + t.slice(-4)
})

async function onToggleAutoReply() {
  await store.updateBotConfig(appId.value, { auto_reply: autoReply.value })
}

onMounted(async () => {
  await store.loadBotConfig(appId.value)
  if (store.botConfig?.auto_reply != null) {
    autoReply.value = store.botConfig.auto_reply
  }
  loading.value = false
})
</script>

<style scoped>
.bot-config {
  padding: 24px;
  max-width: 600px;
  margin: 0 auto;
}
.page-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 24px;
}
.page-header h1 {
  font-size: 24px;
  font-weight: 600;
  margin: 0;
}
.back-link {
  color: #1a73e8;
  text-decoration: none;
  font-size: 14px;
}
.loading {
  text-align: center;
  color: #888;
  padding: 60px;
}
.config-card {
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 24px;
}
.info-row {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 20px;
}
.info-row .label {
  width: 120px;
  flex-shrink: 0;
  font-size: 14px;
  color: #666;
}
.info-row code {
  padding: 8px 12px;
  background: #f5f5f5;
  border-radius: 4px;
  font-size: 13px;
  word-break: break-all;
  flex: 1;
}
.secret {
  font-family: 'Courier New', monospace;
  letter-spacing: 1px;
}
.switch {
  position: relative;
  display: inline-block;
  width: 40px;
  height: 22px;
}
.switch input {
  opacity: 0;
  width: 0;
  height: 0;
}
.slider {
  position: absolute;
  cursor: pointer;
  inset: 0;
  background: #ccc;
  border-radius: 22px;
  transition: 0.3s;
}
.slider::before {
  content: '';
  position: absolute;
  height: 16px;
  width: 16px;
  left: 3px;
  bottom: 3px;
  background: #fff;
  border-radius: 50%;
  transition: 0.3s;
}
.switch input:checked + .slider {
  background: #1a73e8;
}
.switch input:checked + .slider::before {
  transform: translateX(18px);
}
</style>
