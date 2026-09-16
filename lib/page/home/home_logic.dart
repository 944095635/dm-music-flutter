import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dm_music/apis/cloud_music_api/cloud_music_api.dart';
import 'package:dm_music/apis/cloud_music_api/models/cloud_play_list.dart';
import 'package:dm_music/model/music.dart';

/// 主页逻辑
class HomeLogic extends GetxController with StateMixin {
  /// 最新官方音乐
  final List<Music> newMusic = [];

  /// 流行音乐
  final List<Music> popularMusic = [];

  /// 推荐歌单
  final List<CloudPlayList> recommendMusic = [];

  @override
  void onInit() {
    super.onInit();
    initMusic();
  }

  /// 初始化热门音乐
  Future<void> initMusic() async {
    await initNewMusic();

    await initPopularMusic();

    await initRecommendMusic();

    await Future.delayed(const Duration(seconds: 1));

    // 更新状态
    change(null, status: RxStatus.success());
  }

  /// 初始化最新音乐
  Future<void> initNewMusic() async {
    try {
      var response = await http.get(
        Uri.parse(
          'http://music.dmskin.com/music/new_releases/new_releases.json',
        ),
      );
      var data = json.decode(response.body);
      newMusic.clear();
      for (var element in data) {
        newMusic.add(Music.fromJson(element));
      }
    } catch (_) {}
  }

  /// 初始化流行音乐
  Future<void> initPopularMusic() async {
    try {
      final response = await http.get(
        Uri.parse('http://music.dmskin.com/music/popular/popular.json'),
      );
      final data = json.decode(response.body);
      popularMusic.clear();
      for (var element in data) {
        popularMusic.add(Music.fromJson(element));
      }
    } catch (_) {}
  }

  /// 初始化推荐歌单
  Future<void> initRecommendMusic() async {
    try {
      final playList = await CloudMusicApi.playlist();
      recommendMusic.clear();
      recommendMusic.addAll(playList);
    } catch (_) {}
  }

  /// 刷新数据
  Future<void> refreshData() async {
    await initMusic();
  }
}
