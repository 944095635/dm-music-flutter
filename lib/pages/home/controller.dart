import 'package:dm_music/api/cloud_music_api/cloud_music_api.dart';
import 'package:dm_music/api/cloud_music_api/models/cloud_music.dart';
import 'package:dm_music/api/cloud_music_api/models/cloud_play_list.dart';
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

  /// 新歌排行榜
  List<Music> newSongs = List.empty(growable: true);

  /// 歌单
  List<CloudPlayList> playList = List.empty(growable: true);

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  _initData() async {
    value = TestApi.getMusicList();

    // 获取最新音乐
    List<CloudMusic> newSongsData = await CloudMusicApi.personalizedNewsong();
    for (var newSong in newSongsData) {
      newSongs.add(
        Music()
          ..author = newSong.author?.join(",") ?? ""
          ..name = newSong.name
          ..cover = newSong.cover!
          ..source = newSong.source!,
      );
    }

    // 获取最新音乐
    playList = await CloudMusicApi.playlist();

    change(GetStatus.success(value));
    // if (music.value != null) {
    //   displayMusicInfo.value = true;
    // }
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

    Get.to(() => const PlayPage(), transition: Transition.fadeIn);
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

  @override
  onTapPlay() {
    bool play = super.onTapPlay();
    if (music.value != null) {
      if (play) {
        /// 显示菜单
        displayMusicInfo.value = true;
      } else {
        displayMusicInfo.value = false;
      }
    }
    return play;
  }

  void onTapPlayNewSong(Music newMusic) async {
    PlayService playService = Get.find<PlayService>();
    await playService.stop();
    await playService.updatePlayList(newSongs, newSongs.indexOf(newMusic));
    await playService.play();

    /// 显示菜单
    displayMusicInfo.value = true;
  }

  void onTapPlayListItem(CloudPlayList newMusic) async {
    // 获取最新音乐
    List<CloudMusic> newSongsData =
        await CloudMusicApi.playListDetail(data: {"id": newMusic.id});
    List<Music> songs = List.empty(growable: true);
    for (var newSong in newSongsData) {
      songs.add(
        Music()
          ..author = newSong.author?.join(",") ?? ""
          ..name = newSong.name
          ..cover = newSong.cover!
          ..source = newSong.source,
      );
    }

    PlayService playService = Get.find<PlayService>();
    await playService.stop();
    await playService.updatePlayList(songs, 0);
    await playService.play();

    music.value = songs.first;

    /// 显示菜单
    displayMusicInfo.value = true;
  }
}
