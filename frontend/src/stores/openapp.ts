import { defineStore } from 'pinia'
import { ref } from 'vue'
import type {
  OpenApp,
  RedirectUri,
  OutgoingWebhook,
  ScheduledTask,
  AppBotConfig,
  AppStats,
  Version,
  Review,
  DashboardOverview,
  TrendPoint,
} from '@/services/openapp'
import * as openappApi from '@/services/openapp'

export const useOpenAppStore = defineStore('openapp', () => {
  const apps = ref<OpenApp[]>([])
  const currentApp = ref<OpenApp | null>(null)
  const redirectUris = ref<RedirectUri[]>([])
  const webhooks = ref<OutgoingWebhook[]>([])
  const tasks = ref<ScheduledTask[]>([])
  const botConfig = ref<AppBotConfig | null>(null)
  const stats = ref<AppStats | null>(null)
  const versions = ref<Version[]>([])
  const reviews = ref<Review[]>([])
  const dashboard = ref<DashboardOverview | null>(null)
  const trends = ref<TrendPoint[]>([])
  const loading = ref(false)

  async function loadApps() {
    loading.value = true
    try {
      apps.value = await openappApi.listApps()
    } finally {
      loading.value = false
    }
  }

  async function createApp(data: {
    name: string
    description?: string
    callback_url?: string
  }): Promise<OpenApp> {
    const app = await openappApi.createApp(data)
    apps.value.push(app)
    return app
  }

  async function loadApp(id: string) {
    loading.value = true
    try {
      currentApp.value = await openappApi.getApp(id)
    } finally {
      loading.value = false
    }
  }

  async function updateApp(
    id: string,
    data: Partial<Pick<OpenApp, 'name' | 'description' | 'icon_url' | 'callback_url'>>,
  ) {
    currentApp.value = await openappApi.updateApp(id, data)
  }

  async function removeApp(id: string) {
    await openappApi.deleteApp(id)
    apps.value = apps.value.filter((a) => a.id !== id)
    currentApp.value = null
  }

  async function regenerateSecret(id: string) {
    const result = await openappApi.regenerateSecret(id)
    if (currentApp.value) {
      currentApp.value.app_secret = result.app_secret
    }
    return result
  }

  async function loadRedirectUris(appId: string) {
    redirectUris.value = await openappApi.listRedirectUris(appId)
  }

  async function addRedirectUri(appId: string, uri: string) {
    await openappApi.addRedirectUri(appId, uri)
    await loadRedirectUris(appId)
  }

  async function removeRedirectUri(appId: string, uriId: number) {
    await openappApi.deleteRedirectUri(appId, uriId)
    await loadRedirectUris(appId)
  }

  async function loadWebhooks(appId: string) {
    webhooks.value = await openappApi.listWebhooks(appId)
  }

  async function createWebhook(appId: string, data: { name: string; url: string }) {
    await openappApi.createWebhook(appId, data)
    await loadWebhooks(appId)
  }

  async function updateWebhook(appId: string, whId: number, data: Partial<OutgoingWebhook>) {
    await openappApi.updateWebhook(appId, whId, data)
    await loadWebhooks(appId)
  }

  async function removeWebhook(appId: string, whId: number) {
    await openappApi.deleteWebhook(appId, whId)
    await loadWebhooks(appId)
  }

  async function loadTasks(appId: string) {
    tasks.value = await openappApi.listTasks(appId)
  }

  async function createTask(
    appId: string,
    data: {
      name: string
      cron_expr: string
      action_type: string
      action_config: Record<string, unknown>
    },
  ) {
    await openappApi.createTask(appId, data)
    await loadTasks(appId)
  }

  async function updateTask(
    appId: string,
    taskId: number,
    data: Partial<ScheduledTask>,
  ) {
    await openappApi.updateTask(appId, taskId, data)
    await loadTasks(appId)
  }

  async function removeTask(appId: string, taskId: number) {
    await openappApi.deleteTask(appId, taskId)
    await loadTasks(appId)
  }

  async function toggleTask(appId: string, taskId: number, enabled: boolean) {
    if (enabled) {
      await openappApi.resumeTask(appId, taskId)
    } else {
      await openappApi.pauseTask(appId, taskId)
    }
    await loadTasks(appId)
  }

  async function loadBotConfig(appId: string) {
    try {
      botConfig.value = await openappApi.getBotConfig(appId)
    } catch {
      botConfig.value = null
    }
  }

  async function updateBotConfig(appId: string, data: AppBotConfig) {
    botConfig.value = await openappApi.updateBotConfig(appId, data)
  }

  async function loadStats(appId: string) {
    stats.value = await openappApi.getAppStats(appId)
  }

  async function loadVersions(appId: string) {
    versions.value = await openappApi.listVersions(appId)
  }

  async function submitVersion(
    appId: string,
    data: { version: string; description?: string },
  ) {
    await openappApi.submitVersion(appId, data)
    await loadVersions(appId)
  }

  async function loadReviews(params?: { status?: string; limit?: number; offset?: number }) {
    reviews.value = await openappApi.listReviews(params)
  }

  async function approveReview(reviewId: number, comment?: string) {
    await openappApi.approveReview(reviewId, comment)
    await loadReviews()
  }

  async function rejectReview(reviewId: number, comment: string) {
    await openappApi.rejectReview(reviewId, comment)
    await loadReviews()
  }

  async function loadDashboard() {
    dashboard.value = await openappApi.getDashboardOverview()
    trends.value = await openappApi.getDashboardTrends()
  }

  return {
    apps,
    currentApp,
    redirectUris,
    webhooks,
    tasks,
    botConfig,
    stats,
    versions,
    reviews,
    dashboard,
    trends,
    loading,
    loadApps,
    createApp,
    loadApp,
    updateApp,
    removeApp,
    regenerateSecret,
    loadRedirectUris,
    addRedirectUri,
    removeRedirectUri,
    loadWebhooks,
    createWebhook,
    updateWebhook,
    removeWebhook,
    loadTasks,
    createTask,
    updateTask,
    removeTask,
    toggleTask,
    loadBotConfig,
    updateBotConfig,
    loadStats,
    loadVersions,
    submitVersion,
    loadReviews,
    approveReview,
    rejectReview,
    loadDashboard,
  }
})
