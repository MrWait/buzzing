import { describe, it, before } from 'node:test';
import assert from 'node:assert/strict';
import { initProto, getProto, BuzzingClient, fullLogin, getConfig, safeDecode, str } from '../../lib/index.js';

let client;
let chatId = null;
let sentMessageId = null;

/**
 * 创建一个群聊用于消息测试
 */
async function createChat() {
  const cmdEnum = getProto().lookupEnum('command.Command');
  const CreateChatRequest = getProto().lookupType('chat.CreateChatRequest');
  const Chat = getProto().lookupType('entity.Chat');
  const chat = Chat.create({
    chat_type: 2,
    name: `msg-test-chat-${Date.now()}`,
    member_ids: [String(client.userId)],
  });
  const reqBytes = CreateChatRequest.encode(
    CreateChatRequest.create({ chat })
  ).finish();

  const res = await client.httpRequest(cmdEnum.values.CHAT_CREATE, reqBytes);
  assert.ok(res.code === 0 || res.code === 200, `create chat code=${res.code}`);
  const dec = safeDecode(getProto(), 'chat.CreateChatResponse', res.data);
  assert.ok(dec.ok, `create chat decode failed: ${dec.error}`);
  return str(dec.result.chat_id);
}

before(async () => {
  await initProto();
  const config = getConfig();
  const result = await fullLogin(new BuzzingClient(), config.phone, config.password);
  client = result.client;
  chatId = await createChat();
});

describe('message', () => {

  it('should send a text message', async () => {
    assert.ok(chatId);

    const cmdEnum = getProto().lookupEnum('command.Command');
    const Message = getProto().lookupType('entity.Message');
    const MessageText = getProto().lookupType('entity.MessageText');
    const textContent = MessageText.encode(
      MessageText.create({ text: `hello-${Date.now()}` })
    ).finish();

    const draftMsg = Message.create({
      chat_id: chatId,
      tpy: 1,
      content: new Uint8Array(textContent),
    });

    // 直接发送消息，不经过 draft
    const sendCmd = cmdEnum.values.MESSAGE_SEND;
    const SendMessageRequest = getProto().lookupType('message.SendMessageRequest');
    const sendReqBytes = SendMessageRequest.encode(
      SendMessageRequest.create({ client_id: 0, message: draftMsg })
    ).finish();

    const sendRes = await client.httpRequest(sendCmd, sendReqBytes);
    if (sendRes.code !== 0 && sendRes.code !== 200) {
      const err = safeDecode(getProto(), 'entity.CommonError', sendRes.data);
      assert.fail(`send message failed code=${sendRes.code} error=${err.ok ? JSON.stringify(err.result) : err.error}`);
    }

    const dec = safeDecode(getProto(), 'message.SendMessageResponse', sendRes.data);
    assert.ok(dec.ok, `decode send response failed: ${dec.error}`);
    assert.ok(dec.result.id, 'should have message id');
    sentMessageId = str(dec.result.id);
  });

  it('should get messages by range', async () => {
    assert.ok(chatId, 'need a chat');
    assert.ok(sentMessageId, 'need a sent message');

    const cmdEnum = getProto().lookupEnum('command.Command');
    const GetMessageByRangeRequest = getProto().lookupType('message.GetMessageByRangeRequest');
    const reqBytes = GetMessageByRangeRequest.encode(
      GetMessageByRangeRequest.create({ chat_id: chatId, pos: 0, count: 10, direct: 3 })
    ).finish();

    const res = await client.httpRequest(cmdEnum.values.MESSAGE_GET_BY_RANGE, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `get range code=${res.code}`);

    const dec = safeDecode(getProto(), 'message.GetMessageByRangeResponse', res.data);
    assert.ok(dec.ok, `decode get range failed: ${dec.error}`);
    assert.ok(dec.result.entity?.messages, 'should have messages map');
    // map<int64> 的 key 是原始二进制字符串，需按 msg.id 查找
    const found = Object.values(dec.result.entity.messages).find(
      msg => str(msg.id) === sentMessageId
    );
    assert.ok(found, `should find our message ${sentMessageId} in range`);
  });

  it('should get message by IDs', async () => {
    assert.ok(sentMessageId);

    const cmdEnum = getProto().lookupEnum('command.Command');
    const GetMessageByIdsRequest = getProto().lookupType('message.GetMessageByIdsRequest');
    const reqBytes = GetMessageByIdsRequest.encode(
      GetMessageByIdsRequest.create({ ids: [sentMessageId] })
    ).finish();

    const res = await client.httpRequest(cmdEnum.values.MESSAGE_GET_BY_IDS, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `get by ids code=${res.code}`);

    const dec = safeDecode(getProto(), 'message.GetMessageByIdsResponse', res.data);
    assert.ok(dec.ok, `decode get by ids failed: ${dec.error}`);
    assert.ok(dec.result.entity?.messages, 'should have messages map');
    const found = Object.values(dec.result.entity.messages).find(
      msg => str(msg.id) === sentMessageId
    );
    assert.ok(found, `should find message by id ${sentMessageId}`);
  });

  it('should read messages', async () => {
    assert.ok(chatId && sentMessageId);

    const cmdEnum = getProto().lookupEnum('command.Command');
    const MessageReadRequest = getProto().lookupType('message.MessageReadRequest');
    const reqBytes = MessageReadRequest.encode(
      MessageReadRequest.create({ chat_id: chatId, max_pos: 0, message_ids: [sentMessageId] })
    ).finish();

    const res = await client.httpRequest(cmdEnum.values.MESSAGE_READ, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `read code=${res.code}`);
  });

  it('should set reaction on message', async () => {
    assert.ok(sentMessageId);

    const cmdEnum = getProto().lookupEnum('command.Command');
    const SetMessageReactitonRequest = getProto().lookupType('message.SetMessageReactitonRequest');
    const reqBytes = SetMessageReactitonRequest.encode(
      SetMessageReactitonRequest.create({ message_id: sentMessageId, reaction: 1, set: true })
    ).finish();

    const res = await client.httpRequest(cmdEnum.values.REACTION_SET, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `set reaction code=${res.code}`);
  });

});
