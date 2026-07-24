import api from './api'

function unwrap<T>(res: { data: { data: T } }): T {
  return res.data.data
}

export interface OpenApp {
  id: string
  name: string
  description?: string
  icon_url?: string
  app_id: string
  app_secret: string
  callback_url?: string
  status: string
  created_at: string
  updated_at: string
}

export interface RedirectUri {
  id: number
  app_id: number
  uri: string
}

export interface OutgoingWebhook {
  id: number
  app_id: number
  name: string
  url: string
  enabled: boolean
}

export interface ScheduledTask {
  id: number
  app_id: number
  name: string
  cron_expr: string
  action_type: string
  action_config: Record<string, unknown>
  enabled: boolean
}

export interface AppBotConfig {
  webhook_url?: string
  token?: string
  auto_reply?: boolean
  [key: string]: unknown
}

export interface AppStats {
  total_calls?: number
  error_count?: number
  daily_stats?: Record<string, number>
}

export interface Version {
  id: number
  app_id: number
  version: string
  description?: string
  status: string
  created_at: string
}

export interface Review {
  id: number
  app_id: number
  version_id: number
  reviewer_id: number
  status: string
  comment?: string
  created_at: string
}

export interface DashboardOverview {
  total_apps: number
  total_installations: number
  total_calls_today: number
  pending_reviews: number
}

export interface TrendPoint {
  date: string
  calls: number
  installations: number
}

export async function listApps(): Promise<OpenApp[]> {
  const res = await api.get('/openapi/v1/apps')
  const body = unwrap(res) as { items: OpenApp[] }
  return body.items ?? []
}

export async function createApp(data: {
  name: string
  description?: string
  callback_url?: string
}): Promise<OpenApp> {
  const res = await api.post('/openapi/v1/apps', data)
  return unwrap(res) as OpenApp
}

export async function getApp(id: string): Promise<OpenApp> {
  const res = await api.get(`/openapi/v1/apps/${id}`)
  return unwrap(res) as OpenApp
}

export async function updateApp(
  id: string,
  data: Partial<Pick<OpenApp, 'name' | 'description' | 'icon_url' | 'callback_url'>>,
): Promise<OpenApp> {
  const res = await api.patch(`/openapi/v1/apps/${id}`, data)
  return unwrap(res) as OpenApp
}

export async function deleteApp(id: string): Promise<void> {
  await api.delete(`/openapi/v1/apps/${id}`)
}

export async function regenerateSecret(id: string): Promise<{ app_secret: string }> {
  const res = await api.post(`/openapi/v1/apps/${id}/regenerate-secret`)
  return unwrap(res) as { app_secret: string }
}

// OAuth
export async function listRedirectUris(appId: string): Promise<RedirectUri[]> {
  const res = await api.get(`/openapi/v1/apps/${appId}/redirect-uris`)
  return unwrap(res) as RedirectUri[]
}

export async function addRedirectUri(appId: string, uri: string): Promise<RedirectUri> {
  const res = await api.post(`/openapi/v1/apps/${appId}/redirect-uris`, { uri })
  return unwrap(res) as RedirectUri
}

export async function deleteRedirectUri(appId: string, uriId: number): Promise<void> {
  await api.delete(`/openapi/v1/apps/${appId}/redirect-uris/${uriId}`)
}

// Webhooks
export async function listWebhooks(appId: string): Promise<OutgoingWebhook[]> {
  const res = await api.get(`/openapi/v1/apps/${appId}/webhooks`)
  return unwrap(res) as OutgoingWebhook[]
}

export async function createWebhook(
  appId: string,
  data: { name: string; url: string },
): Promise<OutgoingWebhook> {
  const res = await api.post(`/openapi/v1/apps/${appId}/webhooks`, data)
  return unwrap(res) as OutgoingWebhook
}

export async function updateWebhook(
  appId: string,
  whId: number,
  data: Partial<OutgoingWebhook>,
): Promise<OutgoingWebhook> {
  const res = await api.patch(`/openapi/v1/apps/${appId}/webhooks/${whId}`, data)
  return unwrap(res) as OutgoingWebhook
}

export async function deleteWebhook(appId: string, whId: number): Promise<void> {
  await api.delete(`/openapi/v1/apps/${appId}/webhooks/${whId}`)
}

// Tasks
export async function listTasks(appId: string): Promise<ScheduledTask[]> {
  const res = await api.get(`/openapi/v1/apps/${appId}/tasks`)
  return unwrap(res) as ScheduledTask[]
}

export async function createTask(
  appId: string,
  data: {
    name: string
    cron_expr: string
    action_type: string
    action_config: Record<string, unknown>
  },
): Promise<ScheduledTask> {
  const res = await api.post(`/openapi/v1/apps/${appId}/tasks`, data)
  return unwrap(res) as ScheduledTask
}

export async function updateTask(
  appId: string,
  taskId: number,
  data: Partial<ScheduledTask>,
): Promise<ScheduledTask> {
  const res = await api.patch(`/openapi/v1/apps/${appId}/tasks/${taskId}`, data)
  return unwrap(res) as ScheduledTask
}

export async function deleteTask(appId: string, taskId: number): Promise<void> {
  await api.delete(`/openapi/v1/apps/${appId}/tasks/${taskId}`)
}

export async function pauseTask(appId: string, taskId: number): Promise<void> {
  await api.post(`/openapi/v1/apps/${appId}/tasks/${taskId}/pause`)
}

export async function resumeTask(appId: string, taskId: number): Promise<void> {
  await api.post(`/openapi/v1/apps/${appId}/tasks/${taskId}/resume`)
}

// Bot
export async function getBotConfig(appId: string): Promise<AppBotConfig> {
  const res = await api.get(`/openapi/v1/apps/${appId}/bot`)
  return unwrap(res) as AppBotConfig
}

export async function updateBotConfig(
  appId: string,
  data: AppBotConfig,
): Promise<AppBotConfig> {
  const res = await api.patch(`/openapi/v1/apps/${appId}/bot`, data)
  return unwrap(res) as AppBotConfig
}

// Stats & Logs
export async function getAppStats(
  appId: string,
  params?: { start_date?: string; end_date?: string },
): Promise<AppStats> {
  const res = await api.get(`/openapi/v1/apps/${appId}/stats`, { params })
  return unwrap(res) as AppStats
}

export async function getErrorLogs(
  appId: string,
  params?: { limit?: number; offset?: number },
): Promise<unknown[]> {
  const res = await api.get(`/openapi/v1/apps/${appId}/error-logs`, { params })
  return unwrap(res) as unknown[]
}

// Versions
export async function listVersions(appId: string): Promise<Version[]> {
  const res = await api.get(`/openapi/v1/apps/${appId}/versions`)
  return unwrap(res) as Version[]
}

export async function submitVersion(
  appId: string,
  data: { version: string; description?: string },
): Promise<Version> {
  const res = await api.post(`/openapi/v1/apps/${appId}/versions`, data)
  return unwrap(res) as Version
}

// Admin
export async function listReviews(params?: {
  status?: string
  limit?: number
  offset?: number
}): Promise<Review[]> {
  const res = await api.get('/openapi/v1/admin/reviews', { params })
  return unwrap(res) as Review[]
}

export async function getReviewDetail(reviewId: number): Promise<Review> {
  const res = await api.get(`/openapi/v1/admin/reviews/${reviewId}`)
  return unwrap(res) as Review
}

export async function approveReview(
  reviewId: number,
  comment?: string,
): Promise<void> {
  await api.post(`/openapi/v1/admin/reviews/${reviewId}/approve`, { comment })
}

export async function rejectReview(
  reviewId: number,
  comment: string,
): Promise<void> {
  await api.post(`/openapi/v1/admin/reviews/${reviewId}/reject`, { comment })
}

export async function unpublishApp(appId: number): Promise<void> {
  await api.post(`/openapi/v1/admin/apps/${appId}/unpublish`)
}

// Dashboard
export async function getDashboardOverview(): Promise<DashboardOverview> {
  const res = await api.get('/openapi/v1/admin/dashboard/overview')
  return unwrap(res) as DashboardOverview
}

export async function getDashboardTrends(params?: {
  days?: number
}): Promise<TrendPoint[]> {
  const res = await api.get('/openapi/v1/admin/dashboard/trends', { params })
  return unwrap(res) as TrendPoint[]
}
