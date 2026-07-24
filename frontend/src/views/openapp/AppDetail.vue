<template>
  <div class="app-detail-layout">
    <aside class="app-sidebar">
      <router-link :to="{ name: 'AppList' }" class="back-link">&larr; 返回</router-link>
      <div class="app-summary">
        <div class="app-summary-name">{{ store.currentApp?.name || '应用' }}</div>
        <div class="app-summary-id">{{ store.currentApp?.app_id || '' }}</div>
      </div>
      <nav class="sidebar-nav">
        <button
          v-for="tab in tabs"
          :key="tab.key"
          :class="['sidebar-item', { active: activeTab === tab.key }]"
          @click="activeTab = tab.key"
        >
          <span class="sidebar-icon">{{ tab.icon }}</span>
          <span>{{ tab.label }}</span>
        </button>
      </nav>
    </aside>
    <main class="app-content">
      <header class="page-header">
        <h1>{{ store.currentApp?.name || '应用详情' }}</h1>
      </header>

      <div v-if="loading" class="loading">加载中...</div>
      <template v-else-if="store.currentApp">
          <!-- Basic Info -->
          <section v-if="activeTab === 'basic'">
            <div class="info-card">
              <h3>基本信息</h3>
              <div class="info-row">
                <span class="label">名称</span>
                <input v-model="editForm.name" class="edit-input" />
              </div>
              <div class="info-row">
                <span class="label">描述</span>
                <textarea v-model="editForm.description" class="edit-input" rows="2"></textarea>
              </div>
              <div class="info-row">
                <span class="label">回调 URL</span>
                <input v-model="editForm.callback_url" class="edit-input" />
              </div>
              <div class="info-row">
                <span class="label">状态</span>
                <span>{{ store.currentApp.status === 'active' ? '已启用' : store.currentApp.status }}</span>
              </div>
              <div class="info-row copy-row">
                <span class="label">App ID</span>
                <code>{{ store.currentApp.app_id }}</code>
                <button class="copy-btn" @click="copy(store.currentApp!.app_id)">复制</button>
              </div>
              <div class="info-row copy-row">
                <span class="label">App Secret</span>
                <code class="secret">{{ maskedSecret }}</code>
                <button class="copy-btn" @click="copy(store.currentApp!.app_secret)">复制</button>
              </div>
              <div class="form-actions">
                <button class="btn-primary" @click="onSave">保存修改</button>
                <button class="btn-outline" @click="onRegenerateSecret">重新生成 Secret</button>
                <button class="btn-danger" @click="onDelete">删除应用</button>
              </div>
            </div>
          </section>

          <!-- OAuth -->
          <section v-if="activeTab === 'oauth'">
            <div class="info-card">
              <h3>重定向 URI</h3>
              <div class="add-row">
                <input v-model="newUri" placeholder="https://example.com/callback" class="edit-input" />
                <button class="btn-primary" @click="addUri">添加</button>
              </div>
              <ul class="uri-list">
                <li v-for="uri in store.redirectUris" :key="uri.id">
                  <code>{{ uri.uri }}</code>
                  <button class="btn-icon" @click="removeUri(uri.id)">删除</button>
                </li>
                <li v-if="store.redirectUris.length === 0" class="empty-hint">暂无重定向 URI</li>
              </ul>
            </div>
          </section>

          <!-- Webhooks -->
          <section v-if="activeTab === 'webhook'">
            <div class="info-card">
              <h3>出站 Webhook</h3>
              <button class="btn-primary" @click="showWebhookDialog = true">添加 Webhook</button>
              <table class="data-table" v-if="store.webhooks.length > 0">
                <thead>
                  <tr>
                    <th>名称</th>
                    <th>URL</th>
                    <th>状态</th>
                    <th>操作</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="wh in store.webhooks" :key="wh.id">
                    <td>{{ wh.name }}</td>
                    <td class="url-cell">{{ wh.url }}</td>
                    <td>{{ wh.enabled ? '启用' : '禁用' }}</td>
                    <td>
                      <button class="btn-sm" @click="editWebhook(wh)">编辑</button>
                      <button class="btn-sm btn-danger" @click="removeWebhook(wh.id)">删除</button>
                    </td>
                  </tr>
                </tbody>
              </table>
              <p v-else class="empty-hint">暂无 Webhook</p>
            </div>
          </section>

          <!-- Stats -->
          <section v-if="activeTab === 'stats'">
            <div class="info-card">
              <h3>调用统计</h3>
              <div v-if="store.stats" class="stats-grid">
                <div class="stat-item">
                  <span class="stat-value">{{ store.stats.total_calls || 0 }}</span>
                  <span class="stat-label">总调用</span>
                </div>
                <div class="stat-item">
                  <span class="stat-value">{{ store.stats.error_count || 0 }}</span>
                  <span class="stat-label">错误数</span>
                </div>
              </div>
              <p v-else class="empty-hint">暂无统计数据</p>
            </div>
          </section>

          <!-- Versions -->
          <section v-if="activeTab === 'version'">
            <div class="info-card">
              <h3>版本管理</h3>
              <div class="add-row">
                <input v-model="newVersion.version" placeholder="版本号 (如 1.0.0)" class="edit-input" style="width: 200px" />
                <input v-model="newVersion.description" placeholder="版本描述" class="edit-input" />
                <button class="btn-primary" @click="submitVersion">提交审核</button>
              </div>
              <table class="data-table" v-if="store.versions.length > 0">
                <thead>
                  <tr>
                    <th>版本</th>
                    <th>描述</th>
                    <th>状态</th>
                    <th>提交时间</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="v in store.versions" :key="v.id">
                    <td>{{ v.version }}</td>
                    <td>{{ v.description || '-' }}</td>
                    <td>{{ v.status }}</td>
                    <td>{{ v.created_at }}</td>
                  </tr>
                </tbody>
              </table>
              <p v-else class="empty-hint">暂无版本</p>
            </div>
          </section>
    </template>
        </main>
  </div>

  <!-- Webhook Dialog -->
  <Teleport to="body">
    <div v-if="showWebhookDialog" class="modal-overlay" @click.self="showWebhookDialog = false">
      <div class="modal-content">
        <h3>{{ editingWebhook ? '编辑 Webhook' : '添加 Webhook' }}</h3>
        <div class="form-group">
          <label>名称</label>
          <input v-model="webhookForm.name" class="edit-input" />
        </div>
        <div class="form-group">
          <label>URL</label>
          <input v-model="webhookForm.url" class="edit-input" />
        </div>
        <div class="form-actions">
          <button class="btn-cancel" @click="showWebhookDialog = false">取消</button>
          <button class="btn-primary" @click="saveWebhook">保存</button>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { onMounted, ref, reactive, computed } from 'vue'
import { useRoute } from 'vue-router'
import { useOpenAppStore } from '@/stores/openapp'
import type { OutgoingWebhook } from '@/services/openapp'

const route = useRoute()
const store = useOpenAppStore()
const appId = computed(() => route.params.id as string)

const loading = ref(true)
const activeTab = ref('basic')

const tabs = [
  { key: 'basic', label: '基本信息', icon: '⚙' },
  { key: 'oauth', label: 'OAuth', icon: '🔐' },
  { key: 'webhook', label: 'Webhook', icon: '🔗' },
  { key: 'stats', label: '统计', icon: '📊' },
  { key: 'version', label: '版本', icon: '📦' },
]

const editForm = reactive({ name: '', description: '', callback_url: '' })
const newUri = ref('')
const newVersion = reactive({ version: '', description: '' })
const showWebhookDialog = ref(false)
const editingWebhook = ref<OutgoingWebhook | null>(null)
const webhookForm = reactive({ name: '', url: '' })

const maskedSecret = computed(() => {
  const s = store.currentApp?.app_secret || ''
  if (s.length <= 8) return s
  return s.slice(0, 4) + '****' + s.slice(-4)
})

async function loadAll() {
  loading.value = true
  try {
    await store.loadApp(appId.value)
    const app = store.currentApp
    if (app) {
      editForm.name = app.name
      editForm.description = app.description || ''
      editForm.callback_url = app.callback_url || ''
    }
    await Promise.all([
      store.loadRedirectUris(appId.value),
      store.loadWebhooks(appId.value),
      store.loadStats(appId.value),
      store.loadVersions(appId.value),
    ])
  } finally {
    loading.value = false
  }
}

function copy(text: string) {
  navigator.clipboard.writeText(text)
}

async function onSave() {
  await store.updateApp(appId.value, { ...editForm })
}

async function onRegenerateSecret() {
  if (!confirm('重新生成后旧 Secret 将立即失效，确定继续？')) return
  await store.regenerateSecret(appId.value)
}

async function onDelete() {
  if (!confirm('确定要删除此应用？此操作不可撤销。')) return
  await store.removeApp(appId.value)
}

async function addUri() {
  if (!newUri.value.trim()) return
  await store.addRedirectUri(appId.value, newUri.value.trim())
  newUri.value = ''
}

async function removeUri(uriId: number) {
  await store.removeRedirectUri(appId.value, uriId)
}

async function saveWebhook() {
  const data = { name: webhookForm.name.trim(), url: webhookForm.url.trim() }
  if (editingWebhook.value) {
    await store.updateWebhook(appId.value, editingWebhook.value.id, data)
  } else {
    await store.createWebhook(appId.value, data)
  }
  showWebhookDialog.value = false
  editingWebhook.value = null
  webhookForm.name = ''
  webhookForm.url = ''
}

function editWebhook(wh: OutgoingWebhook) {
  editingWebhook.value = wh
  webhookForm.name = wh.name
  webhookForm.url = wh.url
  showWebhookDialog.value = true
}

async function removeWebhook(whId: number) {
  if (!confirm('确定删除此 Webhook？')) return
  await store.removeWebhook(appId.value, whId)
}

async function submitVersion() {
  if (!newVersion.version.trim()) return
  await store.submitVersion(appId.value, { ...newVersion })
  newVersion.version = ''
  newVersion.description = ''
}

onMounted(loadAll)
</script>

<style scoped>
.app-detail-layout {
  display: flex;
  min-height: 100vh;
}

.app-sidebar {
  width: 220px;
  flex-shrink: 0;
  background: #fff;
  border-right: 1px solid #e0e0e0;
  padding: 24px 16px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.back-link {
  color: #1a73e8;
  text-decoration: none;
  font-size: 14px;
}

.app-summary {
  padding: 0;
}
.app-summary-name {
  font-size: 16px;
  font-weight: 600;
  color: #333;
  margin-bottom: 4px;
}
.app-summary-id {
  font-size: 12px;
  color: #999;
  word-break: break-all;
}

.sidebar-nav {
  display: flex;
  flex-direction: column;
}

.sidebar-item {
  display: flex;
  align-items: center;
  gap: 10px;
  width: 100%;
  padding: 12px 16px;
  border: none;
  border-radius: 6px;
  background: none;
  cursor: pointer;
  font-size: 14px;
  color: #555;
  text-align: left;
}
.sidebar-item:hover {
  background: #f5f5f5;
}
.sidebar-item.active {
  color: #1a73e8;
  background: #e8f0fe;
  font-weight: 500;
}
.sidebar-icon {
  font-size: 16px;
  width: 20px;
  text-align: center;
}

.app-content {
  flex: 1;
  padding: 32px 40px;
  max-width: 960px;
}

.page-header {
  margin-bottom: 24px;
}
.page-header h1 {
  font-size: 24px;
  font-weight: 600;
  margin: 0;
}

.loading {
  text-align: center;
  color: #888;
  padding: 60px;
}
.sidebar-item:last-child {
  border-bottom: none;
}
.sidebar-item:hover {
  background: #f5f5f5;
}
.sidebar-item.active {
  color: #1a73e8;
  background: #e8f0fe;
  font-weight: 500;
}
.sidebar-icon {
  font-size: 16px;
  width: 20px;
  text-align: center;
}

.panel {
  flex: 1;
  min-width: 0;
}

.panel .info-card {
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 24px;
}
.panel .info-card h3 {
  margin: 0 0 16px;
  font-size: 16px;
  font-weight: 500;
}
.info-row {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  margin-bottom: 16px;
}
.info-row .label {
  width: 120px;
  flex-shrink: 0;
  font-size: 14px;
  color: #666;
  padding-top: 8px;
}
.info-row .edit-input {
  flex: 1;
}
.copy-row code {
  flex: 1;
  padding: 8px 12px;
  background: #f5f5f5;
  border-radius: 4px;
  font-size: 13px;
  word-break: break-all;
}
.copy-btn {
  padding: 4px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  background: #fff;
  cursor: pointer;
  font-size: 12px;
}
.form-actions {
  display: flex;
  gap: 12px;
  margin-top: 24px;
  flex-wrap: wrap;
}
.edit-input {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 14px;
  box-sizing: border-box;
}
.edit-input:focus {
  outline: none;
  border-color: #1a73e8;
}
.add-row {
  display: flex;
  gap: 8px;
  margin-bottom: 16px;
}
.add-row .edit-input {
  flex: 1;
}
.uri-list {
  list-style: none;
  padding: 0;
  margin: 0;
}
.uri-list li {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid #f0f0f0;
}
.empty-hint {
  color: #888;
  font-size: 14px;
}
.data-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 12px;
}
.data-table th,
.data-table td {
  text-align: left;
  padding: 10px 12px;
  border-bottom: 1px solid #f0f0f0;
  font-size: 14px;
}
.data-table th {
  font-weight: 500;
  color: #666;
  background: #fafafa;
}
.url-cell {
  max-width: 300px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.btn-primary {
  padding: 8px 20px;
  border: none;
  border-radius: 6px;
  background: #1a73e8;
  color: #fff;
  font-size: 14px;
  cursor: pointer;
}
.btn-primary:hover { background: #1557b0; }
.btn-outline {
  padding: 8px 20px;
  border: 1px solid #ddd;
  border-radius: 6px;
  background: #fff;
  cursor: pointer;
  font-size: 14px;
}
.btn-danger {
  padding: 8px 20px;
  border: none;
  border-radius: 6px;
  background: #d32f2f;
  color: #fff;
  font-size: 14px;
  cursor: pointer;
}
.btn-sm {
  padding: 4px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  background: #fff;
  cursor: pointer;
  font-size: 12px;
  margin-right: 4px;
}
.btn-sm.btn-danger {
  border-color: #d32f2f;
  color: #d32f2f;
}
.btn-icon {
  border: none;
  background: none;
  color: #d32f2f;
  cursor: pointer;
  font-size: 13px;
}
.stats-grid {
  display: flex;
  gap: 24px;
}
.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px 32px;
  background: #fafafa;
  border-radius: 8px;
}
.stat-value {
  font-size: 28px;
  font-weight: 600;
  color: #1a73e8;
}
.stat-label {
  font-size: 13px;
  color: #666;
  margin-top: 4px;
}
/* Modal */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
}
.modal-content {
  background: #fff;
  border-radius: 8px;
  padding: 24px;
  width: 480px;
  max-width: 90vw;
}
.modal-content h3 {
  margin: 0 0 20px;
  font-size: 18px;
  font-weight: 500;
}
.form-group {
  margin-bottom: 16px;
}
.form-group label {
  display: block;
  font-size: 14px;
  font-weight: 500;
  margin-bottom: 6px;
}
.btn-cancel {
  padding: 8px 20px;
  border: 1px solid #ddd;
  border-radius: 6px;
  background: #fff;
  cursor: pointer;
  font-size: 14px;
}
.secret {
  font-family: 'Courier New', monospace;
  letter-spacing: 1px;
}
</style>
