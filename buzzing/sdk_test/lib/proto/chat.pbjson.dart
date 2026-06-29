// This is a generated file - do not edit.
//
// Generated from chat.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use createChatRequestDescriptor instead')
const CreateChatRequest$json = {
  '1': 'CreateChatRequest',
  '2': [
    {'1': 'chat', '3': 1, '4': 1, '5': 11, '6': '.entity.Chat', '10': 'chat'},
  ],
};

/// Descriptor for `CreateChatRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createChatRequestDescriptor = $convert.base64Decode(
    'ChFDcmVhdGVDaGF0UmVxdWVzdBIgCgRjaGF0GAEgASgLMgwuZW50aXR5LkNoYXRSBGNoYXQ=');

@$core.Deprecated('Use createChatResponseDescriptor instead')
const CreateChatResponse$json = {
  '1': 'CreateChatResponse',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
    {
      '1': 'entities',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.entity.Entity',
      '10': 'entities'
    },
  ],
};

/// Descriptor for `CreateChatResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createChatResponseDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVDaGF0UmVzcG9uc2USFwoHY2hhdF9pZBgBIAEoA1IGY2hhdElkEioKCGVudGl0aW'
    'VzGAIgASgLMg4uZW50aXR5LkVudGl0eVIIZW50aXRpZXM=');

@$core.Deprecated('Use getChatByIdsRequestDescriptor instead')
const GetChatByIdsRequest$json = {
  '1': 'GetChatByIdsRequest',
  '2': [
    {'1': 'ids', '3': 1, '4': 3, '5': 3, '10': 'ids'},
  ],
};

/// Descriptor for `GetChatByIdsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getChatByIdsRequestDescriptor = $convert
    .base64Decode('ChNHZXRDaGF0QnlJZHNSZXF1ZXN0EhAKA2lkcxgBIAMoA1IDaWRz');

@$core.Deprecated('Use getChatByIdsResponseDescriptor instead')
const GetChatByIdsResponse$json = {
  '1': 'GetChatByIdsResponse',
  '2': [
    {
      '1': 'entities',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.entity.Entity',
      '10': 'entities'
    },
  ],
};

/// Descriptor for `GetChatByIdsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getChatByIdsResponseDescriptor = $convert.base64Decode(
    'ChRHZXRDaGF0QnlJZHNSZXNwb25zZRIqCghlbnRpdGllcxgBIAEoCzIOLmVudGl0eS5FbnRpdH'
    'lSCGVudGl0aWVz');

@$core.Deprecated('Use setChatDraftRequestDescriptor instead')
const SetChatDraftRequest$json = {
  '1': 'SetChatDraftRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'content', '3': 2, '4': 1, '5': 12, '10': 'content'},
    {'1': 'time_ms', '3': 3, '4': 1, '5': 3, '10': 'timeMs'},
  ],
};

/// Descriptor for `SetChatDraftRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setChatDraftRequestDescriptor = $convert.base64Decode(
    'ChNTZXRDaGF0RHJhZnRSZXF1ZXN0EhcKB2NoYXRfaWQYASABKANSBmNoYXRJZBIYCgdjb250ZW'
    '50GAIgASgMUgdjb250ZW50EhcKB3RpbWVfbXMYAyABKANSBnRpbWVNcw==');

@$core.Deprecated('Use setChatDraftResponseDescriptor instead')
const SetChatDraftResponse$json = {
  '1': 'SetChatDraftResponse',
};

/// Descriptor for `SetChatDraftResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setChatDraftResponseDescriptor =
    $convert.base64Decode('ChRTZXRDaGF0RHJhZnRSZXNwb25zZQ==');

@$core.Deprecated('Use getChatDraftRequestDescriptor instead')
const GetChatDraftRequest$json = {
  '1': 'GetChatDraftRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
  ],
};

/// Descriptor for `GetChatDraftRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getChatDraftRequestDescriptor =
    $convert.base64Decode(
        'ChNHZXRDaGF0RHJhZnRSZXF1ZXN0EhcKB2NoYXRfaWQYASABKANSBmNoYXRJZA==');

@$core.Deprecated('Use getChatDraftResponseDescriptor instead')
const GetChatDraftResponse$json = {
  '1': 'GetChatDraftResponse',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'content', '3': 2, '4': 1, '5': 12, '10': 'content'},
    {'1': 'time_ms', '3': 3, '4': 1, '5': 3, '10': 'timeMs'},
  ],
};

/// Descriptor for `GetChatDraftResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getChatDraftResponseDescriptor = $convert.base64Decode(
    'ChRHZXRDaGF0RHJhZnRSZXNwb25zZRIXCgdjaGF0X2lkGAEgASgDUgZjaGF0SWQSGAoHY29udG'
    'VudBgCIAEoDFIHY29udGVudBIXCgd0aW1lX21zGAMgASgDUgZ0aW1lTXM=');

@$core.Deprecated('Use dismissChatRequestDescriptor instead')
const DismissChatRequest$json = {
  '1': 'DismissChatRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
  ],
};

/// Descriptor for `DismissChatRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dismissChatRequestDescriptor =
    $convert.base64Decode(
        'ChJEaXNtaXNzQ2hhdFJlcXVlc3QSFwoHY2hhdF9pZBgBIAEoA1IGY2hhdElk');

@$core.Deprecated('Use dismissChatResponseDescriptor instead')
const DismissChatResponse$json = {
  '1': 'DismissChatResponse',
};

/// Descriptor for `DismissChatResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dismissChatResponseDescriptor =
    $convert.base64Decode('ChNEaXNtaXNzQ2hhdFJlc3BvbnNl');

@$core.Deprecated('Use updateChatRequestDescriptor instead')
const UpdateChatRequest$json = {
  '1': 'UpdateChatRequest',
  '2': [
    {'1': 'chat', '3': 1, '4': 1, '5': 11, '6': '.entity.Chat', '10': 'chat'},
  ],
};

/// Descriptor for `UpdateChatRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateChatRequestDescriptor = $convert.base64Decode(
    'ChFVcGRhdGVDaGF0UmVxdWVzdBIgCgRjaGF0GAEgASgLMgwuZW50aXR5LkNoYXRSBGNoYXQ=');

@$core.Deprecated('Use updateChatResponseDescriptor instead')
const UpdateChatResponse$json = {
  '1': 'UpdateChatResponse',
};

/// Descriptor for `UpdateChatResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateChatResponseDescriptor =
    $convert.base64Decode('ChJVcGRhdGVDaGF0UmVzcG9uc2U=');

@$core.Deprecated('Use addChatChatterRequestDescriptor instead')
const AddChatChatterRequest$json = {
  '1': 'AddChatChatterRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'ids', '3': 2, '4': 3, '5': 3, '10': 'ids'},
  ],
};

/// Descriptor for `AddChatChatterRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addChatChatterRequestDescriptor = $convert.base64Decode(
    'ChVBZGRDaGF0Q2hhdHRlclJlcXVlc3QSFwoHY2hhdF9pZBgBIAEoA1IGY2hhdElkEhAKA2lkcx'
    'gCIAMoA1IDaWRz');

@$core.Deprecated('Use addChatChatterResponseDescriptor instead')
const AddChatChatterResponse$json = {
  '1': 'AddChatChatterResponse',
};

/// Descriptor for `AddChatChatterResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addChatChatterResponseDescriptor =
    $convert.base64Decode('ChZBZGRDaGF0Q2hhdHRlclJlc3BvbnNl');

@$core.Deprecated('Use removeChatChatterRequestDescriptor instead')
const RemoveChatChatterRequest$json = {
  '1': 'RemoveChatChatterRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'ids', '3': 2, '4': 3, '5': 3, '10': 'ids'},
  ],
};

/// Descriptor for `RemoveChatChatterRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeChatChatterRequestDescriptor =
    $convert.base64Decode(
        'ChhSZW1vdmVDaGF0Q2hhdHRlclJlcXVlc3QSFwoHY2hhdF9pZBgBIAEoA1IGY2hhdElkEhAKA2'
        'lkcxgCIAMoA1IDaWRz');

@$core.Deprecated('Use removeChatChatterResponseDescriptor instead')
const RemoveChatChatterResponse$json = {
  '1': 'RemoveChatChatterResponse',
};

/// Descriptor for `RemoveChatChatterResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeChatChatterResponseDescriptor =
    $convert.base64Decode('ChlSZW1vdmVDaGF0Q2hhdHRlclJlc3BvbnNl');

@$core.Deprecated('Use readChatMessageRequestDescriptor instead')
const ReadChatMessageRequest$json = {
  '1': 'ReadChatMessageRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'pos', '3': 2, '4': 1, '5': 5, '10': 'pos'},
    {'1': 'message_ids', '3': 3, '4': 3, '5': 3, '10': 'messageIds'},
  ],
};

/// Descriptor for `ReadChatMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List readChatMessageRequestDescriptor =
    $convert.base64Decode(
        'ChZSZWFkQ2hhdE1lc3NhZ2VSZXF1ZXN0EhcKB2NoYXRfaWQYASABKANSBmNoYXRJZBIQCgNwb3'
        'MYAiABKAVSA3BvcxIfCgttZXNzYWdlX2lkcxgDIAMoA1IKbWVzc2FnZUlkcw==');

@$core.Deprecated('Use readChatMessageResponseDescriptor instead')
const ReadChatMessageResponse$json = {
  '1': 'ReadChatMessageResponse',
};

/// Descriptor for `ReadChatMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List readChatMessageResponseDescriptor =
    $convert.base64Decode('ChdSZWFkQ2hhdE1lc3NhZ2VSZXNwb25zZQ==');

@$core.Deprecated('Use quitChatRequestDescriptor instead')
const QuitChatRequest$json = {
  '1': 'QuitChatRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
  ],
};

/// Descriptor for `QuitChatRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List quitChatRequestDescriptor = $convert
    .base64Decode('Cg9RdWl0Q2hhdFJlcXVlc3QSFwoHY2hhdF9pZBgBIAEoA1IGY2hhdElk');

@$core.Deprecated('Use quitChatResponseDescriptor instead')
const QuitChatResponse$json = {
  '1': 'QuitChatResponse',
};

/// Descriptor for `QuitChatResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List quitChatResponseDescriptor =
    $convert.base64Decode('ChBRdWl0Q2hhdFJlc3BvbnNl');
