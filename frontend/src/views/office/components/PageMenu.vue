<template>
  <Teleport to="body">
    <div v-if="open" class="pm-overlay" @click.self="close">
      <!-- =========== Main Menu =========== -->
      <div v-if="currentPage === 'main'" class="pm-menu" :style="menuStyle">
        <div class="pm-item" @click="toggleStar">
          <span class="pm-icon">{{ starred ? '★' : '☆' }}</span>
          <span>{{ starred ? '取消收藏' : '添加到收藏' }}</span>
        </div>
        <div class="pm-item" @click="handleDuplicate">
          <span class="pm-icon">⎘</span>
          <span>创建副本</span>
        </div>
        <div class="pm-item" @click="goTo('info')">
          <span class="pm-icon">ℹ</span>
          <span>文档信息</span>
        </div>
        <div class="pm-item" @click="goTo('history')">
          <span class="pm-icon">🕐</span>
          <span>历史记录</span>
        </div>
      </div>

      <!-- =========== Info Page =========== -->
      <div v-if="currentPage === 'info'" class="pm-panel" :style="menuStyle">
        <div class="pm-header">
          <button class="pm-back" @click="goBack">←</button>
          <h3>文档信息</h3>
        </div>
        <div class="pm-body info-body">
          <div class="info-row"><label>标题</label><span>{{ docData?.title ?? '' }}</span></div>
          <div class="info-row"><label>类型</label><span>{{ docData?.doc_type === 1 ? '文档' : '页面' }}</span></div>
          <div class="info-row"><label>创建时间</label><span>{{ docData?.created_at ?? '' }}</span></div>
          <div class="info-row"><label>更新时间</label><span>{{ docData?.updated_at ?? '' }}</span></div>
          <div class="info-row"><label>版本号</label><span>v{{ docData?.version ?? 0 }}</span></div>
        </div>
      </div>

      <!-- =========== History Page =========== -->
      <div v-if="currentPage === 'history'" class="pm-panel" :style="menuStyle">
        <div class="pm-header">
          <button class="pm-back" @click="goBack">←</button>
          <h3>历史记录</h3>
        </div>
        <div class="pm-body history-body">
          <div v-if="loadingVersions" class="pm-empty">加载中…</div>
          <div v-else-if="versions.length === 0" class="pm-empty">暂无历史版本</div>
          <div v-for="v in versions" :key="v.id" class="history-item">
            <div class="history-title">{{ v.title }}</div>
            <div class="history-meta">{{ v.created_at }}</div>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useDocumentStore } from '@/stores/document'
import { docsApi } from '@/services/office/docs'
import { versionsApi, type VersionDto } from '@/services/office/versions'

const props = withDefaults(defineProps<{
  open: boolean
  docId: string
  triggerRect: { top: number; bottom: number; left: number; right: number; width: number; height: number }
}>(), {
  triggerRect: () => ({ top: 0, bottom: 0, left: 0, right: 0, width: 0, height: 0 }),
})
const emit = defineEmits<{ (e: 'update:open', v: boolean): void }>()

const router = useRouter()
const docStore = useDocumentStore()

const pageStack = ref<string[]>(['main'])
const currentPage = computed(() => pageStack.value[pageStack.value.length - 1])

function goTo(page: string) { pageStack.value.push(page) }
function goBack() { if (pageStack.value.length > 1) pageStack.value.pop() }

const menuStyle = computed(() => {
  const r = props.triggerRect
  return {
    position: 'fixed',
    top: `${r.bottom + 4}px`,
    right: `${Math.max(8, window.innerWidth - r.right)}px`,
    zIndex: 1050,
  }
})

function close() {
  emit('update:open', false)
  pageStack.value = ['main']
}

// Star
const starred = computed(() => docStore.starredSet.has(props.docId))

async function toggleStar() {
  await docStore.toggleStar(props.docId)
  close()
}

// Duplicate
const docTitle = ref('')
const docData = ref<{ title: string; doc_type: number; created_at: string; updated_at: string; version: number } | null>(null)

async function loadDocInfo() {
  try {
    const { data } = await docsApi.get(props.docId)
    docData.value = data
    docTitle.value = data.title
  } catch { /* ignore */ }
}

async function handleDuplicate() {
  try {
    const { data } = await docsApi.duplicate(props.docId)
    close()
    router.push({ name: 'OfficeEditor', params: { docId: data.id } })
  } catch { /* ignore */ }
}

// Version history
const versions = ref<VersionDto[]>([])
const loadingVersions = ref(false)

async function loadVersions() {
  loadingVersions.value = true
  try {
    const { data } = await versionsApi.list(props.docId)
    versions.value = data
  } catch { versions.value = [] }
  finally { loadingVersions.value = false }
}

watch(currentPage, (page) => {
  if (page === 'info') loadDocInfo()
  if (page === 'history' && versions.value.length === 0) loadVersions()
})
</script>

<style scoped>
.pm-overlay {
  position: fixed;
  inset: 0;
  z-index: 1050;
}
.pm-menu {
  position: absolute;
  min-width: 180px;
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  padding: 4px 0;
}
.pm-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 14px;
  cursor: pointer;
  font-size: 13px;
  color: #1f2937;
}
.pm-item:hover {
  background: #f3f4f6;
}
.pm-icon {
  width: 18px;
  text-align: center;
  font-size: 14px;
  flex-shrink: 0;
}
.pm-panel {
  position: absolute;
  width: 320px;
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  display: flex;
  flex-direction: column;
  max-height: 60vh;
}
.pm-header {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 12px 14px 8px;
  border-bottom: 1px solid #eee;
  flex-shrink: 0;
}
.pm-header h3 {
  margin: 0;
  font-size: 14px;
  font-weight: 600;
}
.pm-back {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 16px;
  color: #666;
  padding: 0 4px;
}
.pm-back:hover { color: #333; }
.pm-body {
  padding: 12px 14px 14px;
  overflow-y: auto;
  flex: 1;
}
.pm-empty {
  padding: 24px 0;
  text-align: center;
  color: #999;
  font-size: 12px;
}
.info-body { display: flex; flex-direction: column; gap: 10px; }
.info-row {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  font-size: 13px;
}
.info-row label {
  color: #6b7280;
  flex-shrink: 0;
  min-width: 60px;
}
.info-row span { color: #1f2937; word-break: break-all; }
.history-item {
  padding: 8px 0;
  border-bottom: 1px solid #f0f0f0;
}
.history-item:last-child { border-bottom: none; }
.history-title { font-size: 13px; color: #1f2937; margin-bottom: 2px; }
.history-meta { font-size: 11px; color: #9ca3af; }
</style>
