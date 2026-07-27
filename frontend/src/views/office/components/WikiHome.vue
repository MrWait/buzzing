<template>
  <div v-if="wiki" class="wiki-home">
    <div class="wh-header">
      <div class="wh-icon">{{ wiki.icon || '📚' }}</div>
      <div>
        <h2 class="wh-name">{{ wiki.name }}</h2>
        <p v-if="wiki.description" class="wh-desc">{{ wiki.description }}</p>
        <p class="wh-meta">{{ wiki.member_count }} 位成员</p>
      </div>
    </div>

    <div class="wh-section">
      <h3 class="wh-section-title">📌 置顶文档</h3>
      <div v-if="pins.length === 0" class="wh-empty">暂无置顶文档</div>
      <div v-for="d in pins" :key="d.id" class="wh-doc-row" @click="openDoc(d.id)">
        <span class="wh-doc-icon">{{ d.icon || '📄' }}</span>
        <span class="wh-doc-title">{{ d.title || '未命名' }}</span>
      </div>
    </div>

    <div class="wh-section">
      <h3 class="wh-section-title">🕐 最近更新</h3>
      <div v-if="recentDocs.length === 0" class="wh-empty">暂无文档</div>
      <div v-for="d in recentDocs" :key="d.id" class="wh-doc-row" @click="openDoc(d.id)">
        <span class="wh-doc-icon">{{ d.icon || '📄' }}</span>
        <span class="wh-doc-title">{{ d.title || '未命名' }}</span>
        <span class="wh-doc-time">{{ formatTime(d.updated_at) }}</span>
      </div>
    </div>
  </div>
  <div v-else class="wiki-home wiki-home--empty">
    <p>选择一个知识库查看概览</p>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useWikiStore } from '@/stores/wiki'
import { wikisApi, type WikiDetailDto } from '@/services/office/wikis'

const router = useRouter()
const wikiStore = useWikiStore()

const wiki = ref<WikiDetailDto | null>(null)
const pins = ref<any[]>([])
const recentDocs = ref<any[]>([])

onMounted(() => {
  loadWiki()
})

watch(() => wikiStore.currentWikiId, () => {
  loadWiki()
})

async function loadWiki() {
  const id = wikiStore.currentWikiId
  if (!id) {
    wiki.value = null
    pins.value = []
    recentDocs.value = []
    return
  }
  try {
    const [{ data: detail }, { data: p }, { data: r }] = await Promise.all([
      wikisApi.get(id),
      wikisApi.listPins(id),
      wikisApi.recent(id),
    ])
    wiki.value = detail
    pins.value = p as any[]
    recentDocs.value = r as any[]
  } catch {
    // ignore
  }
}

function openDoc(id: string) {
  router.push({ name: 'OfficeEditor', params: { docId: id } })
}

function formatTime(iso: string) {
  try {
    return new Date(iso).toLocaleDateString('zh-CN', {
      month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit',
    })
  } catch {
    return iso
  }
}
</script>

<style scoped>
.wiki-home {
  max-width: 720px;
  margin: 0 auto;
  padding: 32px 24px;
}
.wiki-home--empty {
  text-align: center;
  color: #999;
  padding: 80px 24px;
}
.wh-header {
  display: flex;
  align-items: flex-start;
  gap: 16px;
  margin-bottom: 32px;
}
.wh-icon {
  font-size: 40px;
  line-height: 1;
}
.wh-name {
  margin: 0 0 4px;
  font-size: 22px;
  font-weight: 700;
}
.wh-desc {
  margin: 0 0 4px;
  color: #666;
  font-size: 14px;
}
.wh-meta {
  margin: 0;
  color: #999;
  font-size: 12px;
}
.wh-section {
  margin-bottom: 28px;
}
.wh-section-title {
  font-size: 14px;
  font-weight: 600;
  margin: 0 0 12px;
  color: #333;
}
.wh-empty {
  color: #999;
  font-size: 13px;
  padding: 12px 0;
}
.wh-doc-row {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  border-radius: 6px;
  cursor: pointer;
  transition: background 0.1s;
}
.wh-doc-row:hover {
  background: #f5f5f5;
}
.wh-doc-icon {
  font-size: 16px;
  width: 24px;
  text-align: center;
}
.wh-doc-title {
  flex: 1;
  font-size: 14px;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.wh-doc-time {
  font-size: 12px;
  color: #999;
  white-space: nowrap;
}
</style>
