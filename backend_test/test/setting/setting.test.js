import { describe, it, before } from 'node:test';
import assert from 'node:assert/strict';
import { initProto, getProto, BuzzingClient, fullLogin, getConfig, safeDecode } from '../../lib/index.js';

let client;

before(async () => {
  await initProto();
  const config = getConfig();
  const result = await fullLogin(new BuzzingClient(), config.phone, config.password);
  client = result.client;
});

describe('setting', () => {

  it('should get all settings', async () => {
    const cmdEnum = getProto().lookupEnum('command.Command');
    const GetAllSettingsRequest = getProto().lookupType('setting.GetAllSettingsRequest');
    const reqBytes = GetAllSettingsRequest.encode(
      GetAllSettingsRequest.create({})
    ).finish();
    const res = await client.httpRequest(cmdEnum.values.SETTING_GET_ALL, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `code=${res.code} dataSize=${res.data.byteLength}`);

    if (res.data.byteLength > 0) {
      const dec = safeDecode(getProto(), 'setting.GetAllSettingsResponse', res.data);
      assert.ok(dec.ok, `decode failed: ${dec.error}`);
      assert.ok(dec.result.settings !== undefined, 'should have settings');
    } else {
      console.log('GetAllSettings returned empty payload');
    }
  });

  it('should get setting by type', async () => {
    const cmdEnum = getProto().lookupEnum('command.Command');
    const GetSettingByTypeRequest = getProto().lookupType('setting.GetSettingByTypeRequest');
    const reqBytes = GetSettingByTypeRequest.encode(
      GetSettingByTypeRequest.create({ type: 1 })
    ).finish();
    const res = await client.httpRequest(cmdEnum.values.SETTING_GET_BY_TYPE, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `code=${res.code} dataSize=${res.data.byteLength}`);

    if (res.data.byteLength > 0) {
      const dec = safeDecode(getProto(), 'setting.GetSettingByTypeResponse', res.data);
      assert.ok(dec.ok, `decode failed: ${dec.error}`);
      assert.ok(dec.result.setting !== undefined, 'should have setting');
    } else {
      console.log('GetSettingByType returned empty payload');
    }
  });

  it('should update setting by type', async () => {
    const cmdEnum = getProto().lookupEnum('command.Command');
    const UpdateSettingRequest = getProto().lookupType('setting.UpdateSettingRequest');
    const value = Buffer.from(JSON.stringify({ key: 'value', ts: Date.now() }), 'utf-8');
    const reqBytes = UpdateSettingRequest.encode(
      UpdateSettingRequest.create({ type: 1, value: new Uint8Array(value) })
    ).finish();
    const res = await client.httpRequest(cmdEnum.values.SETTING_UPDATE, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `code=${res.code} dataSize=${res.data.byteLength}`);
  });

  it('should read back updated setting', async () => {
    const cmdEnum = getProto().lookupEnum('command.Command');
    const GetSettingByTypeRequest = getProto().lookupType('setting.GetSettingByTypeRequest');
    const reqBytes = GetSettingByTypeRequest.encode(
      GetSettingByTypeRequest.create({ type: 1 })
    ).finish();
    const res = await client.httpRequest(cmdEnum.values.SETTING_GET_BY_TYPE, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `code=${res.code} dataSize=${res.data.byteLength}`);

    if (res.data.byteLength > 0) {
      const dec = safeDecode(getProto(), 'setting.GetSettingByTypeResponse', res.data);
      assert.ok(dec.ok, `decode failed: ${dec.error}`);
      assert.ok(dec.result.setting, 'should have setting after update');
    } else {
      console.log('GetSettingByType returned empty payload after update');
    }
  });

});
