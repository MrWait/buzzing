// This is a generated file - do not edit.
//
// Generated from calendar.proto.

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

@$core.Deprecated('Use calendarGetListRequestDescriptor instead')
const CalendarGetListRequest$json = {
  '1': 'CalendarGetListRequest',
};

/// Descriptor for `CalendarGetListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarGetListRequestDescriptor =
    $convert.base64Decode('ChZDYWxlbmRhckdldExpc3RSZXF1ZXN0');

@$core.Deprecated('Use calendarGetListResponseDescriptor instead')
const CalendarGetListResponse$json = {
  '1': 'CalendarGetListResponse',
  '2': [
    {
      '1': 'calendars',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.entity.Calendar',
      '10': 'calendars'
    },
  ],
};

/// Descriptor for `CalendarGetListResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarGetListResponseDescriptor =
    $convert.base64Decode(
        'ChdDYWxlbmRhckdldExpc3RSZXNwb25zZRIuCgljYWxlbmRhcnMYASADKAsyEC5lbnRpdHkuQ2'
        'FsZW5kYXJSCWNhbGVuZGFycw==');

@$core.Deprecated('Use calendarCreateRequestDescriptor instead')
const CalendarCreateRequest$json = {
  '1': 'CalendarCreateRequest',
  '2': [
    {
      '1': 'calendar',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.entity.Calendar',
      '10': 'calendar'
    },
  ],
};

/// Descriptor for `CalendarCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarCreateRequestDescriptor = $convert.base64Decode(
    'ChVDYWxlbmRhckNyZWF0ZVJlcXVlc3QSLAoIY2FsZW5kYXIYASABKAsyEC5lbnRpdHkuQ2FsZW'
    '5kYXJSCGNhbGVuZGFy');

@$core.Deprecated('Use calendarCreateResponseDescriptor instead')
const CalendarCreateResponse$json = {
  '1': 'CalendarCreateResponse',
  '2': [
    {
      '1': 'calendar',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.entity.Calendar',
      '10': 'calendar'
    },
  ],
};

/// Descriptor for `CalendarCreateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarCreateResponseDescriptor =
    $convert.base64Decode(
        'ChZDYWxlbmRhckNyZWF0ZVJlc3BvbnNlEiwKCGNhbGVuZGFyGAEgASgLMhAuZW50aXR5LkNhbG'
        'VuZGFyUghjYWxlbmRhcg==');

@$core.Deprecated('Use calendarUpdateRequestDescriptor instead')
const CalendarUpdateRequest$json = {
  '1': 'CalendarUpdateRequest',
  '2': [
    {
      '1': 'calendar',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.entity.Calendar',
      '10': 'calendar'
    },
  ],
};

/// Descriptor for `CalendarUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarUpdateRequestDescriptor = $convert.base64Decode(
    'ChVDYWxlbmRhclVwZGF0ZVJlcXVlc3QSLAoIY2FsZW5kYXIYASABKAsyEC5lbnRpdHkuQ2FsZW'
    '5kYXJSCGNhbGVuZGFy');

@$core.Deprecated('Use calendarUpdateResponseDescriptor instead')
const CalendarUpdateResponse$json = {
  '1': 'CalendarUpdateResponse',
  '2': [
    {
      '1': 'calendar',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.entity.Calendar',
      '10': 'calendar'
    },
  ],
};

/// Descriptor for `CalendarUpdateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarUpdateResponseDescriptor =
    $convert.base64Decode(
        'ChZDYWxlbmRhclVwZGF0ZVJlc3BvbnNlEiwKCGNhbGVuZGFyGAEgASgLMhAuZW50aXR5LkNhbG'
        'VuZGFyUghjYWxlbmRhcg==');

@$core.Deprecated('Use calendarDeleteRequestDescriptor instead')
const CalendarDeleteRequest$json = {
  '1': 'CalendarDeleteRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
  ],
};

/// Descriptor for `CalendarDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarDeleteRequestDescriptor = $convert
    .base64Decode('ChVDYWxlbmRhckRlbGV0ZVJlcXVlc3QSDgoCaWQYASABKANSAmlk');

@$core.Deprecated('Use calendarDeleteResponseDescriptor instead')
const CalendarDeleteResponse$json = {
  '1': 'CalendarDeleteResponse',
};

/// Descriptor for `CalendarDeleteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarDeleteResponseDescriptor =
    $convert.base64Decode('ChZDYWxlbmRhckRlbGV0ZVJlc3BvbnNl');

@$core.Deprecated('Use calendarSearchRequestDescriptor instead')
const CalendarSearchRequest$json = {
  '1': 'CalendarSearchRequest',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'limit', '3': 2, '4': 1, '5': 5, '10': 'limit'},
    {'1': 'offset', '3': 3, '4': 1, '5': 5, '10': 'offset'},
  ],
};

/// Descriptor for `CalendarSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarSearchRequestDescriptor = $convert.base64Decode(
    'ChVDYWxlbmRhclNlYXJjaFJlcXVlc3QSEAoDa2V5GAEgASgJUgNrZXkSFAoFbGltaXQYAiABKA'
    'VSBWxpbWl0EhYKBm9mZnNldBgDIAEoBVIGb2Zmc2V0');

@$core.Deprecated('Use calendarSearchResponseDescriptor instead')
const CalendarSearchResponse$json = {
  '1': 'CalendarSearchResponse',
  '2': [
    {
      '1': 'calendars',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.entity.Calendar',
      '10': 'calendars'
    },
  ],
};

/// Descriptor for `CalendarSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarSearchResponseDescriptor =
    $convert.base64Decode(
        'ChZDYWxlbmRhclNlYXJjaFJlc3BvbnNlEi4KCWNhbGVuZGFycxgBIAMoCzIQLmVudGl0eS5DYW'
        'xlbmRhclIJY2FsZW5kYXJz');

@$core.Deprecated('Use calendarPushListRequestDescriptor instead')
const CalendarPushListRequest$json = {
  '1': 'CalendarPushListRequest',
  '2': [
    {
      '1': 'calendars',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.entity.Calendar',
      '10': 'calendars'
    },
  ],
};

/// Descriptor for `CalendarPushListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarPushListRequestDescriptor =
    $convert.base64Decode(
        'ChdDYWxlbmRhclB1c2hMaXN0UmVxdWVzdBIuCgljYWxlbmRhcnMYASADKAsyEC5lbnRpdHkuQ2'
        'FsZW5kYXJSCWNhbGVuZGFycw==');

@$core.Deprecated('Use calendarSubscribeRequestDescriptor instead')
const CalendarSubscribeRequest$json = {
  '1': 'CalendarSubscribeRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'subscribe', '3': 2, '4': 1, '5': 8, '10': 'subscribe'},
  ],
};

/// Descriptor for `CalendarSubscribeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarSubscribeRequestDescriptor =
    $convert.base64Decode(
        'ChhDYWxlbmRhclN1YnNjcmliZVJlcXVlc3QSDgoCaWQYASABKANSAmlkEhwKCXN1YnNjcmliZR'
        'gCIAEoCFIJc3Vic2NyaWJl');

@$core.Deprecated('Use calendarSubscribeResponseDescriptor instead')
const CalendarSubscribeResponse$json = {
  '1': 'CalendarSubscribeResponse',
};

/// Descriptor for `CalendarSubscribeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarSubscribeResponseDescriptor =
    $convert.base64Decode('ChlDYWxlbmRhclN1YnNjcmliZVJlc3BvbnNl');

@$core.Deprecated('Use calendarPushUpdateRequestDescriptor instead')
const CalendarPushUpdateRequest$json = {
  '1': 'CalendarPushUpdateRequest',
  '2': [
    {
      '1': 'calendar',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.entity.Calendar',
      '10': 'calendar'
    },
  ],
};

/// Descriptor for `CalendarPushUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarPushUpdateRequestDescriptor =
    $convert.base64Decode(
        'ChlDYWxlbmRhclB1c2hVcGRhdGVSZXF1ZXN0EiwKCGNhbGVuZGFyGAEgASgLMhAuZW50aXR5Lk'
        'NhbGVuZGFyUghjYWxlbmRhcg==');

@$core.Deprecated('Use scheduleCreateRequestDescriptor instead')
const ScheduleCreateRequest$json = {
  '1': 'ScheduleCreateRequest',
  '2': [
    {
      '1': 'schedule',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.entity.Schedule',
      '10': 'schedule'
    },
  ],
};

/// Descriptor for `ScheduleCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scheduleCreateRequestDescriptor = $convert.base64Decode(
    'ChVTY2hlZHVsZUNyZWF0ZVJlcXVlc3QSLAoIc2NoZWR1bGUYASABKAsyEC5lbnRpdHkuU2NoZW'
    'R1bGVSCHNjaGVkdWxl');

@$core.Deprecated('Use scheduleCreateResponseDescriptor instead')
const ScheduleCreateResponse$json = {
  '1': 'ScheduleCreateResponse',
  '2': [
    {
      '1': 'schedule',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.entity.Schedule',
      '10': 'schedule'
    },
  ],
};

/// Descriptor for `ScheduleCreateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scheduleCreateResponseDescriptor =
    $convert.base64Decode(
        'ChZTY2hlZHVsZUNyZWF0ZVJlc3BvbnNlEiwKCHNjaGVkdWxlGAEgASgLMhAuZW50aXR5LlNjaG'
        'VkdWxlUghzY2hlZHVsZQ==');

@$core.Deprecated('Use scheduleRemoveRequestDescriptor instead')
const ScheduleRemoveRequest$json = {
  '1': 'ScheduleRemoveRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'cycle_id', '3': 2, '4': 1, '5': 3, '10': 'cycleId'},
    {'1': 'modify_scope', '3': 3, '4': 1, '5': 5, '10': 'modifyScope'},
  ],
};

/// Descriptor for `ScheduleRemoveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scheduleRemoveRequestDescriptor = $convert.base64Decode(
    'ChVTY2hlZHVsZVJlbW92ZVJlcXVlc3QSDgoCaWQYASABKANSAmlkEhkKCGN5Y2xlX2lkGAIgAS'
    'gDUgdjeWNsZUlkEiEKDG1vZGlmeV9zY29wZRgDIAEoBVILbW9kaWZ5U2NvcGU=');

@$core.Deprecated('Use scheduleRemoveResponseDescriptor instead')
const ScheduleRemoveResponse$json = {
  '1': 'ScheduleRemoveResponse',
};

/// Descriptor for `ScheduleRemoveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scheduleRemoveResponseDescriptor =
    $convert.base64Decode('ChZTY2hlZHVsZVJlbW92ZVJlc3BvbnNl');

@$core.Deprecated('Use scheduleUpdateRequestDescriptor instead')
const ScheduleUpdateRequest$json = {
  '1': 'ScheduleUpdateRequest',
  '2': [
    {
      '1': 'schedule',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.entity.Schedule',
      '10': 'schedule'
    },
    {'1': 'modify_scope', '3': 3, '4': 1, '5': 5, '10': 'modifyScope'},
  ],
};

/// Descriptor for `ScheduleUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scheduleUpdateRequestDescriptor = $convert.base64Decode(
    'ChVTY2hlZHVsZVVwZGF0ZVJlcXVlc3QSLAoIc2NoZWR1bGUYASABKAsyEC5lbnRpdHkuU2NoZW'
    'R1bGVSCHNjaGVkdWxlEiEKDG1vZGlmeV9zY29wZRgDIAEoBVILbW9kaWZ5U2NvcGU=');

@$core.Deprecated('Use scheduleUpdateResponseDescriptor instead')
const ScheduleUpdateResponse$json = {
  '1': 'ScheduleUpdateResponse',
  '2': [
    {
      '1': 'schedule',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.entity.Schedule',
      '10': 'schedule'
    },
  ],
};

/// Descriptor for `ScheduleUpdateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scheduleUpdateResponseDescriptor =
    $convert.base64Decode(
        'ChZTY2hlZHVsZVVwZGF0ZVJlc3BvbnNlEiwKCHNjaGVkdWxlGAEgASgLMhAuZW50aXR5LlNjaG'
        'VkdWxlUghzY2hlZHVsZQ==');

@$core.Deprecated('Use schedulePullByIdsRequestDescriptor instead')
const SchedulePullByIdsRequest$json = {
  '1': 'SchedulePullByIdsRequest',
  '2': [
    {'1': 'calendar_id', '3': 1, '4': 1, '5': 3, '10': 'calendarId'},
    {'1': 'ids', '3': 2, '4': 3, '5': 3, '10': 'ids'},
  ],
};

/// Descriptor for `SchedulePullByIdsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List schedulePullByIdsRequestDescriptor =
    $convert.base64Decode(
        'ChhTY2hlZHVsZVB1bGxCeUlkc1JlcXVlc3QSHwoLY2FsZW5kYXJfaWQYASABKANSCmNhbGVuZG'
        'FySWQSEAoDaWRzGAIgAygDUgNpZHM=');

@$core.Deprecated('Use schedulePullByIdsResponseDescriptor instead')
const SchedulePullByIdsResponse$json = {
  '1': 'SchedulePullByIdsResponse',
  '2': [
    {
      '1': 'schedules',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.entity.Schedule',
      '10': 'schedules'
    },
    {
      '1': 'entity',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.entity.Entity',
      '10': 'entity'
    },
  ],
};

/// Descriptor for `SchedulePullByIdsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List schedulePullByIdsResponseDescriptor = $convert.base64Decode(
    'ChlTY2hlZHVsZVB1bGxCeUlkc1Jlc3BvbnNlEi4KCXNjaGVkdWxlcxgBIAMoCzIQLmVudGl0eS'
    '5TY2hlZHVsZVIJc2NoZWR1bGVzEiYKBmVudGl0eRgCIAEoCzIOLmVudGl0eS5FbnRpdHlSBmVu'
    'dGl0eQ==');

@$core.Deprecated('Use schedulePullByCalendarIdsRequestDescriptor instead')
const SchedulePullByCalendarIdsRequest$json = {
  '1': 'SchedulePullByCalendarIdsRequest',
  '2': [
    {'1': 'calendar_ids', '3': 1, '4': 3, '5': 3, '10': 'calendarIds'},
    {'1': 'start_time', '3': 2, '4': 1, '5': 3, '10': 'startTime'},
    {'1': 'end_time', '3': 3, '4': 1, '5': 3, '10': 'endTime'},
  ],
};

/// Descriptor for `SchedulePullByCalendarIdsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List schedulePullByCalendarIdsRequestDescriptor =
    $convert.base64Decode(
        'CiBTY2hlZHVsZVB1bGxCeUNhbGVuZGFySWRzUmVxdWVzdBIhCgxjYWxlbmRhcl9pZHMYASADKA'
        'NSC2NhbGVuZGFySWRzEh0KCnN0YXJ0X3RpbWUYAiABKANSCXN0YXJ0VGltZRIZCghlbmRfdGlt'
        'ZRgDIAEoA1IHZW5kVGltZQ==');

@$core.Deprecated('Use schedulePullByCalendarIdsResponseDescriptor instead')
const SchedulePullByCalendarIdsResponse$json = {
  '1': 'SchedulePullByCalendarIdsResponse',
  '2': [
    {
      '1': 'schedules',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.entity.Schedule',
      '10': 'schedules'
    },
  ],
};

/// Descriptor for `SchedulePullByCalendarIdsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List schedulePullByCalendarIdsResponseDescriptor =
    $convert.base64Decode(
        'CiFTY2hlZHVsZVB1bGxCeUNhbGVuZGFySWRzUmVzcG9uc2USLgoJc2NoZWR1bGVzGAEgAygLMh'
        'AuZW50aXR5LlNjaGVkdWxlUglzY2hlZHVsZXM=');

@$core.Deprecated('Use schedulePullBusyRequestDescriptor instead')
const SchedulePullBusyRequest$json = {
  '1': 'SchedulePullBusyRequest',
  '2': [
    {'1': 'user_ids', '3': 1, '4': 3, '5': 3, '10': 'userIds'},
    {'1': 'start_time', '3': 2, '4': 1, '5': 3, '10': 'startTime'},
    {'1': 'end_time', '3': 3, '4': 1, '5': 3, '10': 'endTime'},
  ],
};

/// Descriptor for `SchedulePullBusyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List schedulePullBusyRequestDescriptor = $convert.base64Decode(
    'ChdTY2hlZHVsZVB1bGxCdXN5UmVxdWVzdBIZCgh1c2VyX2lkcxgBIAMoA1IHdXNlcklkcxIdCg'
    'pzdGFydF90aW1lGAIgASgDUglzdGFydFRpbWUSGQoIZW5kX3RpbWUYAyABKANSB2VuZFRpbWU=');

@$core.Deprecated('Use schedulePullBusyResponseDescriptor instead')
const SchedulePullBusyResponse$json = {
  '1': 'SchedulePullBusyResponse',
  '2': [
    {
      '1': 'schedules',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.calendar.SchedulePullBusyResponse.SchedulesEntry',
      '10': 'schedules'
    },
  ],
  '3': [SchedulePullBusyResponse_SchedulesEntry$json],
};

@$core.Deprecated('Use schedulePullBusyResponseDescriptor instead')
const SchedulePullBusyResponse_SchedulesEntry$json = {
  '1': 'SchedulesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 3, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.entity.UserScheduleBrief',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `SchedulePullBusyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List schedulePullBusyResponseDescriptor = $convert.base64Decode(
    'ChhTY2hlZHVsZVB1bGxCdXN5UmVzcG9uc2USTwoJc2NoZWR1bGVzGAEgAygLMjEuY2FsZW5kYX'
    'IuU2NoZWR1bGVQdWxsQnVzeVJlc3BvbnNlLlNjaGVkdWxlc0VudHJ5UglzY2hlZHVsZXMaVwoO'
    'U2NoZWR1bGVzRW50cnkSEAoDa2V5GAEgASgDUgNrZXkSLwoFdmFsdWUYAiABKAsyGS5lbnRpdH'
    'kuVXNlclNjaGVkdWxlQnJpZWZSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use schedulePushUpdateRequestDescriptor instead')
const SchedulePushUpdateRequest$json = {
  '1': 'SchedulePushUpdateRequest',
  '2': [
    {
      '1': 'schedules',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.entity.Schedule',
      '10': 'schedules'
    },
  ],
};

/// Descriptor for `SchedulePushUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List schedulePushUpdateRequestDescriptor =
    $convert.base64Decode(
        'ChlTY2hlZHVsZVB1c2hVcGRhdGVSZXF1ZXN0Ei4KCXNjaGVkdWxlcxgBIAMoCzIQLmVudGl0eS'
        '5TY2hlZHVsZVIJc2NoZWR1bGVz');

@$core.Deprecated('Use schedulePullByCycleRequestDescriptor instead')
const SchedulePullByCycleRequest$json = {
  '1': 'SchedulePullByCycleRequest',
  '2': [
    {'1': 'rule_id', '3': 1, '4': 1, '5': 3, '10': 'ruleId'},
    {'1': 'start_at', '3': 2, '4': 1, '5': 3, '10': 'startAt'},
    {'1': 'end_at', '3': 3, '4': 1, '5': 3, '10': 'endAt'},
  ],
};

/// Descriptor for `SchedulePullByCycleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List schedulePullByCycleRequestDescriptor =
    $convert.base64Decode(
        'ChpTY2hlZHVsZVB1bGxCeUN5Y2xlUmVxdWVzdBIXCgdydWxlX2lkGAEgASgDUgZydWxlSWQSGQ'
        'oIc3RhcnRfYXQYAiABKANSB3N0YXJ0QXQSFQoGZW5kX2F0GAMgASgDUgVlbmRBdA==');

@$core.Deprecated('Use schedulePullByCycleResponseDescriptor instead')
const SchedulePullByCycleResponse$json = {
  '1': 'SchedulePullByCycleResponse',
  '2': [
    {
      '1': 'schedules',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.entity.Schedule',
      '10': 'schedules'
    },
  ],
};

/// Descriptor for `SchedulePullByCycleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List schedulePullByCycleResponseDescriptor =
    $convert.base64Decode(
        'ChtTY2hlZHVsZVB1bGxCeUN5Y2xlUmVzcG9uc2USLgoJc2NoZWR1bGVzGAEgAygLMhAuZW50aX'
        'R5LlNjaGVkdWxlUglzY2hlZHVsZXM=');

@$core.Deprecated('Use scheduleDeletePushDescriptor instead')
const ScheduleDeletePush$json = {
  '1': 'ScheduleDeletePush',
  '2': [
    {'1': 'ids', '3': 1, '4': 3, '5': 3, '10': 'ids'},
    {'1': 'cycle_rule_id', '3': 2, '4': 1, '5': 3, '10': 'cycleRuleId'},
    {'1': 'start_time', '3': 3, '4': 1, '5': 3, '10': 'startTime'},
  ],
};

/// Descriptor for `ScheduleDeletePush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scheduleDeletePushDescriptor = $convert.base64Decode(
    'ChJTY2hlZHVsZURlbGV0ZVB1c2gSEAoDaWRzGAEgAygDUgNpZHMSIgoNY3ljbGVfcnVsZV9pZB'
    'gCIAEoA1ILY3ljbGVSdWxlSWQSHQoKc3RhcnRfdGltZRgDIAEoA1IJc3RhcnRUaW1l');

@$core.Deprecated('Use scheduleRemindPushDescriptor instead')
const ScheduleRemindPush$json = {
  '1': 'ScheduleRemindPush',
  '2': [
    {'1': 'schedule_id', '3': 1, '4': 1, '5': 3, '10': 'scheduleId'},
    {'1': 'start_time', '3': 2, '4': 1, '5': 3, '10': 'startTime'},
    {'1': 'end_time', '3': 3, '4': 1, '5': 3, '10': 'endTime'},
    {'1': 'title', '3': 4, '4': 1, '5': 9, '10': 'title'},
    {'1': 'location', '3': 5, '4': 1, '5': 9, '10': 'location'},
    {'1': 'notify_minute', '3': 6, '4': 1, '5': 5, '10': 'notifyMinute'},
  ],
};

/// Descriptor for `ScheduleRemindPush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scheduleRemindPushDescriptor = $convert.base64Decode(
    'ChJTY2hlZHVsZVJlbWluZFB1c2gSHwoLc2NoZWR1bGVfaWQYASABKANSCnNjaGVkdWxlSWQSHQ'
    'oKc3RhcnRfdGltZRgCIAEoA1IJc3RhcnRUaW1lEhkKCGVuZF90aW1lGAMgASgDUgdlbmRUaW1l'
    'EhQKBXRpdGxlGAQgASgJUgV0aXRsZRIaCghsb2NhdGlvbhgFIAEoCVIIbG9jYXRpb24SIwoNbm'
    '90aWZ5X21pbnV0ZRgGIAEoBVIMbm90aWZ5TWludXRl');
