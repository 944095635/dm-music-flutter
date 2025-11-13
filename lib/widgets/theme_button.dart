import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

/// 主题切换按钮
class ThemeButton extends StatelessWidget {
  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    /// 主题
    final ThemeData theme = Theme.of(context);

    final double iconSize = 20;

    final bool isDarkMode = Get.isDarkMode;

    return IconButton(
      onPressed: () {
        if (isDarkMode) {
          Get.changeThemeMode(ThemeMode.light);
        } else {
          Get.changeThemeMode(ThemeMode.dark);
        }
      },
      icon: SvgPicture.asset(
        isDarkMode ? 'assets/svgs/sun_bold.svg' : 'assets/svgs/moon_bold.svg',
        width: iconSize,
        height: iconSize,
        colorFilter: ColorFilter.mode(
          theme.colorScheme.onSurface,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
