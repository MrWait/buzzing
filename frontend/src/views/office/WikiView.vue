<template>
  <div class="wiki-layout">
    <WikiSidebar :wiki-id="wikiId" />
    <section class="wiki-content">
      <div v-if="loading" class="loading">加载中…</div>
      <template v-else-if="wiki">
        <header class="wiki-header">
          <span class="wiki-icon-big">{{ wiki.icon || '📚' }}</span>
          <h2>{{ wiki.name }}</h2>
          <span class="wiki-meta">{{ wiki.description || '' }}</span>
        </header>

        <!-- 最近更新 -->
        <section class="recent-section">
          <h3>最近更新</h3>
          <div v-if="recentDocs.length === 0" class="empty">暂无文档</div>
          <div
            v-for="doc in recentDocs"
            :key="doc.id"
            class="doc-item"
            @click="openDoc(doc.id)"
          >
            <span class="doc-icon">{{ doc.icon || '📄' }}</span>
            <span class="doc-title">{{ doc.title }}</span>
            <span class="doc-time">{{ formatTime(doc.updated_at) }}</span>
          </div>
        </section>
      </template>
      <div v-else class="not-found">知识库不存在</div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useWikiStore } from '@/stores/wiki'
import { wikisApi } from '@/services/office/wikis'
import type { DocDto } from '@/services/office/docs'
import WikiSidebar from './components/WikiSidebar.vue'

const route = useRoute()
const router = useRouter()
const wikiStore = useWikiStore()

const wikiId = computed(() => route.params.wikiId as string)
const wiki = computed(() => wikiStore.wikis.find(w => w.id === wikiId.value))
const loading = ref(false)
const recentDocs = ref<DocDto[]>([])

onMounted(async () => {
  await wikiStore.loadWikis()
  await loadRecent()
})

async function loadRecent() {
  loading.value = true
  try {
    const { data } = await wikisApi.recent(wikiId.value)
    recentDocs.value = data
  } finally {
    loading.value = false
  }
}

function openDoc(id: string) {
  router.push({ name: 'WikiEditor', params: { wikiId: wikiId.value, docId: id } })
}

function formatTime(t: string) {
  if (!t) return ''
  const d = new Date(t)
  const now = new Date()
  const diff = now.getTime() - d.getTime()
  if (diff < 3600000) return `${Math.floor(diff / 60000)} 分钟前`
  if (diff < 86400000) return `${Math.floor(diff / 3600000)} 小时前`
  return d.toLocaleDateString('zh-CN')
}
</script>

<style scoped>
.wiki-layout {
  display: flex;
  height: 100%;
  position: relative;
}
.wiki-content {
  flex: 1;
  min-width: 0;
  padding: 24px 32px;
  overflow-y: auto;
  max-width: 720px;
  margin: 0 auto;
}
.loading, .not-found {
  padding: 48px;
  text-align: center;
  color: #9ca3af;
}
.wiki-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 32px;
  padding-bottom: 16px;
  border-bottom: 1px solid #eee;
}
.wiki-icon-big {
  font-size: 36px;
}
.wiki-header h2 {
  font-size: 20px;
  font-weight: 600;
  margin: 0;
  color: #1f2937;
}
.wiki-meta {
  color: #9ca3af;
  font-size: 13px;
}
.recent-section h3 {
  font-size: 14px;
  font-weight: 600;
  color: #374151;
  margin-bottom: 12px;
}
.empty {
  color: #9ca3af;
  padding: 24px 0;
  text-align: center;
}
.doc-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  border-radius: 6px;
  cursor: pointer;
  transition: background 0.1s;
}
.doc-item:hover {
  background: #f5f5f5;
}
.doc-icon {
  font-size: 16px;
}
.doc-title {
  flex: 1;
  font-size: 14px;
  color: #374151;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.doc-time {
  font-size: 12px;
  color: #9ca3af;
  white-space: nowrap;
}
</style>
