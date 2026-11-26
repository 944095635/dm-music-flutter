import 'package:dio/dio.dart';

import 'package:dm_music/core/models/music.dart';
import 'package:dm_music/core/models/playlist.dart';
import 'package:dm_music/core/network/api_endpoints.dart';
import 'package:dm_music/core/network/cloud_music_api.dart';
import 'package:dm_music/core/network/dio_client.dart';

/// 首页推荐数据访问。
class HomeRepository {
  HomeRepository({Dio? dio, CloudMusicApi? cloudMusicApi})
    : _dio = dio ?? createDioClient(),
      _cloudMusicApi = cloudMusicApi ?? CloudMusicApi();

  final Dio _dio;
  final CloudMusicApi _cloudMusicApi;

  /// 新歌推荐
  Future<List<Music>> fetchNewReleases() =>
      _fetchMusic(ApiEndpoints.newReleases);

  /// 流行推荐
  Future<List<Music>> fetchPopular() => _fetchMusic(ApiEndpoints.popular);

  /// 网易云推荐歌单（weapi 加密接口）
  Future<List<Playlist>> fetchPlaylists() => _cloudMusicApi.fetchPlaylists();

  /// 网易云歌单曲目（详情 + 播放地址）
  Future<List<Music>> fetchPlaylistTracks(String playlistId) =>
      _cloudMusicApi.fetchPlaylistTracks(playlistId);

  Future<List<Music>> _fetchMusic(String path) async {
    final response = await _dio.get<List<dynamic>>(path);
    final data = response.data;
    if (data == null) return const <Music>[];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Music.fromJson)
        .toList(growable: false);
  }
}
