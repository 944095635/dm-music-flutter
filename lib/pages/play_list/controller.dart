import 'package:dm_music/models/music.dart';
import 'package:dm_music/services/play_service.dart';
import 'package:get/get.dart';

class PlayListController extends GetxController with StateMixin<List<Music>?> {
  PlayListController();

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  _initData() {
    PlayService playService = Get.find<PlayService>();
    value = playService.getPlayList();

    if (value != null && value!.isNotEmpty) {
      change(GetStatus.success(value));
    }
  }

  // @override
  // void onClose() {
  //   super.onClose();
  // }
}
