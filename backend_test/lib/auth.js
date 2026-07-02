import { getConfig } from './config.js';
import { parseJson } from './json.js';

/**
 * 1. 下载 Union Client Config
 * GET {host}/config/client → JSON
 */
export async function fetchConfig() {
  const config = getConfig();
  const url = `${config.host}/config/client`;
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`fetchConfig failed: ${response.status} ${response.statusText}`);
  }
  return await response.json();
}

/**
 * 2. 手机号 + 密码登录
 * POST /api/accounts/login → JSON Account (含 LoginUser 列表)
 *
 * @param {BuzzingClient} client
 * @param {string} phone
 * @param {string} password
 * @param {string} [loginUrl] 可选的完整登录 URL，默认从 config.host 拼接
 */
export async function loginByPhone(client, phone, password, loginUrl) {
  const config = getConfig();
  const url = loginUrl || `${config.host}/api/accounts/login`;

  const response = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ phone, password }),
  });

  if (!response.ok) {
    const text = await response.text().catch(() => '');
    throw new Error(`login failed: ${response.status} ${response.statusText}\n${text}`);
  }

  const text = await response.text();
  const account = parseJson(text);
  if (!account.users || account.users.length === 0) {
    throw new Error('login response has no users');
  }

  const loginUser = account.users[0];
  const token = loginUser.token;
  const user = loginUser.user;

  client.setAuth(token, account, user);
  return { token, user, account, loginUser };
}

/**
 * 3. 选择非个人用户租户身份
 */
export function selectNonPersonalIdentity(account) {
  for (const u of account.users) {
    if (u.tenant && u.tenant.id != null && String(u.tenant.id) !== '0') {
      return {
        loginUser: u,
        token: u.token,
        user: u.user,
        tenant: u.tenant,
      };
    }
  }
  throw new Error('No non-personal identity found in account');
}

/**
 * 完整登录流程：
 *   fetchConfig → applyUnionConfig → loginByPhone → selectNonPersonalIdentity
 *
 * 所有后续 HTTP/WS 请求的地址均从 Union Config 中读取。
 */
export async function fullLogin(client, phone, password) {
  const unionConfig = await fetchConfig();

  // 将 Union Config 应用到 client（设置 httpBase 和 wsUrl）
  client.applyUnionConfig(unionConfig);

  // 从 Union Config 构建登录 URL
  const httpBase = client._httpBase;
  const loginPath = unionConfig.api_login || '/api/accounts/login';
  const loginUrl = `${httpBase}${loginPath}`;

  const auth = await loginByPhone(client, phone, password, loginUrl);
  const identity = selectNonPersonalIdentity(auth.account);

  client.setAuth(identity.token, auth.account, identity.user);
  return {
    client,
    config: unionConfig,
    token: identity.token,
    user: identity.user,
    tenant: identity.tenant,
    account: auth.account,
    loginUser: identity.loginUser,
  };
}
