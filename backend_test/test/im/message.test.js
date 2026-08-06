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

  it('should clear sender unread after sending latest message', async () => {
    assert.ok(chatId && sentMessageId);

    // 发送者发出本会话最新消息后，服务端应把其已读游标推进到本条消息（read_badge == refer_badge），
    // 使该会话未读归零（未读 = refer_badge - read_badge，见 data_sync §6）。多端场景：任一设备发送，
    // 本账号该会话即视为已读。
    const cmdEnum = getProto().lookupEnum('command.Command');
    const PullFeedListRequest = getProto().lookupType('feed.PullFeedListRequest');
    const reqBytes = PullFeedListRequest.encode(
      PullFeedListRequest.create({ cursor: 0, count: 20 })
    ).finish();

    const res = await client.httpRequest(cmdEnum.values.FEED_GET_LIST, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `get feed list code=${res.code}`);
    const dec = safeDecode(getProto(), 'feed.PullFeedListResponse', res.data);
    assert.ok(dec.ok, `decode feed list failed: ${dec.error}`);

    const feeds = dec.result.entity?.feeds || {};
    const feed = Object.values(feeds).find(f => str(f.id) === chatId);
    assert.ok(feed, `should find feed for chat ${chatId}`);
    assert.ok(
      feed.read_badge >= feed.refer_badge && feed.read_pos >= feed.refer_pos,
      `sender read should reach latest: ` +
        `read_badge=${feed.read_badge} refer_badge=${feed.refer_badge} ` +
        `read_pos=${feed.read_pos} refer_pos=${feed.refer_pos}`
    );
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

  it('should merge & compress PUSH_ENTITY_CHANGE(1057) packets on pipeline pull', async () => {
    // 触发多个实体变更产生多行 1057 包：已读（READSTATE=17）→ 连续两次 reaction（REACTION=24）。
    // PIPELINE_PULL_PACKET 时服务端按 (type,id) 合并仅保留 version 最大值，并压缩为少量包。
    const cmdEnum = getProto().lookupEnum('command.Command');
    const PullPipelineRequest = getProto().lookupType('pipeline.PullPipelineRequest');
    const pullAll = async (untilSid, maxPages) => {
      const packets = [];
      let sid = untilSid;
      let more = true;
      for (let i = 0; more && i < maxPages; i++) {
        const r = await client.httpRequest(cmdEnum.values.PIPELINE_PULL_PACKET,
          PullPipelineRequest.encode(PullPipelineRequest.create({ sid, count: 100 })).finish());
        assert.ok(r.code === 0 || r.code === 200, `pull code=${r.code}`);
        const d = safeDecode(getProto(), 'pipeline.PullPipelineResponse', r.data);
        assert.ok(d.ok, `decode pull failed: ${d.error}`);
        packets.push(...d.result.packets);
        sid = Number(d.result.sid);
        more = d.result.has_more;
      }
      return { packets, sid };
    };

    // 拉取不再删除 pipeline 行（多设备共享，清理仅由服务端 TTL worker 执行），
    // 因此历史行会一直累积；本用例按具体消息 id 断言，不受历史行影响。
    // 新发一条消息
    const Message = getProto().lookupType('entity.Message');
    const MessageText = getProto().lookupType('entity.MessageText');
    const textContent = MessageText.encode(
      MessageText.create({ text: `merge-${Date.now()}` })
    ).finish();
    const draftMsg = Message.create({
      chat_id: chatId, tpy: 1, content: new Uint8Array(textContent),
    });
    const SendMessageRequest = getProto().lookupType('message.SendMessageRequest');
    const sendRes = await client.httpRequest(cmdEnum.values.MESSAGE_SEND,
      SendMessageRequest.encode(
        SendMessageRequest.create({ client_id: 0, message: draftMsg })
      ).finish());
    assert.ok(sendRes.code === 0 || sendRes.code === 200, `send code=${sendRes.code}`);
    const sendDec = safeDecode(getProto(), 'message.SendMessageResponse', sendRes.data);
    assert.ok(sendDec.ok, `send decode failed: ${sendDec.error}`);
    const msgId = str(sendDec.result.id);
    assert.ok(msgId, 'should have message id');

    // 已读（READSTATE 变更 v1）
    const MessageReadRequest = getProto().lookupType('message.MessageReadRequest');
    const readRes = await client.httpRequest(cmdEnum.values.MESSAGE_READ,
      MessageReadRequest.encode(
        MessageReadRequest.create({ chat_id: chatId, max_pos: 0, message_ids: [msgId] })
      ).finish());
    assert.ok(readRes.code === 0 || readRes.code === 200, `read code=${readRes.code}`);

    // 连续两次 reaction（REACTION 变更 v2/v3，同一实体多次变更）
    const SetMessageReactitonRequest = getProto().lookupType('message.SetMessageReactitonRequest');
    for (const reaction of [1, 2]) {
      const reRes = await client.httpRequest(cmdEnum.values.REACTION_SET,
        SetMessageReactitonRequest.encode(
          SetMessageReactitonRequest.create({ message_id: msgId, reaction, set: true })
        ).finish());
      assert.ok(reRes.code === 0 || reRes.code === 200, `reaction ${reaction} code=${reRes.code}`);
    }

    // 拉取 pipeline 全量，汇总所有 1057 包里的变更
    const { packets, sid } = await pullAll(0, 100);
    assert.ok(sid > 0, 'should advance sid');
    const PushEntityChanged = getProto().lookupType('pipeline.PushEntityChanged');
    const changeMap = new Map(); // `${type}:${id}` -> {version, operate, count}
    let push1057Count = 0;
    for (const p of packets) {
      if (Number(p.cmd) !== cmdEnum.values.PUSH_ENTITY_CHANGE) continue;
      push1057Count++;
      const chg = PushEntityChanged.decode(p.payload);
      for (const c of chg.changes) {
        const key = `${c.type}:${str(c.id)}`;
        const prev = changeMap.get(key);
        if (prev) {
          prev.count += 1;
          if (Number(c.version) > Number(prev.version)) {
            prev.version = Number(c.version);
            prev.operate = c.operate;
          }
        } else {
          changeMap.set(key, { version: Number(c.version), operate: c.operate, count: 1 });
        }
      }
    }

    // 压缩：至少有一个 1057 包
    assert.ok(push1057Count >= 1, 'should have at least one 1057 packet');

    // 合并策略：本用例消息的 READSTATE(17) 与 REACTION(24) 变更各只出现一次
    // （reaction 触发两次，应被合并为一条保留 version 最大值）
    const rsKey = `17:${msgId}`;
    const rxKey = `24:${msgId}`;
    assert.ok(changeMap.has(rsKey), `should have readstate change for ${msgId}`);
    assert.ok(changeMap.has(rxKey), `should have reaction change for ${msgId}`);
    assert.strictEqual(changeMap.get(rsKey).count, 1, `readstate ${msgId} should appear once`);
    assert.strictEqual(changeMap.get(rxKey).count, 1, `reaction ${msgId} should appear once (merged)`);
    assert.strictEqual(changeMap.get(rxKey).operate, 2, 'reaction operate should be UPDATE(2)');
    assert.ok(
      changeMap.get(rxKey).version > changeMap.get(rsKey).version,
      'merged reaction version should be the max (newer than readstate)'
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

  it('should pull pipeline fresh (sid=0) without replay, returning only cursor', async () => {
    // 全新安装客户端 cursor=0：服务端仅返回当前最大 sid（无 packets、expired=false），
    // 初始数据走 feed 全量同步，无需回放历史。
    const cmdEnum = getProto().lookupEnum('command.Command');
    const PullPipelineRequest = getProto().lookupType('pipeline.PullPipelineRequest');
    const r = await client.httpRequest(cmdEnum.values.PIPELINE_PULL_PACKET,
      PullPipelineRequest.encode(PullPipelineRequest.create({ sid: 0, count: 100 })).finish());
    assert.ok(r.code === 0 || r.code === 200, `pull code=${r.code}`);
    const d = safeDecode(getProto(), 'pipeline.PullPipelineResponse', r.data);
    assert.ok(d.ok, `decode failed: ${d.error}`);
    assert.ok(!d.result.expired, 'fresh pull should not be expired');
    assert.ok(Number(d.result.sid) >= 0, `should return non-negative sid, got ${d.result.sid}`);
    assert.ok(!d.result.has_more, 'fresh pull should not paginate');
    assert.strictEqual(d.result.packets.length, 0, 'fresh pull should return no packets');
  });

  it('should not delete pipeline rows on pull (multi-device shared)', async () => {
    // 拉取不再消费即删（delete_le_sid 已移除）：同一 cursor 重复拉取应拿到相同数据，
    // 数据仅在服务端 TTL 清理时删除。
    const cmdEnum = getProto().lookupEnum('command.Command');
    const PullPipelineRequest = getProto().lookupType('pipeline.PullPipelineRequest');
    const pullPage = async (sid) => {
      const r = await client.httpRequest(cmdEnum.values.PIPELINE_PULL_PACKET,
        PullPipelineRequest.encode(PullPipelineRequest.create({ sid, count: 100 })).finish());
      assert.ok(r.code === 0 || r.code === 200, `pull code=${r.code}`);
      const d = safeDecode(getProto(), 'pipeline.PullPipelineResponse', r.data);
      assert.ok(d.ok, `decode failed: ${d.error}`);
      assert.ok(!d.result.expired, 'should not be expired');
      return d.result;
    };
    const first = await pullPage(0);
    const second = await pullPage(0);
    // 从 0 重复拉取仍能拿到历史数据（未被删除），且 cursor 一致
    assert.ok(Number(first.sid) > 0 || first.packets.length > 0, 'should have data to advance');
    assert.strictEqual(Number(second.sid), Number(first.sid), 'sid should be identical across pulls');
    assert.strictEqual(second.packets.length, first.packets.length,
      'packets should not be consumed by pull');
  });

  // 水位线/expired 路径（服务端 TTL 清理触发）无法仅通过 HTTP 触发（需服务端 DB 侧
  // 种子水位线或等待 30 天 TTL），此处仅验证新字段存在且正常拉取时 expired=false。
  it('should expose expired=false & min_sid on normal pipeline pull', async () => {
    const cmdEnum = getProto().lookupEnum('command.Command');
    const PullPipelineRequest = getProto().lookupType('pipeline.PullPipelineRequest');
    const r = await client.httpRequest(cmdEnum.values.PIPELINE_PULL_PACKET,
      PullPipelineRequest.encode(PullPipelineRequest.create({ sid: 1, count: 100 })).finish());
    assert.ok(r.code === 0 || r.code === 200, `pull code=${r.code}`);
    const d = safeDecode(getProto(), 'pipeline.PullPipelineResponse', r.data);
    assert.ok(d.ok, `decode failed: ${d.error}`);
    assert.strictEqual(d.result.expired, false, 'normal pull should not be expired');
    assert.ok(typeof d.result.min_sid === 'number', 'min_sid should be present');
  });

});
