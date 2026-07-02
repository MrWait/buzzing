/**
 * 安全解码 protobuf 响应。
 * 优先尝试按指定类型解码；失败时尝试解码为 CommonError。
 */
export function safeDecode(proto, typeName, data) {
  try {
    const type = proto.lookupType(typeName);
    const result = type.decode(data);
    return { ok: true, result };
  } catch (e) {
    try {
      const errorType = proto.lookupType('entity.CommonError');
      const err = errorType.decode(data);
      return { ok: false, error: `decode ${typeName} failed: ${e.message}`, commonError: err, raw: data };
    } catch {
      return { ok: false, error: `decode ${typeName} failed: ${e.message}`, raw: data };
    }
  }
}

/**
 * 将 protobuf 中的 int64/Long 字段转为字符串进行比较。
 * protobufjs 对 int64 字段返回 Long 对象，不能直接用 === 比较。
 */
export function str(val) {
  if (val === null || val === undefined) return val;
  return String(val);
}

/**
 * 检查 int64 值是否为 0（兼容 Long 对象）。
 */
export function isZero(val) {
  if (val === 0 || val === '0') return true;
  if (val && typeof val === 'object' && val.low === 0 && val.high === 0) return true;
  return false;
}

/**
 * 检查 int64 值是否非空（兼容 Long 对象）。
 */
export function isNonZero(val) {
  if (val === null || val === undefined) return false;
  if (typeof val === 'number') return val !== 0;
  if (typeof val === 'string') return val !== '0' && val !== '';
  if (typeof val === 'object' && val.low !== undefined) {
    return val.low !== 0 || val.high !== 0;
  }
  return true;
}
