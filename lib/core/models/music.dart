/// 歌曲信息，对应推荐接口返回的一条数据。
class Music {
  const Music({
    required this.name,
    required this.author,
    required this.source,
    required this.cover,
  });

  final String name;
  final String author;
  final String source;
  final String cover;

  factory Music.fromJson(Map<String, dynamic> json) => Music(
        name: json['name'] as String? ?? '',
        author: json['author'] as String? ?? '',
        source: json['source'] as String? ?? '',
        cover: json['cover'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'author': author,
        'source': source,
        'cover': cover,
      };
}
