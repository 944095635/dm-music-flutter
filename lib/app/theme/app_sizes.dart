/// 全局尺寸常量：跨模块共用的尺寸集中在这里，避免各处散落魔法数字。
abstract final class AppSizes {
  /// 常规图标尺寸：喜欢、上一首、下一首等。
  static const double icon = 24;

  /// 主操作图标尺寸：播放/暂停按钮，比常规图标大一号以突出层级。
  static const double primaryIcon = 32;
}
