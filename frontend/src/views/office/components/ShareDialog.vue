<template>
  <div v-if="open" class="share-panel" @mousedown.stop @click.stop>
    <div class="sp-arrow"></div>
    <h3 class="sp-title">共享链接</h3>

    <section class="create-row">
      <div class="row-item">
        <label>权限</label>
        <select v-model.number="newRole">
          <option :value="ROLE_VIEWER">阅读者</option>
          <option :value="ROLE_COMMENTER">评论者</option>
        </select>
      </div>
      <div class="row-item">
        <label>密码 (可选)</label>
        <input v-model="newPassword" type="text" placeholder="留空表示无密码" />
      </div>
      <div class="row-item">
        <label>过期时间 (可选)</label>
        <input v-model="newExpires" type="datetime-local" />
      </div>
      <button class="btn-primary" :disabled="submitting" @click="createShare">
        {{ submitting ? '创建中…' : '创建链接' }}
      </button>
    </section>

    <div v-if="errMsg" class="err">{{ errMsg }}</div>

    <div v-if="!loading" class="share-list">
      <div v-if="shares.length === 0" class="empty">暂无共享链接</div>
      <div v-for="s in shares" :key="s.id" class="share-row">
        <div class="share-meta">
          <div class="share-url">
            <span class="tag">{{ s.role_label }}</span>
            <input readonly :value="fullUrl(s.url)" @click="selectAll($event)" />
            <button class="btn-copy" @click="copy(fullUrl(s.url))">复制</button>
          </div>
          <div class="share-extra">
            <span v-if="s.has_password">密码保护</span>
            <span v-if="s.expires_at">过期: {{ formatDate(s.expires_at) }}</span>
            <span>访问 {{ s.visit_count }}<span v-if="s.max_visits"> / {{ s.max_visits }}</span></span>
            <span v-if="s.revoked" class="revoked">已撤销</span>
          </div>
        </div>
        <button v-if="!s.revoked" class="btn-revoke" @click="revokeShare(s.id)">撤销</button>
      </div>
    </div>
    <div v-else class="loading">加载中…</div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, watch } from 'vue'
import { sharesApi, type ShareInfoDto } from '@/services/office/shares'
import { ROLE_COMMENTER, ROLE_VIEWER } from '@/composables/usePermission'

const props = defineProps<{ open: boolean; docId: string }>()

const shares = ref<ShareInfoDto[]>([])
const loading = ref(false)
const submitting = ref(false)
const errMsg = ref<string | null>(null)
const newRole = ref<number>(ROLE_VIEWER)
const newPassword = ref('')
const newExpires = ref('')

watch(
  () => [props.open, props.docId],
  ([open]) => {
    if (open) refresh()
  },
)
onMounted(() => {
  if (props.open) refresh()
})

async function refresh() {
  loading.value = true
  errMsg.value = null
  try {
    shares.value = await sharesApi.list(props.docId)
  } catch (e) {
    errMsg.value = e instanceof Error ? e.message : String(e)
  } finally {
    loading.value = false
  }
}

async function createShare() {
  submitting.value = true
  errMsg.value = null
  try {
    const params: {
      role: number
      password?: string
      expires_at?: string
    } = { role: newRole.value }
    if (newPassword.value) params.password = newPassword.value
    if (newExpires.value) {
      // datetime-local 格式转 RFC3339
      params.expires_at = new Date(newExpires.value).toISOString()
    }
    await sharesApi.create(props.docId, params)
    newPassword.value = ''
    newExpires.value = ''
    await refresh()
  } catch (e) {
    errMsg.value = e instanceof Error ? e.message : String(e)
  } finally {
    submitting.value = false
  }
}

async function revokeShare(id: string) {
  if (!confirm('确定撤销该链接？撤销后无法恢复。')) return
  try {
    await sharesApi.revoke(id)
    await refresh()
  } catch (e) {
    errMsg.value = e instanceof Error ? e.message : String(e)
  }
}

function fullUrl(path: string) {
  return `${window.location.origin}${path}`
}

function selectAll(e: Event) {
  ;(e.target as HTMLInputElement).select()
}

async function copy(text: string) {
  try {
    await navigator.clipboard.writeText(text)
  } catch {
    // ignore
  }
}

function formatDate(iso: string) {
  try {
    return new Date(iso).toLocaleString('zh-CN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
    })
  } catch {
    return iso
  }
}

</script>

<style scoped>
.share-panel {
  position: absolute;
  top: calc(100% + 8px);
  right: 0;
  z-index: 200;
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 16px;
  min-width: 560px;
  max-width: 640px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
}
.sp-arrow {
  position: absolute;
  top: -6px;
  right: 20px;
  width: 10px;
  height: 10px;
  background: #fff;
  border-left: 1px solid #e0e0e0;
  border-top: 1px solid #e0e0e0;
  transform: rotate(45deg);
}
.sp-title {
  margin: 0 0 16px;
  font-size: 16px;
  font-weight: 600;
}
.create-row {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr auto;
  gap: 10px;
  align-items: end;
  padding: 12px;
  background: #fafafa;
  border-radius: 6px;
  margin-bottom: 12px;
}
.row-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.row-item label {
  font-size: 12px;
  color: #666;
}
.row-item input,
.row-item select {
  padding: 6px 8px;
  border: 1px solid #d0d0d0;
  border-radius: 4px;
  font-size: 13px;
  background: #fff;
  outline: none;
}
.row-item input:focus,
.row-item select:focus {
  border-color: #1565c0;
}
.err {
  color: #d32f2f;
  font-size: 12px;
  margin-bottom: 8px;
}
.loading,
.empty {
  padding: 16px;
  text-align: center;
  color: #888;
  font-size: 13px;
}
.share-list {
  max-height: 320px;
  overflow-y: auto;
  margin-bottom: 12px;
}
.share-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 0;
  border-bottom: 1px solid #f0f0f0;
  gap: 12px;
}
.share-meta {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-width: 0;
}
.share-url {
  display: flex;
  align-items: center;
  gap: 6px;
}
.share-url input {
  flex: 1;
  padding: 4px 8px;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
  font-size: 12px;
  background: #fafafa;
  outline: none;
  min-width: 0;
}
.tag {
  padding: 2px 6px;
  background: #e3f2fd;
  color: #1565c0;
  border-radius: 3px;
  font-size: 11px;
  white-space: nowrap;
}
.share-extra {
  display: flex;
  gap: 12px;
  font-size: 11px;
  color: #888;
}
.revoked {
  color: #d32f2f;
}
.btn-copy,
.btn-revoke,
.btn-primary,
.btn-cancel {
  padding: 6px 12px;
  border: none;
  border-radius: 4px;
  font-size: 12px;
  cursor: pointer;
  transition: background 0.15s;
}
.btn-copy {
  background: #f0f0f0;
  color: #333;
}
.btn-copy:hover {
  background: #e0e0e0;
}
.btn-revoke {
  background: transparent;
  color: #d32f2f;
}
.btn-revoke:hover {
  background: #ffebee;
}
.btn-primary {
  background: #1565c0;
  color: #fff;
  font-size: 13px;
  padding: 8px 14px;
}
.btn-primary:hover:not(:disabled) {
  background: #0d47a1;
}
.btn-primary:disabled {
  background: #90caf9;
  cursor: not-allowed;
}
.btn-cancel {
  background: #f0f0f0;
  color: #333;
  font-size: 13px;
}
.btn-cancel:hover {
  background: #e0e0e0;
}
</style>
