import { useAuthStore } from '@/stores/auth'
import { encode, decode, nextRid } from './im/proto'

const PACKET_TYPE = 'entity.Packet'

function authHeader(): Record<string, string> {
  const token = useAuthStore().token
  return token ? { Authorization: `Bearer ${token}` } : {}
}

export async function apiV1<T>(
  cmd: number,
  payload: Uint8Array,
  resType?: string,
): Promise<{ code: number; data: T }> {
  const rid = parseInt(nextRid(), 10)

  const packet = encode(PACKET_TYPE, { rid, cmd, payload })
  const res = await fetch('/api/v1/raw', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-protobuf',
      'X-Cmd': String(cmd),
      'X-Rid': String(rid),
      ...authHeader(),
    },
    body: packet,
  })
  if (!res.ok) {
    throw new Error(`api_v1 error: ${res.status}`)
  }
  const buf = new Uint8Array(await res.arrayBuffer())
  const resPacket = decode(PACKET_TYPE, buf)
  if (resPacket.code !== 0) {
    throw new Error(`api_v1 cmd=${cmd} code=${resPacket.code}`)
  }
  if (resType) {
    const data = decode(resType, resPacket.payload) as T
    return { code: resPacket.code, data }
  }
  return { code: resPacket.code, data: resPacket.payload as T }
}

export function encodeReq(typeName: string, data: Record<string, any>): Uint8Array {
  return encode(typeName, data)
}
