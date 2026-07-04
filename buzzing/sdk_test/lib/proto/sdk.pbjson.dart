// This is a generated file - do not edit.
//
// Generated from sdk.proto.

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

@$core.Deprecated('Use initRequestDescriptor instead')
const InitRequest$json = {
  '1': 'InitRequest',
  '2': [
    {'1': 'device_type', '3': 1, '4': 1, '5': 5, '10': 'deviceType'},
    {'1': 'app_id', '3': 2, '4': 1, '5': 9, '10': 'appId'},
    {'1': 'app_version', '3': 3, '4': 1, '5': 9, '10': 'appVersion'},
    {'1': 'device_id', '3': 4, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'log_path', '3': 5, '4': 1, '5': 9, '10': 'logPath'},
    {'1': 'storage_path', '3': 6, '4': 1, '5': 9, '10': 'storagePath'},
    {'1': 'locale', '3': 8, '4': 1, '5': 9, '10': 'locale'},
    {'1': 'common_data_path', '3': 9, '4': 1, '5': 9, '10': 'commonDataPath'},
    {'1': 'os_version', '3': 10, '4': 1, '5': 9, '10': 'osVersion'},
    {
      '1': 'env',
      '3': 11,
      '4': 1,
      '5': 14,
      '6': '.entity.EnvChannel',
      '10': 'env'
    },
    {'1': 'path_prefix', '3': 12, '4': 1, '5': 9, '10': 'pathPrefix'},
    {'1': 'custom_log_path', '3': 13, '4': 1, '5': 9, '10': 'customLogPath'},
    {'1': 'is_release', '3': 14, '4': 1, '5': 8, '10': 'isRelease'},
    {'1': 'device_model', '3': 15, '4': 1, '5': 9, '10': 'deviceModel'},
    {
      '1': 'settings_queries',
      '3': 16,
      '4': 3,
      '5': 11,
      '6': '.sdk.InitRequest.SettingsQueriesEntry',
      '10': 'settingsQueries'
    },
    {'1': 'app_channel', '3': 17, '4': 1, '5': 9, '10': 'appChannel'},
  ],
  '3': [InitRequest_SettingsQueriesEntry$json],
};

@$core.Deprecated('Use initRequestDescriptor instead')
const InitRequest_SettingsQueriesEntry$json = {
  '1': 'SettingsQueriesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `InitRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List initRequestDescriptor = $convert.base64Decode(
    'CgtJbml0UmVxdWVzdBIfCgtkZXZpY2VfdHlwZRgBIAEoBVIKZGV2aWNlVHlwZRIVCgZhcHBfaW'
    'QYAiABKAlSBWFwcElkEh8KC2FwcF92ZXJzaW9uGAMgASgJUgphcHBWZXJzaW9uEhsKCWRldmlj'
    'ZV9pZBgEIAEoCVIIZGV2aWNlSWQSGQoIbG9nX3BhdGgYBSABKAlSB2xvZ1BhdGgSIQoMc3Rvcm'
    'FnZV9wYXRoGAYgASgJUgtzdG9yYWdlUGF0aBIWCgZsb2NhbGUYCCABKAlSBmxvY2FsZRIoChBj'
    'b21tb25fZGF0YV9wYXRoGAkgASgJUg5jb21tb25EYXRhUGF0aBIdCgpvc192ZXJzaW9uGAogAS'
    'gJUglvc1ZlcnNpb24SJAoDZW52GAsgASgOMhIuZW50aXR5LkVudkNoYW5uZWxSA2VudhIfCgtw'
    'YXRoX3ByZWZpeBgMIAEoCVIKcGF0aFByZWZpeBImCg9jdXN0b21fbG9nX3BhdGgYDSABKAlSDW'
    'N1c3RvbUxvZ1BhdGgSHQoKaXNfcmVsZWFzZRgOIAEoCFIJaXNSZWxlYXNlEiEKDGRldmljZV9t'
    'b2RlbBgPIAEoCVILZGV2aWNlTW9kZWwSUAoQc2V0dGluZ3NfcXVlcmllcxgQIAMoCzIlLnNkay'
    '5Jbml0UmVxdWVzdC5TZXR0aW5nc1F1ZXJpZXNFbnRyeVIPc2V0dGluZ3NRdWVyaWVzEh8KC2Fw'
    'cF9jaGFubmVsGBEgASgJUgphcHBDaGFubmVsGkIKFFNldHRpbmdzUXVlcmllc0VudHJ5EhAKA2'
    'tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use invokeRequestDescriptor instead')
const InvokeRequest$json = {
  '1': 'InvokeRequest',
  '2': [
    {'1': 'seq', '3': 1, '4': 1, '5': 5, '10': 'seq'},
    {'1': 'command', '3': 2, '4': 1, '5': 5, '10': 'command'},
    {'1': 'user_id', '3': 4, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'source', '3': 5, '4': 1, '5': 5, '10': 'source'},
    {'1': 'payload', '3': 20, '4': 1, '5': 12, '10': 'payload'},
  ],
};

/// Descriptor for `InvokeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List invokeRequestDescriptor = $convert.base64Decode(
    'Cg1JbnZva2VSZXF1ZXN0EhAKA3NlcRgBIAEoBVIDc2VxEhgKB2NvbW1hbmQYAiABKAVSB2NvbW'
    '1hbmQSFwoHdXNlcl9pZBgEIAEoA1IGdXNlcklkEhYKBnNvdXJjZRgFIAEoBVIGc291cmNlEhgK'
    'B3BheWxvYWQYFCABKAxSB3BheWxvYWQ=');

@$core.Deprecated('Use invokeResponseDescriptor instead')
const InvokeResponse$json = {
  '1': 'InvokeResponse',
  '2': [
    {'1': 'seq', '3': 1, '4': 1, '5': 5, '10': 'seq'},
    {'1': 'status', '3': 2, '4': 1, '5': 5, '10': 'status'},
    {'1': 'user_id', '3': 3, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'payload', '3': 4, '4': 1, '5': 12, '10': 'payload'},
  ],
};

/// Descriptor for `InvokeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List invokeResponseDescriptor = $convert.base64Decode(
    'Cg5JbnZva2VSZXNwb25zZRIQCgNzZXEYASABKAVSA3NlcRIWCgZzdGF0dXMYAiABKAVSBnN0YX'
    'R1cxIXCgd1c2VyX2lkGAMgASgDUgZ1c2VySWQSGAoHcGF5bG9hZBgEIAEoDFIHcGF5bG9hZA==');

@$core.Deprecated('Use sdkPushPacketDescriptor instead')
const SdkPushPacket$json = {
  '1': 'SdkPushPacket',
  '2': [
    {'1': 'command', '3': 1, '4': 1, '5': 5, '10': 'command'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'seq', '3': 3, '4': 1, '5': 5, '10': 'seq'},
    {'1': 'payload', '3': 4, '4': 1, '5': 12, '10': 'payload'},
  ],
};

/// Descriptor for `SdkPushPacket`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sdkPushPacketDescriptor = $convert.base64Decode(
    'Cg1TZGtQdXNoUGFja2V0EhgKB2NvbW1hbmQYASABKAVSB2NvbW1hbmQSFwoHdXNlcl9pZBgCIA'
    'EoA1IGdXNlcklkEhAKA3NlcRgDIAEoBVIDc2VxEhgKB3BheWxvYWQYBCABKAxSB3BheWxvYWQ=');

@$core.Deprecated('Use sdkLoginUserRequestDescriptor instead')
const SdkLoginUserRequest$json = {
  '1': 'SdkLoginUserRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 3, '10': 'tenantId'},
    {'1': 'access_token', '3': 3, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'union_id', '3': 4, '4': 1, '5': 5, '10': 'unionId'},
    {
      '1': 'union_client_config',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'unionClientConfig'
    },
  ],
};

/// Descriptor for `SdkLoginUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sdkLoginUserRequestDescriptor = $convert.base64Decode(
    'ChNTZGtMb2dpblVzZXJSZXF1ZXN0EhcKB3VzZXJfaWQYASABKANSBnVzZXJJZBIbCgl0ZW5hbn'
    'RfaWQYAiABKANSCHRlbmFudElkEiEKDGFjY2Vzc190b2tlbhgDIAEoCVILYWNjZXNzVG9rZW4S'
    'GQoIdW5pb25faWQYBCABKAVSB3VuaW9uSWQSLgoTdW5pb25fY2xpZW50X2NvbmZpZxgFIAEoCV'
    'IRdW5pb25DbGllbnRDb25maWc=');

@$core.Deprecated('Use sdkLoginUserResponseDescriptor instead')
const SdkLoginUserResponse$json = {
  '1': 'SdkLoginUserResponse',
};

/// Descriptor for `SdkLoginUserResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sdkLoginUserResponseDescriptor =
    $convert.base64Decode('ChRTZGtMb2dpblVzZXJSZXNwb25zZQ==');

@$core.Deprecated('Use sdkLogoutUserRequestDescriptor instead')
const SdkLogoutUserRequest$json = {
  '1': 'SdkLogoutUserRequest',
};

/// Descriptor for `SdkLogoutUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sdkLogoutUserRequestDescriptor =
    $convert.base64Decode('ChRTZGtMb2dvdXRVc2VyUmVxdWVzdA==');

@$core.Deprecated('Use sdkLogoutUserResponseDescriptor instead')
const SdkLogoutUserResponse$json = {
  '1': 'SdkLogoutUserResponse',
};

/// Descriptor for `SdkLogoutUserResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sdkLogoutUserResponseDescriptor =
    $convert.base64Decode('ChVTZGtMb2dvdXRVc2VyUmVzcG9uc2U=');

@$core.Deprecated('Use pushDeviceKickoffResponseDescriptor instead')
const PushDeviceKickoffResponse$json = {
  '1': 'PushDeviceKickoffResponse',
};

/// Descriptor for `PushDeviceKickoffResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushDeviceKickoffResponseDescriptor =
    $convert.base64Decode('ChlQdXNoRGV2aWNlS2lja29mZlJlc3BvbnNl');

@$core.Deprecated('Use pushFeedCardsResponseDescriptor instead')
const PushFeedCardsResponse$json = {
  '1': 'PushFeedCardsResponse',
};

/// Descriptor for `PushFeedCardsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushFeedCardsResponseDescriptor =
    $convert.base64Decode('ChVQdXNoRmVlZENhcmRzUmVzcG9uc2U=');

@$core.Deprecated('Use getSdkVersionRequestDescriptor instead')
const GetSdkVersionRequest$json = {
  '1': 'GetSdkVersionRequest',
};

/// Descriptor for `GetSdkVersionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSdkVersionRequestDescriptor =
    $convert.base64Decode('ChRHZXRTZGtWZXJzaW9uUmVxdWVzdA==');

@$core.Deprecated('Use getSdkVersionResponseDescriptor instead')
const GetSdkVersionResponse$json = {
  '1': 'GetSdkVersionResponse',
  '2': [
    {'1': 'sdk_version', '3': 1, '4': 1, '5': 9, '10': 'sdkVersion'},
  ],
};

/// Descriptor for `GetSdkVersionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSdkVersionResponseDescriptor = $convert.base64Decode(
    'ChVHZXRTZGtWZXJzaW9uUmVzcG9uc2USHwoLc2RrX3ZlcnNpb24YASABKAlSCnNka1ZlcnNpb2'
    '4=');

@$core.Deprecated('Use avatarKeyDescriptor instead')
const AvatarKey$json = {
  '1': 'AvatarKey',
  '2': [
    {'1': 'entity_id', '3': 1, '4': 1, '5': 9, '10': 'entityId'},
    {'1': 'key', '3': 2, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'entity_type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.sdk.AvatarKey.EntityType',
      '10': 'entityType'
    },
  ],
  '4': [AvatarKey_EntityType$json],
};

@$core.Deprecated('Use avatarKeyDescriptor instead')
const AvatarKey_EntityType$json = {
  '1': 'EntityType',
  '2': [
    {'1': 'OTHERS', '2': 0},
    {'1': 'CHATTER', '2': 1},
    {'1': 'CHAT', '2': 2},
    {'1': 'TENANT', '2': 3},
    {'1': 'NAMECARD', '2': 4},
    {'1': 'TEAM', '2': 5},
  ],
};

/// Descriptor for `AvatarKey`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List avatarKeyDescriptor = $convert.base64Decode(
    'CglBdmF0YXJLZXkSGwoJZW50aXR5X2lkGAEgASgJUghlbnRpdHlJZBIQCgNrZXkYAiABKAlSA2'
    'tleRI6CgtlbnRpdHlfdHlwZRgDIAEoDjIZLnNkay5BdmF0YXJLZXkuRW50aXR5VHlwZVIKZW50'
    'aXR5VHlwZSJTCgpFbnRpdHlUeXBlEgoKBk9USEVSUxAAEgsKB0NIQVRURVIQARIICgRDSEFUEA'
    'ISCgoGVEVOQU5UEAMSDAoITkFNRUNBUkQQBBIICgRURUFNEAU=');

@$core.Deprecated('Use writeClientLogDescriptor instead')
const WriteClientLog$json = {
  '1': 'WriteClientLog',
  '2': [
    {'1': 'msg', '3': 1, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'level', '3': 2, '4': 1, '5': 5, '10': 'level'},
    {'1': 'error', '3': 3, '4': 1, '5': 9, '10': 'error'},
    {'1': 'backtrace', '3': 4, '4': 1, '5': 9, '10': 'backtrace'},
  ],
};

/// Descriptor for `WriteClientLog`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List writeClientLogDescriptor = $convert.base64Decode(
    'Cg5Xcml0ZUNsaWVudExvZxIQCgNtc2cYASABKAlSA21zZxIUCgVsZXZlbBgCIAEoBVIFbGV2ZW'
    'wSFAoFZXJyb3IYAyABKAlSBWVycm9yEhwKCWJhY2t0cmFjZRgEIAEoCVIJYmFja3RyYWNl');

@$core.Deprecated('Use netRequestDescriptor instead')
const NetRequest$json = {
  '1': 'NetRequest',
  '2': [
    {'1': 'cmd', '3': 1, '4': 1, '5': 5, '10': 'cmd'},
    {'1': 'body', '3': 2, '4': 1, '5': 12, '10': 'body'},
  ],
};

/// Descriptor for `NetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List netRequestDescriptor = $convert.base64Decode(
    'CgpOZXRSZXF1ZXN0EhAKA2NtZBgBIAEoBVIDY21kEhIKBGJvZHkYAiABKAxSBGJvZHk=');

@$core.Deprecated('Use pushEntityChangeRequestDescriptor instead')
const PushEntityChangeRequest$json = {
  '1': 'PushEntityChangeRequest',
  '2': [
    {'1': 'types', '3': 1, '4': 3, '5': 5, '10': 'types'},
    {
      '1': 'entity',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.entity.Entity',
      '10': 'entity'
    },
  ],
};

/// Descriptor for `PushEntityChangeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushEntityChangeRequestDescriptor =
    $convert.base64Decode(
        'ChdQdXNoRW50aXR5Q2hhbmdlUmVxdWVzdBIUCgV0eXBlcxgBIAMoBVIFdHlwZXMSJgoGZW50aX'
        'R5GAIgASgLMg4uZW50aXR5LkVudGl0eVIGZW50aXR5');
