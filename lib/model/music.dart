/// 音乐模型
class Music {
  final String author;
  final String name;
  final String source;
  final String cover;

  Music({
    required this.author,
    required this.name,
    required this.source,
    required this.cover,
  });

  factory Music.fromJson(Map<String, dynamic> json) => Music(
    author: json['author'],
    name: json['name'],
    source: json['source'],
    cover: json['cover'],
  );
}
