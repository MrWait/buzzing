import api from './api'

export interface LoginParams {
  phone: string
  password: string
}

export interface TenantInfo {
  id: string
  name: string
  avatar: string
}

export interface UserInfo {
  id: string
  name: string
  avatar: string
}

export interface LoginUser {
  user: UserInfo
  token: string
  tenant: TenantInfo
  token_expire: string
}

export interface LoginResult {
  id: string
  name: string
  users: LoginUser[]
  version: string
}

export async function login(params: LoginParams): Promise<LoginResult> {
  const res = await api.post<LoginResult>('/accounts/login', params)
  return res.data
}
