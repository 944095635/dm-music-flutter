import 'package:dm_music/apis/cloud_music_api/cloud_music_api.dart';
import 'package:dm_music/apis/cloud_music_api/models/cloud_music.dart';
import 'package:dm_music/apis/cloud_music_api/models/cloud_play_list.dart';
import 'package:dm_music/apis/test_api.dart';
import 'package:dm_music/models/music.dart';
import 'package:dm_music/pages/play/play_page.dart';
import 'package:dm_music/services/play_service.dart';
import 'package:get/get.dart';

class HomeLogic extends GetxController with StateMixin {
  /// 播放服务
  final PlayService playService = Get.find();

  /// 最近播放列表
  final List<Music> newReleases = List.empty(growable: true);

  /// 最近播放列表
  final List<Music> songs = List.empty(growable: true);

  /// 歌单
  List<CloudPlayList> playList = List.empty(growable: true);

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  void _initData() async {
    songs.addAll(TestApi.getMusicList());
    //recentlyPlayed.addAll(TestApi.getMusicList1());

    // 获取最新音乐
    List<CloudMusic> newSongsData = await CloudMusicApi.personalizedNewsong();
    for (var newSong in newSongsData) {
      newReleases.add(
        Music()
          ..author = newSong.author?.join(",") ?? ""
          ..name = newSong.name
          ..cover = newSong.cover!
          ..source = newSong.source!,
      );
    }

    // 获取最新音乐
    playList = await CloudMusicApi.playlist();

    change(null, status: RxStatus.success());
  }

  /// 点击音乐卡片
  void onTapMusic(int index) {
    playService.setPlaylist(value!, index: index);
  }

  /// 点击最最新歌曲
  void onTapRecentlyMusic(int index) {
    playService.setPlaylist(newReleases, index: index);
  }

  /// 跳转到播放页面
  void onTapPlay() {
    Get.to(() => PlayPage());
  }

  void onTapPlayListItem(CloudPlayList newMusic) async {
    // 获取最新音乐
    List<CloudMusic> newSongsData = await CloudMusicApi.playListDetail(
      data: {"id": newMusic.id},
    );
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
    playService.setPlaylist(songs);
  }
}
