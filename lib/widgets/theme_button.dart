import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class ThemeButton extends StatelessWidget {
  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    /// 主题
    ThemeData theme = Theme.of(context);

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
        width: 16,
        height: 16,
        colorFilter: ColorFilter.mode(
          theme.colorScheme.onSurface,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
