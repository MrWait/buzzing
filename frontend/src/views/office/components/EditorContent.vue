<template>
  <div class="editor-content">
    <div class="editor-header-sticky">
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
          <div v-if="perm.canEdit.value" class="panel-trigger" ref="memberTriggerRef">
            <button class="header-btn" @click="toggleMembers">
              成员
            </button>
            <MemberDialog :open="showMembers" :doc-id="docId" />
          </div>
          <div v-if="perm.canEdit.value" class="panel-trigger" ref="shareTriggerRef">
            <button class="header-btn header-btn-primary" @click="toggleShare">
              共享
            </button>
            <ShareDialog :open="showShare" :doc-id="docId" />
          </div>
          <TopRightBar />
        </div>
      </header>
      <TitleBar :doc-id="docId" :readonly="isReadonly" />
    </div>
    <ProseEditor :doc-id="docId" :readonly="isReadonly" />
    <SearchBar v-model:open="searchOpen" />
  </div>
</template>

<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, provide, ref, watch } from 'vue'
import { useYjs } from '@/composables/useYjs'
import { useDocumentStore } from '@/stores/document'
import { docsApi } from '@/services/office/docs'
import { usePermission } from '@/composables/usePermission'
import TitleBar from './TitleBar.vue'
import ProseEditor from './ProseEditor.vue'
import Collaborators from './Collaborators.vue'
import SyncStatus from './SyncStatus.vue'
import Breadcrumb, { type BreadcrumbItem } from './Breadcrumb.vue'
import SearchBar from './SearchBar.vue'
import MemberDialog from './MemberDialog.vue'
import ShareDialog from './ShareDialog.vue'
import TopRightBar from '@/components/TopRightBar.vue'

const props = defineProps<{ docId: string; searchOpen?: boolean }>()
const emit = defineEmits<{ (e: 'update:searchOpen', v: boolean): void }>()

const {
  provider,
  type,
  connected,
  saveState,
  lastSavedAt,
  editingUsers,
} = useYjs(props.docId)
provide('yjs-type', type)
provide('yjs-provider', provider)

const store = useDocumentStore()
const searchOpen = ref(false)
const showMembers = ref(false)

// 双向绑定 searchOpen: 父级通过 @search 打开，本地通过 SearchBar @close 关闭
watch(() => props.searchOpen, (v) => {
  if (v !== undefined) searchOpen.value = v
})
watch(searchOpen, (v) => {
  emit('update:searchOpen', v)
})
const showShare = ref(false)
const memberTriggerRef = ref<HTMLElement | null>(null)

const shareTriggerRef = ref<HTMLElement | null>(null)

function toggleMembers() {
  showMembers.value = !showMembers.value
}
function toggleShare() {
  showShare.value = !showShare.value
}

function onOutsideClick(e: MouseEvent) {
  const t = e.target as Node
  if (showMembers.value && memberTriggerRef.value && !memberTriggerRef.value.contains(t)) {
    showMembers.value = false
  }
  if (showShare.value && shareTriggerRef.value && !shareTriggerRef.value.contains(t)) {
    showShare.value = false
  }
}
onMounted(() => document.addEventListener('click', onOutsideClick))
onBeforeUnmount(() => document.removeEventListener('click', onOutsideClick))
const chain = ref<Array<{ id: string; title: string; icon: string | null }>>([])

const perm = usePermission(props.docId)
const isReadonly = computed(() => perm.readOnly.value)

onMounted(async () => {
  await store.reportVisit(props.docId)
  await loadChain(props.docId)
  if (store.spaces.length === 0) {
    await store.loadSpaces()
  }
})

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
</script>

<style scoped>
.editor-content {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  background: #f0f0f0;
}
.editor-header-sticky {
  position: sticky;
  top: 0;
  z-index: 10;
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
.panel-trigger {
  position: relative;
}
</style>
