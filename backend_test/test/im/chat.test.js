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

  it('should dismiss the group chat', async () => {
    assert.ok(createdChatId);

    const cmdEnum = getProto().lookupEnum('command.Command');
    const DismissChatRequest = getProto().lookupType('chat.DismissChatRequest');
    const reqBytes = DismissChatRequest.encode(
      DismissChatRequest.create({ chat_id: createdChatId })
    ).finish();

    const res = await client.httpRequest(cmdEnum.values.CHAT_DISMISS, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `code=${res.code}`);

    const dec = safeDecode(getProto(), 'chat.DismissChatResponse', res.data);
    assert.ok(dec.ok, `decode failed: ${dec.error}`);

    // 解散后 feed 列表不应再包含该会话（feed 状态 >= DismissPending 被过滤）
    const PullFeedListRequest = getProto().lookupType('feed.PullFeedListRequest');
    const feedRes = await client.httpRequest(
      cmdEnum.values.FEED_GET_LIST,
      PullFeedListRequest.encode(
        PullFeedListRequest.create({ cursor: 0, count: 100 })
      ).finish()
    );
    const feedDec = safeDecode(getProto(), 'feed.PullFeedListResponse', feedRes.data);
    assert.ok(feedDec.ok, `feed decode failed: ${feedDec.error}`);
    const feeds = feedDec.result.entity?.feeds || {};
    const found = Object.values(feeds).find(f => str(f.id) === createdChatId);
    assert.ok(!found, 'dismissed chat should not appear in feed list');
  });

  it('should reject sending messages to a dismissed chat', async () => {
    assert.ok(createdChatId);

    const cmdEnum = getProto().lookupEnum('command.Command');
    const Message = getProto().lookupType('entity.Message');
    const MessageText = getProto().lookupType('entity.MessageText');
    const textContent = MessageText.encode(
      MessageText.create({ text: `after-dismiss-${Date.now()}` })
    ).finish();
    const draftMsg = Message.create({
      chat_id: createdChatId,
      tpy: 1,
      content: new Uint8Array(textContent),
    });

    const SendMessageRequest = getProto().lookupType('message.SendMessageRequest');
    const sendRes = await client.httpRequest(
      cmdEnum.values.MESSAGE_SEND,
      SendMessageRequest.encode(
        SendMessageRequest.create({ client_id: 0, message: draftMsg })
      ).finish()
    );
    // 解散后消息发送应被拒绝（chat.status=DELETED，ErrorNoPermision=1005）
    assert.ok(
      sendRes.code !== 0 && sendRes.code !== 200,
      `send to dismissed chat should be rejected, code=${sendRes.code}`
    );
  });

  it('should reject sending messages to a chat where user is not a member', async () => {
    // 单测试账号：先创建一个群聊，群主将自己从成员列表移除，再尝试发消息
    const cmdEnum = getProto().lookupEnum('command.Command');
    const CreateChatRequest = getProto().lookupType('chat.CreateChatRequest');
    const Chat = getProto().lookupType('entity.Chat');
    const chat = Chat.create({
      chat_type: 2,
      name: `non-member-${Date.now()}`,
      member_ids: [String(client.userId)],
    });
    const createRes = await client.httpRequest(
      cmdEnum.values.CHAT_CREATE,
      CreateChatRequest.encode(CreateChatRequest.create({ chat })).finish()
    );
    assert.ok(createRes.code === 0 || createRes.code === 200, `create code=${createRes.code}`);
    const createDec = safeDecode(getProto(), 'chat.CreateChatResponse', createRes.data);
    assert.ok(createDec.ok, `create decode failed: ${createDec.error}`);
    const chatId = str(createDec.result.chat_id);

    // 群主移除自己（仅保留一个成员时，移除后用户即不再属于该群）
    const RemoveChatChatterRequest = getProto().lookupType('chat.RemoveChatChatterRequest');
    const removeRes = await client.httpRequest(
      cmdEnum.values.CHAT_DELETE_CHATTERS,
      RemoveChatChatterRequest.encode(
        RemoveChatChatterRequest.create({ chat_id: chatId, ids: [client.userId] })
      ).finish()
    );
    assert.ok(removeRes.code === 0 || removeRes.code === 200, `remove code=${removeRes.code}`);

    // 非成员发消息应被拒绝（cmv 成员校验，ErrorNoPermision=1005）
    const Message = getProto().lookupType('entity.Message');
    const MessageText = getProto().lookupType('entity.MessageText');
    const textContent = MessageText.encode(
      MessageText.create({ text: `after-remove-${Date.now()}` })
    ).finish();
    const draftMsg = Message.create({
      chat_id: chatId,
      tpy: 1,
      content: new Uint8Array(textContent),
    });
    const SendMessageRequest = getProto().lookupType('message.SendMessageRequest');
    const sendRes = await client.httpRequest(
      cmdEnum.values.MESSAGE_SEND,
      SendMessageRequest.encode(
        SendMessageRequest.create({ client_id: 0, message: draftMsg })
      ).finish()
    );
    assert.ok(
      sendRes.code !== 0 && sendRes.code !== 200,
      `non-member send should be rejected, code=${sendRes.code}`
    );
  });

});
