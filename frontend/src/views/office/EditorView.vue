<template>
  <div class="editor-layout">
    <SpaceSidebar
      @search="searchOpen = true"
      @switch-view="navigateToView"
      @collapse-change="(c) => editorShifted = c"
    />
    <div class="editor-view" :class="{ 'sidebar-collapsed': editorShifted }">
      <header class="editor-header">
        <Breadcrumb :items="crumbs" />
        <div class="editor-header-right">
          <span v-if="isReadonly" class="readonly-tag">只读</span>
          <SyncStatus
            :state="saveState"
            :last-saved-at="lastSavedAt"
            :connected="connected"
          />
          <Collaborators :users="editingUsers" />
          <button
            v-if="perm.canEdit.value"
            class="header-btn"
            @click="showMembers = true"
          >
            成员
          </button>
          <button
            v-if="perm.canEdit.value"
            class="header-btn header-btn-primary"
            @click="showShare = true"
          >
            共享
          </button>
        </div>
      </header>
      <TitleBar :doc-id="docId" :readonly="isReadonly" />
      <ProseEditor :doc-id="docId" :readonly="isReadonly" />
    </div>
    <SearchBar v-model:open="searchOpen" />
    <MemberDialog :open="showMembers" :doc-id="docId" @close="showMembers = false" />
    <ShareDialog :open="showShare" :doc-id="docId" @close="showShare = false" />
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, provide, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useYjs } from '@/composables/useYjs'
import { useDocumentStore } from '@/stores/document'
import { docsApi } from '@/services/office/docs'
import { usePermission } from '@/composables/usePermission'
import SpaceSidebar from './components/SpaceSidebar.vue'
import TitleBar from './components/TitleBar.vue'
import ProseEditor from './components/ProseEditor.vue'
import Collaborators from './components/Collaborators.vue'
import SyncStatus from './components/SyncStatus.vue'
import Breadcrumb, { type BreadcrumbItem } from './components/Breadcrumb.vue'
import SearchBar from './components/SearchBar.vue'
import MemberDialog from './components/MemberDialog.vue'
import ShareDialog from './components/ShareDialog.vue'

const route = useRoute()
const router = useRouter()
const docId = route.params.docId as string

const {
  provider,
  type,
  connected,
  saveState,
  lastSavedAt,
  editingUsers,
} = useYjs(docId)
provide('yjs-type', type)
provide('yjs-provider', provider)

const store = useDocumentStore()
const searchOpen = ref(false)
const editorShifted = ref(false)
const showMembers = ref(false)
const showShare = ref(false)
const chain = ref<Array<{ id: string; title: string; icon: string | null }>>([])

const perm = usePermission(docId)
const isReadonly = computed(() => perm.readOnly.value)

// 上报访问 + 加载面包屑父链
onMounted(async () => {
  await store.reportVisit(docId)
  await loadChain(docId)
  if (store.spaces.length === 0) {
    await store.loadSpaces()
  }
})

watch(
  () => route.params.docId,
  async (id) => {
    if (typeof id === 'string' && id) {
      await store.reportVisit(id)
      await loadChain(id)
    }
  },
)

async function loadChain(id: string) {
  const list: Array<{ id: string; title: string; icon: string | null }> = []
  let cursor: string | null = id
  const visited = new Set<string>()
  while (cursor && !visited.has(cursor)) {
    visited.add(cursor)
    try {
      const { data } = await docsApi.get(cursor)
      list.unshift({ id: data.id, title: data.title || '未命名', icon: data.icon })
      cursor = data.parent_id
      // 顺便记录当前空间
      if (list.length === 1) {
        store.currentSpaceId = data.space_id
      }
    } catch {
      break
    }
  }
  chain.value = list
}

const crumbs = computed<BreadcrumbItem[]>(() => {
  const items: BreadcrumbItem[] = []
  const sp = store.spaces.find(s => s.id === store.currentSpaceId)
  if (sp) {
    items.push({ id: sp.id, label: sp.name, icon: sp.icon ?? undefined, route: { name: 'OfficeHome' } })
  }
  chain.value.forEach((n, idx) => {
    const isLast = idx === chain.value.length - 1
    items.push({
      id: n.id,
      label: n.title,
      icon: n.icon ?? undefined,
      route: isLast ? undefined : { name: 'OfficeEditor', params: { docId: n.id } },
    })
  })
  return items
})

function navigateToView(view: string) {
  if (view === 'trash') {
    router.push({ name: 'OfficeTrash' })
  } else {
    router.push({ name: 'OfficeHome' })
  }
}
</script>

<style scoped>
.editor-layout {
  display: flex;
  height: 100%;
  position: relative;
}

.editor-view {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background: #f0f0f0;
}
.editor-header {
  display: flex;
  align-items: center;
  gap: 16px;
  max-width: 1024px;
  width: 100%;
  margin: 0 auto;
  padding: 8px 24px 0;
}
.editor-header :deep(.breadcrumb) {
  flex: 1;
}
.editor-header-right {
  display: flex;
  align-items: center;
  gap: 12px;
}
.readonly-tag {
  padding: 2px 8px;
  background: #fff3e0;
  color: #e65100;
  border-radius: 4px;
  font-size: 12px;
}
.header-btn {
  padding: 6px 12px;
  border: 1px solid #d0d0d0;
  background: #fff;
  color: #333;
  border-radius: 4px;
  font-size: 13px;
  cursor: pointer;
  transition: background 0.15s;
}
.header-btn:hover {
  background: #f5f5f5;
}
.header-btn-primary {
  background: #1565c0;
  color: #fff;
  border-color: #1565c0;
}
.header-btn-primary:hover {
  background: #0d47a1;
}
.editor-view.sidebar-collapsed {
  padding-left: 60px;
}
</style>
