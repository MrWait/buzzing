// This is a generated file - do not edit.
//
// Generated from invite.proto.

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

@$core.Deprecated('Use inviteLinkDescriptor instead')
const InviteLink$json = {
  '1': 'InviteLink',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'chat_id', '3': 2, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'chat_name', '3': 3, '4': 1, '5': 9, '10': 'chatName'},
    {'1': 'code', '3': 4, '4': 1, '5': 9, '10': 'code'},
    {'1': 'created_by', '3': 5, '4': 1, '5': 3, '10': 'createdBy'},
    {'1': 'created_at', '3': 6, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'expires_at', '3': 7, '4': 1, '5': 3, '10': 'expiresAt'},
    {'1': 'max_uses', '3': 8, '4': 1, '5': 5, '10': 'maxUses'},
    {'1': 'use_count', '3': 9, '4': 1, '5': 5, '10': 'useCount'},
    {'1': 'is_active', '3': 10, '4': 1, '5': 8, '10': 'isActive'},
  ],
};

/// Descriptor for `InviteLink`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inviteLinkDescriptor = $convert.base64Decode(
    'CgpJbnZpdGVMaW5rEg4KAmlkGAEgASgDUgJpZBIXCgdjaGF0X2lkGAIgASgDUgZjaGF0SWQSGw'
    'oJY2hhdF9uYW1lGAMgASgJUghjaGF0TmFtZRISCgRjb2RlGAQgASgJUgRjb2RlEh0KCmNyZWF0'
    'ZWRfYnkYBSABKANSCWNyZWF0ZWRCeRIdCgpjcmVhdGVkX2F0GAYgASgDUgljcmVhdGVkQXQSHQ'
    'oKZXhwaXJlc19hdBgHIAEoA1IJZXhwaXJlc0F0EhkKCG1heF91c2VzGAggASgFUgdtYXhVc2Vz'
    'EhsKCXVzZV9jb3VudBgJIAEoBVIIdXNlQ291bnQSGwoJaXNfYWN0aXZlGAogASgIUghpc0FjdG'
    'l2ZQ==');

@$core.Deprecated('Use inviteLinkCreateRequestDescriptor instead')
const InviteLinkCreateRequest$json = {
  '1': 'InviteLinkCreateRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'expires_at', '3': 2, '4': 1, '5': 3, '10': 'expiresAt'},
    {'1': 'max_uses', '3': 3, '4': 1, '5': 5, '10': 'maxUses'},
  ],
};

/// Descriptor for `InviteLinkCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inviteLinkCreateRequestDescriptor = $convert.base64Decode(
    'ChdJbnZpdGVMaW5rQ3JlYXRlUmVxdWVzdBIXCgdjaGF0X2lkGAEgASgDUgZjaGF0SWQSHQoKZX'
    'hwaXJlc19hdBgCIAEoA1IJZXhwaXJlc0F0EhkKCG1heF91c2VzGAMgASgFUgdtYXhVc2Vz');

@$core.Deprecated('Use inviteLinkCreateResponseDescriptor instead')
const InviteLinkCreateResponse$json = {
  '1': 'InviteLinkCreateResponse',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 9, '10': 'code'},
    {'1': 'url', '3': 2, '4': 1, '5': 9, '10': 'url'},
  ],
};

/// Descriptor for `InviteLinkCreateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inviteLinkCreateResponseDescriptor =
    $convert.base64Decode(
        'ChhJbnZpdGVMaW5rQ3JlYXRlUmVzcG9uc2USEgoEY29kZRgBIAEoCVIEY29kZRIQCgN1cmwYAi'
        'ABKAlSA3VybA==');

@$core.Deprecated('Use inviteLinkJoinRequestDescriptor instead')
const InviteLinkJoinRequest$json = {
  '1': 'InviteLinkJoinRequest',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 9, '10': 'code'},
  ],
};

/// Descriptor for `InviteLinkJoinRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inviteLinkJoinRequestDescriptor =
    $convert.base64Decode(
        'ChVJbnZpdGVMaW5rSm9pblJlcXVlc3QSEgoEY29kZRgBIAEoCVIEY29kZQ==');

@$core.Deprecated('Use inviteLinkJoinResponseDescriptor instead')
const InviteLinkJoinResponse$json = {
  '1': 'InviteLinkJoinResponse',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'chat', '3': 2, '4': 1, '5': 11, '6': '.entity.Chat', '10': 'chat'},
  ],
};

/// Descriptor for `InviteLinkJoinResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inviteLinkJoinResponseDescriptor =
    $convert.base64Decode(
        'ChZJbnZpdGVMaW5rSm9pblJlc3BvbnNlEhcKB2NoYXRfaWQYASABKANSBmNoYXRJZBIgCgRjaG'
        'F0GAIgASgLMgwuZW50aXR5LkNoYXRSBGNoYXQ=');

@$core.Deprecated('Use inviteLinkRevokeRequestDescriptor instead')
const InviteLinkRevokeRequest$json = {
  '1': 'InviteLinkRevokeRequest',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 9, '10': 'code'},
  ],
};

/// Descriptor for `InviteLinkRevokeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inviteLinkRevokeRequestDescriptor =
    $convert.base64Decode(
        'ChdJbnZpdGVMaW5rUmV2b2tlUmVxdWVzdBISCgRjb2RlGAEgASgJUgRjb2Rl');

@$core.Deprecated('Use inviteLinkRevokeResponseDescriptor instead')
const InviteLinkRevokeResponse$json = {
  '1': 'InviteLinkRevokeResponse',
};

/// Descriptor for `InviteLinkRevokeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inviteLinkRevokeResponseDescriptor =
    $convert.base64Decode('ChhJbnZpdGVMaW5rUmV2b2tlUmVzcG9uc2U=');
