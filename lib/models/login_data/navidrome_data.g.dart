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
    );

Map<String, dynamic> _$NavidromeDataToJson(NavidromeData instance) =>
    <String, dynamic>{
      'server': instance.server,
      'user': instance.user,
      'password': instance.password,
    };
