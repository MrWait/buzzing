<template>
  <Teleport to="body">
    <div v-if="open" class="diff-overlay" @click.self="close">
      <div class="diff-modal">
        <div class="diff-header">
          <h3>版本对比</h3>
          <div class="diff-hdr-info">
            <span class="diff-badge diff-badge--add">+{{ stats.additions }} 处新增</span>
            <span class="diff-badge diff-badge--del">-{{ stats.deletions }} 处删除</span>
          </div>
          <button class="diff-close" @click="close">&times;</button>
        </div>
        <div v-if="loading" class="diff-loading">加载中…</div>
        <div v-else-if="errMsg" class="diff-err">{{ errMsg }}</div>
        <div v-else class="diff-body">
          <div v-for="(line, i) in lines" :key="i" :class="['diff-line', `diff-line--${line.type}`]">
            <span class="diff-line-num">{{ line.pos + 1 }}</span>
            <span class="diff-line-sign">{{ line.type === 'insert' ? '+' : line.type === 'delete' ? '-' : ' ' }}</span>
            <span class="diff-line-text">{{ line.text || ' ' }}</span>
          </div>
          <div v-if="lines.length === 0" class="diff-empty">两个版本内容相同</div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { onMounted, ref, watch } from 'vue'
import { versionsApi, type DiffLine, type DiffStats } from '@/services/office/versions'

const props = defineProps<{
  open: boolean
  docId: string
  v1Id: string
  v2Id: string
}>()
const emit = defineEmits<{ (e: 'close'): void }>()

const lines = ref<DiffLine[]>([])
const stats = ref<DiffStats>({ additions: 0, deletions: 0 })
const loading = ref(false)
const errMsg = ref<string | null>(null)

watch(
  () => [props.open, props.v1Id, props.v2Id],
  ([open]) => {
    if (open) loadDiff()
  },
)
onMounted(() => {
  if (props.open) loadDiff()
})

function close() {
  emit('close')
}

async function loadDiff() {
  if (!props.v1Id || !props.v2Id) return
  loading.value = true
  errMsg.value = null
  try {
    const { data } = await versionsApi.diff(props.docId, props.v1Id, props.v2Id)
    lines.value = data.ops
    stats.value = data.stats
  } catch (e) {
    errMsg.value = e instanceof Error ? e.message : String(e)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.diff-overlay {
  position: fixed;
  inset: 0;
  z-index: 1000;
  background: rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
}
.diff-modal {
  background: #fff;
  border-radius: 10px;
  width: 80vw;
  max-width: 900px;
  max-height: 80vh;
  display: flex;
  flex-direction: column;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
}
.diff-header {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px 20px;
  border-bottom: 1px solid #e0e0e0;
}
.diff-header h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
}
.diff-hdr-info {
  display: flex;
  gap: 8px;
  margin-left: auto;
}
.diff-badge {
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
}
.diff-badge--add {
  background: #e8f5e9;
  color: #2e7d32;
}
.diff-badge--del {
  background: #ffebee;
  color: #c62828;
}
.diff-close {
  width: 32px;
  height: 32px;
  border: none;
  background: transparent;
  font-size: 22px;
  cursor: pointer;
  color: #666;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
}
.diff-close:hover {
  background: #f0f0f0;
}
.diff-body {
  flex: 1;
  overflow-y: auto;
  padding: 8px 0;
  font-family: 'SFMono-Regular', 'Menlo', 'Monaco', 'Consolas', monospace;
  font-size: 13px;
  line-height: 1.6;
}
.diff-line {
  display: flex;
  padding: 0 20px;
  min-height: 22px;
}
.diff-line--insert {
  background: #e8f5e9;
}
.diff-line--delete {
  background: #ffebee;
}
.diff-line-num {
  width: 40px;
  text-align: right;
  color: #999;
  padding-right: 12px;
  user-select: none;
}
.diff-line-sign {
  width: 16px;
  color: #666;
  user-select: none;
}
.diff-line-text {
  flex: 1;
  white-space: pre-wrap;
  word-break: break-all;
}
.diff-loading,
.diff-err,
.diff-empty {
  padding: 40px;
  text-align: center;
  color: #888;
  font-size: 14px;
}
.diff-err {
  color: #d32f2f;
}
</style>
