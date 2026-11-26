/// 歌曲信息，对应推荐接口返回的一条数据。
class Music {
  const Music({
    required this.id,
    required this.name,
    required this.author,
    required this.source,
    required this.cover,
  });

  /// 稳定唯一标识，用于收藏。
  /// 歌单曲目是网易云返回的 song id；首页静态 JSON 无 id 字段，
  /// 兜底用 source（静态音频地址，稳定且非空），避免动态播放地址变化导致红心丢失。
  final String id;

  final String name;
  final String author;
  final String source;
  final String cover;

  factory Music.fromJson(Map<String, dynamic> json) {
    final source = json['source'] as String? ?? '';
    return Music(
      id: json['id']?.toString() ?? source,
      name: json['name'] as String? ?? '',
      author: json['author'] as String? ?? '',
      source: source,
      cover: json['cover'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'author': author,
        'source': source,
        'cover': cover,
      };
}
