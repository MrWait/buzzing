// This is a generated file - do not edit.
//
// Generated from gateway.proto.

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

@$core.Deprecated('Use rpcRequestDescriptor instead')
const RpcRequest$json = {
  '1': 'RpcRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `RpcRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rpcRequestDescriptor =
    $convert.base64Decode('CgpScGNSZXF1ZXN0EhIKBG5hbWUYASABKAlSBG5hbWU=');

@$core.Deprecated('Use rpcResponseDescriptor instead')
const RpcResponse$json = {
  '1': 'RpcResponse',
  '2': [
    {'1': 'msg', '3': 1, '4': 1, '5': 9, '10': 'msg'},
  ],
};

/// Descriptor for `RpcResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rpcResponseDescriptor =
    $convert.base64Decode('CgtScGNSZXNwb25zZRIQCgNtc2cYASABKAlSA21zZw==');

@$core.Deprecated('Use gatewayInvokeRequestDescriptor instead')
const GatewayInvokeRequest$json = {
  '1': 'GatewayInvokeRequest',
  '2': [
    {'1': 'req', '3': 1, '4': 1, '5': 11, '6': '.entity.Packet', '10': 'req'},
  ],
};

/// Descriptor for `GatewayInvokeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gatewayInvokeRequestDescriptor = $convert.base64Decode(
    'ChRHYXRld2F5SW52b2tlUmVxdWVzdBIgCgNyZXEYASABKAsyDi5lbnRpdHkuUGFja2V0UgNyZX'
    'E=');

@$core.Deprecated('Use gatewayInvokeResponseDescriptor instead')
const GatewayInvokeResponse$json = {
  '1': 'GatewayInvokeResponse',
  '2': [
    {'1': 'res', '3': 1, '4': 1, '5': 11, '6': '.entity.Packet', '10': 'res'},
  ],
};

/// Descriptor for `GatewayInvokeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gatewayInvokeResponseDescriptor = $convert.base64Decode(
    'ChVHYXRld2F5SW52b2tlUmVzcG9uc2USIAoDcmVzGAEgASgLMg4uZW50aXR5LlBhY2tldFIDcm'
    'Vz');
