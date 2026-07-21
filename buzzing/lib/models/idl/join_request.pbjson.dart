// This is a generated file - do not edit.
//
// Generated from join_request.proto.

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

@$core.Deprecated('Use joinRequestDescriptor instead')
const JoinRequest$json = {
  '1': 'JoinRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'chat_id', '3': 2, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'chat_name', '3': 3, '4': 1, '5': 9, '10': 'chatName'},
    {'1': 'user_id', '3': 4, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'user_name', '3': 5, '4': 1, '5': 9, '10': 'userName'},
    {'1': 'status', '3': 6, '4': 1, '5': 5, '10': 'status'},
    {'1': 'handler_id', '3': 7, '4': 1, '5': 3, '10': 'handlerId'},
    {'1': 'handled_at', '3': 8, '4': 1, '5': 3, '10': 'handledAt'},
    {'1': 'created_at', '3': 9, '4': 1, '5': 3, '10': 'createdAt'},
  ],
};

/// Descriptor for `JoinRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinRequestDescriptor = $convert.base64Decode(
    'CgtKb2luUmVxdWVzdBIOCgJpZBgBIAEoA1ICaWQSFwoHY2hhdF9pZBgCIAEoA1IGY2hhdElkEh'
    'sKCWNoYXRfbmFtZRgDIAEoCVIIY2hhdE5hbWUSFwoHdXNlcl9pZBgEIAEoA1IGdXNlcklkEhsK'
    'CXVzZXJfbmFtZRgFIAEoCVIIdXNlck5hbWUSFgoGc3RhdHVzGAYgASgFUgZzdGF0dXMSHQoKaG'
    'FuZGxlcl9pZBgHIAEoA1IJaGFuZGxlcklkEh0KCmhhbmRsZWRfYXQYCCABKANSCWhhbmRsZWRB'
    'dBIdCgpjcmVhdGVkX2F0GAkgASgDUgljcmVhdGVkQXQ=');

@$core.Deprecated('Use joinRequestCreateRequestDescriptor instead')
const JoinRequestCreateRequest$json = {
  '1': 'JoinRequestCreateRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
  ],
};

/// Descriptor for `JoinRequestCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinRequestCreateRequestDescriptor =
    $convert.base64Decode(
        'ChhKb2luUmVxdWVzdENyZWF0ZVJlcXVlc3QSFwoHY2hhdF9pZBgBIAEoA1IGY2hhdElk');

@$core.Deprecated('Use joinRequestCreateResponseDescriptor instead')
const JoinRequestCreateResponse$json = {
  '1': 'JoinRequestCreateResponse',
  '2': [
    {
      '1': 'request',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.join_request.JoinRequest',
      '10': 'request'
    },
    {
      '1': 'entities',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.entity.Entity',
      '10': 'entities'
    },
  ],
};

/// Descriptor for `JoinRequestCreateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinRequestCreateResponseDescriptor = $convert.base64Decode(
    'ChlKb2luUmVxdWVzdENyZWF0ZVJlc3BvbnNlEjMKB3JlcXVlc3QYASABKAsyGS5qb2luX3JlcX'
    'Vlc3QuSm9pblJlcXVlc3RSB3JlcXVlc3QSKgoIZW50aXRpZXMYAiABKAsyDi5lbnRpdHkuRW50'
    'aXR5UghlbnRpdGllcw==');

@$core.Deprecated('Use joinRequestApproveRequestDescriptor instead')
const JoinRequestApproveRequest$json = {
  '1': 'JoinRequestApproveRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 3, '10': 'requestId'},
  ],
};

/// Descriptor for `JoinRequestApproveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinRequestApproveRequestDescriptor =
    $convert.base64Decode(
        'ChlKb2luUmVxdWVzdEFwcHJvdmVSZXF1ZXN0Eh0KCnJlcXVlc3RfaWQYASABKANSCXJlcXVlc3'
        'RJZA==');

@$core.Deprecated('Use joinRequestApproveResponseDescriptor instead')
const JoinRequestApproveResponse$json = {
  '1': 'JoinRequestApproveResponse',
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

/// Descriptor for `JoinRequestApproveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinRequestApproveResponseDescriptor =
    $convert.base64Decode(
        'ChpKb2luUmVxdWVzdEFwcHJvdmVSZXNwb25zZRIqCghlbnRpdGllcxgBIAEoCzIOLmVudGl0eS'
        '5FbnRpdHlSCGVudGl0aWVz');

@$core.Deprecated('Use joinRequestRejectRequestDescriptor instead')
const JoinRequestRejectRequest$json = {
  '1': 'JoinRequestRejectRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 3, '10': 'requestId'},
  ],
};

/// Descriptor for `JoinRequestRejectRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinRequestRejectRequestDescriptor =
    $convert.base64Decode(
        'ChhKb2luUmVxdWVzdFJlamVjdFJlcXVlc3QSHQoKcmVxdWVzdF9pZBgBIAEoA1IJcmVxdWVzdE'
        'lk');

@$core.Deprecated('Use joinRequestRejectResponseDescriptor instead')
const JoinRequestRejectResponse$json = {
  '1': 'JoinRequestRejectResponse',
};

/// Descriptor for `JoinRequestRejectResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinRequestRejectResponseDescriptor =
    $convert.base64Decode('ChlKb2luUmVxdWVzdFJlamVjdFJlc3BvbnNl');

@$core.Deprecated('Use joinRequestListRequestDescriptor instead')
const JoinRequestListRequest$json = {
  '1': 'JoinRequestListRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'status', '3': 2, '4': 1, '5': 5, '10': 'status'},
    {'1': 'page', '3': 3, '4': 1, '5': 5, '10': 'page'},
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
  ],
};

/// Descriptor for `JoinRequestListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinRequestListRequestDescriptor = $convert.base64Decode(
    'ChZKb2luUmVxdWVzdExpc3RSZXF1ZXN0EhcKB2NoYXRfaWQYASABKANSBmNoYXRJZBIWCgZzdG'
    'F0dXMYAiABKAVSBnN0YXR1cxISCgRwYWdlGAMgASgFUgRwYWdlEhsKCXBhZ2Vfc2l6ZRgEIAEo'
    'BVIIcGFnZVNpemU=');

@$core.Deprecated('Use joinRequestListResponseDescriptor instead')
const JoinRequestListResponse$json = {
  '1': 'JoinRequestListResponse',
  '2': [
    {
      '1': 'requests',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.join_request.JoinRequest',
      '10': 'requests'
    },
    {'1': 'total', '3': 2, '4': 1, '5': 5, '10': 'total'},
  ],
};

/// Descriptor for `JoinRequestListResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinRequestListResponseDescriptor =
    $convert.base64Decode(
        'ChdKb2luUmVxdWVzdExpc3RSZXNwb25zZRI1CghyZXF1ZXN0cxgBIAMoCzIZLmpvaW5fcmVxdW'
        'VzdC5Kb2luUmVxdWVzdFIIcmVxdWVzdHMSFAoFdG90YWwYAiABKAVSBXRvdGFs');
