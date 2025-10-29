import 'package:dm_music/apis/test_api.dart';
import 'package:dm_music/models/music.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeLogic extends GetxController
    with StateMixin<List<Music>>, GetSingleTickerProviderStateMixin {
  /// 播放按钮动画控制器
  late AnimationController playButtonController;

  @override
  void onInit() {
    super.onInit();

    playButtonController = AnimationController(vsync: this)
      ..duration = Durations.long2;

    value = List.empty(growable: true);
    _initData();
  }

  void _initData() {
    value = TestApi.getMusicList();
    change(value, status: RxStatus.success());
  }

  void onTapPlayButton() {
    if (showBar.value) {
      playButtonController.reverse();
    } else {
      playButtonController.forward();
    }
    showBar.value = !showBar.value;
  }

  RxBool showBar = false.obs;

  final Rx<Music> music = Rx(
    Music()
      ..name = "Neon Tears"
      ..author = "Antent"
      ..source = "http://music.dmskin.com/music/Neon Tears by Antent.mp4"
      ..cover = "http://music.dmskin.com/music/Neon Tears.jpg",
  );
}
