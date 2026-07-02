import { describe, it, before } from 'node:test';
import assert from 'node:assert/strict';
import { initProto, getProto, BuzzingClient, fullLogin, getConfig, safeDecode, str, isNonZero } from '../../lib/index.js';

let client;
let createdChatId = null;

before(async () => {
  await initProto();
  const config = getConfig();
  const result = await fullLogin(new BuzzingClient(), config.phone, config.password);
  client = result.client;
});

describe('chat', () => {

  it('should create a group chat', async () => {
    const cmdEnum = getProto().lookupEnum('command.Command');
    const CreateChatRequest = getProto().lookupType('chat.CreateChatRequest');
    const Chat = getProto().lookupType('entity.Chat');
    const chat = Chat.create({
      chat_type: 2,
      name: `test-chat-${Date.now()}`,
      member_ids: [String(client.userId)],
    });
    const reqBytes = CreateChatRequest.encode(
      CreateChatRequest.create({ chat })
    ).finish();

    const res = await client.httpRequest(cmdEnum.values.CHAT_CREATE, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `code=${res.code}`);

    const dec = safeDecode(getProto(), 'chat.CreateChatResponse', res.data);
    assert.ok(dec.ok, `decode failed: ${dec.error}`);
    assert.ok(isNonZero(dec.result.chat_id), 'should have chat_id');
    createdChatId = str(dec.result.chat_id);
  });

  it('should get chat by IDs', async () => {
    assert.ok(createdChatId, 'need a created chat from previous test');

    const cmdEnum = getProto().lookupEnum('command.Command');
    const GetChatByIdsRequest = getProto().lookupType('chat.GetChatByIdsRequest');
    const reqBytes = GetChatByIdsRequest.encode(
      GetChatByIdsRequest.create({ ids: [createdChatId] })
    ).finish();

    const res = await client.httpRequest(cmdEnum.values.CHAT_GET_BY_IDS, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `code=${res.code}`);

    const dec = safeDecode(getProto(), 'chat.GetChatByIdsResponse', res.data);
    assert.ok(dec.ok, `decode failed: ${dec.error}`);

    const chats = dec.result.entities?.chats;
    assert.ok(chats, 'should have chats map');
    // map<int64> 的 key 是原始二进制字符串，需按 chat.id 查找
    const foundChat = Object.values(chats).find(c => str(c.id) === createdChatId);
    assert.ok(foundChat, `should contain our chat ${createdChatId}`);
    assert.ok(foundChat.name, 'chat should have a name');
  });

  it('should update chat name', async () => {
    assert.ok(createdChatId);

    const cmdEnum = getProto().lookupEnum('command.Command');
    const Chat = getProto().lookupType('entity.Chat');
    const UpdateChatRequest = getProto().lookupType('chat.UpdateChatRequest');
    const chat = Chat.create({
      id: createdChatId,
      name: `updated-chat-${Date.now()}`,
    });
    const reqBytes = UpdateChatRequest.encode(
      UpdateChatRequest.create({ chat })
    ).finish();

    const res = await client.httpRequest(cmdEnum.values.CHAT_UPDATE, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `code=${res.code}`);
  });

});
