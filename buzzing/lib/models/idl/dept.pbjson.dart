// This is a generated file - do not edit.
//
// Generated from dept.proto.

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

@$core.Deprecated('Use getDeptRequestDescriptor instead')
const GetDeptRequest$json = {
  '1': 'GetDeptRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 3, '10': 'tenantId'},
    {'1': 'recursive', '3': 3, '4': 1, '5': 8, '10': 'recursive'},
  ],
};

/// Descriptor for `GetDeptRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDeptRequestDescriptor = $convert.base64Decode(
    'Cg5HZXREZXB0UmVxdWVzdBIOCgJpZBgBIAEoA1ICaWQSGwoJdGVuYW50X2lkGAIgASgDUgh0ZW'
    '5hbnRJZBIcCglyZWN1cnNpdmUYAyABKAhSCXJlY3Vyc2l2ZQ==');

@$core.Deprecated('Use getDeptResponseDescriptor instead')
const GetDeptResponse$json = {
  '1': 'GetDeptResponse',
  '2': [
    {
      '1': 'depts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.dept.GetDeptResponse.DeptsEntry',
      '10': 'depts'
    },
    {
      '1': 'users',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.dept.GetDeptResponse.UsersEntry',
      '10': 'users'
    },
  ],
  '3': [GetDeptResponse_DeptsEntry$json, GetDeptResponse_UsersEntry$json],
};

@$core.Deprecated('Use getDeptResponseDescriptor instead')
const GetDeptResponse_DeptsEntry$json = {
  '1': 'DeptsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 3, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.entity.Department',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use getDeptResponseDescriptor instead')
const GetDeptResponse_UsersEntry$json = {
  '1': 'UsersEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 3, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.entity.User', '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `GetDeptResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDeptResponseDescriptor = $convert.base64Decode(
    'Cg9HZXREZXB0UmVzcG9uc2USNgoFZGVwdHMYASADKAsyIC5kZXB0LkdldERlcHRSZXNwb25zZS'
    '5EZXB0c0VudHJ5UgVkZXB0cxI2CgV1c2VycxgCIAMoCzIgLmRlcHQuR2V0RGVwdFJlc3BvbnNl'
    'LlVzZXJzRW50cnlSBXVzZXJzGkwKCkRlcHRzRW50cnkSEAoDa2V5GAEgASgDUgNrZXkSKAoFdm'
    'FsdWUYAiABKAsyEi5lbnRpdHkuRGVwYXJ0bWVudFIFdmFsdWU6AjgBGkYKClVzZXJzRW50cnkS'
    'EAoDa2V5GAEgASgDUgNrZXkSIgoFdmFsdWUYAiABKAsyDC5lbnRpdHkuVXNlclIFdmFsdWU6Aj'
    'gB');
