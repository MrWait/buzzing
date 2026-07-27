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
      { path: 'trash', name: 'OfficeTrash', component: () => import('@/views/office/TrashView.vue') },
      {
        path: 'editor/:docId',
        name: 'OfficeEditor',
        component: () => import('@/views/office/EditorView.vue'),
      },
      {
        path: 'wiki/:wikiId',
        name: 'WikiHome',
        component: () => import('@/views/office/WikiView.vue'),
      },
      {
        path: 'wiki/:wikiId/:docId',
        name: 'WikiEditor',
        component: () => import('@/views/office/WikiEditorView.vue'),
      },
    ],
  },
  {
    path: '/im',
    component: () => import('@/views/im/ImHome.vue'),
    beforeEnter: tenantGuard,
    children: [
      { path: '', redirect: { name: 'ImFeed' } },
      { path: 'feed', name: 'ImFeed', component: { template: '<div />' } },
      {
        path: 'chat/:chatId',
        children: [
          { path: '', name: 'ImChatMain', component: () => import('@/views/im/chat/ChatPanel.vue') },
          { path: 'profile', name: 'ImGroupProfile', component: () => import('@/views/im/chat/GroupProfile.vue') },
        ],
      },
      { path: 'calendar', name: 'ImCalendar', component: { template: '<div />' } },
      { path: 'contacts', name: 'ImContacts', component: { template: '<div />' } },
    ],
  },
  {
    path: '/meeting',
    component: () => import('@/layouts/ModuleLayout.vue'),
    beforeEnter: tenantGuard,
    children: [
      { path: '', name: 'MeetingHome', component: () => import('@/views/meeting/MeetingHomeView.vue') },
    ],
  },
  {
    path: '/meeting/:roomId',
    component: () => import('@/layouts/FullscreenLayout.vue'),
    beforeEnter: tenantGuard,
    children: [
      { path: '', name: 'MeetingRoom', component: () => import('@/views/meeting/MeetingRoomView.vue') },
    ],
  },
  {
    path: '/open',
    component: () => import('@/layouts/ModuleLayout.vue'),
    beforeEnter: tenantGuard,
    children: [
      { path: '', name: 'AppList', component: () => import('@/views/openapp/AppList.vue') },
      { path: 'create', name: 'AppCreate', component: () => import('@/views/openapp/AppCreate.vue') },
      { path: ':id', name: 'AppDetail', component: () => import('@/views/openapp/AppDetail.vue') },
      { path: ':id/bot', name: 'AppBotConfig', component: () => import('@/views/openapp/AppBotConfig.vue') },
      { path: 'stats', name: 'ApiStats', component: () => import('@/views/openapp/ApiStats.vue') },
    ],
  },
  {
    path: '/share/:token',
    name: 'OfficeShare',
    component: () => import('@/views/office/ShareView.vue'),
  },
  { path: '/:pathMatch(.*)*', name: 'NotFound', component: () => import('@/views/error/NotFound.vue') },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
