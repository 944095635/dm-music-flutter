import 'package:flutter/material.dart';

/// 播放按钮的事件封装
mixin class IplayControl {
  Function()? onTapPlay;

  Function()? onTapPlayList;

  Function()? onTapPrevious;

  Function()? onTapNext;

  AnimationController? controller;
}
