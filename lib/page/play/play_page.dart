import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dm_music/page/play/play_logic.dart';

/// 播放页
class PlayPage extends GetView<PlayLogic> {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
