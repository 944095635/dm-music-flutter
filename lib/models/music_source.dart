/// 音乐数据源
class MusicSource {
  late MusicSourceType type;
  late String host;
  late String port;
  late String name;
  late String pwd;
}

/// 音乐数据源类型
enum MusicSourceType {
  /// 支持官方播放源 和 本地音乐源
  dmusic,

  /// 音乐数据源
  navidrome,
}
