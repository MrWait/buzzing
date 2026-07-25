import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { UserInfo, TenantInfo, LoginUser } from '@/services/auth'
import * as authApi from '@/services/auth'

function loadUser(): UserInfo | null {
  try {
    const raw = localStorage.getItem('user')
    return raw ? (JSON.parse(raw) as UserInfo) : null
  } catch {
    return null
  }
}

export const useAuthStore = defineStore('auth', () => {
  const token = ref(localStorage.getItem('token') || '')
  const user = ref<UserInfo | null>(loadUser())
  const loginUsers = ref<LoginUser[]>([])
  const accountName = ref('')

  const currentTenant = computed<TenantInfo | null>(() => {
    const raw = localStorage.getItem('currentTenant')
    if (!raw) {
      console.log('[auth] no currentTenant in localStorage')
      return null
    }
    try {
      const parsed = JSON.parse(raw) as TenantInfo
      console.log('[auth] currentTenant from localStorage:', JSON.stringify(parsed))
      return parsed
    } catch {
      console.warn('[auth] failed to parse currentTenant:', raw)
      return null
    }
  })

  async function login(phone: string, password: string) {
    const res = await authApi.login({ phone, password })
    console.log('[auth] login response:', JSON.stringify(res, null, 2))
    accountName.value = res.name
    loginUsers.value = res.users
  }

  function selectIdentity(lu: LoginUser) {
    console.log('[auth] selectIdentity:', JSON.stringify(lu, null, 2))
    token.value = lu.token
    user.value = lu.user
    localStorage.setItem('token', lu.token)
    localStorage.setItem('user', JSON.stringify(lu.user))
    if (lu.tenant) {
      localStorage.setItem('currentTenant', JSON.stringify(lu.tenant))
    } else {
      localStorage.removeItem('currentTenant')
    }
  }

  function clear() {
    token.value = ''
    user.value = null
    loginUsers.value = []
    accountName.value = ''
    localStorage.removeItem('token')
    localStorage.removeItem('user')
    localStorage.removeItem('currentTenant')
  }

  return { token, user, loginUsers, accountName, currentTenant, login, selectIdentity, clear }
})
