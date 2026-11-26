/// 接口地址常量。
abstract final class ApiEndpoints {
  static const String baseUrl = 'http://music.dmskin.com';

  /// 新歌推荐
  static const String newReleases = '/music/new_releases/new_releases.json';

  /// 流行推荐
  static const String popular = '/music/popular/popular.json';
}
