// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'User.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User()
  ..login = json['login'] as String?
  ..id = (json['id'] as num?)?.toInt()
  ..token = json['token'] as String?
  ..refreshToke = json['refreshToke'] as String?;

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'login': instance.login,
      'id': instance.id,
      'token': instance.token,
      'refreshToke': instance.refreshToke,
    };
