// This is a generated file - do not edit.
//
// Generated from mute.proto.

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

@$core.Deprecated('Use muteMemberRequestDescriptor instead')
const MuteMemberRequest$json = {
  '1': 'MuteMemberRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'member_id', '3': 2, '4': 1, '5': 3, '10': 'memberId'},
    {'1': 'until_ms', '3': 3, '4': 1, '5': 3, '10': 'untilMs'},
  ],
};

/// Descriptor for `MuteMemberRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List muteMemberRequestDescriptor = $convert.base64Decode(
    'ChFNdXRlTWVtYmVyUmVxdWVzdBIXCgdjaGF0X2lkGAEgASgDUgZjaGF0SWQSGwoJbWVtYmVyX2'
    'lkGAIgASgDUghtZW1iZXJJZBIZCgh1bnRpbF9tcxgDIAEoA1IHdW50aWxNcw==');

@$core.Deprecated('Use muteMemberResponseDescriptor instead')
const MuteMemberResponse$json = {
  '1': 'MuteMemberResponse',
};

/// Descriptor for `MuteMemberResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List muteMemberResponseDescriptor =
    $convert.base64Decode('ChJNdXRlTWVtYmVyUmVzcG9uc2U=');

@$core.Deprecated('Use globalMuteRequestDescriptor instead')
const GlobalMuteRequest$json = {
  '1': 'GlobalMuteRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'until_ms', '3': 2, '4': 1, '5': 3, '10': 'untilMs'},
  ],
};

/// Descriptor for `GlobalMuteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List globalMuteRequestDescriptor = $convert.base64Decode(
    'ChFHbG9iYWxNdXRlUmVxdWVzdBIXCgdjaGF0X2lkGAEgASgDUgZjaGF0SWQSGQoIdW50aWxfbX'
    'MYAiABKANSB3VudGlsTXM=');

@$core.Deprecated('Use globalMuteResponseDescriptor instead')
const GlobalMuteResponse$json = {
  '1': 'GlobalMuteResponse',
};

/// Descriptor for `GlobalMuteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List globalMuteResponseDescriptor =
    $convert.base64Decode('ChJHbG9iYWxNdXRlUmVzcG9uc2U=');
