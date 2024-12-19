const proto = require('./proto.js');
const protobuf = require('protobufjs')
const sdk = require('../sdk');
const axios = require('axios');
const jsonbig = require('json-bigint');
const fs = require('fs')

const PBInvokeRequest = proto.lookup('sdk.InvokeRequest')
const PBInvokeResponse = proto.lookup('sdk.InvokeResponse')
const PBInitSdkRequest = proto.lookup('sdk.InitRequest');
const PBLoginUser = proto.lookup('sdk.SdkLoginUserRequest')
const PBSdkPushPacket = proto.lookup('sdk.SdkPushPacket')
const command = proto.lookup('command.Command')

var invoke_seq = 1
var invoke_callback = {}

const ids = []

const configFile = process.env.CONFIG

axios.defaults.baseURL = 'http://127.0.0.1:5150';
axios.defaults.transformResponse = [
  function (data) {
    console.log("parse response: ", data)
    const json = jsonbig({storeAsString: true})
    const res = json.parse(data)
    return res
  }
]

const PBAccount = proto.lookup('entity.Account')
async function account_login(phone, pass) {
  var result = await axios({
    url: '/api/accounts/login',
    method: 'POST',
    json: true,
    headers: {
      "content-type": "application/json",
    },
    data: {
      "phone": phone,
      "password": pass
    }
  }).then(res => {
    console.log('login ok: ', res.data)
    return true;
  }).catch(error => {
    console.log('login error: ', error)
    return false
  })
  console.log("login got ", result)
  return result
}

function init_sdk(userId, token, tenantId) {
  // console.log(PBInitSdkRequest);
  const reqData = {
    deviceType: 1,
    appId: "buzzing",
    appVersion: "4.47.0",
    deviceId: "4aa874dd0fdcfc77fe410e6a2dd521e3",
    logPath: "./logs",
    storagePath: "./store",
    env: 3
  };
  var req = PBInitSdkRequest.create(reqData);
  var data = PBInitSdkRequest.encode(req).finish();
  console.log(data);
  sdk.buzzing_init(data);

  sdk.buzzing_reg_handler(handle_packet_response, handle_packet_push);

  const loginRequest = {
    // userId: '1838493687957450825',
    // userId: BigInt(1819303951095337129),
    userId: userId,
    accessToken: token,
    tenantId: tenantId,
  }
  req = PBLoginUser.create(loginRequest)
  data = PBLoginUser.encode(req).finish()
  rustSdkInvoke(command.values['USER_LOGIN'], data, (code, data) => {
    console.log("login done")
  })
}

function handle_packet_push(data) {
  const buf = protobuf.util.newBuffer(data)
  var packet = PBSdkPushPacket.decode(buf)

  console.log(packet)
}

function handle_packet_response(data) {
  const buf = protobuf.util.newBuffer(data)
  var packet = PBInvokeResponse.decode(buf)
  console.log("response:", packet)

  const callback = invoke_callback[packet.seq]
  if (callback != null) {
    delete invoke_callback[packet.seq]
    callback(packet.status, packet.payload)
  }
}

function rustSdkInvoke(cmd, data, callback) {
  var seq = invoke_seq
  invoke_seq = invoke_seq + 1
  const req = {
    seq: seq,
    command: cmd,
    payload: data
  }
  invoke_callback[seq] = callback
  var request = PBInvokeRequest.create(req)
  const d = PBInvokeRequest.encode(request).finish()
  sdk.buzzing_invoke(d)
}

function wait(ms) {
  return new Promise(resolve => setTimeout(() => resolve(), ms));
}

function handle_packet_push(data) {
  const buf = protobuf.util.newBuffer(data)
  var packet = PBSdkPushPacket.decode(buf)

  console.log(packet)
}

function logout() {
  console.log('logout user')
  rustSdkInvoke(command.values['USER_LOGOUT'], [], (code, data) => {
    console.log("user logout: ", code, data)
  })
}

// USER_GET_BY_IDS = 1300
// GetUserByIdsRequest, GetUserByIdsResponse
const PBGetUserByIdsRequest = proto.lookup('user.GetUserByIdsRequest')
const PBGetUserByIdsResponse = proto.lookup('user.GetUserByIdsResponse')
function user_get_by_ids(ids) {
  const reqData = {
    ids: ids
  }
  var req = PBGetUserByIdsRequest.create(reqData)
  var data = PBGetUserByIdsRequest.encode(req).finish()
  console.log('get user with : ', req)
  rustSdkInvoke(command.values['USER_GET_BY_IDS'], data, (code, data) => {
    console.log("get users: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = PBGetUserByIdsResponse.decode(buf)
      console.log(resp)
      console.log(resp.users.data)
    }
  })
}

const PBCreateChatRequest = proto.lookup('chat.CreateChatRequest')
const PBCreateChatResponse = proto.lookup('chat.CreateChatResponse')
function chat_create(name, memberIds) {
  const reqData = {
    chat: {
      id: 0,
      chatType: 2,
      name: name,
      memberIds: memberIds
    },
  }
  var req = PBCreateChatRequest.create(reqData)
  var data = PBCreateChatRequest.encode(req).finish()
  console.log("start create chat: ", req, data)
  rustSdkInvoke(command.values['CHAT_CREATE'], data, (code, data) => {
    console.log("create chat ack: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = PBCreateChatResponse.decode(buf)
      console.log(resp)
    }
  })
}

function chat_create_p2p(id) {
  const reqData = {
    chat: {
      id: 0,
      chatType: 1,
      peerAId: config['user_id'],
      peerBId: id
    },
  }
  var req = PBCreateChatRequest.create(reqData)
  var data = PBCreateChatRequest.encode(req).finish()
  console.log("start create p2p chat: ", req, data)
  rustSdkInvoke(command.values['CHAT_CREATE'], data, (code, data) => {
    console.log("create p2p chat ack: ", code, data)
    if (code == 200) {
      const buf = protobuf.util.newBuffer(data)
      var resp = PBCreateChatResponse.decode(buf)
      console.log(resp)
    }
  })
}

const PBSendMessageRequest = proto.lookup('message.SendMessageRequest')
const PBSendMessageResponse = proto.lookup('message.SendMessageResponse')
function send_message(stash_id, message) {
  const reqData = {
    clientId: stash_id,
    message: message
  }
  var req = PBSendMessageRequest.create(reqData)
  var data = PBSendMessageRequest.encode(req).finish()
  console.log("send message: ", req)
  rustSdkInvoke(command.values['MESSAGE_SEND'], data, (code, data) => {
    console.log("send message ack: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = PBSendMessageResponse.decode(buf)
      console.log(resp)
    }
  })
}

const PBCreateMessageDraftRequest = proto.lookup('message.CreateMessageDraftRequest')
const PBCreateMessageDraftResponse = proto.lookup('message.CreateMessageDraftResponse')
function send_chat_message(chatId) {
  const reqData = {
    chatId: chatId,
    message: {
      tpy: 1,
      chatId: chatId,
      fromId: 1742894504433002701,
      content: "a hello message",
      summary: "a hello message",
    }
  }
  var req = PBCreateMessageDraftRequest.create(reqData)
  var data = PBCreateMessageDraftRequest.encode(req).finish()
  console.log("create chat message: ", req)
  rustSdkInvoke(command.values['MESSAGE_CREATE_DRAFT'], data, (code, data) => {
    console.log("create p2p message ack: ", code, data)
    if (code == 200) {
      const buf = protobuf.util.newBuffer(data)
      var resp = PBCreateMessageDraftResponse.decode(buf)
      console.log(resp)
      send_message(resp.clientId, reqData.message)
    }
  })
}

const PBPullFeedListRequest = proto.lookup('feed.PullFeedListRequest')
const PBPullFeedListResponse = proto.lookup('feed.PullFeedListResponse')
function feed_get_list() {
  const reqData = {
    // 6050697466152702734
    cursor: '6050697466152702734',
    count: 10,
    prevCursor: 0,
  }
  var req = PBPullFeedListRequest.create(reqData)
  var data = PBPullFeedListRequest.encode(req).finish()
  console.log('get feed list: ', req, data)
  rustSdkInvoke(command.values['FEED_GET_LIST'], data, (code, data) => {
    console.log("get feed list: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = PBPullFeedListResponse.decode(buf)
      console.log(resp)
    }
  })
}

const PBPullFeedByIdsRequest = proto.lookup('feed.PullFeedByIdsRequest')
const PBPullFeedByIdsResponse = proto.lookup('feed.PullFeedByIdsResponse')
function feed_get_by_ids(ids) {
  const reqData = {
    ids: ids
  }
  var req = PBPullFeedByIdsRequest.create(reqData)
  var data = PBPullFeedByIdsRequest.encode(req).finish()
  console.log('get feed by ids: ', req)
  rustSdkInvoke(command.values['FEED_GET_BY_IDS'], data, (code, data) => {
    console.log("get feed by ids: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = PBPullFeedByIdsResponse.decode(buf)
      console.log(resp)
    }
  })
}

const PBRemoveFeedRequest = proto.lookup('feed.RemoveFeedRequest')
const PBRemoveFeedResponse = proto.lookup('feed.RemoveFeedResponse')
function feed_remove(feedId) {
  const reqData = {
    id: feedId
  }
  var req = PBRemoveFeedRequest.create(reqData)
  var data = PBRemoveFeedRequest.encode(req).finish()
  console.log('remove feed start: ', req)
  rustSdkInvoke(command.values['FEED_REMOVE'], data, (code, data) => {
    console.log("remove feed finish: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = PBRemoveFeedResponse.decode(buf)
      console.log(resp)
    }
  })
}

const PBActiveFeedRequest = proto.lookup('feed.ActiveFeedRequest')
const PBActiveFeedResponse = proto.lookup('feed.ActiveFeedResponse')
function feed_active(feedId) {
  const reqData = {
    id: feedId
  }
  var req = PBActiveFeedRequest.create(reqData)
  var data = PBActiveFeedRequest.encode(req).finish()
  console.log('active feed start: ', req)
  rustSdkInvoke(command.values['FEED_ACTIVE'], data, (code, data) => {
    console.log("active feed finish: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = PBActiveFeedResponse.decode(buf)
      console.log(resp)
    }
  })
}

const PBSetFeedTopRequest = proto.lookup('feed.SetFeedTopRequest')
const PBSetFeedTopResponse = proto.lookup('feed.SetFeedTopResponse')
function feed_set_top(feedId, top) {
  const reqData = {
    id: feedId,
    top: top
  }
  var req = PBSetFeedTopRequest.create(reqData)
  var data = PBSetFeedTopRequest.encode(req).finish()
  console.log('set feed top start: ', req)
  rustSdkInvoke(command.values['FEED_SET_TOP'], data, (code, data) => {
    console.log("set feed top finish: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = PBSetFeedTopResponse.decode(buf)
      console.log(resp)
    }
  })
}

const PBSetFeedMuteRequest = proto.lookup('feed.SetFeedMuteRequest')
const PBSetFeedMuteResponse = proto.lookup('feed.SetFeedMuteResponse')
function feed_set_mute(feedId, mute) {
  const reqData = {
    id: feedId,
    mute: mute
  }
  var req = PBSetFeedMuteRequest.create(reqData)
  var data = PBSetFeedMuteRequest.encode(req).finish()
  console.log('set feed mute start: ', req)
  rustSdkInvoke(command.values['FEED_SET_MUTE'], data, (code, data) => {
    console.log("set feed mute finish: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = PBSetFeedMuteResponse.decode(buf)
      console.log(resp)
    }
  })
}

const PBGetFeedTopListRequest = proto.lookup('feed.GetFeedTopListRequest')
const PBGetFeedTopListResponse = proto.lookup('feed.GetFeedTopListResponse')
function feed_get_top() {
  const reqData = {}
  var req = PBGetFeedTopListRequest.create(reqData)
  var data = PBGetFeedTopListRequest.encode(req).finish()
  console.log('get feed top list start: ', req)
  rustSdkInvoke(command.values['FEED_GET_TOP_LIST'], data, (code, data) => {
    console.log("get feed top list finish: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = PBGetFeedTopListResponse.decode(buf)
      console.log(resp)
    }
  })
}

const PBGetMessageByPosRequest = proto.lookup('message.GetMessageByPosRequest')
const PBGetMessageByPosResponse = proto.lookup('message.GetMessageByPosResponse')
function feed_get_message(feedId, pos, count) {
  let reqData = {
    chatId: feedId,
    pos: pos,
    count: count,
    direct: 1
  }
  var req = PBGetMessageByPosRequest.create(reqData)
  var data = PBGetMessageByPosRequest.encode(req).finish()
  console.log('get message by pos start: ', req)
  rustSdkInvoke(command.values['MESSAGE_GET_BY_POS'], data, (code, data) => {
    console.log("get message by pos finish: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = PBGetMessageByPosResponse.decode(buf)
      console.log(resp)
    }
  })
}

const PBSetChatDraftRequest = proto.lookup('chat.SetChatDraftRequest')
const PBSetChatDraftResponse = proto.lookup('chat.SetChatDraftResponse')
function feed_set_draft(feedId, content) {
  let reqData = {
    chatId: feedId,
    content: content,
  }
  var req = PBSetChatDraftRequest.create(reqData)
  var data = PBSetChatDraftRequest.encode(req).finish()
  console.log('set chat draft: ', req)
  rustSdkInvoke(command.values['CHAT_SET_DRAFT'], data, (code, data) => {
    console.log("set chat draft finish: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = PBSetChatDraftResponse.decode(buf)
      console.log(resp)
    }
  })
}

const PBGetChatDraftRequest = proto.lookup('chat.GetChatDraftRequest')
const PBGetChatDraftResponse = proto.lookup('chat.GetChatDraftResponse')
function chat_get_draft(chatId) {
  let reqData = {
    chatId: chatId
  }
  var req = PBGetChatDraftRequest.create(reqData)
  var data = PBGetChatDraftRequest.encode(req).finish()
  console.log('get chat draft: ', req)
  rustSdkInvoke(command.values['CHAT_GET_DRAFT'], data, (code, data) => {
    console.log("get chat draft finish: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = PBGetChatDraftResponse.decode(buf)
      console.log(resp)
    }
  })
}

const PBDismissChatRequest = proto.lookup('chat.DismissChatRequest')
const PBDismissChatAck = proto.lookup('chat.DismissChatAck')
function chat_dismiss(feedId) {
  let reqData = {
    chatId: feedId
  }
  var req = PBDismissChatRequest.create(reqData)
  var data = PBDismissChatRequest.encode(req).finish()
  console.log('dismiss chat: ', req)
  rustSdkInvoke(command.values['CHAT_DISMISS'], data, (code, data) => {
    console.log("dismiss chat finish: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = PBDismissChatAck.decode(buf)
      console.log(resp)
    }
  })
}

const PBUpdateChatRequest = proto.lookup('chat.UpdateChatRequest')
const PBUpdateChatAck = proto.lookup('chat.UpdateChatAck')
function chat_update(feedId, name) {
  let reqData = {
    chatId: feedId,
    name: name
  }
  var req = PBUpdateChatRequest.create(reqData)
  var data = PBUpdateChatRequest.encode(req).finish()
  console.log('update chat: ', req)
  rustSdkInvoke(command.values['CHAT_UPDATE'], data, (code, data) => {
    console.log("update chat finish: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = PBUpdateChatAck.decode(buf)
      console.log(resp)
    }
  })
}

const PBAddChatChatterRequest = proto.lookup('chat.AddChatChatterRequest')
const PBAddChatChatterResponse = proto.lookup('chat.AddChatChatterResponse')
function chat_add_chatter(feedId, id) {
  let reqData = {
    chatId: feedId,
    chatters: [{id: id, role: 1}]
  }
  var req = PBAddChatChatterRequest.create(reqData)
  var data = PBAddChatChatterRequest.encode(req).finish()
  console.log('chat add chatter: ', req)
  rustSdkInvoke(command.values['CHAT_ADD_CHATTERS'], data, (code, data) => {
    console.log("chat add chatter finish: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = PBAddChatChatterResponse.decode(buf)
      console.log(resp)
    }
  })
}

const PBRemoveChatChatterRequest = proto.lookup('chat.RemoveChatChatterRequest')
const PBRemoveChatChatterResponse = proto.lookup('chat.RemoveChatChatterAck')
function chat_delete_chatter(feedId, id) {
  let reqData = {
    chatId: feedId,
    ids: [id]
  }
  var req = PBRemoveChatChatterRequest.create(reqData)
  var data = PBRemoveChatChatterRequest.encode(req).finish()
  console.log('chat del chatter: ', req)
  rustSdkInvoke(command.values['CHAT_DELETE_CHATTERS'], data, (code, data) => {
    console.log("chat delete chatter finish: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = PBRemoveChatChatterResponse.decode(buf)
      console.log(resp)
    }
  })
}

const PBReadMessageRequest  = proto.lookup('chat.ReadMessageRequest')
const PBReadMessageResponse  = proto.lookup('chat.ReadMessageResponse')
function message_read(feedId, pos, ids) {
  let reqData = {
    chatId: feedId,
    maxPos: pos,
    messageIds: ids
  }
  var req = PBReadMessageRequest.create(reqData)
  var data = PBReadMessageRequest.encode(req).finish()
  console.log('message read: ', req)
  rustSdkInvoke(command.values['MESSAGE_READ'], data, (code, data) => {
    console.log("message read finish: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = PBReadMessageResponse.decode(buf)
      console.log(resp)
    }
  })
}

/*
const Calendar = proto.lookup('calendar.')
const Calendar = proto.lookup('calendar.')
function calendar_get_list() {
  let reqData = {}
  var req = Calendar.create(reqData)
  var data = Calendar.encode(req).finish()
  console.log('calendar get list: ', req)
  rustSdkInvoke(command.values['CALENDAR_GET_LIST'], data, (code, data) => {
    console.log("calendar get list: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = Calendar.decode(buf)
      console.log(resp)
    }
  })
}
*/

const CalendarGetListRequest = proto.lookup('calendar.CalendarGetListRequest')
const CalendarGetListResponse = proto.lookup('calendar.CalendarGetListResponse')
function calendar_get_list() {
  let reqData = {}
  var req = CalendarGetListRequest.create(reqData)
  var data = CalendarGetListRequest.encode(req).finish()
  console.log('calendar get list: ', req)
  rustSdkInvoke(command.values['CALENDAR_GET_LIST'], data, (code, data) => {
    console.log("calendar get list: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = CalendarGetListResponse.decode(buf)
      console.log(resp)
    }
  })
}

const CalendarCreateRequest = proto.lookup('calendar.CalendarCreateRequest')
const CalendarCreateResponse = proto.lookup('calendar.CalendarCreateResponse')
function calendar_create() {
  let reqData = {
    calendar: {
      id: 0,
      creater: 0,
      color: 0,
      name: "Pub112",
      desc: "public calendar - 112",
      isDefault: false,
      public: true,
    }
  }
  var req = CalendarCreateRequest.create(reqData)
  var data = CalendarCreateRequest.encode(req).finish()
  console.log('calendar create: ', req)
  rustSdkInvoke(command.values['CALENDAR_CREATE'], data, (code, data) => {
    console.log("calendar create: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = CalendarCreateResponse.decode(buf)
      console.log(resp)
    }
  })
}

const CalendarUpdateRequest = proto.lookup('calendar.CalendarUpdateRequest')
const CalendarUpdateResponse = proto.lookup('calendar.CalendarUpdateResponse')
function calendar_update(id, name) {
  let reqData = {
    calendar: {
      id: id,
      creater: 0,
      subscribe_time: 0,
      tenant_id: 0,
      color: 0,
      name: name,
      desc: name + "112",
      public: true,
      subscribers: {
        subscribers: {}
      }
    }
  }
  var req = Calendar.create(reqData)
  var data = Calendar.encode(req).finish()
  console.log('calendar update: ', req)
  rustSdkInvoke(command.values['CALENDAR_UPDATE'], data, (code, data) => {
    console.log("calendar update: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = CalendarUpdateResponse.decode(buf)
      console.log(resp)
    }
  })
}

const CalendarDeleteRequest = proto.lookup('calendar.CalendarDeleteRequest')
const CalendarDeleteResponse = proto.lookup('calendar.CalendarDeleteResponse')
function calendar_delete(id) {
  let reqData = {
    id: id
  }
  var req = CalendarDeleteRequest.create(reqData)
  var data = CalendarDeleteRequest.encode(req).finish()
  console.log('calendar delete: ', req)
  rustSdkInvoke(command.values['CALENDAR_DELETE'], data, (code, data) => {
    console.log("calendar delete: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = CalendarDeleteResponse.decode(buf)
      console.log(resp)
    }
  })
}

const CalendarSearchRequest = proto.lookup('calendar.CalendarSearchRequest')
const CalendarSearchResponse = proto.lookup('calendar.CalendarSearchResponse')
function calendar_search(key) {
  let reqData = {
    key: key
  }
  var req = CalendarSearchRequest.create(reqData)
  var data = CalendarSearchRequest.encode(req).finish()
  console.log('calendar search: ', req)
  rustSdkInvoke(command.values['CALENDAR_SEARCH'], data, (code, data) => {
    console.log("calendar search: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = CalendarSearchResponse.decode(buf)
      console.log(resp)
    }
  })
}

const CalendarSubscribeRequest = proto.lookup('calendar.CalendarSubscribeRequest')
const CalendarSubscribeResponse = proto.lookup('calendar.CalendarSubscribeResponse')
function calendar_subscribe(id, sub) {
  let reqData = {
    id: 1,
    subscribe: sub,
  }
  var req = CalendarSubscribeRequest.create(reqData)
  var data = CalendarSubscribeRequest.encode(req).finish()
  console.log('calendar subscribe: ', req)
  rustSdkInvoke(command.values['CALENDAR_SUBSCRIBE'], data, (code, data) => {
    console.log("calendar subscribe success: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = CalendarSubscribeResponse.decode(buf)
      console.log(resp)
    }
  })
}

/*
const Schedule = proto.lookup('calendar.')
const Schedule = proto.lookup('calendar.')
function schedule_create(id) {
  let reqData = {}
  var req = Schedule.create(reqData)
  var data = Schedule.encode(req).finish()
  console.log('schedule: ', req)
  rustSdkInvoke(command.values['SCHEDULE_'], data, (code, data) => {
    console.log("schedule: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = schedule.decode(buf)
      console.log(resp)
    }
  })
}
*/

const ScheduleCreateRequest = proto.lookup('calendar.ScheduleCreateRequest')
const ScheduleCreateResponse = proto.lookup('calendar.ScheduleCreateResponse')
function schedule_create(id) {
  let user = config.user
  let reqData = {
    schedule: {
      id: 0,
      calendarId: id,
      type: 0,
      startTime: 1755745293509,
      endTime: 1755745395509,
      needCheckin: true,
      showAsIdle: true,
      location: "Shanghai",
      title: "Schedule 0001",
      memberIds: [user.peer_a, user.peer_b]
    }
  }
  var req = ScheduleCreateRequest.create(reqData)
  var data = ScheduleCreateRequest.encode(req).finish()
  console.log('schedule create: ', req)
  rustSdkInvoke(command.values['SCHEDULE_CREATE'], data, (code, data) => {
    console.log("schedule create finish: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = ScheduleCreateResponse.decode(buf)
      console.log(resp)
    }
  })
}

const ScheduleRemoveRequest = proto.lookup('calendar.ScheduleRemoveRequest')
const ScheduleRemoveResponse = proto.lookup('calendar.ScheduleRemoveResponse')
function schedule_remove(id, with_all) {
  let reqData = {
    id: id,
    wish_all: id,
  }
  var req = ScheduleRemoveRequest.create(reqData)
  var data = ScheduleRemoveRequest.encode(req).finish()
  console.log('schedule remove: ', req)
  rustSdkInvoke(command.values['SCHEDULE_REMOVE'], data, (code, data) => {
    console.log("schedule remove finish: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = ScheduleRemoveResponse.decode(buf)
      console.log(resp)
    }
  })
}

const ScheduleUpdateRequest = proto.lookup('calendar.ScheduleUpdateRequest')
const ScheduleUpdateResponse = proto.lookup('calendar.ScheduleUpdateResponse')
function schedule_update(id, name) {
  let reqData = {}
  var req = ScheduleUpdateRequest.create(reqData)
  var data = ScheduleUpdateRequest.encode(req).finish()
  console.log('schedule update: ', req)
  rustSdkInvoke(command.values['SCHEDULE_UPDATE'], data, (code, data) => {
    console.log("schedule update finish: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = ScheduleUpdateResponse.decode(buf)
      console.log(resp)
    }
  })
}

const SchedulePullByIdsRequest = proto.lookup('calendar.SchedulePullByIdsRequest')
const SchedulePullByIdsResponse = proto.lookup('calendar.SchedulePullByIdsResponse')
function schedule_pull_by_ids(ids) {
  let reqData = {}
  var req = SchedulePullByIdsRequest.create(reqData)
  var data = SchedulePullByIdsRequest.encode(req).finish()
  console.log('schedule pull by ids: ', req)
  rustSdkInvoke(command.values['SCHEDULE_PULL_BY_IDS'], data, (code, data) => {
    console.log("schedule pull by ids finish: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = SchedulePullByIdsResponse.decode(buf)
      console.log(resp)
    }
  })
}

const SchedulePullByCalendarIdsRequest = proto.lookup('calendar.SchedulePullByCalendarIdsRequest')
const SchedulePullByCalendarIdsResponse = proto.lookup('calendar.SchedulePullByCalendarIdsResponse')
function schedule_pull_by_calendar_ids(ids, start, end) {
  let reqData = {}
  var req = SchedulePullByCalendarIdsRequest.create(reqData)
  var data = SchedulePullByCalendarIdsRequest.encode(req).finish()
  console.log('schedule pull by calendar ids: ', req)
  rustSdkInvoke(command.values['SCHEDULE_PULL_BY_CALENDAR_IDS'], data, (code, data) => {
    console.log("schedule pull by calendar ids finish: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = SchedulePullByCalendarIdsResponse.decode(buf)
      console.log(resp)
    }
  })
}

const SchedulePullBusyRequest = proto.lookup('calendar.SchedulePullBusyRequest')
const SchedulePullBusyResponse = proto.lookup('calendar.SchedulePullBusyResponse')
function schedule_pull_busy(id, start, end) {
  let reqData = {}
  var req = SchedulePullBusyRequest.create(reqData)
  var data = SchedulePullBusyRequest.encode(req).finish()
  console.log('schedule pull busy: ', req)
  rustSdkInvoke(command.values['SCHEDULE_PULL_BUSY'], data, (code, data) => {
    console.log("schedule pull busy finish: ", code, data)
    if (code == 0) {
      const buf = protobuf.util.newBuffer(data)
      var resp = SchedulePullBusyResponse.decode(buf)
      console.log(resp)
    }
  })
}

const PBSendLogRequest  = proto.lookup('sdk.SendLogRequest')
function log(text) {
  let reqData = {
    text: text
  }
  var req = PBSendLogRequest.create(reqData)
  var data = PBSendLogRequest.encode(req).finish()
  console.log('send log: ', req)
  rustSdkInvoke(command.values['SEND_LOG'], data, (code, data) => {
    console.log("send log finish: ", code, data)
  })
}

function exe_message(count) {
  if (count > config.action.r) {
    return
  }

  if (config.action.c == "p2p") {
    send_chat_message(config.message.p2p)
  } else {
    send_chat_message(config.message.group)
  }
}

function exe_chat(count) {
  if (count > config.action.r) {
    return
  }
  c = config.action.c
  p2p_peer = config['chat']['p2p_peer']
  p2p_id = config.message.p2p
  grop_id = config.message.group
  if (c == "create_p2p") {
    chat_create_p2p(p2p_peer)
  } else if (c == "create_group"){
    chat_create("chat_001", config['chat']['group'])
  } else if (c == "add") {
    chat_add_chatters()
  }
}

function exe_feed(count) {
  if (count > config.action.r) {
    return
  }
  c = config.action.c
  chat = config.feed.id
  if (c == "top_1") {
    feed_set_top(chat, true)
  } else if (c == "top_0") {
    feed_set_top(chat, false)
  } else if (c == "mute_1") {
    feed_set_mute(chat, true)
  } else if (c == "mute_1") {
    feed_set_mute(chat, false)
  } else if (c == "remove") {
    feed_remove(chat)
  } else if (c == "active") {
    feed_active(chat)
  } else if (c == "top") {
    feed_get_top()
  } else if (c == "get") {
    feed_get_by_ids([chat])
  } else if (c == "list") {
    feed_get_list()
  }
}

function exe_user(count) {
  if (count > config.action.r) {
    return
  }

  c = config.action.c
  user_a = config.user.user_a
  user_b = config.user.user_b

  if (c == "get") {
    user_get_by_ids([user_a, user_b])
  }
}

// calendar: create, update, remove, list, subscribe
function exe_calendar(count) {
  if (count > config.action.r) {
    return
  }

  c = config.action.c
  calendar = config.calendar
  if (c == "create") {
    calendar_create()
  } else if (c == "update") {
    calendar_update(calendar.custom_id)
  } else if (c == "delete") {
    calendar_delete(calendar.custom_id)
  } else if (c == "list") {
    calendar_get_list()
  } else if (c == "subscribe") {
    calendar_subscribe(calendar.cid, true)
  } else if (c == "search") {
    calendar_search("Pub")
  }
}

// schedule: create, remove, update, by_id, by_cal, busy
function exe_schedule(count) {
  if (count > config.action.r) {
    return
  }
  c = config.action.c
  schedule = config.schedule

  if (c == "create") {
    schedule_create(schedule.cid)
  } else if (c == "remove") {
    schedule_remove(schedule.sid)
  } else if (c == "update") {
    schedule_update(schedule.sid)
  } else if (c == "by_id") {
    schedule_pull_by_ids([schedule.sid])
  } else if (c == "by_cal") {
    schedule_pull_by_calendar_ids([schedule.cid])
  } else if (c == "busy") {
    schedule_pull_busy(config.user.user_a)
  }
}

async function run_sdk() {
  init_sdk(config['user_id'], config['token'], config['tenant']);
  await wait(2000);

  var count = 0;
  var t = config.action.t
  while (true) {
    await wait(1000);
    count += 1;
    if (t == "message") { exe_message(count) }
    if (t == "chat") { exe_chat(count) }
    if (t == "dept") { exe_dept(count) }
    if (t == "feed") { exe_feed(count) }
    if (t == "user") { exe_user(count) }
    if (t == "calendar") { exe_calendar(count) }
    if (t == "schedule") { exe_schedule(count) }
  }
}

async function login() {
  await account_login(config.phone, config.pass)
}

var config = {}
async function main() {
  console.log("config file:", configFile)
  var data = fs.readFileSync(configFile, "utf8")
  config = JSON.parse(data)
  console.log("config: ", config)
  run_sdk()
  // login()
  console.log("exited")
}

main();
