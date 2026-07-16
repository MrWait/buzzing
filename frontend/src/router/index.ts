import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'
import { tenantGuard } from './guards'
import { useAuthStore } from '@/stores/auth'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/layouts/AuthLayout.vue'),
    beforeEnter: () => {
      const auth = useAuthStore()
      if (auth.token && auth.currentTenant) {
        return { name: 'Hub' }
      }
    },
    children: [
      { path: '', component: () => import('@/views/login/LoginView.vue') },
    ],
  },
  {
    path: '/select-tenant',
    component: () => import('@/layouts/HubLayout.vue'),
    children: [
      { path: '', name: 'TenantSelect', component: () => import('@/views/tenant/TenantSelectView.vue') },
    ],
  },
  {
    path: '/hub',
    component: () => import('@/layouts/HubLayout.vue'),
    beforeEnter: tenantGuard,
    children: [
      { path: '', name: 'Hub', component: () => import('@/views/hub/HubView.vue') },
    ],
  },
  {
    path: '/',
    component: () => import('@/layouts/HubLayout.vue'),
    beforeEnter: tenantGuard,
    children: [
      { path: '', redirect: { name: 'Hub' } },
    ],
  },
  {
    path: '/office',
    component: () => import('@/layouts/ModuleLayout.vue'),
    beforeEnter: tenantGuard,
    children: [
      { path: '', name: 'OfficeHome', component: () => import('@/views/office/HomeView.vue') },
      {
        path: 'editor/:docId',
        name: 'OfficeEditor',
        component: () => import('@/views/office/EditorView.vue'),
      },
    ],
  },
  { path: '/:pathMatch(.*)*', name: 'NotFound', component: () => import('@/views/error/NotFound.vue') },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
