import 'package:dm_music_flutter/widgets/blur_widget.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget getAppBar({
  double appHeight = 80,
  Widget? title,
  Widget? leading,
  List<Widget>? actions,
  PreferredSize? bottom,
  required BorderRadius radius,
  required Color backgroundColor,
}) {
  if (actions != null) {
    actions.add(const SizedBox(width: 8));
  }
  return PreferredSize(
    preferredSize: Size(0, appHeight),
    child: BlurWidget(
      radius: radius,
      backgroundColor: backgroundColor,
      child: AppBar(
        title: title,
        toolbarHeight: appHeight,
        leading: leading,
        leadingWidth: 80,
        titleSpacing: 20,
        actions: actions,
        bottom: bottom,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    ),
  );
}
