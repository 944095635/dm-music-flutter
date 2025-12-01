// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_lrc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MusicLrc _$MusicLrcFromJson(Map<String, dynamic> json) => MusicLrc()
  ..lang = json['lang'] as String
  ..line = (json['line'] as List<dynamic>)
      .map((e) => MusicLrcLine.fromJson(e as Map<String, dynamic>))
      .toList()
  ..synced = json['synced'] as bool;

Map<String, dynamic> _$MusicLrcToJson(MusicLrc instance) => <String, dynamic>{
  'lang': instance.lang,
  'line': instance.line,
  'synced': instance.synced,
};

MusicLrcLine _$MusicLrcLineFromJson(Map<String, dynamic> json) => MusicLrcLine()
  ..start = (json['start'] as num).toInt()
  ..value = json['value'] as String;

Map<String, dynamic> _$MusicLrcLineToJson(MusicLrcLine instance) =>
    <String, dynamic>{'start': instance.start, 'value': instance.value};
