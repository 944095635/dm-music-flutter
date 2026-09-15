import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dm_music/model/music.dart';

/// 主页逻辑
class HomeLogic extends GetxController with StateMixin {
  /// 热门音乐
  final List<Music> hotMusic = [];

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
      hotMusic.add(Music.fromJson(element));
    }

    // 更新状态
    change(null, status: RxStatus.success());
  }
}
