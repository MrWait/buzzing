import { computed, ref, watch } from 'vue'
import type { Ref } from 'vue'
import api from '@/services/api'

export const ROLE_VIEWER = 0
export const ROLE_COMMENTER = 1
export const ROLE_EDITOR = 2
export const ROLE_OWNER = 3

export function roleLabel(role: number): string {
  switch (role) {
    case ROLE_OWNER:
      return '所有者'
    case ROLE_EDITOR:
      return '编辑者'
    case ROLE_COMMENTER:
      return '评论者'
    default:
      return '阅读者'
  }
}

interface PermissionResp {
  role: number
  role_label: string
}

/**
 * 查询当前用户对文档的权限；共享 token 模式下直接使用传入的 role。
 */
export function usePermission(docId: Ref<string> | string, overrideRole?: Ref<number | null>) {
  const role = ref<number | null>(null)
  const loading = ref(true)
  const error = ref<string | null>(null)

  const canView = computed(() => (role.value ?? -1) >= ROLE_VIEWER)
  const canComment = computed(() => (role.value ?? -1) >= ROLE_COMMENTER)
  const canEdit = computed(() => (role.value ?? -1) >= ROLE_EDITOR)
  const isOwner = computed(() => (role.value ?? -1) >= ROLE_OWNER)
  const readOnly = computed(() => !canEdit.value)

  async function refresh() {
    if (overrideRole && overrideRole.value != null) {
      role.value = overrideRole.value
      loading.value = false
      return
    }
    const id = typeof docId === 'string' ? docId : docId.value
    if (!id) return
    loading.value = true
    error.value = null
    try {
      const { data } = await api.get<PermissionResp>(`/office/docs/${id}/permission`)
      role.value = data.role
    } catch (e: unknown) {
      role.value = null
      error.value = e instanceof Error ? e.message : String(e)
    } finally {
      loading.value = false
    }
  }

  if (typeof docId !== 'string') {
    watch(docId, refresh, { immediate: true })
  } else {
    refresh()
  }

  return {
    role,
    loading,
    error,
    canView,
    canComment,
    canEdit,
    isOwner,
    readOnly,
    refresh,
  }
}
