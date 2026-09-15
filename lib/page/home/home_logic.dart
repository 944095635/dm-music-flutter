import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dm_music/model/music.dart';

/// 主页逻辑
class HomeLogic extends GetxController with StateMixin {
  /// 最近播放列表
  final List<Music> playMusic = [];

  /// 最新官方音乐
  final List<Music> newMusic = [];

  @override
  void onInit() {
    super.onInit();
    initMusic();
  }

  /// 初始化热门音乐
  Future<void> initMusic() async {
    // await Future.delayed(const Duration(seconds: 3));
    var response = await http.get(
      Uri.parse('http://music.dmskin.com/music/music_hot.json'),
    );
    var data = json.decode(response.body);
    for (var element in data) {
      newMusic.add(Music.fromJson(element));
    }

    // 更新状态
    change(null, status: RxStatus.success());
  }

  /// 播放音乐 - 插入最近播放列表
  void onPlay(Music music) {
    // 移除重复项
    if (playMusic.contains(music)) {
      playMusic.remove(music);
    }
    // 插入到最前面
    playMusic.insert(0, music);
    // 数量超过10项，移除最后一项
    if (playMusic.length > 10) {
      playMusic.removeLast();
    }

    // 更新状态
    change(null, status: RxStatus.success());
  }
}
