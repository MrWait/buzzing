// This is a generated file - do not edit.
//
// Generated from entity.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class EnvChannel extends $pb.ProtobufEnum {
  static const EnvChannel ENV_UNKNOWN =
      EnvChannel._(0, _omitEnumNames ? '' : 'ENV_UNKNOWN');
  static const EnvChannel ENV_RELEASE =
      EnvChannel._(1, _omitEnumNames ? '' : 'ENV_RELEASE');
  static const EnvChannel ENV_PRERELEASE =
      EnvChannel._(2, _omitEnumNames ? '' : 'ENV_PRERELEASE');
  static const EnvChannel ENV_DEV =
      EnvChannel._(3, _omitEnumNames ? '' : 'ENV_DEV');

  static const $core.List<EnvChannel> values = <EnvChannel>[
    ENV_UNKNOWN,
    ENV_RELEASE,
    ENV_PRERELEASE,
    ENV_DEV,
  ];

  static final $core.List<EnvChannel?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static EnvChannel? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const EnvChannel._(super.value, super.name);
}

class PackageType extends $pb.ProtobufEnum {
  static const PackageType PACKAGE_UNKNOWN =
      PackageType._(0, _omitEnumNames ? '' : 'PACKAGE_UNKNOWN');
  static const PackageType PACKAGE_RELEASE =
      PackageType._(1, _omitEnumNames ? '' : 'PACKAGE_RELEASE');
  static const PackageType PACKAGE_DEBUG =
      PackageType._(2, _omitEnumNames ? '' : 'PACKAGE_DEBUG');

  static const $core.List<PackageType> values = <PackageType>[
    PACKAGE_UNKNOWN,
    PACKAGE_RELEASE,
    PACKAGE_DEBUG,
  ];

  static final $core.List<PackageType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static PackageType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PackageType._(super.value, super.name);
}

class OSType extends $pb.ProtobufEnum {
  static const OSType OS_UNKNOWN =
      OSType._(0, _omitEnumNames ? '' : 'OS_UNKNOWN');
  static const OSType OS_WINDOWS =
      OSType._(1, _omitEnumNames ? '' : 'OS_WINDOWS');
  static const OSType OS_MACOS = OSType._(2, _omitEnumNames ? '' : 'OS_MACOS');
  static const OSType OS_ANDROID =
      OSType._(3, _omitEnumNames ? '' : 'OS_ANDROID');
  static const OSType OS_IOS = OSType._(4, _omitEnumNames ? '' : 'OS_IOS');

  static const $core.List<OSType> values = <OSType>[
    OS_UNKNOWN,
    OS_WINDOWS,
    OS_MACOS,
    OS_ANDROID,
    OS_IOS,
  ];

  static final $core.List<OSType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static OSType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const OSType._(super.value, super.name);
}

class DataSource extends $pb.ProtobufEnum {
  static const DataSource SOURCE_UNKNOWN =
      DataSource._(0, _omitEnumNames ? '' : 'SOURCE_UNKNOWN');
  static const DataSource SOURCE_LOCAL_ONLY =
      DataSource._(1, _omitEnumNames ? '' : 'SOURCE_LOCAL_ONLY');
  static const DataSource SOURCE_LOCAL_FIRST =
      DataSource._(2, _omitEnumNames ? '' : 'SOURCE_LOCAL_FIRST');
  static const DataSource SOURCE_SERVER_FIRST =
      DataSource._(3, _omitEnumNames ? '' : 'SOURCE_SERVER_FIRST');

  static const $core.List<DataSource> values = <DataSource>[
    SOURCE_UNKNOWN,
    SOURCE_LOCAL_ONLY,
    SOURCE_LOCAL_FIRST,
    SOURCE_SERVER_FIRST,
  ];

  static final $core.List<DataSource?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static DataSource? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DataSource._(super.value, super.name);
}

class ChatType extends $pb.ProtobufEnum {
  static const ChatType CHAT_UNKNOWN =
      ChatType._(0, _omitEnumNames ? '' : 'CHAT_UNKNOWN');
  static const ChatType CHAT_P2P =
      ChatType._(1, _omitEnumNames ? '' : 'CHAT_P2P');
  static const ChatType CHAT_GROUP =
      ChatType._(2, _omitEnumNames ? '' : 'CHAT_GROUP');

  static const $core.List<ChatType> values = <ChatType>[
    CHAT_UNKNOWN,
    CHAT_P2P,
    CHAT_GROUP,
  ];

  static final $core.List<ChatType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ChatType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ChatType._(super.value, super.name);
}

class UserType extends $pb.ProtobufEnum {
  static const UserType USER_TYPE_UNKNOWN =
      UserType._(0, _omitEnumNames ? '' : 'USER_TYPE_UNKNOWN');
  static const UserType USER_TYPE_PERSONAL =
      UserType._(1, _omitEnumNames ? '' : 'USER_TYPE_PERSONAL');
  static const UserType USER_TYPE_TENANT =
      UserType._(2, _omitEnumNames ? '' : 'USER_TYPE_TENANT');

  static const $core.List<UserType> values = <UserType>[
    USER_TYPE_UNKNOWN,
    USER_TYPE_PERSONAL,
    USER_TYPE_TENANT,
  ];

  static final $core.List<UserType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static UserType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const UserType._(super.value, super.name);
}

class TenantPermision extends $pb.ProtobufEnum {
  static const TenantPermision TENANT_PERMISION_UNKNOWN =
      TenantPermision._(0, _omitEnumNames ? '' : 'TENANT_PERMISION_UNKNOWN');
  static const TenantPermision TENANT_PERMISION_NORMAL =
      TenantPermision._(1, _omitEnumNames ? '' : 'TENANT_PERMISION_NORMAL');
  static const TenantPermision TENANT_PERMISION_ADMIN =
      TenantPermision._(2, _omitEnumNames ? '' : 'TENANT_PERMISION_ADMIN');
  static const TenantPermision TENANT_PERMISION_SUPER_ADMIN = TenantPermision._(
      3, _omitEnumNames ? '' : 'TENANT_PERMISION_SUPER_ADMIN');

  static const $core.List<TenantPermision> values = <TenantPermision>[
    TENANT_PERMISION_UNKNOWN,
    TENANT_PERMISION_NORMAL,
    TENANT_PERMISION_ADMIN,
    TENANT_PERMISION_SUPER_ADMIN,
  ];

  static final $core.List<TenantPermision?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static TenantPermision? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TenantPermision._(super.value, super.name);
}

class BizType extends $pb.ProtobufEnum {
  static const BizType BIZ_UNKNOWN =
      BizType._(0, _omitEnumNames ? '' : 'BIZ_UNKNOWN');
  static const BizType BIZ_IM = BizType._(1, _omitEnumNames ? '' : 'BIZ_IM');
  static const BizType BIZ_GATEWAY =
      BizType._(2, _omitEnumNames ? '' : 'BIZ_GATEWAY');
  static const BizType BIZ_SETTING =
      BizType._(3, _omitEnumNames ? '' : 'BIZ_SETTING');
  static const BizType BIZ_CALENDAR =
      BizType._(4, _omitEnumNames ? '' : 'BIZ_CALENDAR');
  static const BizType BIZ_TODO =
      BizType._(5, _omitEnumNames ? '' : 'BIZ_TODO');
  static const BizType BIZ_RTC = BizType._(6, _omitEnumNames ? '' : 'BIZ_RTC');
  static const BizType BIZ_OFFICE =
      BizType._(7, _omitEnumNames ? '' : 'BIZ_OFFICE');
  static const BizType BIZ_USER =
      BizType._(8, _omitEnumNames ? '' : 'BIZ_USER');
  static const BizType BIZ_STORAGE =
      BizType._(9, _omitEnumNames ? '' : 'BIZ_STORAGE');

  static const $core.List<BizType> values = <BizType>[
    BIZ_UNKNOWN,
    BIZ_IM,
    BIZ_GATEWAY,
    BIZ_SETTING,
    BIZ_CALENDAR,
    BIZ_TODO,
    BIZ_RTC,
    BIZ_OFFICE,
    BIZ_USER,
    BIZ_STORAGE,
  ];

  static final $core.List<BizType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 9);
  static BizType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const BizType._(super.value, super.name);
}

class EntityType extends $pb.ProtobufEnum {
  static const EntityType ENTITY_TYPE_UNKNOWN =
      EntityType._(0, _omitEnumNames ? '' : 'ENTITY_TYPE_UNKNOWN');
  static const EntityType USER = EntityType._(1, _omitEnumNames ? '' : 'USER');
  static const EntityType CHAT = EntityType._(2, _omitEnumNames ? '' : 'CHAT');
  static const EntityType BOT = EntityType._(4, _omitEnumNames ? '' : 'BOT');
  static const EntityType DOC = EntityType._(5, _omitEnumNames ? '' : 'DOC');
  static const EntityType FEED = EntityType._(6, _omitEnumNames ? '' : 'FEED');
  static const EntityType ACCOUNT =
      EntityType._(7, _omitEnumNames ? '' : 'ACCOUNT');
  static const EntityType TENANT =
      EntityType._(8, _omitEnumNames ? '' : 'TENANT');
  static const EntityType DEPARTMENT =
      EntityType._(9, _omitEnumNames ? '' : 'DEPARTMENT');
  static const EntityType OPENAPP =
      EntityType._(10, _omitEnumNames ? '' : 'OPENAPP');
  static const EntityType SUBSCRIPTION =
      EntityType._(11, _omitEnumNames ? '' : 'SUBSCRIPTION');
  static const EntityType DOC_FEED =
      EntityType._(12, _omitEnumNames ? '' : 'DOC_FEED');
  static const EntityType THREAD =
      EntityType._(14, _omitEnumNames ? '' : 'THREAD');
  static const EntityType MESSAGE =
      EntityType._(15, _omitEnumNames ? '' : 'MESSAGE');
  static const EntityType DEPT = EntityType._(16, _omitEnumNames ? '' : 'DEPT');
  static const EntityType READSTATE =
      EntityType._(17, _omitEnumNames ? '' : 'READSTATE');
  static const EntityType FILE_TYPE =
      EntityType._(18, _omitEnumNames ? '' : 'FILE_TYPE');
  static const EntityType URL = EntityType._(19, _omitEnumNames ? '' : 'URL');
  static const EntityType SETTING =
      EntityType._(20, _omitEnumNames ? '' : 'SETTING');
  static const EntityType CALENDAR =
      EntityType._(21, _omitEnumNames ? '' : 'CALENDAR');
  static const EntityType SCHEDULE =
      EntityType._(22, _omitEnumNames ? '' : 'SCHEDULE');
  static const EntityType SCHEDULE_CYCLE =
      EntityType._(23, _omitEnumNames ? '' : 'SCHEDULE_CYCLE');

  static const $core.List<EntityType> values = <EntityType>[
    ENTITY_TYPE_UNKNOWN,
    USER,
    CHAT,
    BOT,
    DOC,
    FEED,
    ACCOUNT,
    TENANT,
    DEPARTMENT,
    OPENAPP,
    SUBSCRIPTION,
    DOC_FEED,
    THREAD,
    MESSAGE,
    DEPT,
    READSTATE,
    FILE_TYPE,
    URL,
    SETTING,
    CALENDAR,
    SCHEDULE,
    SCHEDULE_CYCLE,
  ];

  static final $core.List<EntityType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 23);
  static EntityType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const EntityType._(super.value, super.name);
}

class SettingType extends $pb.ProtobufEnum {
  static const SettingType SETTING_TYPE_UNKNOWN =
      SettingType._(0, _omitEnumNames ? '' : 'SETTING_TYPE_UNKNOWN');
  static const SettingType SETTING_FAVORITE =
      SettingType._(1, _omitEnumNames ? '' : 'SETTING_FAVORITE');
  static const SettingType SETTING_TOP_LIST =
      SettingType._(2, _omitEnumNames ? '' : 'SETTING_TOP_LIST');
  static const SettingType USER_CALENDAR_LIST =
      SettingType._(3, _omitEnumNames ? '' : 'USER_CALENDAR_LIST');

  static const $core.List<SettingType> values = <SettingType>[
    SETTING_TYPE_UNKNOWN,
    SETTING_FAVORITE,
    SETTING_TOP_LIST,
    USER_CALENDAR_LIST,
  ];

  static final $core.List<SettingType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static SettingType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SettingType._(super.value, super.name);
}

class EntityStatus extends $pb.ProtobufEnum {
  static const EntityStatus STATUS_UNKNOWN =
      EntityStatus._(0, _omitEnumNames ? '' : 'STATUS_UNKNOWN');
  static const EntityStatus NORMAL =
      EntityStatus._(1, _omitEnumNames ? '' : 'NORMAL');
  static const EntityStatus INVISIBLE =
      EntityStatus._(2, _omitEnumNames ? '' : 'INVISIBLE');
  static const EntityStatus DELETE_PENDING =
      EntityStatus._(3, _omitEnumNames ? '' : 'DELETE_PENDING');
  static const EntityStatus DISMISS_PENDING =
      EntityStatus._(4, _omitEnumNames ? '' : 'DISMISS_PENDING');
  static const EntityStatus DELETED =
      EntityStatus._(5, _omitEnumNames ? '' : 'DELETED');
  static const EntityStatus RECALL =
      EntityStatus._(6, _omitEnumNames ? '' : 'RECALL');
  static const EntityStatus STOP =
      EntityStatus._(7, _omitEnumNames ? '' : 'STOP');
  static const EntityStatus FAIL =
      EntityStatus._(8, _omitEnumNames ? '' : 'FAIL');

  static const $core.List<EntityStatus> values = <EntityStatus>[
    STATUS_UNKNOWN,
    NORMAL,
    INVISIBLE,
    DELETE_PENDING,
    DISMISS_PENDING,
    DELETED,
    RECALL,
    STOP,
    FAIL,
  ];

  static final $core.List<EntityStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 8);
  static EntityStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const EntityStatus._(super.value, super.name);
}

class MessageType extends $pb.ProtobufEnum {
  static const MessageType MESSAGE_TYPE_UNKNOWN =
      MessageType._(0, _omitEnumNames ? '' : 'MESSAGE_TYPE_UNKNOWN');
  static const MessageType TEXT =
      MessageType._(1, _omitEnumNames ? '' : 'TEXT');
  static const MessageType IMAGE =
      MessageType._(2, _omitEnumNames ? '' : 'IMAGE');
  static const MessageType FILE =
      MessageType._(3, _omitEnumNames ? '' : 'FILE');
  static const MessageType VOICE =
      MessageType._(4, _omitEnumNames ? '' : 'VOICE');
  static const MessageType MEDIA =
      MessageType._(5, _omitEnumNames ? '' : 'MEDIA');
  static const MessageType RICH_TEXT =
      MessageType._(6, _omitEnumNames ? '' : 'RICH_TEXT');
  static const MessageType LOCATION =
      MessageType._(7, _omitEnumNames ? '' : 'LOCATION');
  static const MessageType CARD =
      MessageType._(8, _omitEnumNames ? '' : 'CARD');
  static const MessageType VOTE =
      MessageType._(9, _omitEnumNames ? '' : 'VOTE');
  static const MessageType REDPACKET =
      MessageType._(10, _omitEnumNames ? '' : 'REDPACKET');
  static const MessageType RICH_TEXT_QUILL =
      MessageType._(11, _omitEnumNames ? '' : 'RICH_TEXT_QUILL');
  static const MessageType MEETING_INVITE =
      MessageType._(12, _omitEnumNames ? '' : 'MEETING_INVITE');

  static const $core.List<MessageType> values = <MessageType>[
    MESSAGE_TYPE_UNKNOWN,
    TEXT,
    IMAGE,
    FILE,
    VOICE,
    MEDIA,
    RICH_TEXT,
    LOCATION,
    CARD,
    VOTE,
    REDPACKET,
    RICH_TEXT_QUILL,
    MEETING_INVITE,
  ];

  static final $core.List<MessageType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 12);
  static MessageType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MessageType._(super.value, super.name);
}

class Direct extends $pb.ProtobufEnum {
  static const Direct NONE = Direct._(0, _omitEnumNames ? '' : 'NONE');
  static const Direct UP = Direct._(1, _omitEnumNames ? '' : 'UP');
  static const Direct DOWN = Direct._(2, _omitEnumNames ? '' : 'DOWN');
  static const Direct BOTH = Direct._(3, _omitEnumNames ? '' : 'BOTH');

  static const $core.List<Direct> values = <Direct>[
    NONE,
    UP,
    DOWN,
    BOTH,
  ];

  static final $core.List<Direct?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static Direct? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Direct._(super.value, super.name);
}

class Operate extends $pb.ProtobufEnum {
  static const Operate OPERATE_NONE =
      Operate._(0, _omitEnumNames ? '' : 'OPERATE_NONE');
  static const Operate OPERATE_CREATE =
      Operate._(1, _omitEnumNames ? '' : 'OPERATE_CREATE');
  static const Operate OPERATE_UPDATE =
      Operate._(2, _omitEnumNames ? '' : 'OPERATE_UPDATE');
  static const Operate OPERATE_DELETE =
      Operate._(3, _omitEnumNames ? '' : 'OPERATE_DELETE');
  static const Operate OPERATE_SEARCH =
      Operate._(4, _omitEnumNames ? '' : 'OPERATE_SEARCH');

  static const $core.List<Operate> values = <Operate>[
    OPERATE_NONE,
    OPERATE_CREATE,
    OPERATE_UPDATE,
    OPERATE_DELETE,
    OPERATE_SEARCH,
  ];

  static final $core.List<Operate?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static Operate? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Operate._(super.value, super.name);
}

class ClientPlatform extends $pb.ProtobufEnum {
  static const ClientPlatform PLATFORM_UNKNOWN =
      ClientPlatform._(0, _omitEnumNames ? '' : 'PLATFORM_UNKNOWN');
  static const ClientPlatform WINDOWS =
      ClientPlatform._(1, _omitEnumNames ? '' : 'WINDOWS');
  static const ClientPlatform MACOS =
      ClientPlatform._(2, _omitEnumNames ? '' : 'MACOS');
  static const ClientPlatform WEB =
      ClientPlatform._(3, _omitEnumNames ? '' : 'WEB');
  static const ClientPlatform ANDROID =
      ClientPlatform._(4, _omitEnumNames ? '' : 'ANDROID');
  static const ClientPlatform IOS =
      ClientPlatform._(5, _omitEnumNames ? '' : 'IOS');

  static const $core.List<ClientPlatform> values = <ClientPlatform>[
    PLATFORM_UNKNOWN,
    WINDOWS,
    MACOS,
    WEB,
    ANDROID,
    IOS,
  ];

  static final $core.List<ClientPlatform?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static ClientPlatform? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ClientPlatform._(super.value, super.name);
}

class CalendarRole extends $pb.ProtobufEnum {
  static const CalendarRole RoleUnknown =
      CalendarRole._(0, _omitEnumNames ? '' : 'RoleUnknown');
  static const CalendarRole RoleGuest =
      CalendarRole._(1, _omitEnumNames ? '' : 'RoleGuest');
  static const CalendarRole RoleSubscriber =
      CalendarRole._(2, _omitEnumNames ? '' : 'RoleSubscriber');
  static const CalendarRole RoleEditor =
      CalendarRole._(3, _omitEnumNames ? '' : 'RoleEditor');
  static const CalendarRole RoleManager =
      CalendarRole._(4, _omitEnumNames ? '' : 'RoleManager');
  static const CalendarRole RoleOwner =
      CalendarRole._(5, _omitEnumNames ? '' : 'RoleOwner');

  static const $core.List<CalendarRole> values = <CalendarRole>[
    RoleUnknown,
    RoleGuest,
    RoleSubscriber,
    RoleEditor,
    RoleManager,
    RoleOwner,
  ];

  static final $core.List<CalendarRole?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static CalendarRole? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CalendarRole._(super.value, super.name);
}

class ImageIcon_IconType extends $pb.ProtobufEnum {
  static const ImageIcon_IconType UNKNOWN_ICON_TYPE =
      ImageIcon_IconType._(0, _omitEnumNames ? '' : 'UNKNOWN_ICON_TYPE');
  static const ImageIcon_IconType EMOJI =
      ImageIcon_IconType._(1, _omitEnumNames ? '' : 'EMOJI');
  static const ImageIcon_IconType IMAGE =
      ImageIcon_IconType._(2, _omitEnumNames ? '' : 'IMAGE');

  static const $core.List<ImageIcon_IconType> values = <ImageIcon_IconType>[
    UNKNOWN_ICON_TYPE,
    EMOJI,
    IMAGE,
  ];

  static final $core.List<ImageIcon_IconType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ImageIcon_IconType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ImageIcon_IconType._(super.value, super.name);
}

class CycleRule_CycleType extends $pb.ProtobufEnum {
  static const CycleRule_CycleType CycleNone =
      CycleRule_CycleType._(0, _omitEnumNames ? '' : 'CycleNone');
  static const CycleRule_CycleType CycleByDay =
      CycleRule_CycleType._(1, _omitEnumNames ? '' : 'CycleByDay');
  static const CycleRule_CycleType CycleByWeek =
      CycleRule_CycleType._(2, _omitEnumNames ? '' : 'CycleByWeek');
  static const CycleRule_CycleType CycleByMonth =
      CycleRule_CycleType._(3, _omitEnumNames ? '' : 'CycleByMonth');
  static const CycleRule_CycleType CycleByMonthWeek =
      CycleRule_CycleType._(4, _omitEnumNames ? '' : 'CycleByMonthWeek');
  static const CycleRule_CycleType CycleByYear =
      CycleRule_CycleType._(5, _omitEnumNames ? '' : 'CycleByYear');

  static const $core.List<CycleRule_CycleType> values = <CycleRule_CycleType>[
    CycleNone,
    CycleByDay,
    CycleByWeek,
    CycleByMonth,
    CycleByMonthWeek,
    CycleByYear,
  ];

  static final $core.List<CycleRule_CycleType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static CycleRule_CycleType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CycleRule_CycleType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
