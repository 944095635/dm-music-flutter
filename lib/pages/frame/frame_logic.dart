import 'package:dm_music/apis/test_api.dart';
import 'package:dm_music/models/music.dart';
import 'package:get/get.dart';

class FrameLogic extends GetxController with StateMixin<List<Music>> {
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
}
