import 'package:dm_music_flutter/models/music.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  /// 正在播放
  late RxBool playing = false.obs;

  /// 显示音频信息
  late RxBool showMusicInfo = false.obs;

  /// 当前进度
  ValueNotifier<double> progress = ValueNotifier(0);

  late AnimationController controller;

  /// 音乐列表
  late List<Music> musics = List.empty(growable: true);

  /// 当前播放音乐
  Rxn<Music> currentMusic = Rxn();

  /// 播放器实例
  final player = AudioPlayer();

  @override
  void onInit() {
    super.onInit();

    controller = AnimationController(vsync: this)
      ..drive(
        Tween(
          begin: 0,
          end: 1,
        ),
      )
      ..duration = Durations.long2;

    musics.add(
      Music()
        ..name = "Neon Tears"
        ..auth = "Antent"
        ..url = "http://www.dmskin.com/music/Neon Tears by Antent.mp4"
        ..image = "http://www.dmskin.com/music/Neon Tears.jpg",
    );

    musics.add(
      Music()
        ..name = "SHINE BRIGHT"
        ..auth = "ANA"
        ..url = "http://www.dmskin.com/music/ANA%20-%20SHINE%20BRIGHT.mp3"
        ..image = "http://www.dmskin.com/music/a2.jpg",
    );

    musics.add(
      Music()
        ..name = "M (Above & Beyond remix)"
        ..auth = "浜崎あゆみ"
        ..url = "http://www.dmskin.com/music/M.mp4"
        ..image = "http://www.dmskin.com/music/M (Above & Beyond remix).jpg",
    );

    musics.add(
      Music()
        ..name = "Feels Like Home"
        ..auth = "Andrew Rayel"
        ..url = "http://www.dmskin.com/music/DJ%20ProjectGiulia%20-%20Nu.flac"
        ..image = "http://www.dmskin.com/music/2.jpg",
    );

    musics.add(
      Music()
        ..name = "Nu"
        ..auth = "DJ Project"
        ..url = "http://www.dmskin.com/music/DJ%20ProjectGiulia%20-%20Nu.flac"
        ..image = "http://www.dmskin.com/music/djproject.jpg",
    );

    musics.add(
      Music()
        ..name = "Sólblóm 向日葵"
        ..auth = "BRÍET"
        ..url = "http://www.dmskin.com/music/xiangrikui.mp4"
        ..image = "http://www.dmskin.com/music/xiangrikui.jpg",
    );

    musics.add(
      Music()
        ..name = "Hann er ekki þú 他不是你"
        ..auth = "BRÍET"
        ..url = "http://www.dmskin.com/music/tabushini.mp4"
        ..image = "http://www.dmskin.com/music/a1.jpg",
    );

    player.positionStream.listen((event) {
      if (player.duration != null) {
        progress.value = event.inMicroseconds / player.duration!.inMicroseconds;
        //debugPrint("百分比:$progress");
      }
    });
  }

  /// 更新播放按钮状态
  void updatePlayIcon() {
    if (playing.value) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }

  void stop() async {
    await player.stop();
    playing.value = false;
    updatePlayIcon();
  }

  void play() async {
    if (currentMusic.value != null) {
      playing.value = true;
      player.play();
      showMusicInfo.value = true;
      updatePlayIcon();
    }
  }

  /// 播放音频设备
  void playMusic(Music music) async {
    currentMusic.value = music;
    // Schemes: (https: | file: | asset: )
    await player.setUrl(music.url);
    play();
  }
}
