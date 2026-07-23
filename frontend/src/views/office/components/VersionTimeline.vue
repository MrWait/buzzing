<template>
  <div v-if="open" class="version-panel" @mousedown.stop @click.stop>
    <div class="vp-arrow"></div>
    <div class="vp-header">
      <h3 class="vp-title">版本历史</h3>
      <button v-if="!showCreateForm" class="header-btn" @click="showCreateForm = true">
        + 创建版本
      </button>
      <button v-else class="header-btn" @click="showCreateForm = false">取消</button>
    </div>

    <form v-if="showCreateForm" class="create-form" @submit.prevent="handleCreate">
      <input
        v-model="newTitle"
        type="text"
        placeholder="版本名称"
        required
        class="form-input"
      />
      <input
        v-model="newDesc"
        type="text"
        placeholder="版本描述（可选）"
        class="form-input"
      />
      <button type="submit" class="btn-primary btn-sm" :disabled="creating">
        {{ creating ? '创建中…' : '保存版本' }}
      </button>
    </form>

    <div v-if="errMsg" class="err">{{ errMsg }}</div>

    <div v-if="!loading" class="version-list">
      <div
        v-for="v in versions"
        :key="v.id"
        class="version-row"
        :class="{ 'version-row--selected': selectedVersionId === v.id }"
      >
        <label v-if="compareMode" class="v-checkbox">
          <input
            type="checkbox"
            :checked="compareSelection.has(v.id)"
            @change="toggleCompare(v.id)"
          />
        </label>
        <div class="v-meta" @click="selectForActions(v.id)">
          <div class="v-title">
            <span class="v-number">v{{ v.version_number }}</span>
            {{ v.title || '未命名版本' }}
          </div>
          <div v-if="v.description" class="v-desc">{{ v.description }}</div>
          <div class="v-info">
            <span>{{ formatDate(v.created_at) }}</span>
            <span v-if="v.is_minor" class="tag-minor">小更新</span>
          </div>
        </div>
        <div class="v-actions">
          <button
            class="btn-text"
            title="对比"
            @click="startCompare(v.id)"
          >
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M12 5v14M5 12h14"/>
            </svg>
          </button>
          <button
            class="btn-text btn-text--danger"
            title="回滚"
            @click="confirmRestore(v)"
          >
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"/>
              <path d="M3 3v5h5"/>
            </svg>
          </button>
        </div>
      </div>
      <div v-if="versions.length === 0" class="empty">暂未创建版本</div>
    </div>
    <div v-else class="loading">加载中…</div>

    <RestoreConfirmDialog
      :open="showRestoreConfirm"
      :version="restoreTarget"
      @confirm="handleRestore"
      @cancel="showRestoreConfirm = false"
    />

    <VersionDiff
      :open="showDiff"
      :v1-id="diffV1Id"
      :v2-id="diffV2Id"
      :doc-id="docId"
      @close="showDiff = false"
    />
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, watch } from 'vue'
import { versionsApi, type VersionDto } from '@/services/office/versions'
import RestoreConfirmDialog from './RestoreConfirmDialog.vue'
import VersionDiff from './VersionDiff.vue'

const props = defineProps<{ open: boolean; docId: string }>()
const emit = defineEmits<{
  (e: 'restored'): void
}>()

const versions = ref<VersionDto[]>([])
const loading = ref(false)
const errMsg = ref<string | null>(null)
const showCreateForm = ref(false)
const creating = ref(false)
const newTitle = ref('')
const newDesc = ref('')

const selectedVersionId = ref<string | null>(null)
const compareMode = ref(false)
const compareSelection = ref<Set<string>>(new Set())
const showDiff = ref(false)
const diffV1Id = ref('')
const diffV2Id = ref('')
const showRestoreConfirm = ref(false)
const restoreTarget = ref<VersionDto | null>(null)

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
    const { data } = await versionsApi.list(props.docId)
    versions.value = data
  } catch (e) {
    errMsg.value = e instanceof Error ? e.message : String(e)
  } finally {
    loading.value = false
  }
}

async function handleCreate() {
  creating.value = true
  errMsg.value = null
  try {
    await versionsApi.create(props.docId, {
      title: newTitle.value,
      description: newDesc.value || undefined,
    })
    newTitle.value = ''
    newDesc.value = ''
    showCreateForm.value = false
    await refresh()
  } catch (e) {
    errMsg.value = e instanceof Error ? e.message : String(e)
  } finally {
    creating.value = false
  }
}

function selectForActions(id: string) {
  selectedVersionId.value = selectedVersionId.value === id ? null : id
}

function startCompare(id: string) {
  if (!compareMode.value) {
    compareMode.value = true
    compareSelection.value = new Set([id])
    return
  }
  if (compareSelection.value.size === 0) {
    compareSelection.value = new Set([id])
    return
  }
  if (compareSelection.value.has(id)) {
    compareSelection.value.delete(id)
    if (compareSelection.value.size === 0) compareMode.value = false
    return
  }
  if (compareSelection.value.size >= 2) {
    compareSelection.value = new Set([id])
    return
  }
  compareSelection.value.add(id)
  doCompare()
}

function toggleCompare(id: string) {
  if (compareSelection.value.has(id)) {
    compareSelection.value.delete(id)
    if (compareSelection.value.size === 0) compareMode.value = false
  } else if (compareSelection.value.size < 2) {
    compareSelection.value.add(id)
    if (compareSelection.value.size === 2) doCompare()
  }
}

function doCompare() {
  const arr = Array.from(compareSelection.value)
  const byNumber = (a: string, b: string) => {
    const f = versions.value.find((v) => v.id === a)
    const g = versions.value.find((v) => v.id === b)
    return (f?.version_number ?? 0) - (g?.version_number ?? 0)
  }
  arr.sort(byNumber)
  diffV1Id.value = arr[0]
  diffV2Id.value = arr[1]
  showDiff.value = true
}

function confirmRestore(v: VersionDto) {
  restoreTarget.value = v
  showRestoreConfirm.value = true
}

async function handleRestore() {
  if (!restoreTarget.value) return
  try {
    await versionsApi.restore(props.docId, restoreTarget.value.id)
    showRestoreConfirm.value = false
    restoreTarget.value = null
    await refresh()
    emit('restored')
  } catch (e) {
    errMsg.value = e instanceof Error ? e.message : String(e)
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
.version-panel {
  position: absolute;
  top: calc(100% + 8px);
  right: 0;
  z-index: 200;
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 16px;
  min-width: 480px;
  max-width: 560px;
  max-height: 520px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
}
.vp-arrow {
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
.vp-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}
.vp-title {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
}
.header-btn {
  display: flex;
  align-items: center;
  height: 32px;
  padding: 0 12px;
  border: 1px solid #d0d0d0;
  background: #fff;
  color: #333;
  border-radius: 6px;
  font-size: 13px;
  cursor: pointer;
  transition: background 0.15s;
}
.header-btn:hover {
  background: #f5f5f5;
}
.create-form {
  display: flex;
  gap: 8px;
  align-items: center;
  margin-bottom: 12px;
  padding: 12px;
  background: #fafafa;
  border-radius: 6px;
}
.form-input {
  flex: 1;
  padding: 6px 8px;
  border: 1px solid #d0d0d0;
  border-radius: 4px;
  font-size: 13px;
  outline: none;
  min-width: 0;
}
.form-input:focus {
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
.version-list {
  max-height: 360px;
  overflow-y: auto;
}
.version-row {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  padding: 10px 8px;
  border-bottom: 1px solid #f0f0f0;
  transition: background 0.1s;
}
.version-row:hover,
.version-row--selected {
  background: #f8f9ff;
}
.v-checkbox {
  margin-top: 2px;
}
.v-meta {
  flex: 1;
  cursor: pointer;
  min-width: 0;
}
.v-title {
  font-size: 14px;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 6px;
}
.v-number {
  padding: 1px 5px;
  background: #e3f2fd;
  color: #1565c0;
  border-radius: 3px;
  font-size: 11px;
  white-space: nowrap;
}
.v-desc {
  font-size: 12px;
  color: #666;
  margin-top: 2px;
}
.v-info {
  font-size: 11px;
  color: #999;
  margin-top: 4px;
  display: flex;
  align-items: center;
  gap: 8px;
}
.tag-minor {
  padding: 1px 4px;
  background: #fff3e0;
  color: #e65100;
  border-radius: 2px;
  font-size: 10px;
}
.v-actions {
  display: flex;
  gap: 4px;
  opacity: 0;
  transition: opacity 0.1s;
}
.version-row:hover .v-actions {
  opacity: 1;
}
.btn-text {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  border: none;
  background: transparent;
  color: #666;
  cursor: pointer;
  border-radius: 4px;
}
.btn-text:hover {
  background: #f0f0f0;
  color: #333;
}
.btn-text--danger:hover {
  background: #ffebee;
  color: #d32f2f;
}
.btn-sm {
  padding: 6px 12px;
  font-size: 12px;
}
.btn-primary {
  background: #1565c0;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: background 0.15s;
  white-space: nowrap;
}
.btn-primary:hover:not(:disabled) {
  background: #0d47a1;
}
.btn-primary:disabled {
  background: #90caf9;
  cursor: not-allowed;
}
</style>
