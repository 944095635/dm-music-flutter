// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_source.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MusicSource _$MusicSourceFromJson(Map<String, dynamic> json) => MusicSource(
  data: json['data'],
  id: json['id'] as String,
  type: $enumDecode(_$MusicSourceTypeEnumMap, json['type']),
);

Map<String, dynamic> _$MusicSourceToJson(MusicSource instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$MusicSourceTypeEnumMap[instance.type]!,
      'data': instance.data,
    };

const _$MusicSourceTypeEnumMap = {
  MusicSourceType.dmusic: 'dmusic',
  MusicSourceType.navidrome: 'navidrome',
};
