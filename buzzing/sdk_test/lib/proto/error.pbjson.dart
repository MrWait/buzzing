// This is a generated file - do not edit.
//
// Generated from error.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use errorCodeDescriptor instead')
const ErrorCode$json = {
  '1': 'ErrorCode',
  '2': [
    {'1': 'ERROR_UNKNOWN', '2': 0},
    {'1': 'OK', '2': 200},
    {'1': 'ERROR_SDK_ERROR', '2': 1000},
    {'1': 'ERROR_SERVER_ERROR', '2': 1001},
    {'1': 'ERROR_NOT_AUTH', '2': 1002},
    {'1': 'ERROR_ON_PROCESS', '2': 1003},
    {'1': 'ERROR_TIMEOUT', '2': 1004},
    {'1': 'ERROR_NO_PERMISION', '2': 1005},
    {'1': 'ERROR_PARAM_INVALID', '2': 1006},
    {'1': 'ERROR_INVALID_DATA', '2': 1007},
  ],
};

/// Descriptor for `ErrorCode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List errorCodeDescriptor = $convert.base64Decode(
    'CglFcnJvckNvZGUSEQoNRVJST1JfVU5LTk9XThAAEgcKAk9LEMgBEhQKD0VSUk9SX1NES19FUl'
    'JPUhDoBxIXChJFUlJPUl9TRVJWRVJfRVJST1IQ6QcSEwoORVJST1JfTk9UX0FVVEgQ6gcSFQoQ'
    'RVJST1JfT05fUFJPQ0VTUxDrBxISCg1FUlJPUl9USU1FT1VUEOwHEhcKEkVSUk9SX05PX1BFUk'
    '1JU0lPThDtBxIYChNFUlJPUl9QQVJBTV9JTlZBTElEEO4HEhcKEkVSUk9SX0lOVkFMSURfREFU'
    'QRDvBw==');
