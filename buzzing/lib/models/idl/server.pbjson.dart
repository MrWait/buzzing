// This is a generated file - do not edit.
//
// Generated from server.proto.

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

@$core.Deprecated('Use pullPacketsBySidsRequestDescriptor instead')
const PullPacketsBySidsRequest$json = {
  '1': 'PullPacketsBySidsRequest',
  '2': [
    {'1': 'sids', '3': 1, '4': 1, '5': 9, '10': 'sids'},
  ],
};

/// Descriptor for `PullPacketsBySidsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pullPacketsBySidsRequestDescriptor =
    $convert.base64Decode(
        'ChhQdWxsUGFja2V0c0J5U2lkc1JlcXVlc3QSEgoEc2lkcxgBIAEoCVIEc2lkcw==');

@$core.Deprecated('Use pullPacketsBySidsResponseDescriptor instead')
const PullPacketsBySidsResponse$json = {
  '1': 'PullPacketsBySidsResponse',
  '2': [
    {
      '1': 'packets',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.server.PullPacketsBySidsResponse.PacketsEntry',
      '10': 'packets'
    },
  ],
  '3': [PullPacketsBySidsResponse_PacketsEntry$json],
};

@$core.Deprecated('Use pullPacketsBySidsResponseDescriptor instead')
const PullPacketsBySidsResponse_PacketsEntry$json = {
  '1': 'PacketsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.entity.Packet',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `PullPacketsBySidsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pullPacketsBySidsResponseDescriptor = $convert.base64Decode(
    'ChlQdWxsUGFja2V0c0J5U2lkc1Jlc3BvbnNlEkgKB3BhY2tldHMYASADKAsyLi5zZXJ2ZXIuUH'
    'VsbFBhY2tldHNCeVNpZHNSZXNwb25zZS5QYWNrZXRzRW50cnlSB3BhY2tldHMaSgoMUGFja2V0'
    'c0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EiQKBXZhbHVlGAIgASgLMg4uZW50aXR5LlBhY2tldF'
    'IFdmFsdWU6AjgB');

@$core.Deprecated('Use processMultiPacketsRequestDescriptor instead')
const ProcessMultiPacketsRequest$json = {
  '1': 'ProcessMultiPacketsRequest',
  '2': [
    {'1': 'packets', '3': 1, '4': 3, '5': 12, '10': 'packets'},
  ],
};

/// Descriptor for `ProcessMultiPacketsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List processMultiPacketsRequestDescriptor =
    $convert.base64Decode(
        'ChpQcm9jZXNzTXVsdGlQYWNrZXRzUmVxdWVzdBIYCgdwYWNrZXRzGAEgAygMUgdwYWNrZXRz');

@$core.Deprecated('Use processMultiPacketsResponseDescriptor instead')
const ProcessMultiPacketsResponse$json = {
  '1': 'ProcessMultiPacketsResponse',
  '2': [
    {'1': 'results', '3': 1, '4': 3, '5': 12, '10': 'results'},
    {
      '1': 'results_extension',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.server.ProcessMultiPacketsResponse.ResultsExtensionEntry',
      '10': 'resultsExtension'
    },
  ],
  '3': [ProcessMultiPacketsResponse_ResultsExtensionEntry$json],
};

@$core.Deprecated('Use processMultiPacketsResponseDescriptor instead')
const ProcessMultiPacketsResponse_ResultsExtensionEntry$json = {
  '1': 'ResultsExtensionEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.server.MultiPacketResultExt',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `ProcessMultiPacketsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List processMultiPacketsResponseDescriptor = $convert.base64Decode(
    'ChtQcm9jZXNzTXVsdGlQYWNrZXRzUmVzcG9uc2USGAoHcmVzdWx0cxgBIAMoDFIHcmVzdWx0cx'
    'JmChFyZXN1bHRzX2V4dGVuc2lvbhgCIAMoCzI5LnNlcnZlci5Qcm9jZXNzTXVsdGlQYWNrZXRz'
    'UmVzcG9uc2UuUmVzdWx0c0V4dGVuc2lvbkVudHJ5UhByZXN1bHRzRXh0ZW5zaW9uGmEKFVJlc3'
    'VsdHNFeHRlbnNpb25FbnRyeRIQCgNrZXkYASABKAVSA2tleRIyCgV2YWx1ZRgCIAEoCzIcLnNl'
    'cnZlci5NdWx0aVBhY2tldFJlc3VsdEV4dFIFdmFsdWU6AjgB');

@$core.Deprecated('Use multiPacketResultExtDescriptor instead')
const MultiPacketResultExt$json = {
  '1': 'MultiPacketResultExt',
  '2': [
    {'1': 'status_code', '3': 1, '4': 1, '5': 5, '10': 'statusCode'},
  ],
};

/// Descriptor for `MultiPacketResultExt`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List multiPacketResultExtDescriptor = $convert.base64Decode(
    'ChRNdWx0aVBhY2tldFJlc3VsdEV4dBIfCgtzdGF0dXNfY29kZRgBIAEoBVIKc3RhdHVzQ29kZQ'
    '==');

@$core.Deprecated('Use pullPacketsBySeqIdRequestDescriptor instead')
const PullPacketsBySeqIdRequest$json = {
  '1': 'PullPacketsBySeqIdRequest',
  '2': [
    {'1': 'sid', '3': 1, '4': 1, '5': 9, '10': 'sid'},
    {'1': 'count', '3': 2, '4': 1, '5': 13, '10': 'count'},
    {'1': 'version', '3': 3, '4': 1, '5': 13, '10': 'version'},
    {
      '1': 'frontier_downgrade',
      '3': 4,
      '4': 1,
      '5': 8,
      '10': 'frontierDowngrade'
    },
    {'1': 'batch_uniq_id', '3': 5, '4': 1, '5': 9, '10': 'batchUniqId'},
    {'1': 'batch_index', '3': 6, '4': 1, '5': 3, '10': 'batchIndex'},
  ],
};

/// Descriptor for `PullPacketsBySeqIdRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pullPacketsBySeqIdRequestDescriptor = $convert.base64Decode(
    'ChlQdWxsUGFja2V0c0J5U2VxSWRSZXF1ZXN0EhAKA3NpZBgBIAEoCVIDc2lkEhQKBWNvdW50GA'
    'IgASgNUgVjb3VudBIYCgd2ZXJzaW9uGAMgASgNUgd2ZXJzaW9uEi0KEmZyb250aWVyX2Rvd25n'
    'cmFkZRgEIAEoCFIRZnJvbnRpZXJEb3duZ3JhZGUSIgoNYmF0Y2hfdW5pcV9pZBgFIAEoCVILYm'
    'F0Y2hVbmlxSWQSHwoLYmF0Y2hfaW5kZXgYBiABKANSCmJhdGNoSW5kZXg=');

@$core.Deprecated('Use pullPacketsBySeqIdResponseDescriptor instead')
const PullPacketsBySeqIdResponse$json = {
  '1': 'PullPacketsBySeqIdResponse',
  '2': [
    {'1': 'has_more', '3': 1, '4': 1, '5': 8, '10': 'hasMore'},
    {
      '1': 'packets',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.entity.Packet',
      '10': 'packets'
    },
    {
      '1': 'last_packet_create_time',
      '3': 3,
      '4': 1,
      '5': 3,
      '10': 'lastPacketCreateTime'
    },
    {'1': 'last_sid', '3': 4, '4': 1, '5': 9, '10': 'lastSid'},
    {'1': 'response_time', '3': 5, '4': 1, '5': 3, '10': 'responseTime'},
    {'1': 'max_batch_index', '3': 6, '4': 1, '5': 3, '10': 'maxBatchIndex'},
  ],
};

/// Descriptor for `PullPacketsBySeqIdResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pullPacketsBySeqIdResponseDescriptor = $convert.base64Decode(
    'ChpQdWxsUGFja2V0c0J5U2VxSWRSZXNwb25zZRIZCghoYXNfbW9yZRgBIAEoCFIHaGFzTW9yZR'
    'IoCgdwYWNrZXRzGAIgAygLMg4uZW50aXR5LlBhY2tldFIHcGFja2V0cxI1ChdsYXN0X3BhY2tl'
    'dF9jcmVhdGVfdGltZRgDIAEoA1IUbGFzdFBhY2tldENyZWF0ZVRpbWUSGQoIbGFzdF9zaWQYBC'
    'ABKAlSB2xhc3RTaWQSIwoNcmVzcG9uc2VfdGltZRgFIAEoA1IMcmVzcG9uc2VUaW1lEiYKD21h'
    'eF9iYXRjaF9pbmRleBgGIAEoA1INbWF4QmF0Y2hJbmRleA==');
