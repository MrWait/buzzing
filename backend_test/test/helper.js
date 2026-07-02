import { initProto } from '../lib/proto.js';
import { BuzzingClient, fullLogin, getConfig } from '../lib/index.js';

export async function init() {
  await initProto();
}

/**
 * 创建一个已登录的客户端，使用非个人用户租户身份。
 */
export async function createLoggedInClient() {
  await initProto();
  const config = getConfig();
  const client = new BuzzingClient();
  const result = await fullLogin(client, config.phone, config.password);
  return result;
}
