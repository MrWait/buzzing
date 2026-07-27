<template>
  <div class="wiki-grid">
    <header class="wg-header">
      <h2>知识库</h2>
      <div class="wg-header-right">
        <button class="wg-add-btn" @click="showCreate = !showCreate">+</button>
        <TopRightBar />
      </div>
    </header>

    <div v-if="showCreate" class="wg-create-form">
      <input v-model="newWikiName" placeholder="知识库名称" @keyup.enter="handleCreate" />
      <button @click="handleCreate">确定</button>
    </div>

    <div v-if="filteredWikis.length === 0" class="wg-empty">暂无知识库</div>
    <div v-else class="wg-grid">
      <div
        v-for="w in filteredWikis"
        :key="w.id"
        class="wg-card"
        :class="{ active: w.id === wikiStore.currentWikiId }"
        @click="switchWiki(w.id)"
      >
        <div class="wg-card-icon">{{ w.icon || '📚' }}</div>
        <div class="wg-card-name">{{ w.name }}</div>
        <button
          class="wg-card-pin"
          :class="{ pinned: wikiStore.pinnedWikiIds.has(w.id) }"
          @click.stop="wikiStore.togglePinWiki(w.id)"
          :title="wikiStore.pinnedWikiIds.has(w.id) ? '取消置顶' : '置顶'"
        >📌</button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useWikiStore } from '@/stores/wiki'
import { wikisApi } from '@/services/office/wikis'
import TopRightBar from '@/components/TopRightBar.vue'

const wikiStore = useWikiStore()
const router = useRouter()
const showCreate = ref(false)
const newWikiName = ref('')

const filteredWikis = computed(() => wikiStore.wikis)

onMounted(() => {
  wikiStore.loadPinnedFromStorage()
  wikiStore.loadWikis()
})

function switchWiki(id: string) {
  router.push({ name: 'WikiHome', params: { wikiId: id } })
}

async function handleCreate() {
  if (!newWikiName.value.trim()) return
  const { data } = await wikisApi.create({ name: newWikiName.value.trim() })
  await wikiStore.loadWikis(true)
  newWikiName.value = ''
  showCreate.value = false
  if (data.home_doc_id) {
    router.push({ name: 'WikiEditor', params: { wikiId: data.id, docId: data.home_doc_id } })
  } else {
    router.push({ name: 'WikiHome', params: { wikiId: data.id } })
  }
}
</script>

<style scoped>
.wiki-grid {
  max-width: 720px;
  margin: 0 auto;
}
.wg-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 24px;
}
.wg-header h2 {
  font-size: 20px;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}
.wg-header-right {
  display: flex;
  align-items: center;
  gap: 8px;
}
.wg-add-btn {
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #1a1a2e;
  color: #fff;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 16px;
  font-weight: 600;
  line-height: 1;
}
.wg-add-btn:hover {
  background: #2a2a4e;
}
.wg-create-form {
  display: flex;
  gap: 8px;
  margin-bottom: 20px;
  max-width: 320px;
}
.wg-create-form input {
  flex: 1;
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 13px;
}
.wg-create-form button {
  padding: 8px 16px;
  background: #1565c0;
  color: #fff;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 13px;
}
.wg-create-form button:hover {
  background: #0d47a1;
}
.wg-empty {
  color: #9ca3af;
  padding: 64px 0;
  text-align: center;
}
.wg-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
}
.wg-card {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 24px 12px 20px;
  border: 1px solid #eee;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.15s;
  text-align: center;
}
.wg-card:hover {
  background: #f5f5f5;
  border-color: #d0d0d0;
}
.wg-card.active {
  border-color: #1565c0;
  background: #e3f2fd;
}
.wg-card-icon {
  font-size: 40px;
  margin-bottom: 12px;
}
.wg-card-name {
  font-size: 14px;
  font-weight: 500;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  width: 100%;
  white-space: nowrap;
}
.wg-card-pin {
  position: absolute;
  top: 6px;
  right: 6px;
  width: 24px;
  height: 24px;
  display: none;
  align-items: center;
  justify-content: center;
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 6px;
  cursor: pointer;
  font-size: 12px;
  padding: 0;
  line-height: 1;
}
.wg-card:hover .wg-card-pin {
  display: flex;
}
.wg-card-pin.pinned {
  display: flex;
  background: #e3f2fd;
  border-color: #1565c0;
}
</style>
