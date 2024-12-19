// This is a generated file - do not edit.
//
// Generated from user.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use registerRequestDescriptor instead')
const RegisterRequest$json = {
  '1': 'RegisterRequest',
  '2': [
    {'1': 'mobile', '3': 1, '4': 1, '5': 9, '10': 'mobile'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `RegisterRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerRequestDescriptor = $convert.base64Decode(
    'Cg9SZWdpc3RlclJlcXVlc3QSFgoGbW9iaWxlGAEgASgJUgZtb2JpbGUSGgoIcGFzc3dvcmQYAi'
    'ABKAlSCHBhc3N3b3JkEhIKBG5hbWUYAyABKAlSBG5hbWU=');

@$core.Deprecated('Use registerResponseDescriptor instead')
const RegisterResponse$json = {
  '1': 'RegisterResponse',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'access_expire', '3': 2, '4': 1, '5': 3, '10': 'accessExpire'},
    {'1': 'refresh_token', '3': 3, '4': 1, '5': 3, '10': 'refreshToken'},
    {'1': 'users', '3': 4, '4': 3, '5': 11, '6': '.entity.User', '10': 'users'},
  ],
};

/// Descriptor for `RegisterResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerResponseDescriptor = $convert.base64Decode(
    'ChBSZWdpc3RlclJlc3BvbnNlEiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG9rZW4SIw'
    'oNYWNjZXNzX2V4cGlyZRgCIAEoA1IMYWNjZXNzRXhwaXJlEiMKDXJlZnJlc2hfdG9rZW4YAyAB'
    'KANSDHJlZnJlc2hUb2tlbhIiCgV1c2VycxgEIAMoCzIMLmVudGl0eS5Vc2VyUgV1c2Vycw==');

@$core.Deprecated('Use joinTenantRequestDescriptor instead')
const JoinTenantRequest$json = {
  '1': 'JoinTenantRequest',
};

/// Descriptor for `JoinTenantRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinTenantRequestDescriptor =
    $convert.base64Decode('ChFKb2luVGVuYW50UmVxdWVzdA==');

@$core.Deprecated('Use joinTenantResponseDescriptor instead')
const JoinTenantResponse$json = {
  '1': 'JoinTenantResponse',
};

/// Descriptor for `JoinTenantResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinTenantResponseDescriptor =
    $convert.base64Decode('ChJKb2luVGVuYW50UmVzcG9uc2U=');

@$core.Deprecated('Use createTenantRequestDescriptor instead')
const CreateTenantRequest$json = {
  '1': 'CreateTenantRequest',
};

/// Descriptor for `CreateTenantRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createTenantRequestDescriptor =
    $convert.base64Decode('ChNDcmVhdGVUZW5hbnRSZXF1ZXN0');

@$core.Deprecated('Use createTenantResponseDescriptor instead')
const CreateTenantResponse$json = {
  '1': 'CreateTenantResponse',
};

/// Descriptor for `CreateTenantResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createTenantResponseDescriptor =
    $convert.base64Decode('ChRDcmVhdGVUZW5hbnRSZXNwb25zZQ==');

@$core.Deprecated('Use createDepartmentRequestDescriptor instead')
const CreateDepartmentRequest$json = {
  '1': 'CreateDepartmentRequest',
};

/// Descriptor for `CreateDepartmentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createDepartmentRequestDescriptor =
    $convert.base64Decode('ChdDcmVhdGVEZXBhcnRtZW50UmVxdWVzdA==');

@$core.Deprecated('Use createDepartMentResponseDescriptor instead')
const CreateDepartMentResponse$json = {
  '1': 'CreateDepartMentResponse',
};

/// Descriptor for `CreateDepartMentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createDepartMentResponseDescriptor =
    $convert.base64Decode('ChhDcmVhdGVEZXBhcnRNZW50UmVzcG9uc2U=');

@$core.Deprecated('Use loginAccountRequestDescriptor instead')
const LoginAccountRequest$json = {
  '1': 'LoginAccountRequest',
  '2': [
    {'1': 'mobile', '3': 1, '4': 1, '5': 9, '10': 'mobile'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `LoginAccountRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginAccountRequestDescriptor = $convert.base64Decode(
    'ChNMb2dpbkFjY291bnRSZXF1ZXN0EhYKBm1vYmlsZRgBIAEoCVIGbW9iaWxlEhoKCHBhc3N3b3'
    'JkGAIgASgJUghwYXNzd29yZA==');

@$core.Deprecated('Use loginAccountResponseDescriptor instead')
const LoginAccountResponse$json = {
  '1': 'LoginAccountResponse',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'access_expire', '3': 2, '4': 1, '5': 3, '10': 'accessExpire'},
    {'1': 'refresh_token', '3': 3, '4': 1, '5': 3, '10': 'refreshToken'},
    {'1': 'users', '3': 4, '4': 3, '5': 11, '6': '.entity.User', '10': 'users'},
  ],
};

/// Descriptor for `LoginAccountResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginAccountResponseDescriptor = $convert.base64Decode(
    'ChRMb2dpbkFjY291bnRSZXNwb25zZRIhCgxhY2Nlc3NfdG9rZW4YASABKAlSC2FjY2Vzc1Rva2'
    'VuEiMKDWFjY2Vzc19leHBpcmUYAiABKANSDGFjY2Vzc0V4cGlyZRIjCg1yZWZyZXNoX3Rva2Vu'
    'GAMgASgDUgxyZWZyZXNoVG9rZW4SIgoFdXNlcnMYBCADKAsyDC5lbnRpdHkuVXNlclIFdXNlcn'
    'M=');

@$core.Deprecated('Use loginWsRequestDescriptor instead')
const LoginWsRequest$json = {
  '1': 'LoginWsRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'token', '3': 3, '4': 1, '5': 9, '10': 'token'},
    {'1': 'app_version', '3': 4, '4': 1, '5': 9, '10': 'appVersion'},
  ],
};

/// Descriptor for `LoginWsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginWsRequestDescriptor = $convert.base64Decode(
    'Cg5Mb2dpbldzUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgDUgZ1c2VySWQSGwoJZGV2aWNlX2lkGA'
    'IgASgJUghkZXZpY2VJZBIUCgV0b2tlbhgDIAEoCVIFdG9rZW4SHwoLYXBwX3ZlcnNpb24YBCAB'
    'KAlSCmFwcFZlcnNpb24=');

@$core.Deprecated('Use loginWsResponseDescriptor instead')
const LoginWsResponse$json = {
  '1': 'LoginWsResponse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'account_id', '3': 2, '4': 1, '5': 3, '10': 'accountId'},
    {'1': 'tenant_id', '3': 3, '4': 1, '5': 3, '10': 'tenantId'},
    {'1': 'user', '3': 4, '4': 1, '5': 11, '6': '.entity.User', '10': 'user'},
  ],
};

/// Descriptor for `LoginWsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginWsResponseDescriptor = $convert.base64Decode(
    'Cg9Mb2dpbldzUmVzcG9uc2USDgoCaWQYASABKANSAmlkEh0KCmFjY291bnRfaWQYAiABKANSCW'
    'FjY291bnRJZBIbCgl0ZW5hbnRfaWQYAyABKANSCHRlbmFudElkEiAKBHVzZXIYBCABKAsyDC5l'
    'bnRpdHkuVXNlclIEdXNlcg==');

@$core.Deprecated('Use refreshTokenRequestDescriptor instead')
const RefreshTokenRequest$json = {
  '1': 'RefreshTokenRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
  ],
};

/// Descriptor for `RefreshTokenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List refreshTokenRequestDescriptor =
    $convert.base64Decode(
        'ChNSZWZyZXNoVG9rZW5SZXF1ZXN0EhcKB3VzZXJfaWQYASABKANSBnVzZXJJZA==');

@$core.Deprecated('Use refreshTokenResponseDescriptor instead')
const RefreshTokenResponse$json = {
  '1': 'RefreshTokenResponse',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'access_expire', '3': 2, '4': 1, '5': 3, '10': 'accessExpire'},
    {'1': 'refresh_token', '3': 3, '4': 1, '5': 3, '10': 'refreshToken'},
    {'1': 'user', '3': 4, '4': 1, '5': 11, '6': '.entity.User', '10': 'user'},
  ],
};

/// Descriptor for `RefreshTokenResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List refreshTokenResponseDescriptor = $convert.base64Decode(
    'ChRSZWZyZXNoVG9rZW5SZXNwb25zZRIhCgxhY2Nlc3NfdG9rZW4YASABKAlSC2FjY2Vzc1Rva2'
    'VuEiMKDWFjY2Vzc19leHBpcmUYAiABKANSDGFjY2Vzc0V4cGlyZRIjCg1yZWZyZXNoX3Rva2Vu'
    'GAMgASgDUgxyZWZyZXNoVG9rZW4SIAoEdXNlchgEIAEoCzIMLmVudGl0eS5Vc2VyUgR1c2Vy');

@$core.Deprecated('Use generateTokenRequestDescriptor instead')
const GenerateTokenRequest$json = {
  '1': 'GenerateTokenRequest',
  '2': [
    {'1': 'userId', '3': 1, '4': 1, '5': 3, '10': 'userId'},
  ],
};

/// Descriptor for `GenerateTokenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateTokenRequestDescriptor =
    $convert.base64Decode(
        'ChRHZW5lcmF0ZVRva2VuUmVxdWVzdBIWCgZ1c2VySWQYASABKANSBnVzZXJJZA==');

@$core.Deprecated('Use generateTokenResponseDescriptor instead')
const GenerateTokenResponse$json = {
  '1': 'GenerateTokenResponse',
  '2': [
    {'1': 'accessToken', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'accessExpire', '3': 2, '4': 1, '5': 3, '10': 'accessExpire'},
    {'1': 'refreshAfter', '3': 3, '4': 1, '5': 3, '10': 'refreshAfter'},
  ],
};

/// Descriptor for `GenerateTokenResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateTokenResponseDescriptor = $convert.base64Decode(
    'ChVHZW5lcmF0ZVRva2VuUmVzcG9uc2USIAoLYWNjZXNzVG9rZW4YASABKAlSC2FjY2Vzc1Rva2'
    'VuEiIKDGFjY2Vzc0V4cGlyZRgCIAEoA1IMYWNjZXNzRXhwaXJlEiIKDHJlZnJlc2hBZnRlchgD'
    'IAEoA1IMcmVmcmVzaEFmdGVy');

@$core.Deprecated('Use getUserByIdsRequestDescriptor instead')
const GetUserByIdsRequest$json = {
  '1': 'GetUserByIdsRequest',
  '2': [
    {'1': 'ids', '3': 1, '4': 3, '5': 3, '10': 'ids'},
  ],
};

/// Descriptor for `GetUserByIdsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUserByIdsRequestDescriptor = $convert
    .base64Decode('ChNHZXRVc2VyQnlJZHNSZXF1ZXN0EhAKA2lkcxgBIAMoA1IDaWRz');

@$core.Deprecated('Use getUserByIdsResponseDescriptor instead')
const GetUserByIdsResponse$json = {
  '1': 'GetUserByIdsResponse',
  '2': [
    {'1': 'users', '3': 1, '4': 3, '5': 11, '6': '.entity.User', '10': 'users'},
  ],
};

/// Descriptor for `GetUserByIdsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUserByIdsResponseDescriptor = $convert.base64Decode(
    'ChRHZXRVc2VyQnlJZHNSZXNwb25zZRIiCgV1c2VycxgBIAMoCzIMLmVudGl0eS5Vc2VyUgV1c2'
    'Vycw==');

@$core.Deprecated('Use pushUserInfoRequestDescriptor instead')
const PushUserInfoRequest$json = {
  '1': 'PushUserInfoRequest',
  '2': [
    {'1': 'users', '3': 1, '4': 3, '5': 11, '6': '.entity.User', '10': 'users'},
  ],
};

/// Descriptor for `PushUserInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushUserInfoRequestDescriptor = $convert.base64Decode(
    'ChNQdXNoVXNlckluZm9SZXF1ZXN0EiIKBXVzZXJzGAEgAygLMgwuZW50aXR5LlVzZXJSBXVzZX'
    'Jz');
