import 'package:dm_music/api/test_api.dart';
import 'package:dm_music/mixin/play_mixin.dart';
import 'package:dm_music/models/music.dart';
import 'package:dm_music/pages/play/index.dart';
import 'package:dm_music/services/play_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin, StateMixin<List<Music>>, PlayMixin {
  HomeController();

  /// 播放信息显示
  var displayMusicInfo = false.obs;

  /// 脚手架组件用于打开和关闭侧边窗
  var scaffoldKey = GlobalKey<ScaffoldState>();

  /// 打开侧边栏
  void openDrawer() {
    scaffoldKey.currentState?.openEndDrawer();
  }

  /// 关闭侧边栏
  void closeDrawer() {
    scaffoldKey.currentState?.closeEndDrawer();
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  _initData() async {
    value = TestApi.getMusicList();
    change(GetStatus.success(value));
    if (music.value != null) {
      displayMusicInfo.value = true;
    }
  }

  @override
  void dispose() {
    close();
    super.dispose();
  }

  /// 点击播放的音乐
  void onTapPlayMusic() async {
    // Navigator.of(Get.context!).push(MaterialPageRoute(
    //   builder: (context) {
    //     return const PlayPage();
    //   },
    // ));

    // TODO GETX 网页跳转有一点问题
    // await Navigator.of(Get.context!).push(
    //   CupertinoPageRoute(
    //     builder: (context) {
    //       return const PlayPage();
    //     },
    //   ),
    // );
    // Get.delete<PlayController>();

    Get.to(() => const PlayPage(), transition: Transition.downToUp);
  }

  /// 点击音乐列表 - 将音乐添加到播放列表
  void onTapPlayList(int index) async {
    PlayService playService = Get.find<PlayService>();
    await playService.stop();
    await playService.updatePlayList(value, index);
    await playService.play();

    /// 显示菜单
    displayMusicInfo.value = true;
  }
}
