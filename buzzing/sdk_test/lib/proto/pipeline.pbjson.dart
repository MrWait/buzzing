// This is a generated file - do not edit.
//
// Generated from pipeline.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use pullPipelineRequestDescriptor instead')
const PullPipelineRequest$json = {
  '1': 'PullPipelineRequest',
  '2': [
    {'1': 'sid', '3': 1, '4': 1, '5': 3, '10': 'sid'},
    {'1': 'count', '3': 2, '4': 1, '5': 5, '10': 'count'},
  ],
};

/// Descriptor for `PullPipelineRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pullPipelineRequestDescriptor = $convert.base64Decode(
    'ChNQdWxsUGlwZWxpbmVSZXF1ZXN0EhAKA3NpZBgBIAEoA1IDc2lkEhQKBWNvdW50GAIgASgFUg'
    'Vjb3VudA==');

@$core.Deprecated('Use pullPipelineResponseDescriptor instead')
const PullPipelineResponse$json = {
  '1': 'PullPipelineResponse',
  '2': [
    {'1': 'sid', '3': 1, '4': 1, '5': 3, '10': 'sid'},
    {
      '1': 'packets',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.entity.Packet',
      '10': 'packets'
    },
    {'1': 'has_more', '3': 3, '4': 1, '5': 8, '10': 'hasMore'},
  ],
};

/// Descriptor for `PullPipelineResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pullPipelineResponseDescriptor = $convert.base64Decode(
    'ChRQdWxsUGlwZWxpbmVSZXNwb25zZRIQCgNzaWQYASABKANSA3NpZBIoCgdwYWNrZXRzGAIgAy'
    'gLMg4uZW50aXR5LlBhY2tldFIHcGFja2V0cxIZCghoYXNfbW9yZRgDIAEoCFIHaGFzTW9yZQ==');

@$core.Deprecated('Use pushEntityChangedDescriptor instead')
const PushEntityChanged$json = {
  '1': 'PushEntityChanged',
  '2': [
    {
      '1': 'changes',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.entity.EntityChange',
      '10': 'changes'
    },
  ],
};

/// Descriptor for `PushEntityChanged`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushEntityChangedDescriptor = $convert.base64Decode(
    'ChFQdXNoRW50aXR5Q2hhbmdlZBIuCgdjaGFuZ2VzGAEgAygLMhQuZW50aXR5LkVudGl0eUNoYW'
    '5nZVIHY2hhbmdlcw==');

@$core.Deprecated('Use pullEntityRequestDescriptor instead')
const PullEntityRequest$json = {
  '1': 'PullEntityRequest',
  '2': [
    {'1': 'ids', '3': 1, '4': 3, '5': 11, '6': '.entity.EntityId', '10': 'ids'},
  ],
};

/// Descriptor for `PullEntityRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pullEntityRequestDescriptor = $convert.base64Decode(
    'ChFQdWxsRW50aXR5UmVxdWVzdBIiCgNpZHMYASADKAsyEC5lbnRpdHkuRW50aXR5SWRSA2lkcw'
    '==');

@$core.Deprecated('Use pullEntityResponseDescriptor instead')
const PullEntityResponse$json = {
  '1': 'PullEntityResponse',
  '2': [
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

/// Descriptor for `PullEntityResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pullEntityResponseDescriptor = $convert.base64Decode(
    'ChJQdWxsRW50aXR5UmVzcG9uc2USJgoGZW50aXR5GAIgASgLMg4uZW50aXR5LkVudGl0eVIGZW'
    '50aXR5');
