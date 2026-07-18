// This is a generated file - do not edit.
//
// Generated from meeting.proto.

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

@$core.Deprecated('Use meetingStatusDescriptor instead')
const MeetingStatus$json = {
  '1': 'MeetingStatus',
  '2': [
    {'1': 'MEETING_UNKNOWN', '2': 0},
    {'1': 'MEETING_ACTIVE', '2': 1},
    {'1': 'MEETING_ENDED', '2': 2},
  ],
};

/// Descriptor for `MeetingStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List meetingStatusDescriptor = $convert.base64Decode(
    'Cg1NZWV0aW5nU3RhdHVzEhMKD01FRVRJTkdfVU5LTk9XThAAEhIKDk1FRVRJTkdfQUNUSVZFEA'
    'ESEQoNTUVFVElOR19FTkRFRBAC');

@$core.Deprecated('Use meetingListFilterDescriptor instead')
const MeetingListFilter$json = {
  '1': 'MeetingListFilter',
  '2': [
    {'1': 'MEETING_LIST_UNSPECIFIED', '2': 0},
    {'1': 'MEETING_LIST_ACTIVE', '2': 1},
    {'1': 'MEETING_LIST_HISTORY', '2': 2},
    {'1': 'MEETING_LIST_SCHEDULED', '2': 3},
  ],
};

/// Descriptor for `MeetingListFilter`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List meetingListFilterDescriptor = $convert.base64Decode(
    'ChFNZWV0aW5nTGlzdEZpbHRlchIcChhNRUVUSU5HX0xJU1RfVU5TUEVDSUZJRUQQABIXChNNRU'
    'VUSU5HX0xJU1RfQUNUSVZFEAESGAoUTUVFVElOR19MSVNUX0hJU1RPUlkQAhIaChZNRUVUSU5H'
    'X0xJU1RfU0NIRURVTEVEEAM=');

@$core.Deprecated('Use meetingPushActionDescriptor instead')
const MeetingPushAction$json = {
  '1': 'MeetingPushAction',
  '2': [
    {'1': 'MEETING_PUSH_UNSPECIFIED', '2': 0},
    {'1': 'MEETING_PUSH_JOINED', '2': 1},
    {'1': 'MEETING_PUSH_LEFT', '2': 2},
    {'1': 'MEETING_PUSH_ENDED', '2': 3},
    {'1': 'MEETING_PUSH_KICKED', '2': 4},
    {'1': 'MEETING_PUSH_ROLE_CHANGED', '2': 5},
    {'1': 'MEETING_PUSH_INVITED', '2': 6},
    {'1': 'MEETING_PUSH_REMINDER', '2': 7},
  ],
};

/// Descriptor for `MeetingPushAction`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List meetingPushActionDescriptor = $convert.base64Decode(
    'ChFNZWV0aW5nUHVzaEFjdGlvbhIcChhNRUVUSU5HX1BVU0hfVU5TUEVDSUZJRUQQABIXChNNRU'
    'VUSU5HX1BVU0hfSk9JTkVEEAESFQoRTUVFVElOR19QVVNIX0xFRlQQAhIWChJNRUVUSU5HX1BV'
    'U0hfRU5ERUQQAxIXChNNRUVUSU5HX1BVU0hfS0lDS0VEEAQSHQoZTUVFVElOR19QVVNIX1JPTE'
    'VfQ0hBTkdFRBAFEhgKFE1FRVRJTkdfUFVTSF9JTlZJVEVEEAYSGQoVTUVFVElOR19QVVNIX1JF'
    'TUlOREVSEAc=');

@$core.Deprecated('Use meetingSettingsDescriptor instead')
const MeetingSettings$json = {
  '1': 'MeetingSettings',
  '2': [
    {'1': 'mute_on_entry', '3': 1, '4': 1, '5': 8, '10': 'muteOnEntry'},
    {
      '1': 'allow_screen_share',
      '3': 2,
      '4': 1,
      '5': 8,
      '10': 'allowScreenShare'
    },
    {'1': 'record_enabled', '3': 3, '4': 1, '5': 8, '10': 'recordEnabled'},
  ],
};

/// Descriptor for `MeetingSettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meetingSettingsDescriptor = $convert.base64Decode(
    'Cg9NZWV0aW5nU2V0dGluZ3MSIgoNbXV0ZV9vbl9lbnRyeRgBIAEoCFILbXV0ZU9uRW50cnkSLA'
    'oSYWxsb3dfc2NyZWVuX3NoYXJlGAIgASgIUhBhbGxvd1NjcmVlblNoYXJlEiUKDnJlY29yZF9l'
    'bmFibGVkGAMgASgIUg1yZWNvcmRFbmFibGVk');

@$core.Deprecated('Use meetingMemberDescriptor instead')
const MeetingMember$json = {
  '1': 'MeetingMember',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'role', '3': 2, '4': 1, '5': 5, '10': 'role'},
    {'1': 'status', '3': 3, '4': 1, '5': 5, '10': 'status'},
    {'1': 'joined_at', '3': 4, '4': 1, '5': 3, '10': 'joinedAt'},
    {'1': 'left_at', '3': 5, '4': 1, '5': 3, '10': 'leftAt'},
  ],
};

/// Descriptor for `MeetingMember`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meetingMemberDescriptor = $convert.base64Decode(
    'Cg1NZWV0aW5nTWVtYmVyEhcKB3VzZXJfaWQYASABKANSBnVzZXJJZBISCgRyb2xlGAIgASgFUg'
    'Ryb2xlEhYKBnN0YXR1cxgDIAEoBVIGc3RhdHVzEhsKCWpvaW5lZF9hdBgEIAEoA1IIam9pbmVk'
    'QXQSFwoHbGVmdF9hdBgFIAEoA1IGbGVmdEF0');

@$core.Deprecated('Use meetingInfoDescriptor instead')
const MeetingInfo$json = {
  '1': 'MeetingInfo',
  '2': [
    {'1': 'room_id', '3': 1, '4': 1, '5': 9, '10': 'roomId'},
    {'1': 'host_id', '3': 2, '4': 1, '5': 3, '10': 'hostId'},
    {'1': 'member_ids', '3': 3, '4': 3, '5': 3, '10': 'memberIds'},
    {'1': 'title', '3': 4, '4': 1, '5': 9, '10': 'title'},
    {'1': 'created_at', '3': 5, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'password', '3': 6, '4': 1, '5': 9, '10': 'password'},
    {
      '1': 'status',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.meeting.MeetingStatus',
      '10': 'status'
    },
    {'1': 'id', '3': 8, '4': 1, '5': 3, '10': 'id'},
    {'1': 'scheduled_at', '3': 9, '4': 1, '5': 3, '10': 'scheduledAt'},
    {'1': 'started_at', '3': 10, '4': 1, '5': 3, '10': 'startedAt'},
    {'1': 'ended_at', '3': 11, '4': 1, '5': 3, '10': 'endedAt'},
    {'1': 'tenant_id', '3': 12, '4': 1, '5': 3, '10': 'tenantId'},
    {
      '1': 'members',
      '3': 13,
      '4': 3,
      '5': 11,
      '6': '.meeting.MeetingMember',
      '10': 'members'
    },
    {
      '1': 'settings',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.meeting.MeetingSettings',
      '10': 'settings'
    },
    {'1': 'max_participants', '3': 15, '4': 1, '5': 5, '10': 'maxParticipants'},
  ],
};

/// Descriptor for `MeetingInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meetingInfoDescriptor = $convert.base64Decode(
    'CgtNZWV0aW5nSW5mbxIXCgdyb29tX2lkGAEgASgJUgZyb29tSWQSFwoHaG9zdF9pZBgCIAEoA1'
    'IGaG9zdElkEh0KCm1lbWJlcl9pZHMYAyADKANSCW1lbWJlcklkcxIUCgV0aXRsZRgEIAEoCVIF'
    'dGl0bGUSHQoKY3JlYXRlZF9hdBgFIAEoA1IJY3JlYXRlZEF0EhoKCHBhc3N3b3JkGAYgASgJUg'
    'hwYXNzd29yZBIuCgZzdGF0dXMYByABKA4yFi5tZWV0aW5nLk1lZXRpbmdTdGF0dXNSBnN0YXR1'
    'cxIOCgJpZBgIIAEoA1ICaWQSIQoMc2NoZWR1bGVkX2F0GAkgASgDUgtzY2hlZHVsZWRBdBIdCg'
    'pzdGFydGVkX2F0GAogASgDUglzdGFydGVkQXQSGQoIZW5kZWRfYXQYCyABKANSB2VuZGVkQXQS'
    'GwoJdGVuYW50X2lkGAwgASgDUgh0ZW5hbnRJZBIwCgdtZW1iZXJzGA0gAygLMhYubWVldGluZy'
    '5NZWV0aW5nTWVtYmVyUgdtZW1iZXJzEjQKCHNldHRpbmdzGA4gASgLMhgubWVldGluZy5NZWV0'
    'aW5nU2V0dGluZ3NSCHNldHRpbmdzEikKEG1heF9wYXJ0aWNpcGFudHMYDyABKAVSD21heFBhcn'
    'RpY2lwYW50cw==');

@$core.Deprecated('Use meetingCreateRequestDescriptor instead')
const MeetingCreateRequest$json = {
  '1': 'MeetingCreateRequest',
  '2': [
    {'1': 'title', '3': 1, '4': 1, '5': 9, '10': 'title'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
    {'1': 'scheduled_at', '3': 3, '4': 1, '5': 3, '10': 'scheduledAt'},
    {'1': 'max_participants', '3': 4, '4': 1, '5': 5, '10': 'maxParticipants'},
    {
      '1': 'settings',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.meeting.MeetingSettings',
      '10': 'settings'
    },
  ],
};

/// Descriptor for `MeetingCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meetingCreateRequestDescriptor = $convert.base64Decode(
    'ChRNZWV0aW5nQ3JlYXRlUmVxdWVzdBIUCgV0aXRsZRgBIAEoCVIFdGl0bGUSGgoIcGFzc3dvcm'
    'QYAiABKAlSCHBhc3N3b3JkEiEKDHNjaGVkdWxlZF9hdBgDIAEoA1ILc2NoZWR1bGVkQXQSKQoQ'
    'bWF4X3BhcnRpY2lwYW50cxgEIAEoBVIPbWF4UGFydGljaXBhbnRzEjQKCHNldHRpbmdzGAUgAS'
    'gLMhgubWVldGluZy5NZWV0aW5nU2V0dGluZ3NSCHNldHRpbmdz');

@$core.Deprecated('Use meetingCreateResponseDescriptor instead')
const MeetingCreateResponse$json = {
  '1': 'MeetingCreateResponse',
  '2': [
    {
      '1': 'meeting',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.meeting.MeetingInfo',
      '10': 'meeting'
    },
  ],
};

/// Descriptor for `MeetingCreateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meetingCreateResponseDescriptor = $convert.base64Decode(
    'ChVNZWV0aW5nQ3JlYXRlUmVzcG9uc2USLgoHbWVldGluZxgBIAEoCzIULm1lZXRpbmcuTWVldG'
    'luZ0luZm9SB21lZXRpbmc=');

@$core.Deprecated('Use meetingGetListRequestDescriptor instead')
const MeetingGetListRequest$json = {
  '1': 'MeetingGetListRequest',
  '2': [
    {
      '1': 'filter',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.meeting.MeetingListFilter',
      '10': 'filter'
    },
    {'1': 'page', '3': 2, '4': 1, '5': 5, '10': 'page'},
    {'1': 'page_size', '3': 3, '4': 1, '5': 5, '10': 'pageSize'},
  ],
};

/// Descriptor for `MeetingGetListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meetingGetListRequestDescriptor = $convert.base64Decode(
    'ChVNZWV0aW5nR2V0TGlzdFJlcXVlc3QSMgoGZmlsdGVyGAEgASgOMhoubWVldGluZy5NZWV0aW'
    '5nTGlzdEZpbHRlclIGZmlsdGVyEhIKBHBhZ2UYAiABKAVSBHBhZ2USGwoJcGFnZV9zaXplGAMg'
    'ASgFUghwYWdlU2l6ZQ==');

@$core.Deprecated('Use meetingGetListResponseDescriptor instead')
const MeetingGetListResponse$json = {
  '1': 'MeetingGetListResponse',
  '2': [
    {
      '1': 'meetings',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meeting.MeetingInfo',
      '10': 'meetings'
    },
    {'1': 'total', '3': 2, '4': 1, '5': 5, '10': 'total'},
  ],
};

/// Descriptor for `MeetingGetListResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meetingGetListResponseDescriptor =
    $convert.base64Decode(
        'ChZNZWV0aW5nR2V0TGlzdFJlc3BvbnNlEjAKCG1lZXRpbmdzGAEgAygLMhQubWVldGluZy5NZW'
        'V0aW5nSW5mb1IIbWVldGluZ3MSFAoFdG90YWwYAiABKAVSBXRvdGFs');

@$core.Deprecated('Use meetingPushUpdateDescriptor instead')
const MeetingPushUpdate$json = {
  '1': 'MeetingPushUpdate',
  '2': [
    {
      '1': 'meeting',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.meeting.MeetingInfo',
      '10': 'meeting'
    },
    {
      '1': 'action',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.meeting.MeetingPushAction',
      '10': 'action'
    },
  ],
};

/// Descriptor for `MeetingPushUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meetingPushUpdateDescriptor = $convert.base64Decode(
    'ChFNZWV0aW5nUHVzaFVwZGF0ZRIuCgdtZWV0aW5nGAEgASgLMhQubWVldGluZy5NZWV0aW5nSW'
    '5mb1IHbWVldGluZxIyCgZhY3Rpb24YAiABKA4yGi5tZWV0aW5nLk1lZXRpbmdQdXNoQWN0aW9u'
    'UgZhY3Rpb24=');

@$core.Deprecated('Use meetingInviteDescriptor instead')
const MeetingInvite$json = {
  '1': 'MeetingInvite',
  '2': [
    {'1': 'room_id', '3': 1, '4': 1, '5': 9, '10': 'roomId'},
    {'1': 'meeting_id', '3': 2, '4': 1, '5': 3, '10': 'meetingId'},
    {'1': 'title', '3': 3, '4': 1, '5': 9, '10': 'title'},
    {'1': 'host_id', '3': 4, '4': 1, '5': 3, '10': 'hostId'},
    {'1': 'host_name', '3': 5, '4': 1, '5': 9, '10': 'hostName'},
  ],
};

/// Descriptor for `MeetingInvite`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meetingInviteDescriptor = $convert.base64Decode(
    'Cg1NZWV0aW5nSW52aXRlEhcKB3Jvb21faWQYASABKAlSBnJvb21JZBIdCgptZWV0aW5nX2lkGA'
    'IgASgDUgltZWV0aW5nSWQSFAoFdGl0bGUYAyABKAlSBXRpdGxlEhcKB2hvc3RfaWQYBCABKANS'
    'Bmhvc3RJZBIbCglob3N0X25hbWUYBSABKAlSCGhvc3ROYW1l');

@$core.Deprecated('Use joinMeetingRequestDescriptor instead')
const JoinMeetingRequest$json = {
  '1': 'JoinMeetingRequest',
  '2': [
    {'1': 'room_id', '3': 1, '4': 1, '5': 9, '10': 'roomId'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `JoinMeetingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinMeetingRequestDescriptor = $convert.base64Decode(
    'ChJKb2luTWVldGluZ1JlcXVlc3QSFwoHcm9vbV9pZBgBIAEoCVIGcm9vbUlkEhoKCHBhc3N3b3'
    'JkGAIgASgJUghwYXNzd29yZA==');

@$core.Deprecated('Use joinMeetingResponseDescriptor instead')
const JoinMeetingResponse$json = {
  '1': 'JoinMeetingResponse',
  '2': [
    {
      '1': 'meeting',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.meeting.MeetingInfo',
      '10': 'meeting'
    },
  ],
};

/// Descriptor for `JoinMeetingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinMeetingResponseDescriptor = $convert.base64Decode(
    'ChNKb2luTWVldGluZ1Jlc3BvbnNlEi4KB21lZXRpbmcYASABKAsyFC5tZWV0aW5nLk1lZXRpbm'
    'dJbmZvUgdtZWV0aW5n');

@$core.Deprecated('Use leaveMeetingRequestDescriptor instead')
const LeaveMeetingRequest$json = {
  '1': 'LeaveMeetingRequest',
  '2': [
    {'1': 'room_id', '3': 1, '4': 1, '5': 9, '10': 'roomId'},
  ],
};

/// Descriptor for `LeaveMeetingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List leaveMeetingRequestDescriptor =
    $convert.base64Decode(
        'ChNMZWF2ZU1lZXRpbmdSZXF1ZXN0EhcKB3Jvb21faWQYASABKAlSBnJvb21JZA==');

@$core.Deprecated('Use leaveMeetingResponseDescriptor instead')
const LeaveMeetingResponse$json = {
  '1': 'LeaveMeetingResponse',
};

/// Descriptor for `LeaveMeetingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List leaveMeetingResponseDescriptor =
    $convert.base64Decode('ChRMZWF2ZU1lZXRpbmdSZXNwb25zZQ==');

@$core.Deprecated('Use endMeetingRequestDescriptor instead')
const EndMeetingRequest$json = {
  '1': 'EndMeetingRequest',
  '2': [
    {'1': 'room_id', '3': 1, '4': 1, '5': 9, '10': 'roomId'},
  ],
};

/// Descriptor for `EndMeetingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List endMeetingRequestDescriptor = $convert.base64Decode(
    'ChFFbmRNZWV0aW5nUmVxdWVzdBIXCgdyb29tX2lkGAEgASgJUgZyb29tSWQ=');

@$core.Deprecated('Use endMeetingResponseDescriptor instead')
const EndMeetingResponse$json = {
  '1': 'EndMeetingResponse',
};

/// Descriptor for `EndMeetingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List endMeetingResponseDescriptor =
    $convert.base64Decode('ChJFbmRNZWV0aW5nUmVzcG9uc2U=');

@$core.Deprecated('Use getMeetingInfoRequestDescriptor instead')
const GetMeetingInfoRequest$json = {
  '1': 'GetMeetingInfoRequest',
  '2': [
    {'1': 'room_id', '3': 1, '4': 1, '5': 9, '10': 'roomId'},
  ],
};

/// Descriptor for `GetMeetingInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMeetingInfoRequestDescriptor =
    $convert.base64Decode(
        'ChVHZXRNZWV0aW5nSW5mb1JlcXVlc3QSFwoHcm9vbV9pZBgBIAEoCVIGcm9vbUlk');

@$core.Deprecated('Use getMeetingInfoResponseDescriptor instead')
const GetMeetingInfoResponse$json = {
  '1': 'GetMeetingInfoResponse',
  '2': [
    {
      '1': 'meeting',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.meeting.MeetingInfo',
      '10': 'meeting'
    },
  ],
};

/// Descriptor for `GetMeetingInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMeetingInfoResponseDescriptor =
    $convert.base64Decode(
        'ChZHZXRNZWV0aW5nSW5mb1Jlc3BvbnNlEi4KB21lZXRpbmcYASABKAsyFC5tZWV0aW5nLk1lZX'
        'RpbmdJbmZvUgdtZWV0aW5n');

@$core.Deprecated('Use kickMeetingRequestDescriptor instead')
const KickMeetingRequest$json = {
  '1': 'KickMeetingRequest',
  '2': [
    {'1': 'room_id', '3': 1, '4': 1, '5': 9, '10': 'roomId'},
    {'1': 'target_id', '3': 2, '4': 1, '5': 3, '10': 'targetId'},
  ],
};

/// Descriptor for `KickMeetingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List kickMeetingRequestDescriptor = $convert.base64Decode(
    'ChJLaWNrTWVldGluZ1JlcXVlc3QSFwoHcm9vbV9pZBgBIAEoCVIGcm9vbUlkEhsKCXRhcmdldF'
    '9pZBgCIAEoA1IIdGFyZ2V0SWQ=');

@$core.Deprecated('Use kickMeetingResponseDescriptor instead')
const KickMeetingResponse$json = {
  '1': 'KickMeetingResponse',
};

/// Descriptor for `KickMeetingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List kickMeetingResponseDescriptor =
    $convert.base64Decode('ChNLaWNrTWVldGluZ1Jlc3BvbnNl');

@$core.Deprecated('Use setRoleRequestDescriptor instead')
const SetRoleRequest$json = {
  '1': 'SetRoleRequest',
  '2': [
    {'1': 'room_id', '3': 1, '4': 1, '5': 9, '10': 'roomId'},
    {'1': 'target_id', '3': 2, '4': 1, '5': 3, '10': 'targetId'},
    {'1': 'role', '3': 3, '4': 1, '5': 5, '10': 'role'},
  ],
};

/// Descriptor for `SetRoleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setRoleRequestDescriptor = $convert.base64Decode(
    'Cg5TZXRSb2xlUmVxdWVzdBIXCgdyb29tX2lkGAEgASgJUgZyb29tSWQSGwoJdGFyZ2V0X2lkGA'
    'IgASgDUgh0YXJnZXRJZBISCgRyb2xlGAMgASgFUgRyb2xl');

@$core.Deprecated('Use setRoleResponseDescriptor instead')
const SetRoleResponse$json = {
  '1': 'SetRoleResponse',
};

/// Descriptor for `SetRoleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setRoleResponseDescriptor =
    $convert.base64Decode('Cg9TZXRSb2xlUmVzcG9uc2U=');

@$core.Deprecated('Use inviteMeetingRequestDescriptor instead')
const InviteMeetingRequest$json = {
  '1': 'InviteMeetingRequest',
  '2': [
    {'1': 'room_id', '3': 1, '4': 1, '5': 9, '10': 'roomId'},
    {'1': 'target_ids', '3': 2, '4': 3, '5': 3, '10': 'targetIds'},
  ],
};

/// Descriptor for `InviteMeetingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inviteMeetingRequestDescriptor = $convert.base64Decode(
    'ChRJbnZpdGVNZWV0aW5nUmVxdWVzdBIXCgdyb29tX2lkGAEgASgJUgZyb29tSWQSHQoKdGFyZ2'
    'V0X2lkcxgCIAMoA1IJdGFyZ2V0SWRz');

@$core.Deprecated('Use inviteMeetingResponseDescriptor instead')
const InviteMeetingResponse$json = {
  '1': 'InviteMeetingResponse',
};

/// Descriptor for `InviteMeetingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inviteMeetingResponseDescriptor =
    $convert.base64Decode('ChVJbnZpdGVNZWV0aW5nUmVzcG9uc2U=');
