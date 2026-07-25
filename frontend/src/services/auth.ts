import api from './api'

export interface LoginParams {
  phone: string
  password: string
}

export interface UserInfo {
  id: string
  name: string
  avatar: string
  tenant_id?: string
  status?: number
  version?: number
  dept_id?: string
}

export interface TenantInfo {
  id: string
  name: string
  avatar: string
  root_department_id?: string
  owner_id?: string
  version?: number
}

export interface LoginUser {
  user: UserInfo
  token: string
  tenant: TenantInfo
  token_expire: number
}

export interface LoginResult {
  id: string
  name: string
  users: LoginUser[]
  version: number
}

export async function login(params: LoginParams): Promise<LoginResult> {
  const res = await api.post<LoginResult>('/accounts/login', params)
  return res.data
}
