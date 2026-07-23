// This is a generated file - do not edit.
//
// Generated from pin.proto.

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

@$core.Deprecated('Use pinMessageRequestDescriptor instead')
const PinMessageRequest$json = {
  '1': 'PinMessageRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'message_id', '3': 2, '4': 1, '5': 3, '10': 'messageId'},
  ],
};

/// Descriptor for `PinMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pinMessageRequestDescriptor = $convert.base64Decode(
    'ChFQaW5NZXNzYWdlUmVxdWVzdBIXCgdjaGF0X2lkGAEgASgDUgZjaGF0SWQSHQoKbWVzc2FnZV'
    '9pZBgCIAEoA1IJbWVzc2FnZUlk');

@$core.Deprecated('Use pinMessageResponseDescriptor instead')
const PinMessageResponse$json = {
  '1': 'PinMessageResponse',
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

/// Descriptor for `PinMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pinMessageResponseDescriptor = $convert.base64Decode(
    'ChJQaW5NZXNzYWdlUmVzcG9uc2USKgoIZW50aXRpZXMYASABKAsyDi5lbnRpdHkuRW50aXR5Ug'
    'hlbnRpdGllcw==');

@$core.Deprecated('Use unpinMessageRequestDescriptor instead')
const UnpinMessageRequest$json = {
  '1': 'UnpinMessageRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'message_id', '3': 2, '4': 1, '5': 3, '10': 'messageId'},
  ],
};

/// Descriptor for `UnpinMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unpinMessageRequestDescriptor = $convert.base64Decode(
    'ChNVbnBpbk1lc3NhZ2VSZXF1ZXN0EhcKB2NoYXRfaWQYASABKANSBmNoYXRJZBIdCgptZXNzYW'
    'dlX2lkGAIgASgDUgltZXNzYWdlSWQ=');

@$core.Deprecated('Use unpinMessageResponseDescriptor instead')
const UnpinMessageResponse$json = {
  '1': 'UnpinMessageResponse',
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

/// Descriptor for `UnpinMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unpinMessageResponseDescriptor = $convert.base64Decode(
    'ChRVbnBpbk1lc3NhZ2VSZXNwb25zZRIqCghlbnRpdGllcxgBIAEoCzIOLmVudGl0eS5FbnRpdH'
    'lSCGVudGl0aWVz');

@$core.Deprecated('Use getPinnedMessagesRequestDescriptor instead')
const GetPinnedMessagesRequest$json = {
  '1': 'GetPinnedMessagesRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
  ],
};

/// Descriptor for `GetPinnedMessagesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPinnedMessagesRequestDescriptor =
    $convert.base64Decode(
        'ChhHZXRQaW5uZWRNZXNzYWdlc1JlcXVlc3QSFwoHY2hhdF9pZBgBIAEoA1IGY2hhdElk');

@$core.Deprecated('Use getPinnedMessagesResponseDescriptor instead')
const GetPinnedMessagesResponse$json = {
  '1': 'GetPinnedMessagesResponse',
  '2': [
    {
      '1': 'messages',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.entity.Message',
      '10': 'messages'
    },
  ],
};

/// Descriptor for `GetPinnedMessagesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPinnedMessagesResponseDescriptor =
    $convert.base64Decode(
        'ChlHZXRQaW5uZWRNZXNzYWdlc1Jlc3BvbnNlEisKCG1lc3NhZ2VzGAEgAygLMg8uZW50aXR5Lk'
        '1lc3NhZ2VSCG1lc3NhZ2Vz');
