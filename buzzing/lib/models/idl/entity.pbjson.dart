// This is a generated file - do not edit.
//
// Generated from entity.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use envChannelDescriptor instead')
const EnvChannel$json = {
  '1': 'EnvChannel',
  '2': [
    {'1': 'ENV_UNKNOWN', '2': 0},
    {'1': 'ENV_RELEASE', '2': 1},
    {'1': 'ENV_PRERELEASE', '2': 2},
    {'1': 'ENV_DEV', '2': 3},
  ],
};

/// Descriptor for `EnvChannel`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List envChannelDescriptor = $convert.base64Decode(
    'CgpFbnZDaGFubmVsEg8KC0VOVl9VTktOT1dOEAASDwoLRU5WX1JFTEVBU0UQARISCg5FTlZfUF'
    'JFUkVMRUFTRRACEgsKB0VOVl9ERVYQAw==');

@$core.Deprecated('Use packageTypeDescriptor instead')
const PackageType$json = {
  '1': 'PackageType',
  '2': [
    {'1': 'PACKAGE_UNKNOWN', '2': 0},
    {'1': 'PACKAGE_RELEASE', '2': 1},
    {'1': 'PACKAGE_DEBUG', '2': 2},
  ],
};

/// Descriptor for `PackageType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List packageTypeDescriptor = $convert.base64Decode(
    'CgtQYWNrYWdlVHlwZRITCg9QQUNLQUdFX1VOS05PV04QABITCg9QQUNLQUdFX1JFTEVBU0UQAR'
    'IRCg1QQUNLQUdFX0RFQlVHEAI=');

@$core.Deprecated('Use oSTypeDescriptor instead')
const OSType$json = {
  '1': 'OSType',
  '2': [
    {'1': 'OS_UNKNOWN', '2': 0},
    {'1': 'OS_WINDOWS', '2': 1},
    {'1': 'OS_MACOS', '2': 2},
    {'1': 'OS_ANDROID', '2': 3},
    {'1': 'OS_IOS', '2': 4},
  ],
};

/// Descriptor for `OSType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List oSTypeDescriptor = $convert.base64Decode(
    'CgZPU1R5cGUSDgoKT1NfVU5LTk9XThAAEg4KCk9TX1dJTkRPV1MQARIMCghPU19NQUNPUxACEg'
    '4KCk9TX0FORFJPSUQQAxIKCgZPU19JT1MQBA==');

@$core.Deprecated('Use dataSourceDescriptor instead')
const DataSource$json = {
  '1': 'DataSource',
  '2': [
    {'1': 'SOURCE_UNKNOWN', '2': 0},
    {'1': 'SOURCE_LOCAL_ONLY', '2': 1},
    {'1': 'SOURCE_LOCAL_FIRST', '2': 2},
    {'1': 'SOURCE_SERVER_FIRST', '2': 3},
  ],
};

/// Descriptor for `DataSource`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List dataSourceDescriptor = $convert.base64Decode(
    'CgpEYXRhU291cmNlEhIKDlNPVVJDRV9VTktOT1dOEAASFQoRU09VUkNFX0xPQ0FMX09OTFkQAR'
    'IWChJTT1VSQ0VfTE9DQUxfRklSU1QQAhIXChNTT1VSQ0VfU0VSVkVSX0ZJUlNUEAM=');

@$core.Deprecated('Use chatTypeDescriptor instead')
const ChatType$json = {
  '1': 'ChatType',
  '2': [
    {'1': 'CHAT_UNKNOWN', '2': 0},
    {'1': 'CHAT_P2P', '2': 1},
    {'1': 'CHAT_GROUP', '2': 2},
  ],
};

/// Descriptor for `ChatType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List chatTypeDescriptor = $convert.base64Decode(
    'CghDaGF0VHlwZRIQCgxDSEFUX1VOS05PV04QABIMCghDSEFUX1AyUBABEg4KCkNIQVRfR1JPVV'
    'AQAg==');

@$core.Deprecated('Use userTypeDescriptor instead')
const UserType$json = {
  '1': 'UserType',
  '2': [
    {'1': 'USER_TYPE_UNKNOWN', '2': 0},
    {'1': 'USER_TYPE_PERSONAL', '2': 1},
    {'1': 'USER_TYPE_TENANT', '2': 2},
  ],
};

/// Descriptor for `UserType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List userTypeDescriptor = $convert.base64Decode(
    'CghVc2VyVHlwZRIVChFVU0VSX1RZUEVfVU5LTk9XThAAEhYKElVTRVJfVFlQRV9QRVJTT05BTB'
    'ABEhQKEFVTRVJfVFlQRV9URU5BTlQQAg==');

@$core.Deprecated('Use tenantPermisionDescriptor instead')
const TenantPermision$json = {
  '1': 'TenantPermision',
  '2': [
    {'1': 'TENANT_PERMISION_UNKNOWN', '2': 0},
    {'1': 'TENANT_PERMISION_NORMAL', '2': 1},
    {'1': 'TENANT_PERMISION_ADMIN', '2': 2},
    {'1': 'TENANT_PERMISION_SUPER_ADMIN', '2': 3},
  ],
};

/// Descriptor for `TenantPermision`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List tenantPermisionDescriptor = $convert.base64Decode(
    'Cg9UZW5hbnRQZXJtaXNpb24SHAoYVEVOQU5UX1BFUk1JU0lPTl9VTktOT1dOEAASGwoXVEVOQU'
    '5UX1BFUk1JU0lPTl9OT1JNQUwQARIaChZURU5BTlRfUEVSTUlTSU9OX0FETUlOEAISIAocVEVO'
    'QU5UX1BFUk1JU0lPTl9TVVBFUl9BRE1JThAD');

@$core.Deprecated('Use bizTypeDescriptor instead')
const BizType$json = {
  '1': 'BizType',
  '2': [
    {'1': 'BIZ_UNKNOWN', '2': 0},
    {'1': 'BIZ_IM', '2': 1},
    {'1': 'BIZ_GATEWAY', '2': 2},
    {'1': 'BIZ_SETTING', '2': 3},
    {'1': 'BIZ_CALENDAR', '2': 4},
    {'1': 'BIZ_TODO', '2': 5},
    {'1': 'BIZ_RTC', '2': 6},
    {'1': 'BIZ_OFFICE', '2': 7},
    {'1': 'BIZ_USER', '2': 8},
    {'1': 'BIZ_STORAGE', '2': 9},
  ],
};

/// Descriptor for `BizType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List bizTypeDescriptor = $convert.base64Decode(
    'CgdCaXpUeXBlEg8KC0JJWl9VTktOT1dOEAASCgoGQklaX0lNEAESDwoLQklaX0dBVEVXQVkQAh'
    'IPCgtCSVpfU0VUVElORxADEhAKDEJJWl9DQUxFTkRBUhAEEgwKCEJJWl9UT0RPEAUSCwoHQkla'
    'X1JUQxAGEg4KCkJJWl9PRkZJQ0UQBxIMCghCSVpfVVNFUhAIEg8KC0JJWl9TVE9SQUdFEAk=');

@$core.Deprecated('Use entityTypeDescriptor instead')
const EntityType$json = {
  '1': 'EntityType',
  '2': [
    {'1': 'ENTITY_TYPE_UNKNOWN', '2': 0},
    {'1': 'USER', '2': 1},
    {'1': 'CHAT', '2': 2},
    {'1': 'BOT', '2': 4},
    {'1': 'DOC', '2': 5},
    {'1': 'FEED', '2': 6},
    {'1': 'ACCOUNT', '2': 7},
    {'1': 'TENANT', '2': 8},
    {'1': 'DEPARTMENT', '2': 9},
    {'1': 'OPENAPP', '2': 10},
    {'1': 'SUBSCRIPTION', '2': 11},
    {'1': 'DOC_FEED', '2': 12},
    {'1': 'THREAD', '2': 14},
    {'1': 'MESSAGE', '2': 15},
    {'1': 'DEPT', '2': 16},
    {'1': 'READSTATE', '2': 17},
    {'1': 'FILE_TYPE', '2': 18},
    {'1': 'URL', '2': 19},
    {'1': 'SETTING', '2': 20},
    {'1': 'CALENDAR', '2': 21},
    {'1': 'SCHEDULE', '2': 22},
    {'1': 'SCHEDULE_CYCLE', '2': 23},
  ],
};

/// Descriptor for `EntityType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List entityTypeDescriptor = $convert.base64Decode(
    'CgpFbnRpdHlUeXBlEhcKE0VOVElUWV9UWVBFX1VOS05PV04QABIICgRVU0VSEAESCAoEQ0hBVB'
    'ACEgcKA0JPVBAEEgcKA0RPQxAFEggKBEZFRUQQBhILCgdBQ0NPVU5UEAcSCgoGVEVOQU5UEAgS'
    'DgoKREVQQVJUTUVOVBAJEgsKB09QRU5BUFAQChIQCgxTVUJTQ1JJUFRJT04QCxIMCghET0NfRk'
    'VFRBAMEgoKBlRIUkVBRBAOEgsKB01FU1NBR0UQDxIICgRERVBUEBASDQoJUkVBRFNUQVRFEBES'
    'DQoJRklMRV9UWVBFEBISBwoDVVJMEBMSCwoHU0VUVElORxAUEgwKCENBTEVOREFSEBUSDAoIU0'
    'NIRURVTEUQFhISCg5TQ0hFRFVMRV9DWUNMRRAX');

@$core.Deprecated('Use settingTypeDescriptor instead')
const SettingType$json = {
  '1': 'SettingType',
  '2': [
    {'1': 'SETTING_TYPE_UNKNOWN', '2': 0},
    {'1': 'SETTING_FAVORITE', '2': 1},
    {'1': 'SETTING_TOP_LIST', '2': 2},
    {'1': 'USER_CALENDAR_LIST', '2': 3},
  ],
};

/// Descriptor for `SettingType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List settingTypeDescriptor = $convert.base64Decode(
    'CgtTZXR0aW5nVHlwZRIYChRTRVRUSU5HX1RZUEVfVU5LTk9XThAAEhQKEFNFVFRJTkdfRkFWT1'
    'JJVEUQARIUChBTRVRUSU5HX1RPUF9MSVNUEAISFgoSVVNFUl9DQUxFTkRBUl9MSVNUEAM=');

@$core.Deprecated('Use entityStatusDescriptor instead')
const EntityStatus$json = {
  '1': 'EntityStatus',
  '2': [
    {'1': 'STATUS_UNKNOWN', '2': 0},
    {'1': 'NORMAL', '2': 1},
    {'1': 'INVISIBLE', '2': 2},
    {'1': 'DELETE_PENDING', '2': 3},
    {'1': 'DISMISS_PENDING', '2': 4},
    {'1': 'DELETED', '2': 5},
    {'1': 'RECALL', '2': 6},
    {'1': 'STOP', '2': 7},
    {'1': 'FAIL', '2': 8},
  ],
};

/// Descriptor for `EntityStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List entityStatusDescriptor = $convert.base64Decode(
    'CgxFbnRpdHlTdGF0dXMSEgoOU1RBVFVTX1VOS05PV04QABIKCgZOT1JNQUwQARINCglJTlZJU0'
    'lCTEUQAhISCg5ERUxFVEVfUEVORElORxADEhMKD0RJU01JU1NfUEVORElORxAEEgsKB0RFTEVU'
    'RUQQBRIKCgZSRUNBTEwQBhIICgRTVE9QEAcSCAoERkFJTBAI');

@$core.Deprecated('Use messageTypeDescriptor instead')
const MessageType$json = {
  '1': 'MessageType',
  '2': [
    {'1': 'MESSAGE_TYPE_UNKNOWN', '2': 0},
    {'1': 'TEXT', '2': 1},
    {'1': 'IMAGE', '2': 2},
    {'1': 'FILE', '2': 3},
    {'1': 'VOICE', '2': 4},
    {'1': 'MEDIA', '2': 5},
    {'1': 'RICH_TEXT', '2': 6},
    {'1': 'LOCATION', '2': 7},
    {'1': 'CARD', '2': 8},
    {'1': 'VOTE', '2': 9},
    {'1': 'REDPACKET', '2': 10},
    {'1': 'RICH_TEXT_QUILL', '2': 11},
    {'1': 'MEETING_INVITE', '2': 12},
    {'1': 'MARKDOWN', '2': 13},
    {'1': 'FORWARD', '2': 14},
    {'1': 'SYSTEM', '2': 15},
  ],
};

/// Descriptor for `MessageType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List messageTypeDescriptor = $convert.base64Decode(
    'CgtNZXNzYWdlVHlwZRIYChRNRVNTQUdFX1RZUEVfVU5LTk9XThAAEggKBFRFWFQQARIJCgVJTU'
    'FHRRACEggKBEZJTEUQAxIJCgVWT0lDRRAEEgkKBU1FRElBEAUSDQoJUklDSF9URVhUEAYSDAoI'
    'TE9DQVRJT04QBxIICgRDQVJEEAgSCAoEVk9URRAJEg0KCVJFRFBBQ0tFVBAKEhMKD1JJQ0hfVE'
    'VYVF9RVUlMTBALEhIKDk1FRVRJTkdfSU5WSVRFEAwSDAoITUFSS0RPV04QDRILCgdGT1JXQVJE'
    'EA4SCgoGU1lTVEVNEA8=');

@$core.Deprecated('Use directDescriptor instead')
const Direct$json = {
  '1': 'Direct',
  '2': [
    {'1': 'NONE', '2': 0},
    {'1': 'UP', '2': 1},
    {'1': 'DOWN', '2': 2},
    {'1': 'BOTH', '2': 3},
  ],
};

/// Descriptor for `Direct`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List directDescriptor = $convert.base64Decode(
    'CgZEaXJlY3QSCAoETk9ORRAAEgYKAlVQEAESCAoERE9XThACEggKBEJPVEgQAw==');

@$core.Deprecated('Use operateDescriptor instead')
const Operate$json = {
  '1': 'Operate',
  '2': [
    {'1': 'OPERATE_NONE', '2': 0},
    {'1': 'OPERATE_CREATE', '2': 1},
    {'1': 'OPERATE_UPDATE', '2': 2},
    {'1': 'OPERATE_DELETE', '2': 3},
    {'1': 'OPERATE_SEARCH', '2': 4},
  ],
};

/// Descriptor for `Operate`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List operateDescriptor = $convert.base64Decode(
    'CgdPcGVyYXRlEhAKDE9QRVJBVEVfTk9ORRAAEhIKDk9QRVJBVEVfQ1JFQVRFEAESEgoOT1BFUk'
    'FURV9VUERBVEUQAhISCg5PUEVSQVRFX0RFTEVURRADEhIKDk9QRVJBVEVfU0VBUkNIEAQ=');

@$core.Deprecated('Use clientPlatformDescriptor instead')
const ClientPlatform$json = {
  '1': 'ClientPlatform',
  '2': [
    {'1': 'PLATFORM_UNKNOWN', '2': 0},
    {'1': 'WINDOWS', '2': 1},
    {'1': 'MACOS', '2': 2},
    {'1': 'WEB', '2': 3},
    {'1': 'ANDROID', '2': 4},
    {'1': 'IOS', '2': 5},
  ],
};

/// Descriptor for `ClientPlatform`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List clientPlatformDescriptor = $convert.base64Decode(
    'Cg5DbGllbnRQbGF0Zm9ybRIUChBQTEFURk9STV9VTktOT1dOEAASCwoHV0lORE9XUxABEgkKBU'
    '1BQ09TEAISBwoDV0VCEAMSCwoHQU5EUk9JRBAEEgcKA0lPUxAF');

@$core.Deprecated('Use calendarRoleDescriptor instead')
const CalendarRole$json = {
  '1': 'CalendarRole',
  '2': [
    {'1': 'RoleUnknown', '2': 0},
    {'1': 'RoleGuest', '2': 1},
    {'1': 'RoleSubscriber', '2': 2},
    {'1': 'RoleEditor', '2': 3},
    {'1': 'RoleManager', '2': 4},
    {'1': 'RoleOwner', '2': 5},
  ],
};

/// Descriptor for `CalendarRole`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List calendarRoleDescriptor = $convert.base64Decode(
    'CgxDYWxlbmRhclJvbGUSDwoLUm9sZVVua25vd24QABINCglSb2xlR3Vlc3QQARISCg5Sb2xlU3'
    'Vic2NyaWJlchACEg4KClJvbGVFZGl0b3IQAxIPCgtSb2xlTWFuYWdlchAEEg0KCVJvbGVPd25l'
    'chAF');

@$core.Deprecated('Use commonErrorDescriptor instead')
const CommonError$json = {
  '1': 'CommonError',
  '2': [
    {'1': 'status', '3': 1, '4': 1, '5': 5, '10': 'status'},
    {'1': 'code', '3': 2, '4': 1, '5': 5, '10': 'code'},
    {'1': 'display_message', '3': 3, '4': 1, '5': 9, '10': 'displayMessage'},
    {'1': 'display_title', '3': 4, '4': 1, '5': 9, '10': 'displayTitle'},
    {'1': 'server_message', '3': 5, '4': 1, '5': 9, '10': 'serverMessage'},
  ],
};

/// Descriptor for `CommonError`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commonErrorDescriptor = $convert.base64Decode(
    'CgtDb21tb25FcnJvchIWCgZzdGF0dXMYASABKAVSBnN0YXR1cxISCgRjb2RlGAIgASgFUgRjb2'
    'RlEicKD2Rpc3BsYXlfbWVzc2FnZRgDIAEoCVIOZGlzcGxheU1lc3NhZ2USIwoNZGlzcGxheV90'
    'aXRsZRgEIAEoCVIMZGlzcGxheVRpdGxlEiUKDnNlcnZlcl9tZXNzYWdlGAUgASgJUg1zZXJ2ZX'
    'JNZXNzYWdl');

@$core.Deprecated('Use settingDescriptor instead')
const Setting$json = {
  '1': 'Setting',
  '2': [
    {'1': 'version', '3': 1, '4': 1, '5': 3, '10': 'version'},
    {'1': 'data', '3': 2, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `Setting`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List settingDescriptor = $convert.base64Decode(
    'CgdTZXR0aW5nEhgKB3ZlcnNpb24YASABKANSB3ZlcnNpb24SEgoEZGF0YRgCIAEoDFIEZGF0YQ'
    '==');

@$core.Deprecated('Use settingsDescriptor instead')
const Settings$json = {
  '1': 'Settings',
  '2': [
    {
      '1': 'settings',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.entity.Settings.SettingsEntry',
      '10': 'settings'
    },
  ],
  '3': [Settings_SettingsEntry$json],
};

@$core.Deprecated('Use settingsDescriptor instead')
const Settings_SettingsEntry$json = {
  '1': 'SettingsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.entity.Setting',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `Settings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List settingsDescriptor = $convert.base64Decode(
    'CghTZXR0aW5ncxI6CghzZXR0aW5ncxgBIAMoCzIeLmVudGl0eS5TZXR0aW5ncy5TZXR0aW5nc0'
    'VudHJ5UghzZXR0aW5ncxpMCg1TZXR0aW5nc0VudHJ5EhAKA2tleRgBIAEoBVIDa2V5EiUKBXZh'
    'bHVlGAIgASgLMg8uZW50aXR5LlNldHRpbmdSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use userDescriptor instead')
const User$json = {
  '1': 'User',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'status', '3': 3, '4': 1, '5': 5, '10': 'status'},
    {'1': 'tenant_id', '3': 4, '4': 1, '5': 3, '10': 'tenantId'},
    {'1': 'version', '3': 5, '4': 1, '5': 3, '10': 'version'},
    {'1': 'avatar', '3': 6, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'dept_id', '3': 7, '4': 1, '5': 3, '10': 'deptId'},
  ],
};

/// Descriptor for `User`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDescriptor = $convert.base64Decode(
    'CgRVc2VyEg4KAmlkGAEgASgDUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEhYKBnN0YXR1cxgDIA'
    'EoBVIGc3RhdHVzEhsKCXRlbmFudF9pZBgEIAEoA1IIdGVuYW50SWQSGAoHdmVyc2lvbhgFIAEo'
    'A1IHdmVyc2lvbhIWCgZhdmF0YXIYBiABKAlSBmF2YXRhchIXCgdkZXB0X2lkGAcgASgDUgZkZX'
    'B0SWQ=');

@$core.Deprecated('Use userLiteDescriptor instead')
const UserLite$json = {
  '1': 'UserLite',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'status', '3': 3, '4': 1, '5': 5, '10': 'status'},
    {'1': 'tenant_id', '3': 4, '4': 1, '5': 3, '10': 'tenantId'},
    {'1': 'version', '3': 5, '4': 1, '5': 3, '10': 'version'},
    {'1': 'avatar', '3': 6, '4': 1, '5': 9, '10': 'avatar'},
  ],
};

/// Descriptor for `UserLite`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userLiteDescriptor = $convert.base64Decode(
    'CghVc2VyTGl0ZRIOCgJpZBgBIAEoA1ICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRIWCgZzdGF0dX'
    'MYAyABKAVSBnN0YXR1cxIbCgl0ZW5hbnRfaWQYBCABKANSCHRlbmFudElkEhgKB3ZlcnNpb24Y'
    'BSABKANSB3ZlcnNpb24SFgoGYXZhdGFyGAYgASgJUgZhdmF0YXI=');

@$core.Deprecated('Use entityIdDescriptor instead')
const EntityId$json = {
  '1': 'EntityId',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {
      '1': 'type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.entity.EntityType',
      '10': 'type'
    },
  ],
};

/// Descriptor for `EntityId`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List entityIdDescriptor = $convert.base64Decode(
    'CghFbnRpdHlJZBIOCgJpZBgBIAEoA1ICaWQSJgoEdHlwZRgCIAEoDjISLmVudGl0eS5FbnRpdH'
    'lUeXBlUgR0eXBl');

@$core.Deprecated('Use idListDescriptor instead')
const IdList$json = {
  '1': 'IdList',
  '2': [
    {'1': 'ids', '3': 1, '4': 3, '5': 3, '10': 'ids'},
  ],
};

/// Descriptor for `IdList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List idListDescriptor =
    $convert.base64Decode('CgZJZExpc3QSEAoDaWRzGAEgAygDUgNpZHM=');

@$core.Deprecated('Use entityChangeDescriptor instead')
const EntityChange$json = {
  '1': 'EntityChange',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'type', '3': 2, '4': 1, '5': 5, '10': 'type'},
    {'1': 'version', '3': 3, '4': 1, '5': 3, '10': 'version'},
    {'1': 'operate', '3': 4, '4': 1, '5': 5, '10': 'operate'},
  ],
};

/// Descriptor for `EntityChange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List entityChangeDescriptor = $convert.base64Decode(
    'CgxFbnRpdHlDaGFuZ2USDgoCaWQYASABKANSAmlkEhIKBHR5cGUYAiABKAVSBHR5cGUSGAoHdm'
    'Vyc2lvbhgDIAEoA1IHdmVyc2lvbhIYCgdvcGVyYXRlGAQgASgFUgdvcGVyYXRl');

@$core.Deprecated('Use i18nValueDescriptor instead')
const I18nValue$json = {
  '1': 'I18nValue',
  '2': [
    {
      '1': 'value',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.entity.I18nValue.ValueEntry',
      '10': 'value'
    },
  ],
  '3': [I18nValue_ValueEntry$json],
};

@$core.Deprecated('Use i18nValueDescriptor instead')
const I18nValue_ValueEntry$json = {
  '1': 'ValueEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `I18nValue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List i18nValueDescriptor = $convert.base64Decode(
    'CglJMThuVmFsdWUSMgoFdmFsdWUYASADKAsyHC5lbnRpdHkuSTE4blZhbHVlLlZhbHVlRW50cn'
    'lSBXZhbHVlGjgKClZhbHVlRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlS'
    'BXZhbHVlOgI4AQ==');

@$core.Deprecated('Use chatDescriptor instead')
const Chat$json = {
  '1': 'Chat',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'chat_type', '3': 2, '4': 1, '5': 5, '10': 'chatType'},
    {'1': 'status', '3': 3, '4': 1, '5': 5, '10': 'status'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
    {'1': 'peer_a_id', '3': 5, '4': 1, '5': 3, '10': 'peerAId'},
    {'1': 'peer_b_id', '3': 6, '4': 1, '5': 3, '10': 'peerBId'},
    {'1': 'owner_id', '3': 7, '4': 1, '5': 3, '10': 'ownerId'},
    {'1': 'member_ids', '3': 8, '4': 3, '5': 3, '10': 'memberIds'},
    {'1': 'create_at_ms', '3': 9, '4': 1, '5': 3, '10': 'createAtMs'},
    {'1': 'update_at_ms', '3': 10, '4': 1, '5': 3, '10': 'updateAtMs'},
    {'1': 'last_message_id', '3': 11, '4': 1, '5': 3, '10': 'lastMessageId'},
    {
      '1': 'last_message_badge_count',
      '3': 12,
      '4': 1,
      '5': 5,
      '10': 'lastMessageBadgeCount'
    },
    {'1': 'last_message_pos', '3': 13, '4': 1, '5': 5, '10': 'lastMessagePos'},
    {'1': 'admin_ids', '3': 14, '4': 3, '5': 3, '10': 'adminIds'},
    {'1': 'version', '3': 15, '4': 1, '5': 3, '10': 'version'},
    {'1': 'avatar', '3': 16, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'color', '3': 17, '4': 1, '5': 5, '10': 'color'},
  ],
};

/// Descriptor for `Chat`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatDescriptor = $convert.base64Decode(
    'CgRDaGF0Eg4KAmlkGAEgASgDUgJpZBIbCgljaGF0X3R5cGUYAiABKAVSCGNoYXRUeXBlEhYKBn'
    'N0YXR1cxgDIAEoBVIGc3RhdHVzEhIKBG5hbWUYBCABKAlSBG5hbWUSGgoJcGVlcl9hX2lkGAUg'
    'ASgDUgdwZWVyQUlkEhoKCXBlZXJfYl9pZBgGIAEoA1IHcGVlckJJZBIZCghvd25lcl9pZBgHIA'
    'EoA1IHb3duZXJJZBIdCgptZW1iZXJfaWRzGAggAygDUgltZW1iZXJJZHMSIAoMY3JlYXRlX2F0'
    'X21zGAkgASgDUgpjcmVhdGVBdE1zEiAKDHVwZGF0ZV9hdF9tcxgKIAEoA1IKdXBkYXRlQXRNcx'
    'ImCg9sYXN0X21lc3NhZ2VfaWQYCyABKANSDWxhc3RNZXNzYWdlSWQSNwoYbGFzdF9tZXNzYWdl'
    'X2JhZGdlX2NvdW50GAwgASgFUhVsYXN0TWVzc2FnZUJhZGdlQ291bnQSKAoQbGFzdF9tZXNzYW'
    'dlX3BvcxgNIAEoBVIObGFzdE1lc3NhZ2VQb3MSGwoJYWRtaW5faWRzGA4gAygDUghhZG1pbklk'
    'cxIYCgd2ZXJzaW9uGA8gASgDUgd2ZXJzaW9uEhYKBmF2YXRhchgQIAEoCVIGYXZhdGFyEhQKBW'
    'NvbG9yGBEgASgFUgVjb2xvcg==');

@$core.Deprecated('Use feedDescriptor instead')
const Feed$json = {
  '1': 'Feed',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'type', '3': 2, '4': 1, '5': 5, '10': 'type'},
    {'1': 'badge', '3': 3, '4': 1, '5': 5, '10': 'badge'},
    {'1': 'update_time_ms', '3': 4, '4': 1, '5': 3, '10': 'updateTimeMs'},
    {'1': 'rank_time_ms', '3': 5, '4': 1, '5': 3, '10': 'rankTimeMs'},
    {'1': 'refer_id', '3': 6, '4': 1, '5': 3, '10': 'referId'},
    {'1': 'refer_pos', '3': 7, '4': 1, '5': 5, '10': 'referPos'},
    {'1': 'refer_badge', '3': 8, '4': 1, '5': 5, '10': 'referBadge'},
    {'1': 'read_pos', '3': 9, '4': 1, '5': 5, '10': 'readPos'},
    {'1': 'read_badge', '3': 10, '4': 1, '5': 5, '10': 'readBadge'},
    {'1': 'version', '3': 11, '4': 1, '5': 3, '10': 'version'},
    {'1': 'is_top', '3': 12, '4': 1, '5': 5, '10': 'isTop'},
    {'1': 'is_mute', '3': 13, '4': 1, '5': 5, '10': 'isMute'},
    {'1': 'status', '3': 14, '4': 1, '5': 5, '10': 'status'},
  ],
};

/// Descriptor for `Feed`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List feedDescriptor = $convert.base64Decode(
    'CgRGZWVkEg4KAmlkGAEgASgDUgJpZBISCgR0eXBlGAIgASgFUgR0eXBlEhQKBWJhZGdlGAMgAS'
    'gFUgViYWRnZRIkCg51cGRhdGVfdGltZV9tcxgEIAEoA1IMdXBkYXRlVGltZU1zEiAKDHJhbmtf'
    'dGltZV9tcxgFIAEoA1IKcmFua1RpbWVNcxIZCghyZWZlcl9pZBgGIAEoA1IHcmVmZXJJZBIbCg'
    'lyZWZlcl9wb3MYByABKAVSCHJlZmVyUG9zEh8KC3JlZmVyX2JhZGdlGAggASgFUgpyZWZlckJh'
    'ZGdlEhkKCHJlYWRfcG9zGAkgASgFUgdyZWFkUG9zEh0KCnJlYWRfYmFkZ2UYCiABKAVSCXJlYW'
    'RCYWRnZRIYCgd2ZXJzaW9uGAsgASgDUgd2ZXJzaW9uEhUKBmlzX3RvcBgMIAEoBVIFaXNUb3AS'
    'FwoHaXNfbXV0ZRgNIAEoBVIGaXNNdXRlEhYKBnN0YXR1cxgOIAEoBVIGc3RhdHVz');

@$core.Deprecated('Use favoriteDescriptor instead')
const Favorite$json = {
  '1': 'Favorite',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'tpy', '3': 2, '4': 1, '5': 5, '10': 'tpy'},
    {
      '1': 'message',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.entity.Message',
      '10': 'message'
    },
  ],
};

/// Descriptor for `Favorite`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List favoriteDescriptor = $convert.base64Decode(
    'CghGYXZvcml0ZRIOCgJpZBgBIAEoA1ICaWQSEAoDdHB5GAIgASgFUgN0cHkSKQoHbWVzc2FnZR'
    'gDIAEoCzIPLmVudGl0eS5NZXNzYWdlUgdtZXNzYWdl');

@$core.Deprecated('Use favoriteListDescriptor instead')
const FavoriteList$json = {
  '1': 'FavoriteList',
  '2': [
    {
      '1': 'favorites',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.entity.Favorite',
      '10': 'favorites'
    },
  ],
};

/// Descriptor for `FavoriteList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List favoriteListDescriptor = $convert.base64Decode(
    'CgxGYXZvcml0ZUxpc3QSLgoJZmF2b3JpdGVzGAEgAygLMhAuZW50aXR5LkZhdm9yaXRlUglmYX'
    'Zvcml0ZXM=');

@$core.Deprecated('Use readStateDescriptor instead')
const ReadState$json = {
  '1': 'ReadState',
  '2': [
    {'1': 'total', '3': 1, '4': 1, '5': 5, '10': 'total'},
    {'1': 'read_count', '3': 2, '4': 1, '5': 5, '10': 'readCount'},
    {'1': 'unread_count', '3': 3, '4': 1, '5': 5, '10': 'unreadCount'},
    {'1': 'me_read', '3': 4, '4': 1, '5': 8, '10': 'meRead'},
    {'1': 'top_read_ids', '3': 5, '4': 3, '5': 3, '10': 'topReadIds'},
  ],
};

/// Descriptor for `ReadState`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List readStateDescriptor = $convert.base64Decode(
    'CglSZWFkU3RhdGUSFAoFdG90YWwYASABKAVSBXRvdGFsEh0KCnJlYWRfY291bnQYAiABKAVSCX'
    'JlYWRDb3VudBIhCgx1bnJlYWRfY291bnQYAyABKAVSC3VucmVhZENvdW50EhcKB21lX3JlYWQY'
    'BCABKAhSBm1lUmVhZBIgCgx0b3BfcmVhZF9pZHMYBSADKANSCnRvcFJlYWRJZHM=');

@$core.Deprecated('Use reactionDescriptor instead')
const Reaction$json = {
  '1': 'Reaction',
  '2': [
    {'1': 'total', '3': 1, '4': 1, '5': 5, '10': 'total'},
    {'1': 'me_read', '3': 2, '4': 1, '5': 8, '10': 'meRead'},
    {'1': 'top_ids', '3': 3, '4': 3, '5': 3, '10': 'topIds'},
  ],
};

/// Descriptor for `Reaction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reactionDescriptor = $convert.base64Decode(
    'CghSZWFjdGlvbhIUCgV0b3RhbBgBIAEoBVIFdG90YWwSFwoHbWVfcmVhZBgCIAEoCFIGbWVSZW'
    'FkEhcKB3RvcF9pZHMYAyADKANSBnRvcElkcw==');

@$core.Deprecated('Use reactionsDescriptor instead')
const Reactions$json = {
  '1': 'Reactions',
  '2': [
    {
      '1': 'reactions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.entity.Reactions.ReactionsEntry',
      '10': 'reactions'
    },
  ],
  '3': [Reactions_ReactionsEntry$json],
};

@$core.Deprecated('Use reactionsDescriptor instead')
const Reactions_ReactionsEntry$json = {
  '1': 'ReactionsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.entity.Reaction',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `Reactions`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reactionsDescriptor = $convert.base64Decode(
    'CglSZWFjdGlvbnMSPgoJcmVhY3Rpb25zGAEgAygLMiAuZW50aXR5LlJlYWN0aW9ucy5SZWFjdG'
    'lvbnNFbnRyeVIJcmVhY3Rpb25zGk4KDlJlYWN0aW9uc0VudHJ5EhAKA2tleRgBIAEoBVIDa2V5'
    'EiYKBXZhbHVlGAIgASgLMhAuZW50aXR5LlJlYWN0aW9uUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use messageDescriptor instead')
const Message$json = {
  '1': 'Message',
  '2': [
    {'1': 'tpy', '3': 1, '4': 1, '5': 5, '10': 'tpy'},
    {'1': 'id', '3': 2, '4': 1, '5': 3, '10': 'id'},
    {'1': 'chat_id', '3': 3, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'from_id', '3': 4, '4': 1, '5': 3, '10': 'fromId'},
    {'1': 'pos', '3': 5, '4': 1, '5': 5, '10': 'pos'},
    {'1': 'badge_count', '3': 6, '4': 1, '5': 5, '10': 'badgeCount'},
    {'1': 'status', '3': 7, '4': 1, '5': 5, '10': 'status'},
    {'1': 'client_id', '3': 8, '4': 1, '5': 3, '10': 'clientId'},
    {'1': 'create_time_ms', '3': 9, '4': 1, '5': 3, '10': 'createTimeMs'},
    {'1': 'update_time_ms', '3': 10, '4': 1, '5': 3, '10': 'updateTimeMs'},
    {'1': 'at_user_ids', '3': 11, '4': 3, '5': 3, '10': 'atUserIds'},
    {'1': 'content', '3': 20, '4': 1, '5': 12, '10': 'content'},
    {'1': 'summary', '3': 21, '4': 1, '5': 9, '10': 'summary'},
    {'1': 'version', '3': 22, '4': 1, '5': 3, '10': 'version'},
    {
      '1': 'read_state',
      '3': 23,
      '4': 1,
      '5': 11,
      '6': '.entity.ReadState',
      '10': 'readState'
    },
    {
      '1': 'reactions',
      '3': 24,
      '4': 3,
      '5': 11,
      '6': '.entity.Message.ReactionsEntry',
      '10': 'reactions'
    },
    {'1': 'ref_message_id', '3': 31, '4': 1, '5': 3, '10': 'refMessageId'},
    {
      '1': 'ref_data',
      '3': 32,
      '4': 1,
      '5': 11,
      '6': '.entity.MessageReference',
      '10': 'refData'
    },
  ],
  '3': [Message_ReactionsEntry$json],
};

@$core.Deprecated('Use messageDescriptor instead')
const Message_ReactionsEntry$json = {
  '1': 'ReactionsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.entity.Reaction',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `Message`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageDescriptor = $convert.base64Decode(
    'CgdNZXNzYWdlEhAKA3RweRgBIAEoBVIDdHB5Eg4KAmlkGAIgASgDUgJpZBIXCgdjaGF0X2lkGA'
    'MgASgDUgZjaGF0SWQSFwoHZnJvbV9pZBgEIAEoA1IGZnJvbUlkEhAKA3BvcxgFIAEoBVIDcG9z'
    'Eh8KC2JhZGdlX2NvdW50GAYgASgFUgpiYWRnZUNvdW50EhYKBnN0YXR1cxgHIAEoBVIGc3RhdH'
    'VzEhsKCWNsaWVudF9pZBgIIAEoA1IIY2xpZW50SWQSJAoOY3JlYXRlX3RpbWVfbXMYCSABKANS'
    'DGNyZWF0ZVRpbWVNcxIkCg51cGRhdGVfdGltZV9tcxgKIAEoA1IMdXBkYXRlVGltZU1zEh4KC2'
    'F0X3VzZXJfaWRzGAsgAygDUglhdFVzZXJJZHMSGAoHY29udGVudBgUIAEoDFIHY29udGVudBIY'
    'CgdzdW1tYXJ5GBUgASgJUgdzdW1tYXJ5EhgKB3ZlcnNpb24YFiABKANSB3ZlcnNpb24SMAoKcm'
    'VhZF9zdGF0ZRgXIAEoCzIRLmVudGl0eS5SZWFkU3RhdGVSCXJlYWRTdGF0ZRI8CglyZWFjdGlv'
    'bnMYGCADKAsyHi5lbnRpdHkuTWVzc2FnZS5SZWFjdGlvbnNFbnRyeVIJcmVhY3Rpb25zEiQKDn'
    'JlZl9tZXNzYWdlX2lkGB8gASgDUgxyZWZNZXNzYWdlSWQSMwoIcmVmX2RhdGEYICABKAsyGC5l'
    'bnRpdHkuTWVzc2FnZVJlZmVyZW5jZVIHcmVmRGF0YRpOCg5SZWFjdGlvbnNFbnRyeRIQCgNrZX'
    'kYASABKAVSA2tleRImCgV2YWx1ZRgCIAEoCzIQLmVudGl0eS5SZWFjdGlvblIFdmFsdWU6AjgB');

@$core.Deprecated('Use messageReferenceDescriptor instead')
const MessageReference$json = {
  '1': 'MessageReference',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'content', '3': 2, '4': 1, '5': 12, '10': 'content'},
    {'1': 'summary', '3': 3, '4': 1, '5': 9, '10': 'summary'},
    {'1': 'tpy', '3': 4, '4': 1, '5': 5, '10': 'tpy'},
    {'1': 'sender_name', '3': 5, '4': 1, '5': 9, '10': 'senderName'},
  ],
};

/// Descriptor for `MessageReference`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageReferenceDescriptor = $convert.base64Decode(
    'ChBNZXNzYWdlUmVmZXJlbmNlEhcKB2NoYXRfaWQYASABKANSBmNoYXRJZBIYCgdjb250ZW50GA'
    'IgASgMUgdjb250ZW50EhgKB3N1bW1hcnkYAyABKAlSB3N1bW1hcnkSEAoDdHB5GAQgASgFUgN0'
    'cHkSHwoLc2VuZGVyX25hbWUYBSABKAlSCnNlbmRlck5hbWU=');

@$core.Deprecated('Use mentionDescriptor instead')
const Mention$json = {
  '1': 'Mention',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'offset', '3': 3, '4': 1, '5': 5, '10': 'offset'},
    {'1': 'length', '3': 4, '4': 1, '5': 5, '10': 'length'},
  ],
};

/// Descriptor for `Mention`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mentionDescriptor = $convert.base64Decode(
    'CgdNZW50aW9uEhcKB3VzZXJfaWQYASABKANSBnVzZXJJZBISCgRuYW1lGAIgASgJUgRuYW1lEh'
    'YKBm9mZnNldBgDIAEoBVIGb2Zmc2V0EhYKBmxlbmd0aBgEIAEoBVIGbGVuZ3Ro');

@$core.Deprecated('Use messageTextDescriptor instead')
const MessageText$json = {
  '1': 'MessageText',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
    {
      '1': 'mentions',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.entity.Mention',
      '10': 'mentions'
    },
  ],
};

/// Descriptor for `MessageText`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageTextDescriptor = $convert.base64Decode(
    'CgtNZXNzYWdlVGV4dBISCgR0ZXh0GAEgASgJUgR0ZXh0EisKCG1lbnRpb25zGAIgAygLMg8uZW'
    '50aXR5Lk1lbnRpb25SCG1lbnRpb25z');

@$core.Deprecated('Use messageImageDescriptor instead')
const MessageImage$json = {
  '1': 'MessageImage',
  '2': [
    {'1': 'url', '3': 1, '4': 1, '5': 9, '10': 'url'},
    {'1': 'thumbnail_url', '3': 2, '4': 1, '5': 9, '10': 'thumbnailUrl'},
    {'1': 'width', '3': 3, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 4, '4': 1, '5': 5, '10': 'height'},
    {'1': 'alt_text', '3': 5, '4': 1, '5': 9, '10': 'altText'},
  ],
};

/// Descriptor for `MessageImage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageImageDescriptor = $convert.base64Decode(
    'CgxNZXNzYWdlSW1hZ2USEAoDdXJsGAEgASgJUgN1cmwSIwoNdGh1bWJuYWlsX3VybBgCIAEoCV'
    'IMdGh1bWJuYWlsVXJsEhQKBXdpZHRoGAMgASgFUgV3aWR0aBIWCgZoZWlnaHQYBCABKAVSBmhl'
    'aWdodBIZCghhbHRfdGV4dBgFIAEoCVIHYWx0VGV4dA==');

@$core.Deprecated('Use messageFileDescriptor instead')
const MessageFile$json = {
  '1': 'MessageFile',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'size', '3': 2, '4': 1, '5': 3, '10': 'size'},
    {'1': 'mime_type', '3': 3, '4': 1, '5': 9, '10': 'mimeType'},
    {'1': 'url', '3': 4, '4': 1, '5': 9, '10': 'url'},
  ],
};

/// Descriptor for `MessageFile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageFileDescriptor = $convert.base64Decode(
    'CgtNZXNzYWdlRmlsZRISCgRuYW1lGAEgASgJUgRuYW1lEhIKBHNpemUYAiABKANSBHNpemUSGw'
    'oJbWltZV90eXBlGAMgASgJUghtaW1lVHlwZRIQCgN1cmwYBCABKAlSA3VybA==');

@$core.Deprecated('Use messageRichTextDescriptor instead')
const MessageRichText$json = {
  '1': 'MessageRichText',
  '2': [
    {'1': 'delta', '3': 1, '4': 1, '5': 9, '10': 'delta'},
  ],
};

/// Descriptor for `MessageRichText`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageRichTextDescriptor = $convert
    .base64Decode('Cg9NZXNzYWdlUmljaFRleHQSFAoFZGVsdGEYASABKAlSBWRlbHRh');

@$core.Deprecated('Use messageMarkdownDescriptor instead')
const MessageMarkdown$json = {
  '1': 'MessageMarkdown',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
    {'1': 'fallback', '3': 2, '4': 1, '5': 9, '10': 'fallback'},
  ],
};

/// Descriptor for `MessageMarkdown`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageMarkdownDescriptor = $convert.base64Decode(
    'Cg9NZXNzYWdlTWFya2Rvd24SEgoEdGV4dBgBIAEoCVIEdGV4dBIaCghmYWxsYmFjaxgCIAEoCV'
    'IIZmFsbGJhY2s=');

@$core.Deprecated('Use messageForwardDescriptor instead')
const MessageForward$json = {
  '1': 'MessageForward',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
    {'1': 'chat_id', '3': 2, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'chat_name', '3': 3, '4': 1, '5': 9, '10': 'chatName'},
    {'1': 'message_count', '3': 4, '4': 1, '5': 5, '10': 'messageCount'},
    {'1': 'title', '3': 5, '4': 1, '5': 9, '10': 'title'},
    {
      '1': 'items',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.entity.ForwardItem',
      '10': 'items'
    },
  ],
};

/// Descriptor for `MessageForward`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageForwardDescriptor = $convert.base64Decode(
    'Cg5NZXNzYWdlRm9yd2FyZBISCgR0eXBlGAEgASgFUgR0eXBlEhcKB2NoYXRfaWQYAiABKANSBm'
    'NoYXRJZBIbCgljaGF0X25hbWUYAyABKAlSCGNoYXROYW1lEiMKDW1lc3NhZ2VfY291bnQYBCAB'
    'KAVSDG1lc3NhZ2VDb3VudBIUCgV0aXRsZRgFIAEoCVIFdGl0bGUSKQoFaXRlbXMYBiADKAsyEy'
    '5lbnRpdHkuRm9yd2FyZEl0ZW1SBWl0ZW1z');

@$core.Deprecated('Use forwardItemDescriptor instead')
const ForwardItem$json = {
  '1': 'ForwardItem',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'user_name', '3': 2, '4': 1, '5': 9, '10': 'userName'},
    {'1': 'tpy', '3': 3, '4': 1, '5': 5, '10': 'tpy'},
    {'1': 'summary', '3': 4, '4': 1, '5': 9, '10': 'summary'},
    {'1': 'message_id', '3': 5, '4': 1, '5': 3, '10': 'messageId'},
  ],
};

/// Descriptor for `ForwardItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List forwardItemDescriptor = $convert.base64Decode(
    'CgtGb3J3YXJkSXRlbRIXCgd1c2VyX2lkGAEgASgDUgZ1c2VySWQSGwoJdXNlcl9uYW1lGAIgAS'
    'gJUgh1c2VyTmFtZRIQCgN0cHkYAyABKAVSA3RweRIYCgdzdW1tYXJ5GAQgASgJUgdzdW1tYXJ5'
    'Eh0KCm1lc3NhZ2VfaWQYBSABKANSCW1lc3NhZ2VJZA==');

@$core.Deprecated('Use messageSystemDescriptor instead')
const MessageSystem$json = {
  '1': 'MessageSystem',
  '2': [
    {'1': 'action', '3': 1, '4': 1, '5': 5, '10': 'action'},
    {'1': 'text', '3': 2, '4': 1, '5': 9, '10': 'text'},
    {'1': 'operator_id', '3': 3, '4': 1, '5': 3, '10': 'operatorId'},
    {'1': 'target_ids', '3': 4, '4': 3, '5': 3, '10': 'targetIds'},
  ],
};

/// Descriptor for `MessageSystem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageSystemDescriptor = $convert.base64Decode(
    'Cg1NZXNzYWdlU3lzdGVtEhYKBmFjdGlvbhgBIAEoBVIGYWN0aW9uEhIKBHRleHQYAiABKAlSBH'
    'RleHQSHwoLb3BlcmF0b3JfaWQYAyABKANSCm9wZXJhdG9ySWQSHQoKdGFyZ2V0X2lkcxgEIAMo'
    'A1IJdGFyZ2V0SWRz');

@$core.Deprecated('Use fileInfoDescriptor instead')
const FileInfo$json = {
  '1': 'FileInfo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'size', '3': 3, '4': 1, '5': 3, '10': 'size'},
    {'1': 'mime_type', '3': 4, '4': 1, '5': 9, '10': 'mimeType'},
    {'1': 'url', '3': 5, '4': 1, '5': 9, '10': 'url'},
    {'1': 'uploader_id', '3': 6, '4': 1, '5': 3, '10': 'uploaderId'},
    {'1': 'created_at_ms', '3': 7, '4': 1, '5': 3, '10': 'createdAtMs'},
    {'1': 'thumbnail_url', '3': 8, '4': 1, '5': 9, '10': 'thumbnailUrl'},
    {'1': 'width', '3': 9, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 10, '4': 1, '5': 5, '10': 'height'},
    {'1': 'md5', '3': 11, '4': 1, '5': 9, '10': 'md5'},
  ],
};

/// Descriptor for `FileInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileInfoDescriptor = $convert.base64Decode(
    'CghGaWxlSW5mbxIOCgJpZBgBIAEoCVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRISCgRzaXplGA'
    'MgASgDUgRzaXplEhsKCW1pbWVfdHlwZRgEIAEoCVIIbWltZVR5cGUSEAoDdXJsGAUgASgJUgN1'
    'cmwSHwoLdXBsb2FkZXJfaWQYBiABKANSCnVwbG9hZGVySWQSIgoNY3JlYXRlZF9hdF9tcxgHIA'
    'EoA1ILY3JlYXRlZEF0TXMSIwoNdGh1bWJuYWlsX3VybBgIIAEoCVIMdGh1bWJuYWlsVXJsEhQK'
    'BXdpZHRoGAkgASgFUgV3aWR0aBIWCgZoZWlnaHQYCiABKAVSBmhlaWdodBIQCgNtZDUYCyABKA'
    'lSA21kNQ==');

@$core.Deprecated('Use userConfigDescriptor instead')
const UserConfig$json = {
  '1': 'UserConfig',
};

/// Descriptor for `UserConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userConfigDescriptor =
    $convert.base64Decode('CgpVc2VyQ29uZmln');

@$core.Deprecated('Use loginUserDescriptor instead')
const LoginUser$json = {
  '1': 'LoginUser',
  '2': [
    {'1': 'user', '3': 1, '4': 1, '5': 11, '6': '.entity.User', '10': 'user'},
    {'1': 'token', '3': 2, '4': 1, '5': 9, '10': 'token'},
    {
      '1': 'tenant',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.entity.Tenant',
      '10': 'tenant'
    },
    {'1': 'token_expire', '3': 4, '4': 1, '5': 3, '10': 'tokenExpire'},
  ],
};

/// Descriptor for `LoginUser`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginUserDescriptor = $convert.base64Decode(
    'CglMb2dpblVzZXISIAoEdXNlchgBIAEoCzIMLmVudGl0eS5Vc2VyUgR1c2VyEhQKBXRva2VuGA'
    'IgASgJUgV0b2tlbhImCgZ0ZW5hbnQYAyABKAsyDi5lbnRpdHkuVGVuYW50UgZ0ZW5hbnQSIQoM'
    'dG9rZW5fZXhwaXJlGAQgASgDUgt0b2tlbkV4cGlyZQ==');

@$core.Deprecated('Use accountDescriptor instead')
const Account$json = {
  '1': 'Account',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'users',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.entity.LoginUser',
      '10': 'users'
    },
    {'1': 'version', '3': 4, '4': 1, '5': 3, '10': 'version'},
  ],
};

/// Descriptor for `Account`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accountDescriptor = $convert.base64Decode(
    'CgdBY2NvdW50Eg4KAmlkGAEgASgDUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEicKBXVzZXJzGA'
    'MgAygLMhEuZW50aXR5LkxvZ2luVXNlclIFdXNlcnMSGAoHdmVyc2lvbhgEIAEoA1IHdmVyc2lv'
    'bg==');

@$core.Deprecated('Use tenantDescriptor instead')
const Tenant$json = {
  '1': 'Tenant',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'root_department_id',
      '3': 3,
      '4': 1,
      '5': 3,
      '10': 'rootDepartmentId'
    },
    {'1': 'owner_id', '3': 4, '4': 1, '5': 3, '10': 'ownerId'},
    {'1': 'version', '3': 5, '4': 1, '5': 3, '10': 'version'},
    {'1': 'avatar', '3': 6, '4': 1, '5': 9, '10': 'avatar'},
  ],
};

/// Descriptor for `Tenant`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tenantDescriptor = $convert.base64Decode(
    'CgZUZW5hbnQSDgoCaWQYASABKANSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWUSLAoScm9vdF9kZX'
    'BhcnRtZW50X2lkGAMgASgDUhByb290RGVwYXJ0bWVudElkEhkKCG93bmVyX2lkGAQgASgDUgdv'
    'd25lcklkEhgKB3ZlcnNpb24YBSABKANSB3ZlcnNpb24SFgoGYXZhdGFyGAYgASgJUgZhdmF0YX'
    'I=');

@$core.Deprecated('Use departmentDescriptor instead')
const Department$json = {
  '1': 'Department',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'parent_id', '3': 2, '4': 1, '5': 3, '10': 'parentId'},
    {'1': 'tenant_id', '3': 3, '4': 1, '5': 3, '10': 'tenantId'},
    {'1': 'member_ids', '3': 4, '4': 3, '5': 3, '10': 'memberIds'},
    {
      '1': 'sub_department_ids',
      '3': 5,
      '4': 3,
      '5': 3,
      '10': 'subDepartmentIds'
    },
    {'1': 'name', '3': 6, '4': 1, '5': 9, '10': 'name'},
    {'1': 'version', '3': 7, '4': 1, '5': 3, '10': 'version'},
  ],
};

/// Descriptor for `Department`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List departmentDescriptor = $convert.base64Decode(
    'CgpEZXBhcnRtZW50Eg4KAmlkGAEgASgDUgJpZBIbCglwYXJlbnRfaWQYAiABKANSCHBhcmVudE'
    'lkEhsKCXRlbmFudF9pZBgDIAEoA1IIdGVuYW50SWQSHQoKbWVtYmVyX2lkcxgEIAMoA1IJbWVt'
    'YmVySWRzEiwKEnN1Yl9kZXBhcnRtZW50X2lkcxgFIAMoA1IQc3ViRGVwYXJ0bWVudElkcxISCg'
    'RuYW1lGAYgASgJUgRuYW1lEhgKB3ZlcnNpb24YByABKANSB3ZlcnNpb24=');

@$core.Deprecated('Use packetDescriptor instead')
const Packet$json = {
  '1': 'Packet',
  '2': [
    {'1': 'rid', '3': 1, '4': 1, '5': 3, '10': 'rid'},
    {'1': 'cmd', '3': 2, '4': 1, '5': 5, '10': 'cmd'},
    {'1': 'code', '3': 3, '4': 1, '5': 5, '10': 'code'},
    {'1': 'http', '3': 4, '4': 1, '5': 8, '10': 'http'},
    {'1': 'payload', '3': 5, '4': 1, '5': 12, '10': 'payload'},
  ],
};

/// Descriptor for `Packet`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List packetDescriptor = $convert.base64Decode(
    'CgZQYWNrZXQSEAoDcmlkGAEgASgDUgNyaWQSEAoDY21kGAIgASgFUgNjbWQSEgoEY29kZRgDIA'
    'EoBVIEY29kZRISCgRodHRwGAQgASgIUgRodHRwEhgKB3BheWxvYWQYBSABKAxSB3BheWxvYWQ=');

@$core.Deprecated('Use entityDescriptor instead')
const Entity$json = {
  '1': 'Entity',
  '2': [
    {
      '1': 'entity_ids',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.entity.Entity.EntityIdsEntry',
      '10': 'entityIds'
    },
    {
      '1': 'users',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.entity.Entity.UsersEntry',
      '10': 'users'
    },
    {
      '1': 'chats',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.entity.Entity.ChatsEntry',
      '10': 'chats'
    },
    {
      '1': 'messages',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.entity.Entity.MessagesEntry',
      '10': 'messages'
    },
    {
      '1': 'feeds',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.entity.Entity.FeedsEntry',
      '10': 'feeds'
    },
    {
      '1': 'files',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.entity.Entity.FilesEntry',
      '10': 'files'
    },
  ],
  '3': [
    Entity_EntityIdsEntry$json,
    Entity_UsersEntry$json,
    Entity_ChatsEntry$json,
    Entity_MessagesEntry$json,
    Entity_FeedsEntry$json,
    Entity_FilesEntry$json
  ],
};

@$core.Deprecated('Use entityDescriptor instead')
const Entity_EntityIdsEntry$json = {
  '1': 'EntityIdsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 3, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 3, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use entityDescriptor instead')
const Entity_UsersEntry$json = {
  '1': 'UsersEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 3, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.entity.User', '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use entityDescriptor instead')
const Entity_ChatsEntry$json = {
  '1': 'ChatsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 3, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.entity.Chat', '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use entityDescriptor instead')
const Entity_MessagesEntry$json = {
  '1': 'MessagesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 3, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.entity.Message',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use entityDescriptor instead')
const Entity_FeedsEntry$json = {
  '1': 'FeedsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 3, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.entity.Feed', '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use entityDescriptor instead')
const Entity_FilesEntry$json = {
  '1': 'FilesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.entity.FileInfo',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `Entity`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List entityDescriptor = $convert.base64Decode(
    'CgZFbnRpdHkSPAoKZW50aXR5X2lkcxgBIAMoCzIdLmVudGl0eS5FbnRpdHkuRW50aXR5SWRzRW'
    '50cnlSCWVudGl0eUlkcxIvCgV1c2VycxgCIAMoCzIZLmVudGl0eS5FbnRpdHkuVXNlcnNFbnRy'
    'eVIFdXNlcnMSLwoFY2hhdHMYAyADKAsyGS5lbnRpdHkuRW50aXR5LkNoYXRzRW50cnlSBWNoYX'
    'RzEjgKCG1lc3NhZ2VzGAQgAygLMhwuZW50aXR5LkVudGl0eS5NZXNzYWdlc0VudHJ5UghtZXNz'
    'YWdlcxIvCgVmZWVkcxgFIAMoCzIZLmVudGl0eS5FbnRpdHkuRmVlZHNFbnRyeVIFZmVlZHMSLw'
    'oFZmlsZXMYBiADKAsyGS5lbnRpdHkuRW50aXR5LkZpbGVzRW50cnlSBWZpbGVzGjwKDkVudGl0'
    'eUlkc0VudHJ5EhAKA2tleRgBIAEoA1IDa2V5EhQKBXZhbHVlGAIgASgDUgV2YWx1ZToCOAEaRg'
    'oKVXNlcnNFbnRyeRIQCgNrZXkYASABKANSA2tleRIiCgV2YWx1ZRgCIAEoCzIMLmVudGl0eS5V'
    'c2VyUgV2YWx1ZToCOAEaRgoKQ2hhdHNFbnRyeRIQCgNrZXkYASABKANSA2tleRIiCgV2YWx1ZR'
    'gCIAEoCzIMLmVudGl0eS5DaGF0UgV2YWx1ZToCOAEaTAoNTWVzc2FnZXNFbnRyeRIQCgNrZXkY'
    'ASABKANSA2tleRIlCgV2YWx1ZRgCIAEoCzIPLmVudGl0eS5NZXNzYWdlUgV2YWx1ZToCOAEaRg'
    'oKRmVlZHNFbnRyeRIQCgNrZXkYASABKANSA2tleRIiCgV2YWx1ZRgCIAEoCzIMLmVudGl0eS5G'
    'ZWVkUgV2YWx1ZToCOAEaSgoKRmlsZXNFbnRyeRIQCgNrZXkYASABKAlSA2tleRImCgV2YWx1ZR'
    'gCIAEoCzIQLmVudGl0eS5GaWxlSW5mb1IFdmFsdWU6AjgB');

@$core.Deprecated('Use entityImageDescriptor instead')
const EntityImage$json = {
  '1': 'EntityImage',
  '2': [
    {'1': 'url', '3': 1, '4': 1, '5': 9, '10': 'url'},
    {'1': 'width', '3': 3, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 4, '4': 1, '5': 5, '10': 'height'},
    {'1': 'size', '3': 5, '4': 1, '5': 5, '10': 'size'},
  ],
};

/// Descriptor for `EntityImage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List entityImageDescriptor = $convert.base64Decode(
    'CgtFbnRpdHlJbWFnZRIQCgN1cmwYASABKAlSA3VybBIUCgV3aWR0aBgDIAEoBVIFd2lkdGgSFg'
    'oGaGVpZ2h0GAQgASgFUgZoZWlnaHQSEgoEc2l6ZRgFIAEoBVIEc2l6ZQ==');

@$core.Deprecated('Use imageIconDescriptor instead')
const ImageIcon$json = {
  '1': 'ImageIcon',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
    {'1': 'Key', '3': 2, '4': 1, '5': 9, '10': 'Key'},
  ],
  '4': [ImageIcon_IconType$json],
};

@$core.Deprecated('Use imageIconDescriptor instead')
const ImageIcon_IconType$json = {
  '1': 'IconType',
  '2': [
    {'1': 'UNKNOWN_ICON_TYPE', '2': 0},
    {'1': 'EMOJI', '2': 1},
    {'1': 'IMAGE', '2': 2},
  ],
};

/// Descriptor for `ImageIcon`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List imageIconDescriptor = $convert.base64Decode(
    'CglJbWFnZUljb24SEgoEdHlwZRgBIAEoBVIEdHlwZRIQCgNLZXkYAiABKAlSA0tleSI3CghJY2'
    '9uVHlwZRIVChFVTktOT1dOX0lDT05fVFlQRRAAEgkKBUVNT0pJEAESCQoFSU1BR0UQAg==');

@$core.Deprecated('Use pipeUpdateItemDescriptor instead')
const PipeUpdateItem$json = {
  '1': 'PipeUpdateItem',
  '2': [
    {'1': 'sid', '3': 1, '4': 1, '5': 3, '10': 'sid'},
    {'1': 'typ', '3': 2, '4': 1, '5': 5, '10': 'typ'},
    {'1': 'id', '3': 3, '4': 1, '5': 3, '10': 'id'},
    {'1': 'version', '3': 4, '4': 1, '5': 3, '10': 'version'},
  ],
};

/// Descriptor for `PipeUpdateItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pipeUpdateItemDescriptor = $convert.base64Decode(
    'Cg5QaXBlVXBkYXRlSXRlbRIQCgNzaWQYASABKANSA3NpZBIQCgN0eXAYAiABKAVSA3R5cBIOCg'
    'JpZBgDIAEoA1ICaWQSGAoHdmVyc2lvbhgEIAEoA1IHdmVyc2lvbg==');

@$core.Deprecated('Use memberStatusDescriptor instead')
const MemberStatus$json = {
  '1': 'MemberStatus',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'finish_time', '3': 2, '4': 1, '5': 3, '10': 'finishTime'},
    {'1': 'status', '3': 3, '4': 1, '5': 5, '10': 'status'},
    {'1': 'subscribe', '3': 4, '4': 1, '5': 8, '10': 'subscribe'},
  ],
};

/// Descriptor for `MemberStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List memberStatusDescriptor = $convert.base64Decode(
    'CgxNZW1iZXJTdGF0dXMSDgoCaWQYASABKANSAmlkEh8KC2ZpbmlzaF90aW1lGAIgASgDUgpmaW'
    '5pc2hUaW1lEhYKBnN0YXR1cxgDIAEoBVIGc3RhdHVzEhwKCXN1YnNjcmliZRgEIAEoCFIJc3Vi'
    'c2NyaWJl');

@$core.Deprecated('Use taskDescriptor instead')
const Task$json = {
  '1': 'Task',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'creator', '3': 2, '4': 1, '5': 3, '10': 'creator'},
    {'1': 'title', '3': 3, '4': 1, '5': 9, '10': 'title'},
    {'1': 'create_time', '3': 4, '4': 1, '5': 3, '10': 'createTime'},
    {'1': 'update_time', '3': 6, '4': 1, '5': 3, '10': 'updateTime'},
    {'1': 'start_time', '3': 7, '4': 1, '5': 3, '10': 'startTime'},
    {'1': 'deadline', '3': 8, '4': 1, '5': 3, '10': 'deadline'},
    {
      '1': 'status',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.entity.MemberStatus',
      '10': 'status'
    },
  ],
};

/// Descriptor for `Task`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskDescriptor = $convert.base64Decode(
    'CgRUYXNrEg4KAmlkGAEgASgDUgJpZBIYCgdjcmVhdG9yGAIgASgDUgdjcmVhdG9yEhQKBXRpdG'
    'xlGAMgASgJUgV0aXRsZRIfCgtjcmVhdGVfdGltZRgEIAEoA1IKY3JlYXRlVGltZRIfCgt1cGRh'
    'dGVfdGltZRgGIAEoA1IKdXBkYXRlVGltZRIdCgpzdGFydF90aW1lGAcgASgDUglzdGFydFRpbW'
    'USGgoIZGVhZGxpbmUYCCABKANSCGRlYWRsaW5lEiwKBnN0YXR1cxgJIAMoCzIULmVudGl0eS5N'
    'ZW1iZXJTdGF0dXNSBnN0YXR1cw==');

@$core.Deprecated('Use todoDescriptor instead')
const Todo$json = {
  '1': 'Todo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'main', '3': 2, '4': 1, '5': 11, '6': '.entity.Task', '10': 'main'},
    {'1': 'message_count', '3': 3, '4': 1, '5': 5, '10': 'messageCount'},
    {
      '1': 'sub_task',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.entity.Task',
      '10': 'subTask'
    },
  ],
};

/// Descriptor for `Todo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List todoDescriptor = $convert.base64Decode(
    'CgRUb2RvEg4KAmlkGAEgASgDUgJpZBIgCgRtYWluGAIgASgLMgwuZW50aXR5LlRhc2tSBG1haW'
    '4SIwoNbWVzc2FnZV9jb3VudBgDIAEoBVIMbWVzc2FnZUNvdW50EicKCHN1Yl90YXNrGAQgAygL'
    'MgwuZW50aXR5LlRhc2tSB3N1YlRhc2s=');

@$core.Deprecated('Use calendarSubscribersDescriptor instead')
const CalendarSubscribers$json = {
  '1': 'CalendarSubscribers',
  '2': [
    {
      '1': 'subscribers',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.entity.CalendarSubscribers.SubscribersEntry',
      '10': 'subscribers'
    },
  ],
  '3': [CalendarSubscribers_SubscribersEntry$json],
};

@$core.Deprecated('Use calendarSubscribersDescriptor instead')
const CalendarSubscribers_SubscribersEntry$json = {
  '1': 'SubscribersEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 3, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.entity.Calendar.Subscriber',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `CalendarSubscribers`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarSubscribersDescriptor = $convert.base64Decode(
    'ChNDYWxlbmRhclN1YnNjcmliZXJzEk4KC3N1YnNjcmliZXJzGAEgAygLMiwuZW50aXR5LkNhbG'
    'VuZGFyU3Vic2NyaWJlcnMuU3Vic2NyaWJlcnNFbnRyeVILc3Vic2NyaWJlcnMaWwoQU3Vic2Ny'
    'aWJlcnNFbnRyeRIQCgNrZXkYASABKANSA2tleRIxCgV2YWx1ZRgCIAEoCzIbLmVudGl0eS5DYW'
    'xlbmRhci5TdWJzY3JpYmVyUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use calendarDescriptor instead')
const Calendar$json = {
  '1': 'Calendar',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'creater', '3': 3, '4': 1, '5': 3, '10': 'creater'},
    {'1': 'tenant_id', '3': 5, '4': 1, '5': 3, '10': 'tenantId'},
    {'1': 'version', '3': 6, '4': 1, '5': 3, '10': 'version'},
    {'1': 'color', '3': 7, '4': 1, '5': 5, '10': 'color'},
    {'1': 'name', '3': 8, '4': 1, '5': 9, '10': 'name'},
    {'1': 'desc', '3': 9, '4': 1, '5': 9, '10': 'desc'},
    {'1': 'is_default', '3': 10, '4': 1, '5': 8, '10': 'isDefault'},
    {'1': 'public', '3': 11, '4': 1, '5': 8, '10': 'public'},
    {'1': 'enable', '3': 12, '4': 1, '5': 8, '10': 'enable'},
    {
      '1': 'subscribers',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.entity.CalendarSubscribers',
      '10': 'subscribers'
    },
  ],
  '3': [Calendar_Subscriber$json],
};

@$core.Deprecated('Use calendarDescriptor instead')
const Calendar_Subscriber$json = {
  '1': 'Subscriber',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'subscribe_time', '3': 2, '4': 1, '5': 3, '10': 'subscribeTime'},
    {'1': 'role', '3': 3, '4': 1, '5': 5, '10': 'role'},
    {'1': 'color', '3': 4, '4': 1, '5': 5, '10': 'color'},
  ],
};

/// Descriptor for `Calendar`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarDescriptor = $convert.base64Decode(
    'CghDYWxlbmRhchIOCgJpZBgBIAEoA1ICaWQSGAoHY3JlYXRlchgDIAEoA1IHY3JlYXRlchIbCg'
    'l0ZW5hbnRfaWQYBSABKANSCHRlbmFudElkEhgKB3ZlcnNpb24YBiABKANSB3ZlcnNpb24SFAoF'
    'Y29sb3IYByABKAVSBWNvbG9yEhIKBG5hbWUYCCABKAlSBG5hbWUSEgoEZGVzYxgJIAEoCVIEZG'
    'VzYxIdCgppc19kZWZhdWx0GAogASgIUglpc0RlZmF1bHQSFgoGcHVibGljGAsgASgIUgZwdWJs'
    'aWMSFgoGZW5hYmxlGAwgASgIUgZlbmFibGUSPQoLc3Vic2NyaWJlcnMYFCABKAsyGy5lbnRpdH'
    'kuQ2FsZW5kYXJTdWJzY3JpYmVyc1ILc3Vic2NyaWJlcnMabQoKU3Vic2NyaWJlchIOCgJpZBgB'
    'IAEoA1ICaWQSJQoOc3Vic2NyaWJlX3RpbWUYAiABKANSDXN1YnNjcmliZVRpbWUSEgoEcm9sZR'
    'gDIAEoBVIEcm9sZRIUCgVjb2xvchgEIAEoBVIFY29sb3I=');

@$core.Deprecated('Use subscribeCalendarListDescriptor instead')
const SubscribeCalendarList$json = {
  '1': 'SubscribeCalendarList',
  '2': [
    {
      '1': 'calendars',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.entity.Calendar',
      '10': 'calendars'
    },
  ],
};

/// Descriptor for `SubscribeCalendarList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeCalendarListDescriptor = $convert.base64Decode(
    'ChVTdWJzY3JpYmVDYWxlbmRhckxpc3QSLgoJY2FsZW5kYXJzGAEgAygLMhAuZW50aXR5LkNhbG'
    'VuZGFyUgljYWxlbmRhcnM=');

@$core.Deprecated('Use userScheduleBriefDescriptor instead')
const UserScheduleBrief$json = {
  '1': 'UserScheduleBrief',
  '2': [
    {
      '1': 'briefs',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.entity.UserScheduleBrief.Brief',
      '10': 'briefs'
    },
  ],
  '3': [UserScheduleBrief_Brief$json],
};

@$core.Deprecated('Use userScheduleBriefDescriptor instead')
const UserScheduleBrief_Brief$json = {
  '1': 'Brief',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'calendar_id', '3': 2, '4': 1, '5': 3, '10': 'calendarId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'start_time', '3': 4, '4': 1, '5': 3, '10': 'startTime'},
    {'1': 'end_time', '3': 5, '4': 1, '5': 3, '10': 'endTime'},
  ],
};

/// Descriptor for `UserScheduleBrief`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userScheduleBriefDescriptor = $convert.base64Decode(
    'ChFVc2VyU2NoZWR1bGVCcmllZhI3CgZicmllZnMYASADKAsyHy5lbnRpdHkuVXNlclNjaGVkdW'
    'xlQnJpZWYuQnJpZWZSBmJyaWVmcxqGAQoFQnJpZWYSDgoCaWQYASABKANSAmlkEh8KC2NhbGVu'
    'ZGFyX2lkGAIgASgDUgpjYWxlbmRhcklkEhIKBG5hbWUYAyABKAlSBG5hbWUSHQoKc3RhcnRfdG'
    'ltZRgEIAEoA1IJc3RhcnRUaW1lEhkKCGVuZF90aW1lGAUgASgDUgdlbmRUaW1l');

@$core.Deprecated('Use scheduleDescriptor instead')
const Schedule$json = {
  '1': 'Schedule',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'calendar_id', '3': 2, '4': 1, '5': 3, '10': 'calendarId'},
    {'1': 'type', '3': 3, '4': 1, '5': 5, '10': 'type'},
    {'1': 'tenant_id', '3': 4, '4': 1, '5': 3, '10': 'tenantId'},
    {'1': 'owner', '3': 5, '4': 1, '5': 3, '10': 'owner'},
    {'1': 'version', '3': 6, '4': 1, '5': 3, '10': 'version'},
    {'1': 'summary_doc_id', '3': 7, '4': 1, '5': 3, '10': 'summaryDocId'},
    {'1': 'room_id', '3': 8, '4': 1, '5': 3, '10': 'roomId'},
    {'1': 'chat_id', '3': 9, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'cycle_rule_id', '3': 10, '4': 1, '5': 3, '10': 'cycleRuleId'},
    {'1': 'start_time', '3': 11, '4': 1, '5': 3, '10': 'startTime'},
    {'1': 'end_time', '3': 12, '4': 1, '5': 3, '10': 'endTime'},
    {'1': 'color', '3': 13, '4': 1, '5': 5, '10': 'color'},
    {'1': 'public_permision', '3': 14, '4': 1, '5': 5, '10': 'publicPermision'},
    {'1': 'member_count', '3': 15, '4': 1, '5': 5, '10': 'memberCount'},
    {'1': 'member_view_list', '3': 16, '4': 1, '5': 8, '10': 'memberViewList'},
    {
      '1': 'member_invite_other',
      '3': 17,
      '4': 1,
      '5': 8,
      '10': 'memberInviteOther'
    },
    {
      '1': 'member_alter_schedule',
      '3': 18,
      '4': 1,
      '5': 8,
      '10': 'memberAlterSchedule'
    },
    {
      '1': 'member_create_summary',
      '3': 19,
      '4': 1,
      '5': 8,
      '10': 'memberCreateSummary'
    },
    {
      '1': 'member_create_meeting',
      '3': 20,
      '4': 1,
      '5': 8,
      '10': 'memberCreateMeeting'
    },
    {'1': 'need_checkin', '3': 21, '4': 1, '5': 8, '10': 'needCheckin'},
    {'1': 'show_as_idle', '3': 22, '4': 1, '5': 8, '10': 'showAsIdle'},
    {'1': 'exception', '3': 23, '4': 1, '5': 8, '10': 'exception'},
    {'1': 'full_day', '3': 24, '4': 1, '5': 8, '10': 'fullDay'},
    {'1': 'location', '3': 25, '4': 1, '5': 9, '10': 'location'},
    {'1': 'archive', '3': 26, '4': 1, '5': 9, '10': 'archive'},
    {'1': 'desc', '3': 27, '4': 1, '5': 9, '10': 'desc'},
    {'1': 'title', '3': 28, '4': 1, '5': 9, '10': 'title'},
    {'1': 'member_ids', '3': 29, '4': 3, '5': 3, '10': 'memberIds'},
    {'1': 'notify_time', '3': 30, '4': 3, '5': 5, '10': 'notifyTime'},
    {
      '1': 'cycle',
      '3': 31,
      '4': 1,
      '5': 11,
      '6': '.entity.ScheduleCycleRule',
      '10': 'cycle'
    },
    {'1': 'modify_scope', '3': 32, '4': 1, '5': 5, '10': 'modifyScope'},
  ],
};

/// Descriptor for `Schedule`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scheduleDescriptor = $convert.base64Decode(
    'CghTY2hlZHVsZRIOCgJpZBgBIAEoA1ICaWQSHwoLY2FsZW5kYXJfaWQYAiABKANSCmNhbGVuZG'
    'FySWQSEgoEdHlwZRgDIAEoBVIEdHlwZRIbCgl0ZW5hbnRfaWQYBCABKANSCHRlbmFudElkEhQK'
    'BW93bmVyGAUgASgDUgVvd25lchIYCgd2ZXJzaW9uGAYgASgDUgd2ZXJzaW9uEiQKDnN1bW1hcn'
    'lfZG9jX2lkGAcgASgDUgxzdW1tYXJ5RG9jSWQSFwoHcm9vbV9pZBgIIAEoA1IGcm9vbUlkEhcK'
    'B2NoYXRfaWQYCSABKANSBmNoYXRJZBIiCg1jeWNsZV9ydWxlX2lkGAogASgDUgtjeWNsZVJ1bG'
    'VJZBIdCgpzdGFydF90aW1lGAsgASgDUglzdGFydFRpbWUSGQoIZW5kX3RpbWUYDCABKANSB2Vu'
    'ZFRpbWUSFAoFY29sb3IYDSABKAVSBWNvbG9yEikKEHB1YmxpY19wZXJtaXNpb24YDiABKAVSD3'
    'B1YmxpY1Blcm1pc2lvbhIhCgxtZW1iZXJfY291bnQYDyABKAVSC21lbWJlckNvdW50EigKEG1l'
    'bWJlcl92aWV3X2xpc3QYECABKAhSDm1lbWJlclZpZXdMaXN0Ei4KE21lbWJlcl9pbnZpdGVfb3'
    'RoZXIYESABKAhSEW1lbWJlckludml0ZU90aGVyEjIKFW1lbWJlcl9hbHRlcl9zY2hlZHVsZRgS'
    'IAEoCFITbWVtYmVyQWx0ZXJTY2hlZHVsZRIyChVtZW1iZXJfY3JlYXRlX3N1bW1hcnkYEyABKA'
    'hSE21lbWJlckNyZWF0ZVN1bW1hcnkSMgoVbWVtYmVyX2NyZWF0ZV9tZWV0aW5nGBQgASgIUhNt'
    'ZW1iZXJDcmVhdGVNZWV0aW5nEiEKDG5lZWRfY2hlY2tpbhgVIAEoCFILbmVlZENoZWNraW4SIA'
    'oMc2hvd19hc19pZGxlGBYgASgIUgpzaG93QXNJZGxlEhwKCWV4Y2VwdGlvbhgXIAEoCFIJZXhj'
    'ZXB0aW9uEhkKCGZ1bGxfZGF5GBggASgIUgdmdWxsRGF5EhoKCGxvY2F0aW9uGBkgASgJUghsb2'
    'NhdGlvbhIYCgdhcmNoaXZlGBogASgJUgdhcmNoaXZlEhIKBGRlc2MYGyABKAlSBGRlc2MSFAoF'
    'dGl0bGUYHCABKAlSBXRpdGxlEh0KCm1lbWJlcl9pZHMYHSADKANSCW1lbWJlcklkcxIfCgtub3'
    'RpZnlfdGltZRgeIAMoBVIKbm90aWZ5VGltZRIvCgVjeWNsZRgfIAEoCzIZLmVudGl0eS5TY2hl'
    'ZHVsZUN5Y2xlUnVsZVIFY3ljbGUSIQoMbW9kaWZ5X3Njb3BlGCAgASgFUgttb2RpZnlTY29wZQ'
    '==');

@$core.Deprecated('Use cycleRuleDescriptor instead')
const CycleRule$json = {
  '1': 'CycleRule',
  '2': [
    {'1': 'cycle_type', '3': 1, '4': 1, '5': 5, '10': 'cycleType'},
    {'1': 'seq', '3': 2, '4': 1, '5': 5, '10': 'seq'},
    {'1': 'week_seqs', '3': 3, '4': 3, '5': 5, '10': 'weekSeqs'},
  ],
  '4': [CycleRule_CycleType$json],
};

@$core.Deprecated('Use cycleRuleDescriptor instead')
const CycleRule_CycleType$json = {
  '1': 'CycleType',
  '2': [
    {'1': 'CycleNone', '2': 0},
    {'1': 'CycleByDay', '2': 1},
    {'1': 'CycleByWeek', '2': 2},
    {'1': 'CycleByMonth', '2': 3},
    {'1': 'CycleByMonthWeek', '2': 4},
    {'1': 'CycleByYear', '2': 5},
  ],
};

/// Descriptor for `CycleRule`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cycleRuleDescriptor = $convert.base64Decode(
    'CglDeWNsZVJ1bGUSHQoKY3ljbGVfdHlwZRgBIAEoBVIJY3ljbGVUeXBlEhAKA3NlcRgCIAEoBV'
    'IDc2VxEhsKCXdlZWtfc2VxcxgDIAMoBVIId2Vla1NlcXMidAoJQ3ljbGVUeXBlEg0KCUN5Y2xl'
    'Tm9uZRAAEg4KCkN5Y2xlQnlEYXkQARIPCgtDeWNsZUJ5V2VlaxACEhAKDEN5Y2xlQnlNb250aB'
    'ADEhQKEEN5Y2xlQnlNb250aFdlZWsQBBIPCgtDeWNsZUJ5WWVhchAF');

@$core.Deprecated('Use scheduleCycleRuleDescriptor instead')
const ScheduleCycleRule$json = {
  '1': 'ScheduleCycleRule',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'calendar_id', '3': 2, '4': 1, '5': 3, '10': 'calendarId'},
    {'1': 'start_at', '3': 3, '4': 1, '5': 3, '10': 'startAt'},
    {'1': 'stop_at', '3': 4, '4': 1, '5': 3, '10': 'stopAt'},
    {
      '1': 'rule',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.entity.CycleRule',
      '10': 'rule'
    },
    {'1': 'exception_times', '3': 6, '4': 3, '5': 3, '10': 'exceptionTimes'},
    {'1': 'version', '3': 7, '4': 1, '5': 3, '10': 'version'},
  ],
};

/// Descriptor for `ScheduleCycleRule`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scheduleCycleRuleDescriptor = $convert.base64Decode(
    'ChFTY2hlZHVsZUN5Y2xlUnVsZRIOCgJpZBgBIAEoA1ICaWQSHwoLY2FsZW5kYXJfaWQYAiABKA'
    'NSCmNhbGVuZGFySWQSGQoIc3RhcnRfYXQYAyABKANSB3N0YXJ0QXQSFwoHc3RvcF9hdBgEIAEo'
    'A1IGc3RvcEF0EiUKBHJ1bGUYBSABKAsyES5lbnRpdHkuQ3ljbGVSdWxlUgRydWxlEicKD2V4Y2'
    'VwdGlvbl90aW1lcxgGIAMoA1IOZXhjZXB0aW9uVGltZXMSGAoHdmVyc2lvbhgHIAEoA1IHdmVy'
    'c2lvbg==');
