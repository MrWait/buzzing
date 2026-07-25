import { useAuthStore } from '@/stores/auth'
import { lookup, encode, nextRid } from './proto'
import api from '@/services/api'

export interface DeptInfo {
  id: number
  parentId: number
  tenantId: number
  name: string
  memberIds: number[]
  subDepartmentIds: number[]
}

export interface UserInfo {
  id: number
  name: string
  avatar: string
  status: number
  deptId: number
}

export interface DeptData {
  departments: DeptInfo[]
  users: UserInfo[]
}

const CMD = {
  DEPT_GET_BY_ID: 1350,
}

async function protoRequest(
  cmd: number,
  reqMsg: string,
  reqData: Record<string, any>,
  respMsg: string,
): Promise<any> {
  const packetType = lookup('entity.Packet')
  const respType = lookup(respMsg)
  const reqPayload = encode(reqMsg, reqData)
  const rid = nextRid()
  const auth = useAuthStore()
  const boundary = `----FormBoundary${Date.now()}${Math.random()}`
  const encoder = new TextEncoder()
  const header = encoder.encode(
    `--${boundary}\r\nContent-Disposition: form-data; name="data"\r\nContent-Type: application/octet-stream\r\n\r\n`,
  )
  const footer = encoder.encode(`\r\n--${boundary}--\r\n`)
  const parts = [header, reqPayload, footer]
  const totalLen = parts.reduce((s, p) => s + p.byteLength, 0)
  const body = new Uint8Array(totalLen)
  let offset = 0
  for (const p of parts) {
    body.set(p, offset)
    offset += p.byteLength
  }
  const res = await api.post('/v1', body, {
    headers: {
      'Content-Type': `multipart/form-data; boundary=${boundary}`,
      rid,
      cmd: cmd.toString(),
      Authorization: `Bearer ${auth.token}`,
    },
    responseType: 'arraybuffer',
  })
  const code = parseInt(res.headers['code'] || '0', 10)
  const data = new Uint8Array(res.data)
    if (code !== 0) {
    throw new Error(`contacts request failed: cmd=${cmd} code=${code}`)
  }
  const packet = packetType.decode(data) as unknown as { payload: Uint8Array }
  return respType.decode(packet.payload)
}

function parseDepts(raw: Record<string, any> | undefined): DeptInfo[] {
  if (!raw) return []
  return Object.keys(raw).map((k) => {
    const d = raw[k]
    return {
      id: d.id,
      parentId: d.parent_id || 0,
      tenantId: d.tenant_id,
      name: d.name || '',
      memberIds: (d.member_ids || []).map(Number),
      subDepartmentIds: (d.sub_department_ids || []).map(Number),
    }
  })
}

function parseUsers(raw: Record<string, any> | undefined): UserInfo[] {
  if (!raw) return []
  return Object.keys(raw).map((k) => {
    const u = raw[k]
    return {
      id: u.id,
      name: u.name || '',
      avatar: u.avatar || '',
      status: u.status || 0,
      deptId: u.dept_id || 0,
    }
  })
}

export async function getDeptById(id: number, tenantId?: number | string): Promise<DeptData> {
  const req: Record<string, any> = { id, recursive: false }
  if (tenantId) req.tenant_id = tenantId
  console.log('[contacts] getDeptById request:', JSON.stringify(req))
  const resp = await protoRequest(CMD.DEPT_GET_BY_ID, 'dept.GetDeptRequest', req, 'dept.GetDeptResponse')
  return {
    departments: parseDepts(resp.depts),
    users: parseUsers(resp.users),
  }
}
