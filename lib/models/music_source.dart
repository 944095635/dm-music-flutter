import 'package:json_annotation/json_annotation.dart';

part 'music_source.g.dart';

/// 音乐数据源
@JsonSerializable()
class MusicSource {
  // 唯一标识（初期使用url）
  final String id;

  /// 播放源类型
  final MusicSourceType type;

  // 登录数据
  final dynamic data;

  const MusicSource({
    this.data,
    required this.id,
    required this.type,
  });

  factory MusicSource.fromJson(Map<String, dynamic> json) =>
      _$MusicSourceFromJson(json);

  Map<String, dynamic> toJson() => _$MusicSourceToJson(this);
}

/// 音乐数据源类型
enum MusicSourceType {
  // 支持官方播放源 和 本地音乐源
  dmusic(
    "dmusic",
    "DMusic",
    "assets/images/logo.png",
    "/dmusic",
  ),
  // 音乐数据源
  navidrome(
    "navidrome",
    "Navidrome",
    "assets/images/navidrome.png",
    "/navidrome",
  );

  final String id;
  final String name;
  final String route;
  final String icon;
  const MusicSourceType(
    this.id,
    this.name,
    this.icon,
    this.route,
  );
}
