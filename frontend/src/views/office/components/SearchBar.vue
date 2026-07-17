<template>
  <Teleport to="body">
    <div v-if="open" class="search-overlay" @click.self="close">
      <div class="search-panel">
        <div class="search-input-wrap">
          <input
            ref="inputRef"
            v-model="query"
            type="text"
            placeholder="搜索全部文档，Enter 打开，Esc 关闭"
            class="search-input"
            @keydown.esc.prevent="close"
            @keydown.up.prevent="moveIndex(-1)"
            @keydown.down.prevent="moveIndex(1)"
            @keydown.enter.prevent="openSelected"
          />
        </div>
        <div class="search-body">
          <div v-if="loading" class="hint">搜索中…</div>
          <div v-else-if="!query.trim()" class="hint">输入关键词开始搜索</div>
          <div v-else-if="results.length === 0" class="hint">无匹配结果</div>
          <ul v-else class="result-list">
            <li
              v-for="(r, idx) in results"
              :key="r.id"
              :class="{ active: idx === activeIndex }"
              @mouseenter="activeIndex = idx"
              @click="openItem(r)"
            >
              <div class="result-title">
                <span v-if="r.icon" class="icon">{{ r.icon }}</span>
                <span>{{ r.title }}</span>
                <span class="badge">{{ r.matched_in === 'title' ? '标题' : '正文' }}</span>
              </div>
              <div class="result-highlight" v-html="r.highlight || '（无摘要）'" />
              <div class="result-meta">{{ formatTime(r.updated_at) }}</div>
            </li>
          </ul>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, watch, nextTick, onMounted, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import { docsApi, type SearchResultDto } from '@/services/office/docs'

const props = defineProps<{ open: boolean }>()
const emit = defineEmits<{ (e: 'update:open', v: boolean): void }>()

const router = useRouter()
const query = ref('')
const results = ref<SearchResultDto[]>([])
const activeIndex = ref(0)
const loading = ref(false)
const inputRef = ref<HTMLInputElement | null>(null)

let debounceTimer: ReturnType<typeof setTimeout> | null = null

watch(query, (v) => {
  activeIndex.value = 0
  if (debounceTimer) clearTimeout(debounceTimer)
  const q = v.trim()
  if (!q) {
    results.value = []
    loading.value = false
    return
  }
  loading.value = true
  debounceTimer = setTimeout(async () => {
    try {
      const res = await docsApi.search({ q, limit: 30 })
      results.value = res.data
    } catch {
      results.value = []
    } finally {
      loading.value = false
    }
  }, 200)
})

watch(
  () => props.open,
  async (v) => {
    if (v) {
      query.value = ''
      results.value = []
      activeIndex.value = 0
      await nextTick()
      inputRef.value?.focus()
    }
  },
)

function close() {
  emit('update:open', false)
}

function moveIndex(delta: number) {
  if (results.value.length === 0) return
  const next = (activeIndex.value + delta + results.value.length) % results.value.length
  activeIndex.value = next
}

function openSelected() {
  const item = results.value[activeIndex.value]
  if (item) openItem(item)
}

function openItem(item: SearchResultDto) {
  router.push({ name: 'OfficeEditor', params: { docId: item.id } })
  close()
}

function formatTime(iso: string): string {
  const d = new Date(iso)
  return d.toLocaleString('zh-CN')
}

// 全局快捷键 Cmd/Ctrl+K → 打开搜索
function onKeydown(e: KeyboardEvent) {
  const isCmdK = (e.metaKey || e.ctrlKey) && (e.key === 'k' || e.key === 'K')
  if (isCmdK) {
    e.preventDefault()
    emit('update:open', true)
  }
}

onMounted(() => {
  window.addEventListener('keydown', onKeydown)
})
onBeforeUnmount(() => {
  window.removeEventListener('keydown', onKeydown)
})
</script>

<style scoped>
.search-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.35);
  z-index: 1000;
  display: flex;
  justify-content: center;
  align-items: flex-start;
  padding-top: 12vh;
}
.search-panel {
  width: min(640px, 92vw);
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
  overflow: hidden;
  display: flex;
  flex-direction: column;
  max-height: 70vh;
}
.search-input-wrap {
  padding: 12px 16px;
  border-bottom: 1px solid #eee;
}
.search-input {
  width: 100%;
  border: none;
  outline: none;
  font-size: 16px;
  background: transparent;
}
.search-body {
  overflow-y: auto;
}
.hint {
  padding: 32px 16px;
  text-align: center;
  color: #9ca3af;
  font-size: 13px;
}
.result-list {
  list-style: none;
  margin: 0;
  padding: 4px 0;
}
.result-list li {
  padding: 10px 16px;
  cursor: pointer;
  border-left: 3px solid transparent;
  transition: background 0.1s;
}
.result-list li.active {
  background: #eff6ff;
  border-left-color: #2563eb;
}
.result-title {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  font-weight: 600;
  color: #1f2937;
}
.result-title .icon {
  font-size: 16px;
}
.result-title .badge {
  margin-left: auto;
  font-size: 11px;
  color: #6b7280;
  background: #f3f4f6;
  padding: 2px 8px;
  border-radius: 10px;
  font-weight: 400;
}
.result-highlight {
  margin-top: 4px;
  font-size: 12px;
  color: #4b5563;
  line-height: 1.5;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.result-highlight :deep(em) {
  color: #2563eb;
  font-style: normal;
  font-weight: 600;
  background: #fef08a;
  padding: 0 2px;
  border-radius: 2px;
}
.result-meta {
  margin-top: 4px;
  font-size: 11px;
  color: #9ca3af;
}
</style>
