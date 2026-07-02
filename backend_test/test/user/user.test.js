import { describe, it, before } from 'node:test';
import assert from 'node:assert/strict';
import { initProto, getProto, BuzzingClient, fullLogin, getConfig } from '../../lib/index.js';

let client;

before(async () => {
  await initProto();
  const config = getConfig();
  const result = await fullLogin(new BuzzingClient(), config.phone, config.password);
  client = result.client;
});

describe('user', () => {

  it('should get user by IDs', async () => {
    const cmdEnum = getProto().lookupEnum('command.Command');
    const cmd = cmdEnum.values.USER_GET_BY_IDS;

    const GetUserByIdsRequest = getProto().lookupType('user.GetUserByIdsRequest');
    const GetUserByIdsResponse = getProto().lookupType('user.GetUserByIdsResponse');

    const reqBytes = GetUserByIdsRequest.encode(
      GetUserByIdsRequest.create({ ids: [String(client.userId)] })
    ).finish();

    const res = await client.httpRequest(cmd, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `code=${res.code}`);

    const resp = GetUserByIdsResponse.decode(res.data);
    assert.ok(resp.users?.length >= 1);
    assert.equal(String(resp.users[0].id), String(client.userId));
  });

});
