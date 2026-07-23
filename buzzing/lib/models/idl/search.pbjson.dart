// This is a generated file - do not edit.
//
// Generated from search.proto.

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

@$core.Deprecated('Use searchFilterDescriptor instead')
const SearchFilter$json = {
  '1': 'SearchFilter',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'from_id', '3': 2, '4': 1, '5': 3, '10': 'fromId'},
    {'1': 'msg_type', '3': 3, '4': 1, '5': 5, '10': 'msgType'},
    {'1': 'time_start_ms', '3': 4, '4': 1, '5': 3, '10': 'timeStartMs'},
    {'1': 'time_end_ms', '3': 5, '4': 1, '5': 3, '10': 'timeEndMs'},
  ],
};

/// Descriptor for `SearchFilter`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchFilterDescriptor = $convert.base64Decode(
    'CgxTZWFyY2hGaWx0ZXISFwoHY2hhdF9pZBgBIAEoA1IGY2hhdElkEhcKB2Zyb21faWQYAiABKA'
    'NSBmZyb21JZBIZCghtc2dfdHlwZRgDIAEoBVIHbXNnVHlwZRIiCg10aW1lX3N0YXJ0X21zGAQg'
    'ASgDUgt0aW1lU3RhcnRNcxIeCgt0aW1lX2VuZF9tcxgFIAEoA1IJdGltZUVuZE1z');

@$core.Deprecated('Use searchRequestDescriptor instead')
const SearchRequest$json = {
  '1': 'SearchRequest',
  '2': [
    {'1': 'keyword', '3': 1, '4': 1, '5': 9, '10': 'keyword'},
    {'1': 'page', '3': 2, '4': 1, '5': 5, '10': 'page'},
    {'1': 'page_size', '3': 3, '4': 1, '5': 5, '10': 'pageSize'},
    {
      '1': 'filter',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.search.SearchFilter',
      '10': 'filter'
    },
  ],
};

/// Descriptor for `SearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchRequestDescriptor = $convert.base64Decode(
    'Cg1TZWFyY2hSZXF1ZXN0EhgKB2tleXdvcmQYASABKAlSB2tleXdvcmQSEgoEcGFnZRgCIAEoBV'
    'IEcGFnZRIbCglwYWdlX3NpemUYAyABKAVSCHBhZ2VTaXplEiwKBmZpbHRlchgEIAEoCzIULnNl'
    'YXJjaC5TZWFyY2hGaWx0ZXJSBmZpbHRlcg==');

@$core.Deprecated('Use messageSearchResultDescriptor instead')
const MessageSearchResult$json = {
  '1': 'MessageSearchResult',
  '2': [
    {
      '1': 'message',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.entity.Message',
      '10': 'message'
    },
    {'1': 'highlight', '3': 2, '4': 1, '5': 9, '10': 'highlight'},
  ],
};

/// Descriptor for `MessageSearchResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageSearchResultDescriptor = $convert.base64Decode(
    'ChNNZXNzYWdlU2VhcmNoUmVzdWx0EikKB21lc3NhZ2UYASABKAsyDy5lbnRpdHkuTWVzc2FnZV'
    'IHbWVzc2FnZRIcCgloaWdobGlnaHQYAiABKAlSCWhpZ2hsaWdodA==');

@$core.Deprecated('Use searchMessagesResponseDescriptor instead')
const SearchMessagesResponse$json = {
  '1': 'SearchMessagesResponse',
  '2': [
    {
      '1': 'results',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.search.MessageSearchResult',
      '10': 'results'
    },
    {'1': 'total', '3': 2, '4': 1, '5': 5, '10': 'total'},
  ],
};

/// Descriptor for `SearchMessagesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchMessagesResponseDescriptor =
    $convert.base64Decode(
        'ChZTZWFyY2hNZXNzYWdlc1Jlc3BvbnNlEjUKB3Jlc3VsdHMYASADKAsyGy5zZWFyY2guTWVzc2'
        'FnZVNlYXJjaFJlc3VsdFIHcmVzdWx0cxIUCgV0b3RhbBgCIAEoBVIFdG90YWw=');

@$core.Deprecated('Use chatSearchResultDescriptor instead')
const ChatSearchResult$json = {
  '1': 'ChatSearchResult',
  '2': [
    {'1': 'chat', '3': 1, '4': 1, '5': 11, '6': '.entity.Chat', '10': 'chat'},
    {'1': 'highlight', '3': 2, '4': 1, '5': 9, '10': 'highlight'},
  ],
};

/// Descriptor for `ChatSearchResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatSearchResultDescriptor = $convert.base64Decode(
    'ChBDaGF0U2VhcmNoUmVzdWx0EiAKBGNoYXQYASABKAsyDC5lbnRpdHkuQ2hhdFIEY2hhdBIcCg'
    'loaWdobGlnaHQYAiABKAlSCWhpZ2hsaWdodA==');

@$core.Deprecated('Use searchChatsResponseDescriptor instead')
const SearchChatsResponse$json = {
  '1': 'SearchChatsResponse',
  '2': [
    {
      '1': 'results',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.search.ChatSearchResult',
      '10': 'results'
    },
    {'1': 'total', '3': 2, '4': 1, '5': 5, '10': 'total'},
  ],
};

/// Descriptor for `SearchChatsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchChatsResponseDescriptor = $convert.base64Decode(
    'ChNTZWFyY2hDaGF0c1Jlc3BvbnNlEjIKB3Jlc3VsdHMYASADKAsyGC5zZWFyY2guQ2hhdFNlYX'
    'JjaFJlc3VsdFIHcmVzdWx0cxIUCgV0b3RhbBgCIAEoBVIFdG90YWw=');

@$core.Deprecated('Use userSearchResultDescriptor instead')
const UserSearchResult$json = {
  '1': 'UserSearchResult',
  '2': [
    {'1': 'user', '3': 1, '4': 1, '5': 11, '6': '.entity.User', '10': 'user'},
    {'1': 'highlight', '3': 2, '4': 1, '5': 9, '10': 'highlight'},
  ],
};

/// Descriptor for `UserSearchResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userSearchResultDescriptor = $convert.base64Decode(
    'ChBVc2VyU2VhcmNoUmVzdWx0EiAKBHVzZXIYASABKAsyDC5lbnRpdHkuVXNlclIEdXNlchIcCg'
    'loaWdobGlnaHQYAiABKAlSCWhpZ2hsaWdodA==');

@$core.Deprecated('Use searchUsersResponseDescriptor instead')
const SearchUsersResponse$json = {
  '1': 'SearchUsersResponse',
  '2': [
    {
      '1': 'results',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.search.UserSearchResult',
      '10': 'results'
    },
    {'1': 'total', '3': 2, '4': 1, '5': 5, '10': 'total'},
  ],
};

/// Descriptor for `SearchUsersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchUsersResponseDescriptor = $convert.base64Decode(
    'ChNTZWFyY2hVc2Vyc1Jlc3BvbnNlEjIKB3Jlc3VsdHMYASADKAsyGC5zZWFyY2guVXNlclNlYX'
    'JjaFJlc3VsdFIHcmVzdWx0cxIUCgV0b3RhbBgCIAEoBVIFdG90YWw=');

@$core.Deprecated('Use fileSearchResultDescriptor instead')
const FileSearchResult$json = {
  '1': 'FileSearchResult',
  '2': [
    {'1': 'file_id', '3': 1, '4': 1, '5': 9, '10': 'fileId'},
    {'1': 'file_name', '3': 2, '4': 1, '5': 9, '10': 'fileName'},
    {'1': 'mime_type', '3': 3, '4': 1, '5': 9, '10': 'mimeType'},
    {'1': 'size', '3': 4, '4': 1, '5': 3, '10': 'size'},
    {'1': 'url', '3': 5, '4': 1, '5': 9, '10': 'url'},
    {'1': 'highlight', '3': 6, '4': 1, '5': 9, '10': 'highlight'},
    {'1': 'created_at_ms', '3': 7, '4': 1, '5': 3, '10': 'createdAtMs'},
    {'1': 'uploader_id', '3': 8, '4': 1, '5': 3, '10': 'uploaderId'},
  ],
};

/// Descriptor for `FileSearchResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileSearchResultDescriptor = $convert.base64Decode(
    'ChBGaWxlU2VhcmNoUmVzdWx0EhcKB2ZpbGVfaWQYASABKAlSBmZpbGVJZBIbCglmaWxlX25hbW'
    'UYAiABKAlSCGZpbGVOYW1lEhsKCW1pbWVfdHlwZRgDIAEoCVIIbWltZVR5cGUSEgoEc2l6ZRgE'
    'IAEoA1IEc2l6ZRIQCgN1cmwYBSABKAlSA3VybBIcCgloaWdobGlnaHQYBiABKAlSCWhpZ2hsaW'
    'dodBIiCg1jcmVhdGVkX2F0X21zGAcgASgDUgtjcmVhdGVkQXRNcxIfCgt1cGxvYWRlcl9pZBgI'
    'IAEoA1IKdXBsb2FkZXJJZA==');

@$core.Deprecated('Use searchFilesResponseDescriptor instead')
const SearchFilesResponse$json = {
  '1': 'SearchFilesResponse',
  '2': [
    {
      '1': 'results',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.search.FileSearchResult',
      '10': 'results'
    },
    {'1': 'total', '3': 2, '4': 1, '5': 5, '10': 'total'},
  ],
};

/// Descriptor for `SearchFilesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchFilesResponseDescriptor = $convert.base64Decode(
    'ChNTZWFyY2hGaWxlc1Jlc3BvbnNlEjIKB3Jlc3VsdHMYASADKAsyGC5zZWFyY2guRmlsZVNlYX'
    'JjaFJlc3VsdFIHcmVzdWx0cxIUCgV0b3RhbBgCIAEoBVIFdG90YWw=');

@$core.Deprecated('Use globalSearchRequestDescriptor instead')
const GlobalSearchRequest$json = {
  '1': 'GlobalSearchRequest',
  '2': [
    {'1': 'keyword', '3': 1, '4': 1, '5': 9, '10': 'keyword'},
    {'1': 'page', '3': 2, '4': 1, '5': 5, '10': 'page'},
    {'1': 'page_size', '3': 3, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'types', '3': 4, '4': 3, '5': 9, '10': 'types'},
  ],
};

/// Descriptor for `GlobalSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List globalSearchRequestDescriptor = $convert.base64Decode(
    'ChNHbG9iYWxTZWFyY2hSZXF1ZXN0EhgKB2tleXdvcmQYASABKAlSB2tleXdvcmQSEgoEcGFnZR'
    'gCIAEoBVIEcGFnZRIbCglwYWdlX3NpemUYAyABKAVSCHBhZ2VTaXplEhQKBXR5cGVzGAQgAygJ'
    'UgV0eXBlcw==');

@$core.Deprecated('Use globalSearchResponseDescriptor instead')
const GlobalSearchResponse$json = {
  '1': 'GlobalSearchResponse',
  '2': [
    {
      '1': 'messages',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.search.MessageSearchResult',
      '10': 'messages'
    },
    {
      '1': 'chats',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.search.ChatSearchResult',
      '10': 'chats'
    },
    {
      '1': 'users',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.search.UserSearchResult',
      '10': 'users'
    },
    {
      '1': 'files',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.search.FileSearchResult',
      '10': 'files'
    },
    {'1': 'message_total', '3': 5, '4': 1, '5': 5, '10': 'messageTotal'},
    {'1': 'chat_total', '3': 6, '4': 1, '5': 5, '10': 'chatTotal'},
    {'1': 'user_total', '3': 7, '4': 1, '5': 5, '10': 'userTotal'},
    {'1': 'file_total', '3': 8, '4': 1, '5': 5, '10': 'fileTotal'},
  ],
};

/// Descriptor for `GlobalSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List globalSearchResponseDescriptor = $convert.base64Decode(
    'ChRHbG9iYWxTZWFyY2hSZXNwb25zZRI3CghtZXNzYWdlcxgBIAMoCzIbLnNlYXJjaC5NZXNzYW'
    'dlU2VhcmNoUmVzdWx0UghtZXNzYWdlcxIuCgVjaGF0cxgCIAMoCzIYLnNlYXJjaC5DaGF0U2Vh'
    'cmNoUmVzdWx0UgVjaGF0cxIuCgV1c2VycxgDIAMoCzIYLnNlYXJjaC5Vc2VyU2VhcmNoUmVzdW'
    'x0UgV1c2VycxIuCgVmaWxlcxgEIAMoCzIYLnNlYXJjaC5GaWxlU2VhcmNoUmVzdWx0UgVmaWxl'
    'cxIjCg1tZXNzYWdlX3RvdGFsGAUgASgFUgxtZXNzYWdlVG90YWwSHQoKY2hhdF90b3RhbBgGIA'
    'EoBVIJY2hhdFRvdGFsEh0KCnVzZXJfdG90YWwYByABKAVSCXVzZXJUb3RhbBIdCgpmaWxlX3Rv'
    'dGFsGAggASgFUglmaWxlVG90YWw=');
