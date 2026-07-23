// This is a generated file - do not edit.
//
// Generated from message.proto.

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

@$core.Deprecated('Use createMessageDraftRequestDescriptor instead')
const CreateMessageDraftRequest$json = {
  '1': 'CreateMessageDraftRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
    {
      '1': 'message',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.entity.Message',
      '10': 'message'
    },
  ],
};

/// Descriptor for `CreateMessageDraftRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createMessageDraftRequestDescriptor =
    $convert.base64Decode(
        'ChlDcmVhdGVNZXNzYWdlRHJhZnRSZXF1ZXN0EhcKB2NoYXRfaWQYASABKANSBmNoYXRJZBIpCg'
        'dtZXNzYWdlGAIgASgLMg8uZW50aXR5Lk1lc3NhZ2VSB21lc3NhZ2U=');

@$core.Deprecated('Use createMessageDraftResponseDescriptor instead')
const CreateMessageDraftResponse$json = {
  '1': 'CreateMessageDraftResponse',
  '2': [
    {'1': 'client_id', '3': 1, '4': 1, '5': 3, '10': 'clientId'},
  ],
};

/// Descriptor for `CreateMessageDraftResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createMessageDraftResponseDescriptor =
    $convert.base64Decode(
        'ChpDcmVhdGVNZXNzYWdlRHJhZnRSZXNwb25zZRIbCgljbGllbnRfaWQYASABKANSCGNsaWVudE'
        'lk');

@$core.Deprecated('Use sendMessageRequestDescriptor instead')
const SendMessageRequest$json = {
  '1': 'SendMessageRequest',
  '2': [
    {'1': 'client_id', '3': 1, '4': 1, '5': 3, '10': 'clientId'},
    {
      '1': 'message',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.entity.Message',
      '10': 'message'
    },
  ],
};

/// Descriptor for `SendMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendMessageRequestDescriptor = $convert.base64Decode(
    'ChJTZW5kTWVzc2FnZVJlcXVlc3QSGwoJY2xpZW50X2lkGAEgASgDUghjbGllbnRJZBIpCgdtZX'
    'NzYWdlGAIgASgLMg8uZW50aXR5Lk1lc3NhZ2VSB21lc3NhZ2U=');

@$core.Deprecated('Use sendMessageResponseDescriptor instead')
const SendMessageResponse$json = {
  '1': 'SendMessageResponse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
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

/// Descriptor for `SendMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendMessageResponseDescriptor = $convert.base64Decode(
    'ChNTZW5kTWVzc2FnZVJlc3BvbnNlEg4KAmlkGAEgASgDUgJpZBImCgZlbnRpdHkYAiABKAsyDi'
    '5lbnRpdHkuRW50aXR5UgZlbnRpdHk=');

@$core.Deprecated('Use getMessageByRangeRequestDescriptor instead')
const GetMessageByRangeRequest$json = {
  '1': 'GetMessageByRangeRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'pos', '3': 2, '4': 1, '5': 5, '10': 'pos'},
    {'1': 'count', '3': 3, '4': 1, '5': 5, '10': 'count'},
    {'1': 'direct', '3': 4, '4': 1, '5': 5, '10': 'direct'},
  ],
};

/// Descriptor for `GetMessageByRangeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMessageByRangeRequestDescriptor = $convert.base64Decode(
    'ChhHZXRNZXNzYWdlQnlSYW5nZVJlcXVlc3QSFwoHY2hhdF9pZBgBIAEoA1IGY2hhdElkEhAKA3'
    'BvcxgCIAEoBVIDcG9zEhQKBWNvdW50GAMgASgFUgVjb3VudBIWCgZkaXJlY3QYBCABKAVSBmRp'
    'cmVjdA==');

@$core.Deprecated('Use getMessageByRangeResponseDescriptor instead')
const GetMessageByRangeResponse$json = {
  '1': 'GetMessageByRangeResponse',
  '2': [
    {
      '1': 'entity',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.entity.Entity',
      '10': 'entity'
    },
  ],
};

/// Descriptor for `GetMessageByRangeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMessageByRangeResponseDescriptor =
    $convert.base64Decode(
        'ChlHZXRNZXNzYWdlQnlSYW5nZVJlc3BvbnNlEiYKBmVudGl0eRgBIAEoCzIOLmVudGl0eS5Fbn'
        'RpdHlSBmVudGl0eQ==');

@$core.Deprecated('Use getMessageByPosRequestDescriptor instead')
const GetMessageByPosRequest$json = {
  '1': 'GetMessageByPosRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'pos', '3': 2, '4': 3, '5': 5, '10': 'pos'},
  ],
};

/// Descriptor for `GetMessageByPosRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMessageByPosRequestDescriptor =
    $convert.base64Decode(
        'ChZHZXRNZXNzYWdlQnlQb3NSZXF1ZXN0EhcKB2NoYXRfaWQYASABKANSBmNoYXRJZBIQCgNwb3'
        'MYAiADKAVSA3Bvcw==');

@$core.Deprecated('Use getMessageByPosResponseDescriptor instead')
const GetMessageByPosResponse$json = {
  '1': 'GetMessageByPosResponse',
  '2': [
    {
      '1': 'entity',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.entity.Entity',
      '10': 'entity'
    },
  ],
};

/// Descriptor for `GetMessageByPosResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMessageByPosResponseDescriptor =
    $convert.base64Decode(
        'ChdHZXRNZXNzYWdlQnlQb3NSZXNwb25zZRImCgZlbnRpdHkYASABKAsyDi5lbnRpdHkuRW50aX'
        'R5UgZlbnRpdHk=');

@$core.Deprecated('Use getMessageByIdsRequestDescriptor instead')
const GetMessageByIdsRequest$json = {
  '1': 'GetMessageByIdsRequest',
  '2': [
    {'1': 'ids', '3': 1, '4': 3, '5': 3, '10': 'ids'},
    {'1': 'with_full', '3': 2, '4': 1, '5': 8, '10': 'withFull'},
  ],
};

/// Descriptor for `GetMessageByIdsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMessageByIdsRequestDescriptor =
    $convert.base64Decode(
        'ChZHZXRNZXNzYWdlQnlJZHNSZXF1ZXN0EhAKA2lkcxgBIAMoA1IDaWRzEhsKCXdpdGhfZnVsbB'
        'gCIAEoCFIId2l0aEZ1bGw=');

@$core.Deprecated('Use getMessageByIdsResponseDescriptor instead')
const GetMessageByIdsResponse$json = {
  '1': 'GetMessageByIdsResponse',
  '2': [
    {
      '1': 'entity',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.entity.Entity',
      '10': 'entity'
    },
  ],
};

/// Descriptor for `GetMessageByIdsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMessageByIdsResponseDescriptor =
    $convert.base64Decode(
        'ChdHZXRNZXNzYWdlQnlJZHNSZXNwb25zZRImCgZlbnRpdHkYASABKAsyDi5lbnRpdHkuRW50aX'
        'R5UgZlbnRpdHk=');

@$core.Deprecated('Use pushMessagesDescriptor instead')
const PushMessages$json = {
  '1': 'PushMessages',
  '2': [
    {
      '1': 'entity',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.entity.Entity',
      '10': 'entity'
    },
  ],
};

/// Descriptor for `PushMessages`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushMessagesDescriptor = $convert.base64Decode(
    'CgxQdXNoTWVzc2FnZXMSJgoGZW50aXR5GAEgASgLMg4uZW50aXR5LkVudGl0eVIGZW50aXR5');

@$core.Deprecated('Use favoriteAddRequestDescriptor instead')
const FavoriteAddRequest$json = {
  '1': 'FavoriteAddRequest',
  '2': [
    {
      '1': 'favorite',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.entity.Favorite',
      '10': 'favorite'
    },
  ],
};

/// Descriptor for `FavoriteAddRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List favoriteAddRequestDescriptor = $convert.base64Decode(
    'ChJGYXZvcml0ZUFkZFJlcXVlc3QSLAoIZmF2b3JpdGUYASABKAsyEC5lbnRpdHkuRmF2b3JpdG'
    'VSCGZhdm9yaXRl');

@$core.Deprecated('Use favoriteAddResponseDescriptor instead')
const FavoriteAddResponse$json = {
  '1': 'FavoriteAddResponse',
};

/// Descriptor for `FavoriteAddResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List favoriteAddResponseDescriptor =
    $convert.base64Decode('ChNGYXZvcml0ZUFkZFJlc3BvbnNl');

@$core.Deprecated('Use favoriteRemoveRequestDescriptor instead')
const FavoriteRemoveRequest$json = {
  '1': 'FavoriteRemoveRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
  ],
};

/// Descriptor for `FavoriteRemoveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List favoriteRemoveRequestDescriptor = $convert
    .base64Decode('ChVGYXZvcml0ZVJlbW92ZVJlcXVlc3QSDgoCaWQYASABKANSAmlk');

@$core.Deprecated('Use favoriteRemoveResponseDescriptor instead')
const FavoriteRemoveResponse$json = {
  '1': 'FavoriteRemoveResponse',
};

/// Descriptor for `FavoriteRemoveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List favoriteRemoveResponseDescriptor =
    $convert.base64Decode('ChZGYXZvcml0ZVJlbW92ZVJlc3BvbnNl');

@$core.Deprecated('Use pushFavoriteListDescriptor instead')
const PushFavoriteList$json = {
  '1': 'PushFavoriteList',
  '2': [
    {'1': 'version', '3': 1, '4': 1, '5': 3, '10': 'version'},
    {
      '1': 'favorites',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.entity.Favorite',
      '10': 'favorites'
    },
  ],
};

/// Descriptor for `PushFavoriteList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushFavoriteListDescriptor = $convert.base64Decode(
    'ChBQdXNoRmF2b3JpdGVMaXN0EhgKB3ZlcnNpb24YASABKANSB3ZlcnNpb24SLgoJZmF2b3JpdG'
    'VzGAIgAygLMhAuZW50aXR5LkZhdm9yaXRlUglmYXZvcml0ZXM=');

@$core.Deprecated('Use getFavoriteListRequestDescriptor instead')
const GetFavoriteListRequest$json = {
  '1': 'GetFavoriteListRequest',
};

/// Descriptor for `GetFavoriteListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFavoriteListRequestDescriptor =
    $convert.base64Decode('ChZHZXRGYXZvcml0ZUxpc3RSZXF1ZXN0');

@$core.Deprecated('Use getFavoriteListResponseDescriptor instead')
const GetFavoriteListResponse$json = {
  '1': 'GetFavoriteListResponse',
  '2': [
    {'1': 'version', '3': 1, '4': 1, '5': 3, '10': 'version'},
    {
      '1': 'favorites',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.entity.FavoriteList',
      '10': 'favorites'
    },
  ],
};

/// Descriptor for `GetFavoriteListResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFavoriteListResponseDescriptor =
    $convert.base64Decode(
        'ChdHZXRGYXZvcml0ZUxpc3RSZXNwb25zZRIYCgd2ZXJzaW9uGAEgASgDUgd2ZXJzaW9uEjIKCW'
        'Zhdm9yaXRlcxgCIAEoCzIULmVudGl0eS5GYXZvcml0ZUxpc3RSCWZhdm9yaXRlcw==');

@$core.Deprecated('Use messageReadRequestDescriptor instead')
const MessageReadRequest$json = {
  '1': 'MessageReadRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'max_pos', '3': 2, '4': 1, '5': 5, '10': 'maxPos'},
    {'1': 'message_ids', '3': 3, '4': 3, '5': 3, '10': 'messageIds'},
  ],
};

/// Descriptor for `MessageReadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageReadRequestDescriptor = $convert.base64Decode(
    'ChJNZXNzYWdlUmVhZFJlcXVlc3QSFwoHY2hhdF9pZBgBIAEoA1IGY2hhdElkEhcKB21heF9wb3'
    'MYAiABKAVSBm1heFBvcxIfCgttZXNzYWdlX2lkcxgDIAMoA1IKbWVzc2FnZUlkcw==');

@$core.Deprecated('Use messageReadResponseDescriptor instead')
const MessageReadResponse$json = {
  '1': 'MessageReadResponse',
};

/// Descriptor for `MessageReadResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageReadResponseDescriptor =
    $convert.base64Decode('ChNNZXNzYWdlUmVhZFJlc3BvbnNl');

@$core.Deprecated('Use pushReadMessageRequestDescriptor instead')
const PushReadMessageRequest$json = {
  '1': 'PushReadMessageRequest',
  '2': [
    {
      '1': 'entity',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.entity.Entity',
      '10': 'entity'
    },
  ],
};

/// Descriptor for `PushReadMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushReadMessageRequestDescriptor =
    $convert.base64Decode(
        'ChZQdXNoUmVhZE1lc3NhZ2VSZXF1ZXN0EiYKBmVudGl0eRgBIAEoCzIOLmVudGl0eS5FbnRpdH'
        'lSBmVudGl0eQ==');

@$core.Deprecated('Use setMessageReactitonRequestDescriptor instead')
const SetMessageReactitonRequest$json = {
  '1': 'SetMessageReactitonRequest',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 3, '10': 'messageId'},
    {'1': 'reaction', '3': 2, '4': 1, '5': 5, '10': 'reaction'},
    {'1': 'set', '3': 3, '4': 1, '5': 8, '10': 'set'},
  ],
};

/// Descriptor for `SetMessageReactitonRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setMessageReactitonRequestDescriptor =
    $convert.base64Decode(
        'ChpTZXRNZXNzYWdlUmVhY3RpdG9uUmVxdWVzdBIdCgptZXNzYWdlX2lkGAEgASgDUgltZXNzYW'
        'dlSWQSGgoIcmVhY3Rpb24YAiABKAVSCHJlYWN0aW9uEhAKA3NldBgDIAEoCFIDc2V0');

@$core.Deprecated('Use setMessageReactitonResponseDescriptor instead')
const SetMessageReactitonResponse$json = {
  '1': 'SetMessageReactitonResponse',
};

/// Descriptor for `SetMessageReactitonResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setMessageReactitonResponseDescriptor =
    $convert.base64Decode('ChtTZXRNZXNzYWdlUmVhY3RpdG9uUmVzcG9uc2U=');

@$core.Deprecated('Use pushMessageReactionRequestDescriptor instead')
const PushMessageReactionRequest$json = {
  '1': 'PushMessageReactionRequest',
  '2': [
    {
      '1': 'entity',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.entity.Entity',
      '10': 'entity'
    },
  ],
};

/// Descriptor for `PushMessageReactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushMessageReactionRequestDescriptor =
    $convert.base64Decode(
        'ChpQdXNoTWVzc2FnZVJlYWN0aW9uUmVxdWVzdBImCgZlbnRpdHkYASABKAsyDi5lbnRpdHkuRW'
        '50aXR5UgZlbnRpdHk=');

@$core.Deprecated('Use forwardMessageRequestDescriptor instead')
const ForwardMessageRequest$json = {
  '1': 'ForwardMessageRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'forward_type', '3': 2, '4': 1, '5': 5, '10': 'forwardType'},
    {'1': 'source_chat_id', '3': 3, '4': 1, '5': 3, '10': 'sourceChatId'},
    {'1': 'message_ids', '3': 4, '4': 3, '5': 3, '10': 'messageIds'},
  ],
};

/// Descriptor for `ForwardMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List forwardMessageRequestDescriptor = $convert.base64Decode(
    'ChVGb3J3YXJkTWVzc2FnZVJlcXVlc3QSFwoHY2hhdF9pZBgBIAEoA1IGY2hhdElkEiEKDGZvcn'
    'dhcmRfdHlwZRgCIAEoBVILZm9yd2FyZFR5cGUSJAoOc291cmNlX2NoYXRfaWQYAyABKANSDHNv'
    'dXJjZUNoYXRJZBIfCgttZXNzYWdlX2lkcxgEIAMoA1IKbWVzc2FnZUlkcw==');

@$core.Deprecated('Use forwardMessageResponseDescriptor instead')
const ForwardMessageResponse$json = {
  '1': 'ForwardMessageResponse',
  '2': [
    {'1': 'count', '3': 1, '4': 1, '5': 5, '10': 'count'},
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

/// Descriptor for `ForwardMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List forwardMessageResponseDescriptor =
    $convert.base64Decode(
        'ChZGb3J3YXJkTWVzc2FnZVJlc3BvbnNlEhQKBWNvdW50GAEgASgFUgVjb3VudBImCgZlbnRpdH'
        'kYAiABKAsyDi5lbnRpdHkuRW50aXR5UgZlbnRpdHk=');

@$core.Deprecated('Use recallMessageRequestDescriptor instead')
const RecallMessageRequest$json = {
  '1': 'RecallMessageRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
  ],
};

/// Descriptor for `RecallMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recallMessageRequestDescriptor = $convert
    .base64Decode('ChRSZWNhbGxNZXNzYWdlUmVxdWVzdBIOCgJpZBgBIAEoA1ICaWQ=');

@$core.Deprecated('Use recallMessageResponseDescriptor instead')
const RecallMessageResponse$json = {
  '1': 'RecallMessageResponse',
  '2': [
    {
      '1': 'entity',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.entity.Entity',
      '10': 'entity'
    },
  ],
};

/// Descriptor for `RecallMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recallMessageResponseDescriptor = $convert.base64Decode(
    'ChVSZWNhbGxNZXNzYWdlUmVzcG9uc2USJgoGZW50aXR5GAEgASgLMg4uZW50aXR5LkVudGl0eV'
    'IGZW50aXR5');

@$core.Deprecated('Use deleteMessageRequestDescriptor instead')
const DeleteMessageRequest$json = {
  '1': 'DeleteMessageRequest',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 3, '10': 'messageId'},
    {'1': 'mode', '3': 2, '4': 1, '5': 5, '10': 'mode'},
  ],
};

/// Descriptor for `DeleteMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteMessageRequestDescriptor = $convert.base64Decode(
    'ChREZWxldGVNZXNzYWdlUmVxdWVzdBIdCgptZXNzYWdlX2lkGAEgASgDUgltZXNzYWdlSWQSEg'
    'oEbW9kZRgCIAEoBVIEbW9kZQ==');

@$core.Deprecated('Use deleteMessageResponseDescriptor instead')
const DeleteMessageResponse$json = {
  '1': 'DeleteMessageResponse',
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

/// Descriptor for `DeleteMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteMessageResponseDescriptor = $convert.base64Decode(
    'ChVEZWxldGVNZXNzYWdlUmVzcG9uc2USKgoIZW50aXRpZXMYASABKAsyDi5lbnRpdHkuRW50aX'
    'R5UghlbnRpdGllcw==');

@$core.Deprecated('Use getReadMembersRequestDescriptor instead')
const GetReadMembersRequest$json = {
  '1': 'GetReadMembersRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'message_id', '3': 2, '4': 1, '5': 3, '10': 'messageId'},
  ],
};

/// Descriptor for `GetReadMembersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getReadMembersRequestDescriptor = $convert.base64Decode(
    'ChVHZXRSZWFkTWVtYmVyc1JlcXVlc3QSFwoHY2hhdF9pZBgBIAEoA1IGY2hhdElkEh0KCm1lc3'
    'NhZ2VfaWQYAiABKANSCW1lc3NhZ2VJZA==');

@$core.Deprecated('Use readMemberItemDescriptor instead')
const ReadMemberItem$json = {
  '1': 'ReadMemberItem',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'avatar', '3': 3, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'is_read', '3': 4, '4': 1, '5': 8, '10': 'isRead'},
  ],
};

/// Descriptor for `ReadMemberItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List readMemberItemDescriptor = $convert.base64Decode(
    'Cg5SZWFkTWVtYmVySXRlbRIXCgd1c2VyX2lkGAEgASgDUgZ1c2VySWQSEgoEbmFtZRgCIAEoCV'
    'IEbmFtZRIWCgZhdmF0YXIYAyABKAlSBmF2YXRhchIXCgdpc19yZWFkGAQgASgIUgZpc1JlYWQ=');

@$core.Deprecated('Use getReadMembersResponseDescriptor instead')
const GetReadMembersResponse$json = {
  '1': 'GetReadMembersResponse',
  '2': [
    {
      '1': 'members',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.message.ReadMemberItem',
      '10': 'members'
    },
  ],
};

/// Descriptor for `GetReadMembersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getReadMembersResponseDescriptor =
    $convert.base64Decode(
        'ChZHZXRSZWFkTWVtYmVyc1Jlc3BvbnNlEjEKB21lbWJlcnMYASADKAsyFy5tZXNzYWdlLlJlYW'
        'RNZW1iZXJJdGVtUgdtZW1iZXJz');
