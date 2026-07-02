import { describe, it, before } from 'node:test';
import assert from 'node:assert/strict';
import { initProto, getProto, BuzzingClient, fullLogin, getConfig, safeDecode, str } from '../../lib/index.js';

let client;

before(async () => {
  await initProto();
  const config = getConfig();
  const result = await fullLogin(new BuzzingClient(), config.phone, config.password);
  client = result.client;
});

/**
 * 获取 feed 列表中的第一个 feed ID
 */
async function getFirstFeedId() {
  const cmdEnum = getProto().lookupEnum('command.Command');
  const PullFeedListRequest = getProto().lookupType('feed.PullFeedListRequest');
  const reqBytes = PullFeedListRequest.encode(
    PullFeedListRequest.create({ cursor: 0, count: 20 })
  ).finish();

  const res = await client.httpRequest(cmdEnum.values.FEED_GET_LIST, reqBytes);
  if (res.code !== 0 && res.code !== 200) return null;

  const dec = safeDecode(getProto(), 'feed.PullFeedListResponse', res.data);
  if (!dec.ok) return null;
  const feeds = dec.result.entity?.feeds;
  if (feeds && Object.keys(feeds).length > 0) {
    return Object.keys(feeds)[0];
  }
  return null;
}

/**
 * 创建一个群聊来生成 feed
 */
async function createFeedGeneratingChat() {
  const cmdEnum = getProto().lookupEnum('command.Command');
  const CreateChatRequest = getProto().lookupType('chat.CreateChatRequest');
  const Chat = getProto().lookupType('entity.Chat');
  const chat = Chat.create({
    chat_type: 2,
    name: `feed-test-chat-${Date.now()}`,
    member_ids: [String(client.userId)],
  });
  const reqBytes = CreateChatRequest.encode(
    CreateChatRequest.create({ chat })
  ).finish();

  const res = await client.httpRequest(cmdEnum.values.CHAT_CREATE, reqBytes);
  if (res.code !== 0 && res.code !== 200) return false;
  await new Promise(r => setTimeout(r, 500));
  return true;
}

describe('feed', () => {

  it('should get feed list', async () => {
    const cmdEnum = getProto().lookupEnum('command.Command');
    const PullFeedListRequest = getProto().lookupType('feed.PullFeedListRequest');
    const reqBytes = PullFeedListRequest.encode(
      PullFeedListRequest.create({ cursor: 0, count: 20 })
    ).finish();

    const res = await client.httpRequest(cmdEnum.values.FEED_GET_LIST, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `code=${res.code}`);

    const dec = safeDecode(getProto(), 'feed.PullFeedListResponse', res.data);
    assert.ok(dec.ok, `decode failed: ${dec.error}`);
    // cursor 是分页游标（Snowflake ID），不为 0 是正常行为
  });

  it('should get feed top list', async () => {
    const cmdEnum = getProto().lookupEnum('command.Command');
    const GetFeedTopListRequest = getProto().lookupType('feed.GetFeedTopListRequest');
    const reqBytes = GetFeedTopListRequest.encode(
      GetFeedTopListRequest.create({})
    ).finish();

    const res = await client.httpRequest(cmdEnum.values.FEED_GET_TOP_LIST, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `code=${res.code}`);

    const dec = safeDecode(getProto(), 'feed.GetFeedTopListResponse', res.data);
    assert.ok(dec.ok, `decode failed: ${dec.error}`);
    assert.ok(Array.isArray(dec.result.ids), 'should have ids array');
  });

  it('should set feed top and mute', async () => {
    let feedId = await getFirstFeedId();
    if (!feedId) {
      const created = await createFeedGeneratingChat();
      assert.ok(created, 'should create a chat to generate feed');
      feedId = await getFirstFeedId();
      if (!feedId) {
        console.log('No feeds available, skipping set top/mute test');
        return;
      }
    }

    const cmdEnum = getProto().lookupEnum('command.Command');
    const SetFeedTopRequest = getProto().lookupType('feed.SetFeedTopRequest');
    const SetFeedMuteRequest = getProto().lookupType('feed.SetFeedMuteRequest');

    const topRes = await client.httpRequest(
      cmdEnum.values.FEED_SET_TOP,
      SetFeedTopRequest.encode(SetFeedTopRequest.create({ id: feedId, top: true })).finish()
    );
    assert.ok(topRes.code === 0 || topRes.code === 200, `set top code=${topRes.code}`);

    const muteRes = await client.httpRequest(
      cmdEnum.values.FEED_SET_MUTE,
      SetFeedMuteRequest.encode(SetFeedMuteRequest.create({ id: feedId, mute: true })).finish()
    );
    assert.ok(muteRes.code === 0 || muteRes.code === 200, `set mute code=${muteRes.code}`);

    const unMuteRes = await client.httpRequest(
      cmdEnum.values.FEED_SET_MUTE,
      SetFeedMuteRequest.encode(SetFeedMuteRequest.create({ id: feedId, mute: false })).finish()
    );
    assert.ok(unMuteRes.code === 0 || unMuteRes.code === 200, `unmute code=${unMuteRes.code}`);

    const unTopRes = await client.httpRequest(
      cmdEnum.values.FEED_SET_TOP,
      SetFeedTopRequest.encode(SetFeedTopRequest.create({ id: feedId, top: false })).finish()
    );
    assert.ok(unTopRes.code === 0 || unTopRes.code === 200, `untop code=${unTopRes.code}`);
  });

  it('should active a feed', async () => {
    let feedId = await getFirstFeedId();
    if (!feedId) {
      console.log('No feeds available, skipping active feed test');
      return;
    }

    const cmdEnum = getProto().lookupEnum('command.Command');
    const ActiveFeedRequest = getProto().lookupType('feed.ActiveFeedRequest');
    const activeRes = await client.httpRequest(
      cmdEnum.values.FEED_ACTIVE,
      ActiveFeedRequest.encode(ActiveFeedRequest.create({ id: feedId })).finish()
    );
    assert.ok(activeRes.code === 0 || activeRes.code === 200, `active feed code=${activeRes.code}`);
  });

});
