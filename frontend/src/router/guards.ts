import type { NavigationGuardReturn, RouteLocationNormalized } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

export function authGuard(to: RouteLocationNormalized): NavigationGuardReturn {
  const auth = useAuthStore()
  if (!auth.token) {
    return { name: 'Login', query: { redirect: to.fullPath } }
  }
}

export function tenantGuard(to: RouteLocationNormalized): NavigationGuardReturn {
  const auth = useAuthStore()
  if (!auth.token) {
    return { name: 'Login', query: { redirect: to.fullPath } }
  }
  if (!auth.user) {
    return { name: 'TenantSelect' }
  }
}
