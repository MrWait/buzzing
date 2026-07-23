// This is a generated file - do not edit.
//
// Generated from translate.proto.

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

@$core.Deprecated('Use translateMessageRequestDescriptor instead')
const TranslateMessageRequest$json = {
  '1': 'TranslateMessageRequest',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 3, '10': 'messageId'},
    {'1': 'chat_id', '3': 2, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'target_lang', '3': 3, '4': 1, '5': 9, '10': 'targetLang'},
  ],
};

/// Descriptor for `TranslateMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List translateMessageRequestDescriptor = $convert.base64Decode(
    'ChdUcmFuc2xhdGVNZXNzYWdlUmVxdWVzdBIdCgptZXNzYWdlX2lkGAEgASgDUgltZXNzYWdlSW'
    'QSFwoHY2hhdF9pZBgCIAEoA1IGY2hhdElkEh8KC3RhcmdldF9sYW5nGAMgASgJUgp0YXJnZXRM'
    'YW5n');

@$core.Deprecated('Use translateMessageResponseDescriptor instead')
const TranslateMessageResponse$json = {
  '1': 'TranslateMessageResponse',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 3, '10': 'messageId'},
    {'1': 'original_text', '3': 2, '4': 1, '5': 9, '10': 'originalText'},
    {'1': 'translated_text', '3': 3, '4': 1, '5': 9, '10': 'translatedText'},
    {'1': 'target_lang', '3': 4, '4': 1, '5': 9, '10': 'targetLang'},
    {'1': 'source_lang', '3': 5, '4': 1, '5': 9, '10': 'sourceLang'},
  ],
};

/// Descriptor for `TranslateMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List translateMessageResponseDescriptor = $convert.base64Decode(
    'ChhUcmFuc2xhdGVNZXNzYWdlUmVzcG9uc2USHQoKbWVzc2FnZV9pZBgBIAEoA1IJbWVzc2FnZU'
    'lkEiMKDW9yaWdpbmFsX3RleHQYAiABKAlSDG9yaWdpbmFsVGV4dBInCg90cmFuc2xhdGVkX3Rl'
    'eHQYAyABKAlSDnRyYW5zbGF0ZWRUZXh0Eh8KC3RhcmdldF9sYW5nGAQgASgJUgp0YXJnZXRMYW'
    '5nEh8KC3NvdXJjZV9sYW5nGAUgASgJUgpzb3VyY2VMYW5n');

@$core.Deprecated('Use getTranslationLanguagesRequestDescriptor instead')
const GetTranslationLanguagesRequest$json = {
  '1': 'GetTranslationLanguagesRequest',
};

/// Descriptor for `GetTranslationLanguagesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTranslationLanguagesRequestDescriptor =
    $convert.base64Decode('Ch5HZXRUcmFuc2xhdGlvbkxhbmd1YWdlc1JlcXVlc3Q=');

@$core.Deprecated('Use getTranslationLanguagesResponseDescriptor instead')
const GetTranslationLanguagesResponse$json = {
  '1': 'GetTranslationLanguagesResponse',
  '2': [
    {
      '1': 'languages',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.translate.TranslateLanguage',
      '10': 'languages'
    },
  ],
};

/// Descriptor for `GetTranslationLanguagesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTranslationLanguagesResponseDescriptor =
    $convert.base64Decode(
        'Ch9HZXRUcmFuc2xhdGlvbkxhbmd1YWdlc1Jlc3BvbnNlEjoKCWxhbmd1YWdlcxgBIAMoCzIcLn'
        'RyYW5zbGF0ZS5UcmFuc2xhdGVMYW5ndWFnZVIJbGFuZ3VhZ2Vz');

@$core.Deprecated('Use translateLanguageDescriptor instead')
const TranslateLanguage$json = {
  '1': 'TranslateLanguage',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 9, '10': 'code'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `TranslateLanguage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List translateLanguageDescriptor = $convert.base64Decode(
    'ChFUcmFuc2xhdGVMYW5ndWFnZRISCgRjb2RlGAEgASgJUgRjb2RlEhIKBG5hbWUYAiABKAlSBG'
    '5hbWU=');
