// This is a generated file - do not edit.
//
// Generated from setting.proto.

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

@$core.Deprecated('Use getAllSettingsRequestDescriptor instead')
const GetAllSettingsRequest$json = {
  '1': 'GetAllSettingsRequest',
};

/// Descriptor for `GetAllSettingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAllSettingsRequestDescriptor =
    $convert.base64Decode('ChVHZXRBbGxTZXR0aW5nc1JlcXVlc3Q=');

@$core.Deprecated('Use getAllSettingsResponseDescriptor instead')
const GetAllSettingsResponse$json = {
  '1': 'GetAllSettingsResponse',
  '2': [
    {
      '1': 'settings',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.entity.Settings',
      '10': 'settings'
    },
  ],
};

/// Descriptor for `GetAllSettingsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAllSettingsResponseDescriptor =
    $convert.base64Decode(
        'ChZHZXRBbGxTZXR0aW5nc1Jlc3BvbnNlEiwKCHNldHRpbmdzGAEgASgLMhAuZW50aXR5LlNldH'
        'RpbmdzUghzZXR0aW5ncw==');

@$core.Deprecated('Use getSettingByTypeRequestDescriptor instead')
const GetSettingByTypeRequest$json = {
  '1': 'GetSettingByTypeRequest',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
  ],
};

/// Descriptor for `GetSettingByTypeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSettingByTypeRequestDescriptor =
    $convert.base64Decode(
        'ChdHZXRTZXR0aW5nQnlUeXBlUmVxdWVzdBISCgR0eXBlGAEgASgFUgR0eXBl');

@$core.Deprecated('Use getSettingByTypeResponseDescriptor instead')
const GetSettingByTypeResponse$json = {
  '1': 'GetSettingByTypeResponse',
  '2': [
    {
      '1': 'setting',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.entity.Setting',
      '10': 'setting'
    },
  ],
};

/// Descriptor for `GetSettingByTypeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSettingByTypeResponseDescriptor =
    $convert.base64Decode(
        'ChhHZXRTZXR0aW5nQnlUeXBlUmVzcG9uc2USKQoHc2V0dGluZxgBIAEoCzIPLmVudGl0eS5TZX'
        'R0aW5nUgdzZXR0aW5n');

@$core.Deprecated('Use getSettingByVersionRequestDescriptor instead')
const GetSettingByVersionRequest$json = {
  '1': 'GetSettingByVersionRequest',
  '2': [
    {'1': 'version', '3': 1, '4': 1, '5': 3, '10': 'version'},
  ],
};

/// Descriptor for `GetSettingByVersionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSettingByVersionRequestDescriptor =
    $convert.base64Decode(
        'ChpHZXRTZXR0aW5nQnlWZXJzaW9uUmVxdWVzdBIYCgd2ZXJzaW9uGAEgASgDUgd2ZXJzaW9u');

@$core.Deprecated('Use getSettingByVersionResponseDescriptor instead')
const GetSettingByVersionResponse$json = {
  '1': 'GetSettingByVersionResponse',
  '2': [
    {
      '1': 'settings',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.entity.Setting',
      '10': 'settings'
    },
  ],
};

/// Descriptor for `GetSettingByVersionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSettingByVersionResponseDescriptor =
    $convert.base64Decode(
        'ChtHZXRTZXR0aW5nQnlWZXJzaW9uUmVzcG9uc2USKwoIc2V0dGluZ3MYASABKAsyDy5lbnRpdH'
        'kuU2V0dGluZ1IIc2V0dGluZ3M=');

@$core.Deprecated('Use pushSettingsRequestDescriptor instead')
const PushSettingsRequest$json = {
  '1': 'PushSettingsRequest',
  '2': [
    {
      '1': 'settings',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.entity.Settings',
      '10': 'settings'
    },
  ],
};

/// Descriptor for `PushSettingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushSettingsRequestDescriptor = $convert.base64Decode(
    'ChNQdXNoU2V0dGluZ3NSZXF1ZXN0EiwKCHNldHRpbmdzGAEgASgLMhAuZW50aXR5LlNldHRpbm'
    'dzUghzZXR0aW5ncw==');

@$core.Deprecated('Use updateSettingRequestDescriptor instead')
const UpdateSettingRequest$json = {
  '1': 'UpdateSettingRequest',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
    {'1': 'value', '3': 2, '4': 1, '5': 12, '10': 'value'},
  ],
};

/// Descriptor for `UpdateSettingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateSettingRequestDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVTZXR0aW5nUmVxdWVzdBISCgR0eXBlGAEgASgFUgR0eXBlEhQKBXZhbHVlGAIgAS'
    'gMUgV2YWx1ZQ==');

@$core.Deprecated('Use updateSettingResponseDescriptor instead')
const UpdateSettingResponse$json = {
  '1': 'UpdateSettingResponse',
};

/// Descriptor for `UpdateSettingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateSettingResponseDescriptor =
    $convert.base64Decode('ChVVcGRhdGVTZXR0aW5nUmVzcG9uc2U=');
