import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { initProto } from '../../lib/proto.js';
import {
  BuzzingClient,
  loginByPhone,
  selectNonPersonalIdentity,
  fetchConfig,
  fullLogin,
  getConfig,
} from '../../lib/index.js';

await initProto();

const config = getConfig();
let backendUp = false;
try {
  await fetch(`${config.host}/config/client`);
  backendUp = true;
} catch {
  console.log('Backend not available, skipping tests that require connection.');
}

describe('smoke: login flow', () => {

  it('should fetch union client config', { skip: !backendUp }, async () => {
    const unionConfig = await fetchConfig();
    assert.ok(unionConfig, 'unionConfig should be non-empty');
  });

  it('should login and select non-personal tenant user', { skip: !backendUp }, async () => {
    const client = new BuzzingClient();

    const auth = await loginByPhone(client, config.phone, config.password);
    assert.ok(auth.token, 'token should be non-empty');
    assert.ok(Array.isArray(auth.account.users), 'account.users should be an array');
    assert.ok(auth.account.users.length >= 1, 'should have at least one identity');

    const identity = selectNonPersonalIdentity(auth.account);
    assert.ok(identity.tenant, 'non-personal user should have a tenant');
    assert.ok(String(identity.tenant.id) !== '0', 'tenant.id should not be 0');
    assert.ok(identity.user, 'user should be present');
    assert.ok(identity.token, 'token should be present');

    client.setAuth(identity.token, auth.account, identity.user);
    assert.equal(client.userId, identity.user.id);
    assert.equal(client.tenantId, identity.user.tenant_id);
  });

  it('should call HTTP protobuf gateway as non-personal user', { skip: !backendUp }, async () => {
    const client = new BuzzingClient();
    const login = await fullLogin(client, config.phone, config.password);
    assert.ok(login.tenant, 'should be logged in as non-personal user');

    const proto = (await import('../../lib/proto.js')).getProto();
    const cmdEnum = proto.lookupEnum('command.Command');
    const cmd = cmdEnum.values.USER_GET_BY_IDS;

    const GetUserByIdsRequest = proto.lookupType('user.GetUserByIdsRequest');
    const GetUserByIdsResponse = proto.lookupType('user.GetUserByIdsResponse');

    const reqBytes = GetUserByIdsRequest.encode(
      GetUserByIdsRequest.create({ ids: [String(client.userId)] })
    ).finish();

    const res = await client.httpRequest(cmd, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `response code should be 0 or 200, got ${res.code}`);

    const resp = GetUserByIdsResponse.decode(res.data);
    assert.ok(resp.users?.length >= 1, 'should return at least one user');
    assert.equal(
      String(resp.users[0].id),
      String(client.userId),
      'returned user id should match'
    );
  });

  it('should connect WebSocket and send a request', { skip: !backendUp }, async () => {
    const client = new BuzzingClient();
    const login = await fullLogin(client, config.phone, config.password);
    assert.ok(login.tenant, 'should be logged in as non-personal user');

    try {
      await client.connectWs();
      assert.ok(client.wsConnected, 'WS should be connected');

      const proto = (await import('../../lib/proto.js')).getProto();
      const cmdEnum = proto.lookupEnum('command.Command');
      const cmd = cmdEnum.values.USER_GET_BY_IDS;

      const GetUserByIdsRequest = proto.lookupType('user.GetUserByIdsRequest');
      const GetUserByIdsResponse = proto.lookupType('user.GetUserByIdsResponse');

      const reqBytes = GetUserByIdsRequest.encode(
        GetUserByIdsRequest.create({ ids: [String(client.userId)] })
      ).finish();

      const res = await client.wsRequest(cmd, reqBytes);
      assert.ok(res.code === 0 || res.code === 200, `WS response code should be 0 or 200, got ${res.code}`);

      const resp = GetUserByIdsResponse.decode(res.data);
      assert.ok(resp.users?.length >= 1, 'WS should return at least one user');
      assert.equal(
        String(resp.users[0].id),
        String(client.userId),
        'returned user id should match'
      );
    } finally {
      client.closeWs();
    }
  });
});
