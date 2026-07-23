// This is a generated file - do not edit.
//
// Generated from timer.proto.

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

@$core.Deprecated('Use scheduleMessageRequestDescriptor instead')
const ScheduleMessageRequest$json = {
  '1': 'ScheduleMessageRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'send_at_ms', '3': 2, '4': 1, '5': 3, '10': 'sendAtMs'},
    {'1': 'tpy', '3': 3, '4': 1, '5': 5, '10': 'tpy'},
    {'1': 'content', '3': 4, '4': 1, '5': 12, '10': 'content'},
    {'1': 'client_id', '3': 5, '4': 1, '5': 3, '10': 'clientId'},
    {'1': 'at_user_id', '3': 6, '4': 1, '5': 3, '10': 'atUserId'},
    {'1': 'at_user_ids', '3': 7, '4': 3, '5': 3, '10': 'atUserIds'},
  ],
};

/// Descriptor for `ScheduleMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scheduleMessageRequestDescriptor = $convert.base64Decode(
    'ChZTY2hlZHVsZU1lc3NhZ2VSZXF1ZXN0EhcKB2NoYXRfaWQYASABKANSBmNoYXRJZBIcCgpzZW'
    '5kX2F0X21zGAIgASgDUghzZW5kQXRNcxIQCgN0cHkYAyABKAVSA3RweRIYCgdjb250ZW50GAQg'
    'ASgMUgdjb250ZW50EhsKCWNsaWVudF9pZBgFIAEoA1IIY2xpZW50SWQSHAoKYXRfdXNlcl9pZB'
    'gGIAEoA1IIYXRVc2VySWQSHgoLYXRfdXNlcl9pZHMYByADKANSCWF0VXNlcklkcw==');

@$core.Deprecated('Use scheduleMessageResponseDescriptor instead')
const ScheduleMessageResponse$json = {
  '1': 'ScheduleMessageResponse',
  '2': [
    {'1': 'schedule_id', '3': 1, '4': 1, '5': 3, '10': 'scheduleId'},
    {'1': 'schedule_at_ms', '3': 2, '4': 1, '5': 3, '10': 'scheduleAtMs'},
  ],
};

/// Descriptor for `ScheduleMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scheduleMessageResponseDescriptor =
    $convert.base64Decode(
        'ChdTY2hlZHVsZU1lc3NhZ2VSZXNwb25zZRIfCgtzY2hlZHVsZV9pZBgBIAEoA1IKc2NoZWR1bG'
        'VJZBIkCg5zY2hlZHVsZV9hdF9tcxgCIAEoA1IMc2NoZWR1bGVBdE1z');

@$core.Deprecated('Use cancelScheduleRequestDescriptor instead')
const CancelScheduleRequest$json = {
  '1': 'CancelScheduleRequest',
  '2': [
    {'1': 'schedule_id', '3': 1, '4': 1, '5': 3, '10': 'scheduleId'},
  ],
};

/// Descriptor for `CancelScheduleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cancelScheduleRequestDescriptor = $convert.base64Decode(
    'ChVDYW5jZWxTY2hlZHVsZVJlcXVlc3QSHwoLc2NoZWR1bGVfaWQYASABKANSCnNjaGVkdWxlSW'
    'Q=');

@$core.Deprecated('Use cancelScheduleResponseDescriptor instead')
const CancelScheduleResponse$json = {
  '1': 'CancelScheduleResponse',
};

/// Descriptor for `CancelScheduleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cancelScheduleResponseDescriptor =
    $convert.base64Decode('ChZDYW5jZWxTY2hlZHVsZVJlc3BvbnNl');

@$core.Deprecated('Use getScheduledMessagesRequestDescriptor instead')
const GetScheduledMessagesRequest$json = {
  '1': 'GetScheduledMessagesRequest',
  '2': [
    {'1': 'page', '3': 1, '4': 1, '5': 5, '10': 'page'},
    {'1': 'page_size', '3': 2, '4': 1, '5': 5, '10': 'pageSize'},
  ],
};

/// Descriptor for `GetScheduledMessagesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getScheduledMessagesRequestDescriptor =
    $convert.base64Decode(
        'ChtHZXRTY2hlZHVsZWRNZXNzYWdlc1JlcXVlc3QSEgoEcGFnZRgBIAEoBVIEcGFnZRIbCglwYW'
        'dlX3NpemUYAiABKAVSCHBhZ2VTaXpl');

@$core.Deprecated('Use getScheduledMessagesResponseDescriptor instead')
const GetScheduledMessagesResponse$json = {
  '1': 'GetScheduledMessagesResponse',
  '2': [
    {
      '1': 'messages',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.timer.ScheduledMessage',
      '10': 'messages'
    },
    {'1': 'total', '3': 2, '4': 1, '5': 5, '10': 'total'},
  ],
};

/// Descriptor for `GetScheduledMessagesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getScheduledMessagesResponseDescriptor =
    $convert.base64Decode(
        'ChxHZXRTY2hlZHVsZWRNZXNzYWdlc1Jlc3BvbnNlEjMKCG1lc3NhZ2VzGAEgAygLMhcudGltZX'
        'IuU2NoZWR1bGVkTWVzc2FnZVIIbWVzc2FnZXMSFAoFdG90YWwYAiABKAVSBXRvdGFs');

@$core.Deprecated('Use scheduledMessageDescriptor instead')
const ScheduledMessage$json = {
  '1': 'ScheduledMessage',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'chat_id', '3': 2, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'send_at_ms', '3': 3, '4': 1, '5': 3, '10': 'sendAtMs'},
    {'1': 'tpy', '3': 4, '4': 1, '5': 5, '10': 'tpy'},
    {'1': 'content', '3': 5, '4': 1, '5': 12, '10': 'content'},
    {'1': 'status', '3': 6, '4': 1, '5': 5, '10': 'status'},
    {'1': 'created_at_ms', '3': 7, '4': 1, '5': 3, '10': 'createdAtMs'},
  ],
};

/// Descriptor for `ScheduledMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scheduledMessageDescriptor = $convert.base64Decode(
    'ChBTY2hlZHVsZWRNZXNzYWdlEg4KAmlkGAEgASgDUgJpZBIXCgdjaGF0X2lkGAIgASgDUgZjaG'
    'F0SWQSHAoKc2VuZF9hdF9tcxgDIAEoA1IIc2VuZEF0TXMSEAoDdHB5GAQgASgFUgN0cHkSGAoH'
    'Y29udGVudBgFIAEoDFIHY29udGVudBIWCgZzdGF0dXMYBiABKAVSBnN0YXR1cxIiCg1jcmVhdG'
    'VkX2F0X21zGAcgASgDUgtjcmVhdGVkQXRNcw==');
