<template>
  <div class="share-view">
    <div v-if="loading" class="state">加载中…</div>

    <div v-else-if="error" class="state error">
      <div class="icon">×</div>
      <div class="title">链接无效</div>
      <div class="desc">{{ error }}</div>
    </div>

    <div v-else-if="requirePassword" class="password-panel">
      <h2>需要密码</h2>
      <p class="desc">该文档已设置访问密码</p>
      <input
        v-model="password"
        type="password"
        placeholder="请输入密码"
        @keydown.enter="verify"
      />
      <div v-if="pwdError" class="err">{{ pwdError }}</div>
      <button class="btn-primary" :disabled="verifying || !password" @click="verify">
        {{ verifying ? '校验中…' : '进入文档' }}
      </button>
    </div>

    <ShareReader
      v-else-if="docId && shareToken"
      :doc-id="docId"
      :doc-title="docTitle"
      :doc-icon="docIcon"
      :share-token="shareToken"
    />
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'
import { sharesApi } from '@/services/office/shares'
import ShareReader from './components/ShareReader.vue'

const route = useRoute()
const token = route.params.token as string

const loading = ref(true)
const error = ref<string | null>(null)
const requirePassword = ref(false)
const password = ref('')
const pwdError = ref<string | null>(null)
const verifying = ref(false)

const docId = ref<string>('')
const docTitle = ref<string>('')
const docIcon = ref<string | null>(null)
const shareToken = ref<string | null>(null)

onMounted(async () => {
  await resolve()
})

async function resolve() {
  loading.value = true
  error.value = null
  try {
    const data = await sharesApi.resolve(token)
    handleResolved(data)
  } catch (e: unknown) {
    error.value = extractErr(e)
  } finally {
    loading.value = false
  }
}

async function verify() {
  if (!password.value) return
  verifying.value = true
  pwdError.value = null
  try {
    const data = await sharesApi.verify(token, password.value)
    handleResolved(data)
  } catch (e: unknown) {
    pwdError.value = extractErr(e) || '密码错误'
  } finally {
    verifying.value = false
  }
}

function handleResolved(data: {
  doc_id: string
  title: string
  icon: string | null
  require_password: boolean
  token: string | null
}) {
  if (data.require_password && !data.token) {
    requirePassword.value = true
    return
  }
  requirePassword.value = false
  docId.value = data.doc_id
  docTitle.value = data.title
  docIcon.value = data.icon
  shareToken.value = data.token
}

function extractErr(e: unknown): string {
  if (typeof e === 'object' && e !== null) {
    const err = e as { response?: { status?: number }; message?: string }
    if (err.response?.status === 404) return '链接已失效、已撤销或超出访问次数'
    if (err.response?.status === 401) return '密码错误'
    return err.message ?? String(e)
  }
  return String(e)
}
</script>

<style scoped>
.share-view {
  min-height: 100vh;
  background: #f5f7fa;
}
.state {
  padding: 80px 24px;
  text-align: center;
  color: #666;
}
.state.error .icon {
  font-size: 48px;
  color: #d32f2f;
  margin-bottom: 12px;
}
.state .title {
  font-size: 18px;
  color: #333;
  margin-bottom: 6px;
}
.state .desc {
  font-size: 13px;
  color: #999;
}
.password-panel {
  max-width: 360px;
  margin: 120px auto;
  background: #fff;
  padding: 32px;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
  text-align: center;
}
.password-panel h2 {
  margin: 0 0 8px;
  font-size: 18px;
}
.password-panel .desc {
  font-size: 13px;
  color: #888;
  margin-bottom: 16px;
}
.password-panel input {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #d0d0d0;
  border-radius: 4px;
  font-size: 14px;
  outline: none;
  margin-bottom: 12px;
  box-sizing: border-box;
}
.password-panel input:focus {
  border-color: #1565c0;
}
.password-panel .err {
  color: #d32f2f;
  font-size: 12px;
  margin-bottom: 8px;
}
.btn-primary {
  width: 100%;
  padding: 10px 16px;
  background: #1565c0;
  color: #fff;
  border: none;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
}
.btn-primary:hover:not(:disabled) {
  background: #0d47a1;
}
.btn-primary:disabled {
  background: #90caf9;
  cursor: not-allowed;
}
</style>
