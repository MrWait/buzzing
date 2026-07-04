// This is a generated file - do not edit.
//
// Generated from error.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ErrorCode extends $pb.ProtobufEnum {
  static const ErrorCode ERROR_UNKNOWN =
      ErrorCode._(0, _omitEnumNames ? '' : 'ERROR_UNKNOWN');

  /// HTTP
  static const ErrorCode OK = ErrorCode._(200, _omitEnumNames ? '' : 'OK');
  static const ErrorCode ERROR_SDK_ERROR =
      ErrorCode._(1000, _omitEnumNames ? '' : 'ERROR_SDK_ERROR');
  static const ErrorCode ERROR_SERVER_ERROR =
      ErrorCode._(1001, _omitEnumNames ? '' : 'ERROR_SERVER_ERROR');
  static const ErrorCode ERROR_NOT_AUTH =
      ErrorCode._(1002, _omitEnumNames ? '' : 'ERROR_NOT_AUTH');
  static const ErrorCode ERROR_ON_PROCESS =
      ErrorCode._(1003, _omitEnumNames ? '' : 'ERROR_ON_PROCESS');
  static const ErrorCode ERROR_TIMEOUT =
      ErrorCode._(1004, _omitEnumNames ? '' : 'ERROR_TIMEOUT');
  static const ErrorCode ERROR_NO_PERMISION =
      ErrorCode._(1005, _omitEnumNames ? '' : 'ERROR_NO_PERMISION');
  static const ErrorCode ERROR_PARAM_INVALID =
      ErrorCode._(1006, _omitEnumNames ? '' : 'ERROR_PARAM_INVALID');
  static const ErrorCode ERROR_INVALID_DATA =
      ErrorCode._(1007, _omitEnumNames ? '' : 'ERROR_INVALID_DATA');

  static const $core.List<ErrorCode> values = <ErrorCode>[
    ERROR_UNKNOWN,
    OK,
    ERROR_SDK_ERROR,
    ERROR_SERVER_ERROR,
    ERROR_NOT_AUTH,
    ERROR_ON_PROCESS,
    ERROR_TIMEOUT,
    ERROR_NO_PERMISION,
    ERROR_PARAM_INVALID,
    ERROR_INVALID_DATA,
  ];

  static final $core.Map<$core.int, ErrorCode> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static ErrorCode? valueOf($core.int value) => _byValue[value];

  const ErrorCode._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
