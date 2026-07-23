// This is a generated file - do not edit.
//
// Generated from presence.proto.

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

@$core.Deprecated('Use presenceUpdateRequestDescriptor instead')
const PresenceUpdateRequest$json = {
  '1': 'PresenceUpdateRequest',
  '2': [
    {'1': 'status', '3': 1, '4': 1, '5': 5, '10': 'status'},
    {'1': 'status_text', '3': 2, '4': 1, '5': 9, '10': 'statusText'},
  ],
};

/// Descriptor for `PresenceUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List presenceUpdateRequestDescriptor = $convert.base64Decode(
    'ChVQcmVzZW5jZVVwZGF0ZVJlcXVlc3QSFgoGc3RhdHVzGAEgASgFUgZzdGF0dXMSHwoLc3RhdH'
    'VzX3RleHQYAiABKAlSCnN0YXR1c1RleHQ=');

@$core.Deprecated('Use presenceUpdateResponseDescriptor instead')
const PresenceUpdateResponse$json = {
  '1': 'PresenceUpdateResponse',
};

/// Descriptor for `PresenceUpdateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List presenceUpdateResponseDescriptor =
    $convert.base64Decode('ChZQcmVzZW5jZVVwZGF0ZVJlc3BvbnNl');

@$core.Deprecated('Use pushPresenceDescriptor instead')
const PushPresence$json = {
  '1': 'PushPresence',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'status', '3': 2, '4': 1, '5': 5, '10': 'status'},
    {'1': 'status_text', '3': 3, '4': 1, '5': 9, '10': 'statusText'},
    {'1': 'last_seen_ms', '3': 4, '4': 1, '5': 3, '10': 'lastSeenMs'},
  ],
};

/// Descriptor for `PushPresence`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushPresenceDescriptor = $convert.base64Decode(
    'CgxQdXNoUHJlc2VuY2USFwoHdXNlcl9pZBgBIAEoA1IGdXNlcklkEhYKBnN0YXR1cxgCIAEoBV'
    'IGc3RhdHVzEh8KC3N0YXR1c190ZXh0GAMgASgJUgpzdGF0dXNUZXh0EiAKDGxhc3Rfc2Vlbl9t'
    'cxgEIAEoA1IKbGFzdFNlZW5Ncw==');

@$core.Deprecated('Use presenceSubscribeRequestDescriptor instead')
const PresenceSubscribeRequest$json = {
  '1': 'PresenceSubscribeRequest',
  '2': [
    {'1': 'user_ids', '3': 1, '4': 3, '5': 3, '10': 'userIds'},
  ],
};

/// Descriptor for `PresenceSubscribeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List presenceSubscribeRequestDescriptor =
    $convert.base64Decode(
        'ChhQcmVzZW5jZVN1YnNjcmliZVJlcXVlc3QSGQoIdXNlcl9pZHMYASADKANSB3VzZXJJZHM=');

@$core.Deprecated('Use presenceSubscribeResponseDescriptor instead')
const PresenceSubscribeResponse$json = {
  '1': 'PresenceSubscribeResponse',
};

/// Descriptor for `PresenceSubscribeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List presenceSubscribeResponseDescriptor =
    $convert.base64Decode('ChlQcmVzZW5jZVN1YnNjcmliZVJlc3BvbnNl');
