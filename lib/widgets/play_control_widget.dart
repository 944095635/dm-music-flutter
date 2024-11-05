import 'package:flutter/material.dart';

/// 播放按钮的事件封装
abstract class PlayControlWidget extends StatefulWidget {
  final Function()? onTapPlay;

  final Function()? onTapPlayList;

  final Function()? onTapPrevious;

  final Function()? onTapNext;

  final AnimationController controller;

  const PlayControlWidget({
    super.key,
    this.onTapPlayList,
    required this.onTapPlay,
    required this.onTapNext,
    required this.onTapPrevious,
    required this.controller,
  });
}
