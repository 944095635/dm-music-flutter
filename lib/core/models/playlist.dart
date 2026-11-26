/// 网易云推荐歌单，对应 weapi/playlist/list 返回的一条歌单。
class Playlist {
  const Playlist({
    required this.id,
    required this.name,
    required this.author,
    required this.cover,
  });

  final String id;
  final String name;
  final String author;
  final String cover;

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
    id: json['id']?.toString() ?? '',
    name: json['name'] as String? ?? '',
    author: json['author'] as String? ?? '',
    cover: json['cover'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'author': author,
    'cover': cover,
  };
}
