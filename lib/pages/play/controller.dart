import 'package:dm_music/mixin/play_mixin.dart';
import 'package:get/get.dart';

class PlayController extends GetxController
    with GetSingleTickerProviderStateMixin, PlayMixin {
  PlayController();

  final String lyric = "";

  @override
  void onClose() {
    close();
    super.onClose();
  }
}
