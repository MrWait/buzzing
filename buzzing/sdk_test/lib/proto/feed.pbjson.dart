// This is a generated file - do not edit.
//
// Generated from feed.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use pullFeedListRequestDescriptor instead')
const PullFeedListRequest$json = {
  '1': 'PullFeedListRequest',
  '2': [
    {'1': 'cursor', '3': 1, '4': 1, '5': 3, '10': 'cursor'},
    {'1': 'count', '3': 2, '4': 1, '5': 5, '10': 'count'},
    {'1': 'prev_cursor', '3': 3, '4': 1, '5': 3, '10': 'prevCursor'},
  ],
};

/// Descriptor for `PullFeedListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pullFeedListRequestDescriptor = $convert.base64Decode(
    'ChNQdWxsRmVlZExpc3RSZXF1ZXN0EhYKBmN1cnNvchgBIAEoA1IGY3Vyc29yEhQKBWNvdW50GA'
    'IgASgFUgVjb3VudBIfCgtwcmV2X2N1cnNvchgDIAEoA1IKcHJldkN1cnNvcg==');

@$core.Deprecated('Use pullFeedListResponseDescriptor instead')
const PullFeedListResponse$json = {
  '1': 'PullFeedListResponse',
  '2': [
    {'1': 'cursor', '3': 1, '4': 1, '5': 3, '10': 'cursor'},
    {'1': 'has_more', '3': 2, '4': 1, '5': 8, '10': 'hasMore'},
    {
      '1': 'entity',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.entity.Entity',
      '10': 'entity'
    },
  ],
};

/// Descriptor for `PullFeedListResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pullFeedListResponseDescriptor = $convert.base64Decode(
    'ChRQdWxsRmVlZExpc3RSZXNwb25zZRIWCgZjdXJzb3IYASABKANSBmN1cnNvchIZCghoYXNfbW'
    '9yZRgCIAEoCFIHaGFzTW9yZRImCgZlbnRpdHkYBCABKAsyDi5lbnRpdHkuRW50aXR5UgZlbnRp'
    'dHk=');

@$core.Deprecated('Use pushFeedListDescriptor instead')
const PushFeedList$json = {
  '1': 'PushFeedList',
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

/// Descriptor for `PushFeedList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushFeedListDescriptor = $convert.base64Decode(
    'CgxQdXNoRmVlZExpc3QSJgoGZW50aXR5GAEgASgLMg4uZW50aXR5LkVudGl0eVIGZW50aXR5');

@$core.Deprecated('Use pullFeedByIdsRequestDescriptor instead')
const PullFeedByIdsRequest$json = {
  '1': 'PullFeedByIdsRequest',
  '2': [
    {'1': 'ids', '3': 1, '4': 3, '5': 3, '10': 'ids'},
  ],
};

/// Descriptor for `PullFeedByIdsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pullFeedByIdsRequestDescriptor = $convert
    .base64Decode('ChRQdWxsRmVlZEJ5SWRzUmVxdWVzdBIQCgNpZHMYASADKANSA2lkcw==');

@$core.Deprecated('Use pullFeedByIdsResponseDescriptor instead')
const PullFeedByIdsResponse$json = {
  '1': 'PullFeedByIdsResponse',
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

/// Descriptor for `PullFeedByIdsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pullFeedByIdsResponseDescriptor = $convert.base64Decode(
    'ChVQdWxsRmVlZEJ5SWRzUmVzcG9uc2USJgoGZW50aXR5GAEgASgLMg4uZW50aXR5LkVudGl0eV'
    'IGZW50aXR5');

@$core.Deprecated('Use removeFeedRequestDescriptor instead')
const RemoveFeedRequest$json = {
  '1': 'RemoveFeedRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
  ],
};

/// Descriptor for `RemoveFeedRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeFeedRequestDescriptor =
    $convert.base64Decode('ChFSZW1vdmVGZWVkUmVxdWVzdBIOCgJpZBgBIAEoA1ICaWQ=');

@$core.Deprecated('Use removeFeedResponseDescriptor instead')
const RemoveFeedResponse$json = {
  '1': 'RemoveFeedResponse',
};

/// Descriptor for `RemoveFeedResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeFeedResponseDescriptor =
    $convert.base64Decode('ChJSZW1vdmVGZWVkUmVzcG9uc2U=');

@$core.Deprecated('Use setFeedTopRequestDescriptor instead')
const SetFeedTopRequest$json = {
  '1': 'SetFeedTopRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'top', '3': 2, '4': 1, '5': 8, '10': 'top'},
  ],
};

/// Descriptor for `SetFeedTopRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setFeedTopRequestDescriptor = $convert.base64Decode(
    'ChFTZXRGZWVkVG9wUmVxdWVzdBIOCgJpZBgBIAEoA1ICaWQSEAoDdG9wGAIgASgIUgN0b3A=');

@$core.Deprecated('Use setFeedTopResponseDescriptor instead')
const SetFeedTopResponse$json = {
  '1': 'SetFeedTopResponse',
};

/// Descriptor for `SetFeedTopResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setFeedTopResponseDescriptor =
    $convert.base64Decode('ChJTZXRGZWVkVG9wUmVzcG9uc2U=');

@$core.Deprecated('Use setFeedMuteRequestDescriptor instead')
const SetFeedMuteRequest$json = {
  '1': 'SetFeedMuteRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'mute', '3': 2, '4': 1, '5': 8, '10': 'mute'},
  ],
};

/// Descriptor for `SetFeedMuteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setFeedMuteRequestDescriptor = $convert.base64Decode(
    'ChJTZXRGZWVkTXV0ZVJlcXVlc3QSDgoCaWQYASABKANSAmlkEhIKBG11dGUYAiABKAhSBG11dG'
    'U=');

@$core.Deprecated('Use setFeedMuteResponseDescriptor instead')
const SetFeedMuteResponse$json = {
  '1': 'SetFeedMuteResponse',
};

/// Descriptor for `SetFeedMuteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setFeedMuteResponseDescriptor =
    $convert.base64Decode('ChNTZXRGZWVkTXV0ZVJlc3BvbnNl');

@$core.Deprecated('Use getFeedTopListRequestDescriptor instead')
const GetFeedTopListRequest$json = {
  '1': 'GetFeedTopListRequest',
};

/// Descriptor for `GetFeedTopListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFeedTopListRequestDescriptor =
    $convert.base64Decode('ChVHZXRGZWVkVG9wTGlzdFJlcXVlc3Q=');

@$core.Deprecated('Use getFeedTopListResponseDescriptor instead')
const GetFeedTopListResponse$json = {
  '1': 'GetFeedTopListResponse',
  '2': [
    {'1': 'ids', '3': 1, '4': 3, '5': 3, '10': 'ids'},
    {'1': 'version', '3': 2, '4': 1, '5': 3, '10': 'version'},
    {
      '1': 'entity',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.entity.Entity',
      '10': 'entity'
    },
  ],
};

/// Descriptor for `GetFeedTopListResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFeedTopListResponseDescriptor = $convert.base64Decode(
    'ChZHZXRGZWVkVG9wTGlzdFJlc3BvbnNlEhAKA2lkcxgBIAMoA1IDaWRzEhgKB3ZlcnNpb24YAi'
    'ABKANSB3ZlcnNpb24SJgoGZW50aXR5GAMgASgLMg4uZW50aXR5LkVudGl0eVIGZW50aXR5');

@$core.Deprecated('Use activeFeedRequestDescriptor instead')
const ActiveFeedRequest$json = {
  '1': 'ActiveFeedRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
  ],
};

/// Descriptor for `ActiveFeedRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List activeFeedRequestDescriptor =
    $convert.base64Decode('ChFBY3RpdmVGZWVkUmVxdWVzdBIOCgJpZBgBIAEoA1ICaWQ=');

@$core.Deprecated('Use activeFeedResponseDescriptor instead')
const ActiveFeedResponse$json = {
  '1': 'ActiveFeedResponse',
};

/// Descriptor for `ActiveFeedResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List activeFeedResponseDescriptor =
    $convert.base64Decode('ChJBY3RpdmVGZWVkUmVzcG9uc2U=');
