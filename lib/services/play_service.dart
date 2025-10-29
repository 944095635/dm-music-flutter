import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

/// 播放服务
class PlayService extends GetxService {
  /// 播放器实例
  late AudioPlayer _player;

  @override
  void onInit() {
    super.onInit();
    //初始化音频服务
    _player = AudioPlayer();

    // /// 播放顺序变化
    // _player.currentIndexStream.listen((int? index) {
    //   //debugPrint("播放下标变化:${index ?? 0}");
    //   playIndex = index;
    // });
  }
}
