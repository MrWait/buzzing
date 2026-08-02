<template>
  <div v-if="accessDenied" class="access-denied">
    <div class="access-denied-icon">🚫</div>
    <p class="access-denied-text">你对该文档没有访问权限</p>
  </div>
  <div v-else class="editor-content">
    <div class="editor-header-sticky">
      <EditorHeader
        :crumbs="crumbs"
        :save-state="saveState"
        :last-saved-at="lastSavedAt"
        :connected="connected"
      >
        <span v-if="!canEdit" class="readonly-tag">只读</span>
        <Collaborators :users="editingUsers" />
        <div v-if="canEdit" class="panel-trigger" ref="shareTriggerRef">
          <button class="header-btn header-btn-primary" @click="toggleShare">
            共享
          </button>
          <ShareDialog v-model:open="showShare" :doc-id="docId" :trigger-rect="triggerRect" />
          <PageMenu v-model:open="showMenu" :doc-id="docId" :trigger-rect="menuTriggerRect" />
          <CreateMenu v-model:open="showCreate" :doc-id="docId" :parent-id="parentId" :wiki-id="wikiId" :trigger-rect="createTriggerRect" />
        </div>
        <button v-if="canEdit" class="header-btn" @click="toggleEditMode">
          {{ isPreview ? '预览' : '编辑' }}
        </button>
        <span class="icon-group">
          <span ref="menuTriggerRef" class="icon-btn" title="页面设置" @click="toggleMenu">⋯</span>
          <span class="icon-btn" title="搜索" @click="searchOpen = true">🔍</span>
          <span ref="createTriggerRef" class="icon-btn" title="新建文档" @click="toggleCreate">+</span>
        </span>
        <TopRightBar />
      </EditorHeader>
      <TitleBar :doc-id="docId" :model-value="docTitle" :readonly="isReadonly" />
    </div>
    <ProseEditor :doc-id="docId" :readonly="isReadonly" />
    <SearchBar v-model:open="searchOpen" />
  </div>
</template>

<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, provide, ref, watch } from 'vue'
import { useYjs } from '@/composables/useYjs'
import { useAuthStore } from '@/stores/auth'
import { useWikiStore } from '@/stores/wiki'
import { docsApi } from '@/services/office/docs'
import { ROLE_VIEWER, ROLE_EDITOR } from '@/composables/usePermission'
import TitleBar from './TitleBar.vue'
import ProseEditor from './ProseEditor.vue'
import Collaborators from './Collaborators.vue'
import SearchBar from './SearchBar.vue'
import EditorHeader from './EditorHeader.vue'
import type { BreadcrumbItem } from './Breadcrumb.vue'
import type { WalkItem } from '@/services/office/docs'
import ShareDialog from './ShareDialog.vue'
import PageMenu from './PageMenu.vue'
import CreateMenu from './CreateMenu.vue'
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
  connect,
} = useYjs(props.docId, { skipConnect: true })
provide('yjs-type', type)
provide('yjs-provider', provider)

const authStore = useAuthStore()
const wikiStore = useWikiStore()
const currentUserId = computed(() => authStore.user?.id ?? '')
const searchOpen = ref(false)

watch(() => props.searchOpen, (v) => {
  if (v !== undefined) searchOpen.value = v
})
watch(searchOpen, (v) => {
  emit('update:searchOpen', v)
})
const showShare = ref(false)
const shareTriggerRef = ref<HTMLElement | null>(null)
const showMenu = ref(false)
const menuTriggerRef = ref<HTMLElement | null>(null)
const showCreate = ref(false)
const createTriggerRef = ref<HTMLElement | null>(null)
const triggerRect = ref({ top: 0, bottom: 0, left: 0, right: 0, width: 0, height: 0 })
const menuTriggerRect = ref({ top: 0, bottom: 0, left: 0, right: 0, width: 0, height: 0 })
const createTriggerRect = ref({ top: 0, bottom: 0, left: 0, right: 0, width: 0, height: 0 })
const parentId = ref<string | null>(null)
const wikiId = ref<string | null>(null)

function updateTriggerRect() {
  if (shareTriggerRef.value) {
    const r = shareTriggerRef.value.getBoundingClientRect()
    triggerRect.value = { top: r.top, bottom: r.bottom, left: r.left, right: r.right, width: r.width, height: r.height }
  }
}

function toggleShare() {
  updateTriggerRect()
  showShare.value = !showShare.value
}

function toggleMenu() {
  if (menuTriggerRef.value) {
    const r = menuTriggerRef.value.getBoundingClientRect()
    menuTriggerRect.value = { top: r.top, bottom: r.bottom, left: r.left, right: r.right, width: r.width, height: r.height }
  }
  showMenu.value = !showMenu.value
}

function toggleCreate() {
  if (createTriggerRef.value) {
    const r = createTriggerRef.value.getBoundingClientRect()
    createTriggerRect.value = { top: r.top, bottom: r.bottom, left: r.left, right: r.right, width: r.width, height: r.height }
  }
  showCreate.value = !showCreate.value
}

function onResize() {
  if (showShare.value) updateTriggerRect()
}
onMounted(() => window.addEventListener('resize', onResize))
onBeforeUnmount(() => window.removeEventListener('resize', onResize))

function onOutsideClick(e: MouseEvent) {
  const t = e.target as Node
  if (showShare.value && shareTriggerRef.value && !shareTriggerRef.value.contains(t)) {
    showShare.value = false
  }
}
onMounted(() => document.addEventListener('click', onOutsideClick))
onBeforeUnmount(() => document.removeEventListener('click', onOutsideClick))

const isPreview = ref(false)
function toggleEditMode() {
  isPreview.value = !isPreview.value
}
const chain = ref<WalkItem[]>([])
const docTitle = ref('')

const accessDenied = ref(false)
const role = ref(ROLE_VIEWER)
const canEdit = computed(() => role.value >= ROLE_EDITOR)
const isReadonly = computed(() => role.value < ROLE_EDITOR || isPreview.value)

onMounted(async () => {
  try {
    const { data } = await docsApi.get(props.docId)
    role.value = data.role
    docTitle.value = data.title
    chain.value = data.walk
    parentId.value = data.parent_id
    wikiId.value = data.wiki_id
    if (data.wiki_id) {
      wikiStore.setCurrentWiki(data.wiki_id)
    }
    connect()
  } catch {
    accessDenied.value = true
  }
})

const crumbs = computed<BreadcrumbItem[]>(() => {
  const items: BreadcrumbItem[] = []
  chain.value.forEach((n, idx) => {
    const isLast = idx === chain.value.length - 1
    const isUserRoot = n.id === currentUserId.value
    const isWikiRoot = n.type === 1
    items.push({
      id: n.id,
      label: n.title,
      icon: n.icon ?? undefined,
      route: isLast
        ? undefined
        : isUserRoot
          ? { name: 'OfficeHome' }
          : isWikiRoot
            ? { name: 'WikiHome', params: { wikiId: n.id } }
            : { name: 'OfficeEditor', params: { docId: n.id } },
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
.readonly-tag {
  padding: 2px 8px;
  background: #fff3e0;
  color: #e65100;
  border-radius: 4px;
  font-size: 12px;
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
.icon-group {
  display: inline-flex;
  align-items: center;
  gap: 2px;
}
.icon-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 15px;
  line-height: 1;
  color: #6b7280;
  transition: background 0.15s;
}
.icon-btn:hover {
  background: #e5e7eb;
  color: #374151;
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
.access-denied {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 16px;
  padding: 48px;
}
.access-denied-icon {
  font-size: 48px;
  opacity: 0.6;
}
.access-denied-text {
  font-size: 16px;
  color: #6b7280;
}
</style>
