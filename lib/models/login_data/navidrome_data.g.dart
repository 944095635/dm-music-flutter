// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navidrome_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NavidromeData _$NavidromeDataFromJson(Map<String, dynamic> json) =>
    NavidromeData(
        server: json['server'] as String,
        user: json['user'] as String,
        password: json['password'] as String,
      )
      ..subsonicSalt = json['subsonicSalt'] as String?
      ..subsonicToken = json['subsonicToken'] as String?
      ..token = json['token'] as String?;

Map<String, dynamic> _$NavidromeDataToJson(NavidromeData instance) =>
    <String, dynamic>{
      'server': instance.server,
      'user': instance.user,
      'password': instance.password,
      'subsonicSalt': instance.subsonicSalt,
      'subsonicToken': instance.subsonicToken,
      'token': instance.token,
    };
