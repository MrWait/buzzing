// This is a generated file - do not edit.
//
// Generated from meeting.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class MeetingStatus extends $pb.ProtobufEnum {
  static const MeetingStatus MEETING_UNKNOWN =
      MeetingStatus._(0, _omitEnumNames ? '' : 'MEETING_UNKNOWN');
  static const MeetingStatus MEETING_ACTIVE =
      MeetingStatus._(1, _omitEnumNames ? '' : 'MEETING_ACTIVE');
  static const MeetingStatus MEETING_ENDED =
      MeetingStatus._(2, _omitEnumNames ? '' : 'MEETING_ENDED');

  static const $core.List<MeetingStatus> values = <MeetingStatus>[
    MEETING_UNKNOWN,
    MEETING_ACTIVE,
    MEETING_ENDED,
  ];

  static final $core.List<MeetingStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static MeetingStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MeetingStatus._(super.value, super.name);
}

class MeetingListFilter extends $pb.ProtobufEnum {
  static const MeetingListFilter MEETING_LIST_UNSPECIFIED =
      MeetingListFilter._(0, _omitEnumNames ? '' : 'MEETING_LIST_UNSPECIFIED');
  static const MeetingListFilter MEETING_LIST_ACTIVE =
      MeetingListFilter._(1, _omitEnumNames ? '' : 'MEETING_LIST_ACTIVE');
  static const MeetingListFilter MEETING_LIST_HISTORY =
      MeetingListFilter._(2, _omitEnumNames ? '' : 'MEETING_LIST_HISTORY');
  static const MeetingListFilter MEETING_LIST_SCHEDULED =
      MeetingListFilter._(3, _omitEnumNames ? '' : 'MEETING_LIST_SCHEDULED');

  static const $core.List<MeetingListFilter> values = <MeetingListFilter>[
    MEETING_LIST_UNSPECIFIED,
    MEETING_LIST_ACTIVE,
    MEETING_LIST_HISTORY,
    MEETING_LIST_SCHEDULED,
  ];

  static final $core.List<MeetingListFilter?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static MeetingListFilter? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MeetingListFilter._(super.value, super.name);
}

class MeetingPushAction extends $pb.ProtobufEnum {
  static const MeetingPushAction MEETING_PUSH_UNSPECIFIED =
      MeetingPushAction._(0, _omitEnumNames ? '' : 'MEETING_PUSH_UNSPECIFIED');
  static const MeetingPushAction MEETING_PUSH_JOINED =
      MeetingPushAction._(1, _omitEnumNames ? '' : 'MEETING_PUSH_JOINED');
  static const MeetingPushAction MEETING_PUSH_LEFT =
      MeetingPushAction._(2, _omitEnumNames ? '' : 'MEETING_PUSH_LEFT');
  static const MeetingPushAction MEETING_PUSH_ENDED =
      MeetingPushAction._(3, _omitEnumNames ? '' : 'MEETING_PUSH_ENDED');
  static const MeetingPushAction MEETING_PUSH_KICKED =
      MeetingPushAction._(4, _omitEnumNames ? '' : 'MEETING_PUSH_KICKED');
  static const MeetingPushAction MEETING_PUSH_ROLE_CHANGED =
      MeetingPushAction._(5, _omitEnumNames ? '' : 'MEETING_PUSH_ROLE_CHANGED');
  static const MeetingPushAction MEETING_PUSH_INVITED =
      MeetingPushAction._(6, _omitEnumNames ? '' : 'MEETING_PUSH_INVITED');
  static const MeetingPushAction MEETING_PUSH_REMINDER =
      MeetingPushAction._(7, _omitEnumNames ? '' : 'MEETING_PUSH_REMINDER');

  static const $core.List<MeetingPushAction> values = <MeetingPushAction>[
    MEETING_PUSH_UNSPECIFIED,
    MEETING_PUSH_JOINED,
    MEETING_PUSH_LEFT,
    MEETING_PUSH_ENDED,
    MEETING_PUSH_KICKED,
    MEETING_PUSH_ROLE_CHANGED,
    MEETING_PUSH_INVITED,
    MEETING_PUSH_REMINDER,
  ];

  static final $core.List<MeetingPushAction?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 7);
  static MeetingPushAction? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MeetingPushAction._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
