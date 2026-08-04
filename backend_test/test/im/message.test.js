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

  it('should get read members (full list)', async () => {
    assert.ok(chatId && sentMessageId);

    // 已读详情：全量返回成员（含读/未读状态）。单用户已读自己消息 → 应有至少 1 名已读成员
    const cmdEnum = getProto().lookupEnum('command.Command');
    const GetReadMembersRequest = getProto().lookupType('message.GetReadMembersRequest');
    const reqBytes = GetReadMembersRequest.encode(
      GetReadMembersRequest.create({ chat_id: chatId, message_id: sentMessageId })
    ).finish();

    const res = await client.httpRequest(cmdEnum.values.MESSAGE_GET_READ_MEMBERS, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `get read members code=${res.code}`);

    const dec = safeDecode(getProto(), 'message.GetReadMembersResponse', res.data);
    assert.ok(dec.ok, `decode get read members failed: ${dec.error}`);
    assert.ok(dec.result.members && dec.result.members.length >= 1, 'should have >=1 member');
    const readCount = dec.result.members.reduce(
      (acc, m) => acc + (m.isRead ? 1 : 0), 0
    );
    assert.ok(readCount >= 1, `should have >=1 read member, got ${readCount}`);
  });

  it('should lazy pull read entity via pipeline entity change channel', async () => {
    assert.ok(sentMessageId);

    // 已读后，通过 pipeline 实体变更通道懒拉该消息（含完整 read_state）
    const cmdEnum = getProto().lookupEnum('command.Command');
    const PullEntityRequest = getProto().lookupType('pipeline.PullEntityRequest');
    const EntityId = getProto().lookupType('entity.EntityId');
    const reqBytes = PullEntityRequest.encode(
      PullEntityRequest.create({
        ids: [EntityId.create({ id: sentMessageId, type: 15 /* MESSAGE */ })],
      })
    ).finish();

    const res = await client.httpRequest(cmdEnum.values.PIPELINE_PULL_ENTITY, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `pull entity code=${res.code}`);

    const dec = safeDecode(getProto(), 'pipeline.PullEntityResponse', res.data);
    assert.ok(dec.ok, `decode pull entity failed: ${dec.error}`);
    assert.ok(dec.result.entity?.messages, 'should have messages map');
    const found = Object.values(dec.result.entity.messages).find(
      msg => str(msg.id) === sentMessageId
    );
    assert.ok(found, `should find message ${sentMessageId} via pipeline`);
    // 已读为独立实体（Entity.readstates，key=message_id，见 docs/data_sync §5）
    const rs = dec.result.entity.readstates?.[str(sentMessageId)];
    assert.ok(rs, 'should carry read_state via Entity.readstates');
    assert.ok(
      Number(rs.read_count) >= 1,
      `read_count should be >=1, got ${rs.read_count}`
    );
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

  it('should lazy pull reaction via pipeline entity change channel', async () => {
    assert.ok(sentMessageId);

    // reaction 为独立实体（Entity.reactions，key=message_id），走 pipeline 实体变更通道懒拉
    const cmdEnum = getProto().lookupEnum('command.Command');
    const PullEntityRequest = getProto().lookupType('pipeline.PullEntityRequest');
    const EntityId = getProto().lookupType('entity.EntityId');
    const reqBytes = PullEntityRequest.encode(
      PullEntityRequest.create({
        ids: [EntityId.create({ id: sentMessageId, type: 15 /* MESSAGE */ })],
      })
    ).finish();

    const res = await client.httpRequest(cmdEnum.values.PIPELINE_PULL_ENTITY, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `pull entity code=${res.code}`);

    const dec = safeDecode(getProto(), 'pipeline.PullEntityResponse', res.data);
    assert.ok(dec.ok, `decode pull entity failed: ${dec.error}`);
    const found = Object.values(dec.result.entity.messages).find(
      msg => str(msg.id) === sentMessageId
    );
    assert.ok(found, `should find message ${sentMessageId} via pipeline`);
    const rx = dec.result.entity.reactions?.[str(sentMessageId)];
    assert.ok(rx && rx.reactions, 'should carry reactions via Entity.reactions');
    // 至少存在 reaction=1
    assert.ok(
      rx.reactions['1'] || rx.reactions[1] && Number((rx.reactions['1'] || rx.reactions[1]).total) >= 1,
      'should have reaction 1 with total>=1'
    );
  });

  it('should recall message and see tombstone via pipeline', async () => {
    assert.ok(chatId && sentMessageId);

    const cmdEnum = getProto().lookupEnum('command.Command');
    const RecallRequest = getProto().lookupType('message.RecallMessageRequest');
    const recallRes = await client.httpRequest(cmdEnum.values.MESSAGE_RECALL,
      RecallRequest.encode(RecallRequest.create({ id: sentMessageId })).finish());
    assert.ok(recallRes.code === 0 || recallRes.code === 200, `recall code=${recallRes.code}`);

    // 撤回后通过 pipeline 懒拉，应看到 status=RECALL
    const PullEntityRequest = getProto().lookupType('pipeline.PullEntityRequest');
    const EntityId = getProto().lookupType('entity.EntityId');
    const reqBytes = PullEntityRequest.encode(
      PullEntityRequest.create({
        ids: [EntityId.create({ id: sentMessageId, type: 15 })],
      })
    ).finish();
    const res = await client.httpRequest(cmdEnum.values.PIPELINE_PULL_ENTITY, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `pull code=${res.code}`);
    const dec = safeDecode(getProto(), 'pipeline.PullEntityResponse', res.data);
    assert.ok(dec.ok, `decode failed: ${dec.error}`);
    const found = Object.values(dec.result.entity.messages).find(m => str(m.id) === sentMessageId);
    assert.ok(found, 'should find recalled message');
    // entity.EntityStatus: RECALL=6
    assert.ok(Number(found.status) === 6, `status should be RECALL(6), got ${found.status}`);
  });

  it('should delete message and see tombstone via pipeline', async () => {
    assert.ok(chatId && sentMessageId);

    const cmdEnum = getProto().lookupEnum('command.Command');
    const DeleteRequest = getProto().lookupType('message.DeleteMessageRequest');
    // 单用户即 owner/全部，mode=1 表示全局删除
    const delRes = await client.httpRequest(cmdEnum.values.MESSAGE_DELETE,
      DeleteRequest.encode(DeleteRequest.create({ message_id: sentMessageId, mode: 1 })).finish());
    assert.ok(delRes.code === 0 || delRes.code === 200, `delete code=${delRes.code}`);

    const PullEntityRequest = getProto().lookupType('pipeline.PullEntityRequest');
    const EntityId = getProto().lookupType('entity.EntityId');
    const reqBytes = PullEntityRequest.encode(
      PullEntityRequest.create({ ids: [EntityId.create({ id: sentMessageId, type: 15 })] })
    ).finish();
    const res = await client.httpRequest(cmdEnum.values.PIPELINE_PULL_ENTITY, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `pull code=${res.code}`);
    const dec = safeDecode(getProto(), 'pipeline.PullEntityResponse', res.data);
    assert.ok(dec.ok, `decode failed: ${dec.error}`);
    const found = Object.values(dec.result.entity.messages).find(m => str(m.id) === sentMessageId);
    assert.ok(found, 'should find deleted message');
    // entity.EntityStatus: DELETED=5
    assert.ok(Number(found.status) === 5, `status should be DELETED(5), got ${found.status}`);
  });

});
