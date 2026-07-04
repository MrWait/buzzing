// This is a generated file - do not edit.
//
// Generated from sdk.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class AvatarKey_EntityType extends $pb.ProtobufEnum {
  static const AvatarKey_EntityType OTHERS =
      AvatarKey_EntityType._(0, _omitEnumNames ? '' : 'OTHERS');
  static const AvatarKey_EntityType CHATTER =
      AvatarKey_EntityType._(1, _omitEnumNames ? '' : 'CHATTER');
  static const AvatarKey_EntityType CHAT =
      AvatarKey_EntityType._(2, _omitEnumNames ? '' : 'CHAT');
  static const AvatarKey_EntityType TENANT =
      AvatarKey_EntityType._(3, _omitEnumNames ? '' : 'TENANT');
  static const AvatarKey_EntityType NAMECARD =
      AvatarKey_EntityType._(4, _omitEnumNames ? '' : 'NAMECARD');
  static const AvatarKey_EntityType TEAM =
      AvatarKey_EntityType._(5, _omitEnumNames ? '' : 'TEAM');

  static const $core.List<AvatarKey_EntityType> values = <AvatarKey_EntityType>[
    OTHERS,
    CHATTER,
    CHAT,
    TENANT,
    NAMECARD,
    TEAM,
  ];

  static final $core.List<AvatarKey_EntityType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static AvatarKey_EntityType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AvatarKey_EntityType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
