import 'dart:convert';

import 'package:dm_music/apis/cloud_music_api/cloud_music_api.dart';
import 'package:dm_music/apis/cloud_music_api/models/cloud_music.dart';
import 'package:dm_music/apis/cloud_music_api/models/cloud_play_list.dart';
import 'package:dm_music/apis/test_api.dart';
import 'package:dm_music/models/music.dart';
import 'package:dm_music/models/play_list.dart';
import 'package:dm_music/pages/play/play_page.dart';
import 'package:dm_music/services/app_service.dart';
import 'package:dm_music/services/play_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class HomeLogic extends GetxController with StateMixin {
  /// App 服务
  AppService appService = Get.find();

  /// 播放服务
  final PlayService playService = Get.find();

  /// 最近播放列表
  final List<Music> newReleases = List.empty(growable: true);

  /// 最近播放列表
  final List<Music> songs = List.empty(growable: true);

  /// 歌单
  final List<CloudPlayList> playList = List.empty(growable: true);


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
    playList.addAll(await CloudMusicApi.playlist());

    change(null, status: RxStatus.success());
  }

  /// 点击音乐卡片
  void onTapMusic(int index) {
    playService.setPlaylist(songs, index: index);
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

  void onTapPlayList(PlayList playList) async {
    var url = Uri.http('*', '/api/song', {
      "album_id": playList.id,
    });
    var response = await http.get(
      url,
      headers: {"X-Nd-Authorization": "Bearer ${appService.token}"},
    );
    if (response.statusCode == 200) {
      List<dynamic> maps = json.decode(response.body);
      List<Music> songs = List.empty(growable: true);
      for (var map in maps) {
        String source =
            "http://*/rest/stream?u=" +
            appService.userName +
            "&t=25c3ac222ba61a1a71f253aa44a18b22&s=daa3a0&f=json&v=1.8.0&c=NavidromeUI&id=" +
            map["id"] +
            "&_=1762966848799";
        debugPrint(source);
        //http://*/rest/stream?u=dm&t=25c3ac222ba61a1a71f253aa44a18b22&s=daa3a0&f=json&v=1.8.0&c=NavidromeUI&id=fc262a3d9533947f6258fbb3cd864d91&_=1762966848799

        songs.add(
          Music()
            ..author = map["artist"]
            ..name = map["title"]
            ..cover = "http://music.dmskin.com/music/Neon Tears.jpg"
            ..source = source,

          ///vol2/1002/音乐/1-1737/0425-很久以后-G.E.M.邓紫棋.wav
        );
      }
      if (songs.isNotEmpty) {
        playService.setPlaylist(songs);
      }
    }
  }
}
