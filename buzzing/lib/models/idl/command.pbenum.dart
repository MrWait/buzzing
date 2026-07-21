// This is a generated file - do not edit.
//
// Generated from command.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Command extends $pb.ProtobufEnum {
  static const Command COMMAND_UNKNOWN =
      Command._(0, _omitEnumNames ? '' : 'COMMAND_UNKNOWN');

  /// basic
  static const Command ACK = Command._(1, _omitEnumNames ? '' : 'ACK');
  static const Command ECHO = Command._(2, _omitEnumNames ? '' : 'ECHO');
  static const Command SDK_INIT =
      Command._(1000, _omitEnumNames ? '' : 'SDK_INIT');
  static const Command USER_LOGIN =
      Command._(1001, _omitEnumNames ? '' : 'USER_LOGIN');
  static const Command USER_LOGOUT =
      Command._(1002, _omitEnumNames ? '' : 'USER_LOGOUT');
  static const Command SDK_GET_VERSION =
      Command._(1003, _omitEnumNames ? '' : 'SDK_GET_VERSION');
  static const Command SDK_GET_DEVICE_ID =
      Command._(1004, _omitEnumNames ? '' : 'SDK_GET_DEVICE_ID');
  static const Command PUSH_KICKOFF =
      Command._(1005, _omitEnumNames ? '' : 'PUSH_KICKOFF');
  static const Command SDK_WRITE_LOG =
      Command._(1006, _omitEnumNames ? '' : 'SDK_WRITE_LOG');
  static const Command UPLOAD_LOG =
      Command._(1007, _omitEnumNames ? '' : 'UPLOAD_LOG');
  static const Command NET_REQUEST =
      Command._(1008, _omitEnumNames ? '' : 'NET_REQUEST');
  static const Command PUSH_NOTICE =
      Command._(1009, _omitEnumNames ? '' : 'PUSH_NOTICE');
  static const Command PIPELINE_PULL_PACKET =
      Command._(1050, _omitEnumNames ? '' : 'PIPELINE_PULL_PACKET');
  static const Command PIPELINE_PULL_ENTITY =
      Command._(1051, _omitEnumNames ? '' : 'PIPELINE_PULL_ENTITY');
  static const Command PUSH_SETTING =
      Command._(1052, _omitEnumNames ? '' : 'PUSH_SETTING');
  static const Command SETTING_GET_BY_TYPE =
      Command._(1053, _omitEnumNames ? '' : 'SETTING_GET_BY_TYPE');
  static const Command SETTING_GET_BY_CURSOR =
      Command._(1054, _omitEnumNames ? '' : 'SETTING_GET_BY_CURSOR');
  static const Command SETTING_GET_ALL =
      Command._(1055, _omitEnumNames ? '' : 'SETTING_GET_ALL');
  static const Command SETTING_UPDATE =
      Command._(1056, _omitEnumNames ? '' : 'SETTING_UPDATE');
  static const Command PUSH_ENTITY_CHANGE =
      Command._(1057, _omitEnumNames ? '' : 'PUSH_ENTITY_CHANGE');
  static const Command SETTING_SET =
      Command._(1058, _omitEnumNames ? '' : 'SETTING_SET');
  static const Command SETTING_GET =
      Command._(1059, _omitEnumNames ? '' : 'SETTING_GET');
  static const Command FEED_GET_LIST =
      Command._(1100, _omitEnumNames ? '' : 'FEED_GET_LIST');
  static const Command CHAT_CREATE =
      Command._(1101, _omitEnumNames ? '' : 'CHAT_CREATE');
  static const Command CHAT_ENTER =
      Command._(1102, _omitEnumNames ? '' : 'CHAT_ENTER');
  static const Command CHAT_ADD_CHATTERS =
      Command._(1104, _omitEnumNames ? '' : 'CHAT_ADD_CHATTERS');
  static const Command CHAT_DELETE_CHATTERS =
      Command._(1105, _omitEnumNames ? '' : 'CHAT_DELETE_CHATTERS');
  static const Command CHAT_UPDATE =
      Command._(1106, _omitEnumNames ? '' : 'CHAT_UPDATE');
  static const Command CHAT_GET_CHATTERS =
      Command._(1107, _omitEnumNames ? '' : 'CHAT_GET_CHATTERS');
  static const Command CHAT_GET_CHATTER_BY_IDS =
      Command._(1108, _omitEnumNames ? '' : 'CHAT_GET_CHATTER_BY_IDS');
  static const Command CHAT_GET_BY_IDS =
      Command._(1109, _omitEnumNames ? '' : 'CHAT_GET_BY_IDS');
  static const Command CHAT_DISMISS =
      Command._(1110, _omitEnumNames ? '' : 'CHAT_DISMISS');
  static const Command PUSH_FEED_LIST =
      Command._(1111, _omitEnumNames ? '' : 'PUSH_FEED_LIST');
  static const Command CHAT_SET_DRAFT =
      Command._(1112, _omitEnumNames ? '' : 'CHAT_SET_DRAFT');
  static const Command CHAT_GET_DRAFT =
      Command._(1113, _omitEnumNames ? '' : 'CHAT_GET_DRAFT');
  static const Command FEED_REMOVE =
      Command._(1114, _omitEnumNames ? '' : 'FEED_REMOVE');
  static const Command FEED_SET_TOP =
      Command._(1115, _omitEnumNames ? '' : 'FEED_SET_TOP');
  static const Command FEED_GET_TOP_LIST =
      Command._(1116, _omitEnumNames ? '' : 'FEED_GET_TOP_LIST');

  /// PUSH_FEED_TOP_LIST = 1117;
  static const Command FEED_ACTIVE =
      Command._(1118, _omitEnumNames ? '' : 'FEED_ACTIVE');
  static const Command CHAT_QUIT =
      Command._(1119, _omitEnumNames ? '' : 'CHAT_QUIT');
  static const Command FEED_GET_BY_IDS =
      Command._(1120, _omitEnumNames ? '' : 'FEED_GET_BY_IDS');
  static const Command FEED_SET_MUTE =
      Command._(1121, _omitEnumNames ? '' : 'FEED_SET_MUTE');
  static const Command MESSAGE_CREATE_DRAFT =
      Command._(1200, _omitEnumNames ? '' : 'MESSAGE_CREATE_DRAFT');
  static const Command MESSAGE_DELETE_DRAFT =
      Command._(1201, _omitEnumNames ? '' : 'MESSAGE_DELETE_DRAFT');
  static const Command MESSAGE_GET_ALL_DRAFTS =
      Command._(1202, _omitEnumNames ? '' : 'MESSAGE_GET_ALL_DRAFTS');
  static const Command MESSAGE_SEND =
      Command._(1203, _omitEnumNames ? '' : 'MESSAGE_SEND');
  static const Command MESSAGE_RESEND =
      Command._(1204, _omitEnumNames ? '' : 'MESSAGE_RESEND');
  static const Command MESSAGE_RECALL =
      Command._(1205, _omitEnumNames ? '' : 'MESSAGE_RECALL');
  static const Command MESSAGE_DELETE =
      Command._(1206, _omitEnumNames ? '' : 'MESSAGE_DELETE');
  static const Command MESSAGE_GET_BY_POS =
      Command._(1207, _omitEnumNames ? '' : 'MESSAGE_GET_BY_POS');
  static const Command MESSAGE_GET_BY_IDS =
      Command._(1208, _omitEnumNames ? '' : 'MESSAGE_GET_BY_IDS');
  static const Command MESSAGE_READ =
      Command._(1209, _omitEnumNames ? '' : 'MESSAGE_READ');

  /// MESSAGE_GET_READSTATE = 1210;
  static const Command PUSH_MESSAGES =
      Command._(1211, _omitEnumNames ? '' : 'PUSH_MESSAGES');
  static const Command PUSH_MESSAGE_READSTATE =
      Command._(1212, _omitEnumNames ? '' : 'PUSH_MESSAGE_READSTATE');
  static const Command MESSAGE_GET_BY_RANGE =
      Command._(1213, _omitEnumNames ? '' : 'MESSAGE_GET_BY_RANGE');
  static const Command REACTION_SET =
      Command._(1214, _omitEnumNames ? '' : 'REACTION_SET');
  static const Command PUSH_REACTIONS =
      Command._(1215, _omitEnumNames ? '' : 'PUSH_REACTIONS');
  static const Command MESSAGE_FORWARD =
      Command._(1216, _omitEnumNames ? '' : 'MESSAGE_FORWARD');
  static const Command USER_GET_BY_IDS =
      Command._(1300, _omitEnumNames ? '' : 'USER_GET_BY_IDS');
  static const Command USER_UPDATE =
      Command._(1301, _omitEnumNames ? '' : 'USER_UPDATE');
  static const Command PUSH_USER_INFO =
      Command._(1302, _omitEnumNames ? '' : 'PUSH_USER_INFO');
  static const Command DEPT_GET_BY_ID =
      Command._(1350, _omitEnumNames ? '' : 'DEPT_GET_BY_ID');
  static const Command SEARCH_USER =
      Command._(1400, _omitEnumNames ? '' : 'SEARCH_USER');
  static const Command SEARCH_MESSAGE =
      Command._(1401, _omitEnumNames ? '' : 'SEARCH_MESSAGE');
  static const Command SEARCH_CHAT =
      Command._(1402, _omitEnumNames ? '' : 'SEARCH_CHAT');
  static const Command FAVORITE_ADD =
      Command._(1500, _omitEnumNames ? '' : 'FAVORITE_ADD');
  static const Command FAVORITE_REMOVE =
      Command._(1501, _omitEnumNames ? '' : 'FAVORITE_REMOVE');
  static const Command FAVORITE_GET_LIST =
      Command._(1502, _omitEnumNames ? '' : 'FAVORITE_GET_LIST');

  /// calendar: 1600 ~ 1799
  static const Command CALENDAR_GET_LIST =
      Command._(1600, _omitEnumNames ? '' : 'CALENDAR_GET_LIST');
  static const Command CALENDAR_CREATE =
      Command._(1601, _omitEnumNames ? '' : 'CALENDAR_CREATE');
  static const Command CALENDAR_UPDATE =
      Command._(1602, _omitEnumNames ? '' : 'CALENDAR_UPDATE');
  static const Command CALENDAR_DELETE =
      Command._(1603, _omitEnumNames ? '' : 'CALENDAR_DELETE');
  static const Command CALENDAR_SEARCH =
      Command._(1604, _omitEnumNames ? '' : 'CALENDAR_SEARCH');
  static const Command CALENDAR_SUBSCRIBE =
      Command._(1605, _omitEnumNames ? '' : 'CALENDAR_SUBSCRIBE');
  static const Command CALENDAR_PUSH_LIST =
      Command._(1606, _omitEnumNames ? '' : 'CALENDAR_PUSH_LIST');
  static const Command CALENDAR_PUSH_UPDATE =
      Command._(1607, _omitEnumNames ? '' : 'CALENDAR_PUSH_UPDATE');
  static const Command SCHEDULE_CREATE =
      Command._(1610, _omitEnumNames ? '' : 'SCHEDULE_CREATE');
  static const Command SCHEDULE_REMOVE =
      Command._(1611, _omitEnumNames ? '' : 'SCHEDULE_REMOVE');
  static const Command SCHEDULE_UPDATE =
      Command._(1612, _omitEnumNames ? '' : 'SCHEDULE_UPDATE');
  static const Command SCHEDULE_PULL_BY_IDS =
      Command._(1613, _omitEnumNames ? '' : 'SCHEDULE_PULL_BY_IDS');
  static const Command SCHEDULE_PULL_BY_CALENDAR_IDS =
      Command._(1614, _omitEnumNames ? '' : 'SCHEDULE_PULL_BY_CALENDAR_IDS');
  static const Command SCHEDULE_PULL_BUSY =
      Command._(1615, _omitEnumNames ? '' : 'SCHEDULE_PULL_BUSY');
  static const Command SCHEDULE_PUSH_UPDATE =
      Command._(1616, _omitEnumNames ? '' : 'SCHEDULE_PUSH_UPDATE');
  static const Command PUSH_SCHEDULE_REMINDER =
      Command._(1617, _omitEnumNames ? '' : 'PUSH_SCHEDULE_REMINDER');
  static const Command PUSH_SCHEDULE_DELETE =
      Command._(1618, _omitEnumNames ? '' : 'PUSH_SCHEDULE_DELETE');
  static const Command PUSH_SCHEDULE_UPDATE_BY_RANGE =
      Command._(1619, _omitEnumNames ? '' : 'PUSH_SCHEDULE_UPDATE_BY_RANGE');

  /// meeting: 1800 ~ 1899
  static const Command MEETING_CREATE =
      Command._(1800, _omitEnumNames ? '' : 'MEETING_CREATE');
  static const Command MEETING_JOIN =
      Command._(1801, _omitEnumNames ? '' : 'MEETING_JOIN');
  static const Command MEETING_LEAVE =
      Command._(1802, _omitEnumNames ? '' : 'MEETING_LEAVE');
  static const Command MEETING_END =
      Command._(1803, _omitEnumNames ? '' : 'MEETING_END');
  static const Command MEETING_GET_INFO =
      Command._(1804, _omitEnumNames ? '' : 'MEETING_GET_INFO');
  static const Command MEETING_GET_LIST =
      Command._(1805, _omitEnumNames ? '' : 'MEETING_GET_LIST');
  static const Command MEETING_KICK =
      Command._(1806, _omitEnumNames ? '' : 'MEETING_KICK');
  static const Command MEETING_SET_ROLE =
      Command._(1807, _omitEnumNames ? '' : 'MEETING_SET_ROLE');
  static const Command MEETING_INVITE =
      Command._(1808, _omitEnumNames ? '' : 'MEETING_INVITE');
  static const Command MEETING_PUSH_UPDATE =
      Command._(1809, _omitEnumNames ? '' : 'MEETING_PUSH_UPDATE');

  static const $core.List<Command> values = <Command>[
    COMMAND_UNKNOWN,
    ACK,
    ECHO,
    SDK_INIT,
    USER_LOGIN,
    USER_LOGOUT,
    SDK_GET_VERSION,
    SDK_GET_DEVICE_ID,
    PUSH_KICKOFF,
    SDK_WRITE_LOG,
    UPLOAD_LOG,
    NET_REQUEST,
    PUSH_NOTICE,
    PIPELINE_PULL_PACKET,
    PIPELINE_PULL_ENTITY,
    PUSH_SETTING,
    SETTING_GET_BY_TYPE,
    SETTING_GET_BY_CURSOR,
    SETTING_GET_ALL,
    SETTING_UPDATE,
    PUSH_ENTITY_CHANGE,
    SETTING_SET,
    SETTING_GET,
    FEED_GET_LIST,
    CHAT_CREATE,
    CHAT_ENTER,
    CHAT_ADD_CHATTERS,
    CHAT_DELETE_CHATTERS,
    CHAT_UPDATE,
    CHAT_GET_CHATTERS,
    CHAT_GET_CHATTER_BY_IDS,
    CHAT_GET_BY_IDS,
    CHAT_DISMISS,
    PUSH_FEED_LIST,
    CHAT_SET_DRAFT,
    CHAT_GET_DRAFT,
    FEED_REMOVE,
    FEED_SET_TOP,
    FEED_GET_TOP_LIST,
    FEED_ACTIVE,
    CHAT_QUIT,
    FEED_GET_BY_IDS,
    FEED_SET_MUTE,
    MESSAGE_CREATE_DRAFT,
    MESSAGE_DELETE_DRAFT,
    MESSAGE_GET_ALL_DRAFTS,
    MESSAGE_SEND,
    MESSAGE_RESEND,
    MESSAGE_RECALL,
    MESSAGE_DELETE,
    MESSAGE_GET_BY_POS,
    MESSAGE_GET_BY_IDS,
    MESSAGE_READ,
    PUSH_MESSAGES,
    PUSH_MESSAGE_READSTATE,
    MESSAGE_GET_BY_RANGE,
    REACTION_SET,
    PUSH_REACTIONS,
    MESSAGE_FORWARD,
    USER_GET_BY_IDS,
    USER_UPDATE,
    PUSH_USER_INFO,
    DEPT_GET_BY_ID,
    SEARCH_USER,
    SEARCH_MESSAGE,
    SEARCH_CHAT,
    FAVORITE_ADD,
    FAVORITE_REMOVE,
    FAVORITE_GET_LIST,
    CALENDAR_GET_LIST,
    CALENDAR_CREATE,
    CALENDAR_UPDATE,
    CALENDAR_DELETE,
    CALENDAR_SEARCH,
    CALENDAR_SUBSCRIBE,
    CALENDAR_PUSH_LIST,
    CALENDAR_PUSH_UPDATE,
    SCHEDULE_CREATE,
    SCHEDULE_REMOVE,
    SCHEDULE_UPDATE,
    SCHEDULE_PULL_BY_IDS,
    SCHEDULE_PULL_BY_CALENDAR_IDS,
    SCHEDULE_PULL_BUSY,
    SCHEDULE_PUSH_UPDATE,
    PUSH_SCHEDULE_REMINDER,
    PUSH_SCHEDULE_DELETE,
    PUSH_SCHEDULE_UPDATE_BY_RANGE,
    MEETING_CREATE,
    MEETING_JOIN,
    MEETING_LEAVE,
    MEETING_END,
    MEETING_GET_INFO,
    MEETING_GET_LIST,
    MEETING_KICK,
    MEETING_SET_ROLE,
    MEETING_INVITE,
    MEETING_PUSH_UPDATE,
  ];

  static final $core.Map<$core.int, Command> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static Command? valueOf($core.int value) => _byValue[value];

  const Command._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
