import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:dm_music/core/models/music.dart';
import 'package:dm_music/core/models/playlist.dart';
import 'package:dm_music/core/network/user_agent.dart';
import 'package:dm_music/core/network/weapi_cipher.dart';

/// 网易云 weapi 客户端：封装首页需要的推荐歌单与歌单播放链路。
class CloudMusicApi {
  CloudMusicApi({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://music.163.com',
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ),
          );

  final Dio _dio;

  /// 接口要求带浏览器 UA 与来源页，否则可能返回空数据。
  /// UA 复用全局常量（与图片请求同源）。
  static final Map<String, String> _headers = {
    'User-Agent': appUserAgent,
    'Referer': 'https://music.163.com',
  };

  /// 统一的 weapi POST：加密参数、按字符串接收（接口返回 text/plain）、
  /// 手动解码并校验 code。所有接口共用，避免各方法重复解析逻辑。
  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> parameters,
  ) async {
    final response = await _dio.post<String>(
      path,
      data: WeapiCipher.encrypt(parameters),
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: _headers,
      ),
    );

    final raw = response.data;
    if (raw == null || raw.isEmpty) {
      throw StateError('网易云接口 $path 返回空内容');
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      throw StateError(
        '网易云接口 $path 返回非 JSON: ${raw.substring(0, raw.length.clamp(0, 100))}',
      );
    }
    if (decoded is! Map<String, dynamic> || decoded['code'] != 200) {
      throw StateError(
        '网易云接口 $path 返回异常: code=${decoded is Map ? decoded['code'] : '未知'}',
      );
    }
    return decoded;
  }

  /// 拉取推荐歌单。
  ///
  /// weapi 返回 code 非 200 视为失败并抛错，由上层走缓存兜底；
  /// 不在这里返回空列表，避免把失败误判成"确实没有歌单"而覆盖缓存。
  Future<List<Playlist>> fetchPlaylists() async {
    final body = await _post(
      '/weapi/playlist/list',
      const {'offset': 0, 'limit': 30},
    );
    final playlists = body['playlists'];
    if (playlists is! List) return const <Playlist>[];
    return playlists
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => Playlist(
            id: item['id']?.toString() ?? '',
            name: item['name'] as String? ?? '',
            author: (item['creator'] as Map?)?['nickname'] as String? ?? '',
            cover: item['coverImgUrl'] as String? ?? '',
          ),
        )
        .toList(growable: false);
  }

  /// 拉取歌单曲目（含播放地址），按详情顺序返回。
  ///
  /// 两步：v6 详情拿 tracks（id/名称/作者/封面），再用 player/url 批量拿地址。
  /// 详情只返回前若干首（当前接口行为），与旧版一致。
  /// 部分曲目因版权/VIP 拿不到地址（url 为 null），此处保留占位，
  /// source 留空串，顺序不变；播放时由播放器跳过失败项。
  Future<List<Music>> fetchPlaylistTracks(String playlistId) async {
    final detail = await _post('/weapi/v6/playlist/detail', {
      'id': playlistId,
      'offset': 0,
      'limit': 1000,
      'n': 1000,
    });
    final playlist = detail['playlist'];
    final tracks = playlist is Map ? playlist['tracks'] : null;
    if (tracks is! List || tracks.isEmpty) return const <Music>[];

    // 先解析出曲目信息与其 id（Music 本身不含 id）。
    final rows = tracks
        .whereType<Map<String, dynamic>>()
        .map((track) {
          final artists = track['ar'];
          final author = artists is List
              ? artists
                    .whereType<Map<String, dynamic>>()
                    .map((artist) => artist['name'] as String? ?? '')
                    .where((name) => name.isNotEmpty)
                    .join(',')
              : '';
          final album = track['al'];
          return _TrackRow(
            id: track['id']?.toString() ?? '',
            name: track['name'] as String? ?? '',
            author: author,
            cover: album is Map ? album['picUrl'] as String? ?? '' : '',
          );
        })
        .toList(growable: false);

    final urls = await _fetchPlayUrls(rows.map((row) => row.id).toList());
    return rows
        .map(
          (row) => Music(
            name: row.name,
            author: row.author,
            source: urls[row.id] ?? '',
            cover: row.cover,
          ),
        )
        .toList(growable: false);
  }

  /// 批量查询播放地址，返回「歌曲 id → url」。
  /// 无地址（版权/VIP）的曲目 url 为空串，保持键存在以便按 id 对齐。
  Future<Map<String, String>> _fetchPlayUrls(List<String> ids) async {
    if (ids.isEmpty) return const <String, String>{};
    // ids 需形如 "[1,2,3]"；List.toString() 自带方括号，不能再套一层。
    final body = await _post('/weapi/song/enhance/player/url', {
      'ids': ids.toString(),
      'br': 350000,
      'csrf_token': '',
    });
    final data = body['data'];
    if (data is! List) return const <String, String>{};
    return {
      for (final item in data.whereType<Map<String, dynamic>>())
        item['id']?.toString() ?? '': item['url'] as String? ?? '',
    };
  }
}

/// 歌单曲目的中间结构：携带 id 以便和播放地址按 id 对齐。
class _TrackRow {
  const _TrackRow({
    required this.id,
    required this.name,
    required this.author,
    required this.cover,
  });

  final String id;
  final String name;
  final String author;
  final String cover;
}
