import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class ThemeButton extends StatelessWidget {
  const ThemeButton(this.isPC, {super.key});

  final bool isPC;

  @override
  Widget build(BuildContext context) {
    /// 主题
    ThemeData theme = Theme.of(context);

    double? iconSize = isPC ? 16 : null;

    return IconButton(
      onPressed: () {
        if (Get.isDarkMode) {
          Get.changeThemeMode(ThemeMode.light);
        } else {
          Get.changeThemeMode(ThemeMode.dark);
        }
      },
      icon: SvgPicture.asset(
        'assets/svgs/moon_bold.svg',
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
