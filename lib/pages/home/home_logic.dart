import 'package:dm_music/apis/test_api.dart';
import 'package:dm_music/models/music.dart';
import 'package:dm_music/services/play_service.dart';
import 'package:get/get.dart';

class HomeLogic extends GetxController with StateMixin<List<Music>> {
  /// 播放服务
  final PlayService playService = Get.find();

  @override
  void onInit() {
    super.onInit();
    value = List.empty(growable: true);
    _initData();
  }

  void _initData() {
    value = TestApi.getMusicList();
    change(value, status: RxStatus.success());
  }

  /// 点击音乐卡片
  void onTapMusic(Music music) {
    playService.playMusic(music);
  }
}
