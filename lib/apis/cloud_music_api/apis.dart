import 'package:dm_music/apis/cloud_music_api/models/music_api.dart';

class Apis {
  /// 播放地址
  static MusicApi playerUrl = MusicApi(
    host: "music.163.com",
    path: "weapi/song/enhance/player/url",
    method: "post",
    parameters: {
      "br": 350000,
    },
  );

  /// 推荐新音乐
  static MusicApi personalizedNewsong = MusicApi(
    host: "music.163.com",
    path: "weapi/personalized/newsong",
    method: "post",
    parameters: {
      "type": "recommend",
    },
  );

  /// 推荐播放列表
  static MusicApi playlist = MusicApi(
    host: "music.163.com",
    path: "weapi/playlist/list",
    method: "post",
    parameters: {},
  );

  /// 歌单详情
  static MusicApi playListDetail = MusicApi(
    host: "music.163.com",
    path: "weapi/v6/playlist/detail",
    method: "post",
    parameters: {},
  );
}
