// This is a generated file - do not edit.
//
// Generated from typing.proto.

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

@$core.Deprecated('Use typingRequestDescriptor instead')
const TypingRequest$json = {
  '1': 'TypingRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
  ],
};

/// Descriptor for `TypingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List typingRequestDescriptor = $convert
    .base64Decode('Cg1UeXBpbmdSZXF1ZXN0EhcKB2NoYXRfaWQYASABKANSBmNoYXRJZA==');

@$core.Deprecated('Use typingResponseDescriptor instead')
const TypingResponse$json = {
  '1': 'TypingResponse',
};

/// Descriptor for `TypingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List typingResponseDescriptor =
    $convert.base64Decode('Cg5UeXBpbmdSZXNwb25zZQ==');

@$core.Deprecated('Use pushTypingDescriptor instead')
const PushTyping$json = {
  '1': 'PushTyping',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'user_name', '3': 3, '4': 1, '5': 9, '10': 'userName'},
    {'1': 'expire_at_ms', '3': 4, '4': 1, '5': 3, '10': 'expireAtMs'},
  ],
};

/// Descriptor for `PushTyping`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushTypingDescriptor = $convert.base64Decode(
    'CgpQdXNoVHlwaW5nEhcKB2NoYXRfaWQYASABKANSBmNoYXRJZBIXCgd1c2VyX2lkGAIgASgDUg'
    'Z1c2VySWQSGwoJdXNlcl9uYW1lGAMgASgJUgh1c2VyTmFtZRIgCgxleHBpcmVfYXRfbXMYBCAB'
    'KANSCmV4cGlyZUF0TXM=');
