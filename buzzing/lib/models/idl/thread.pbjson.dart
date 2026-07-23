// This is a generated file - do not edit.
//
// Generated from thread.proto.

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

@$core.Deprecated('Use getThreadRequestDescriptor instead')
const GetThreadRequest$json = {
  '1': 'GetThreadRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'root_message_id', '3': 2, '4': 1, '5': 3, '10': 'rootMessageId'},
    {'1': 'page', '3': 3, '4': 1, '5': 5, '10': 'page'},
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
  ],
};

/// Descriptor for `GetThreadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getThreadRequestDescriptor = $convert.base64Decode(
    'ChBHZXRUaHJlYWRSZXF1ZXN0EhcKB2NoYXRfaWQYASABKANSBmNoYXRJZBImCg9yb290X21lc3'
    'NhZ2VfaWQYAiABKANSDXJvb3RNZXNzYWdlSWQSEgoEcGFnZRgDIAEoBVIEcGFnZRIbCglwYWdl'
    'X3NpemUYBCABKAVSCHBhZ2VTaXpl');

@$core.Deprecated('Use getThreadResponseDescriptor instead')
const GetThreadResponse$json = {
  '1': 'GetThreadResponse',
  '2': [
    {
      '1': 'messages',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.entity.Message',
      '10': 'messages'
    },
    {'1': 'total', '3': 2, '4': 1, '5': 5, '10': 'total'},
  ],
};

/// Descriptor for `GetThreadResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getThreadResponseDescriptor = $convert.base64Decode(
    'ChFHZXRUaHJlYWRSZXNwb25zZRIrCghtZXNzYWdlcxgBIAMoCzIPLmVudGl0eS5NZXNzYWdlUg'
    'htZXNzYWdlcxIUCgV0b3RhbBgCIAEoBVIFdG90YWw=');
