import 'package:dm_music/models/music_source.dart';
import 'package:dm_music/pages/init/init_logic.dart';
import 'package:dm_music/pages/init/widgets/init_item.dart';
import 'package:dm_music/themes/dimensions.dart';
import 'package:dm_music/values/strings.dart';
import 'package:dm_music/widgets/sliver_bottom_widget.dart';
import 'package:dm_music/widgets/theme_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled/size_extension.dart';
import 'package:get/get.dart';

/// 初始化页面（复用）
/// 选择一个数据源
/// 记录数据源然后进入对应的页面
class InitPage extends GetView<InitLogic> {
  const InitPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(InitLogic());

    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.appName),
        centerTitle: false,
        actions: [
          ThemeButton(),
          5.horizontalSpace,
        ],
      ),
      body: GetBuilder<InitLogic>(
        builder: (controller) {
          return _buildBody(theme);
        },
      ),
    );
  }

  /// Body
  Widget _buildBody(ThemeData theme) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "选择播放源",
                  style: theme.textTheme.titleMedium,
                ),

                10.verticalSpace,

                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: InitItem(
                        MusicSourceType.dmusic.name,
                        MusicSourceType.dmusic.icon,
                        controller.type == MusicSourceType.dmusic,
                        onTap: () {
                          controller.changeMusicSource(
                            MusicSourceType.dmusic,
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: InitItem(
                        MusicSourceType.navidrome.name,
                        MusicSourceType.navidrome.icon,
                        controller.type == MusicSourceType.navidrome,
                        onTap: () {
                          controller.changeMusicSource(
                            MusicSourceType.navidrome,
                          );
                        },
                      ),
                    ),
                  ],
                ),

                40.verticalSpace,

                /// 选择了对应的播放源 - 显示对应的播放源提示
                switch (controller.type) {
                  null => SizedBox.shrink(),
                  MusicSourceType.dmusic => _buildDMusicInfo(theme),
                  MusicSourceType.navidrome => _buildInputInfo(theme),
                },
              ],
            ),
          ),
        ),

        SliverBottomWidget.button(
          "开始使用",
          onPressed: controller.inputOK ? controller.onTapStart : null,
        ),
      ],
    );
  }

  /// DMusic 播放源的信息
  Widget _buildDMusicInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Strings.appName,
          style: theme.textTheme.titleMedium,
        ),
        10.verticalSpace,
        Text(
          "App官方数据源，支持本地音乐",
          style: TextStyle(
            color: theme.colorScheme.primary.withAlpha(180),
          ),
        ),
        20.verticalSpace,
        TextButton(
          onPressed: () {},
          child: Text(
            "授权本地权限",
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }

  /// 输入播放源的信息
  Widget _buildInputInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "连接到 ${controller.type?.name ?? ""}",
          style: theme.textTheme.titleMedium,
        ),
        10.verticalSpace,
        Text(
          "服务器",
        ),
        5.verticalSpace,
        TextField(
          controller: controller.serverController,
          decoration: InputDecoration(hintText: "请输入服务器"),
        ),
        20.verticalSpace,
        Text(
          "用户名",
        ),
        5.verticalSpace,
        TextField(
          controller: controller.usernameController,
          decoration: InputDecoration(hintText: "请输入用户名"),
        ),
        20.verticalSpace,
        Text(
          "密码",
        ),
        5.verticalSpace,
        TextField(
          obscureText: true,
          controller: controller.passwordController,
          decoration: InputDecoration(hintText: "请输入密码"),
        ),
      ],
    );
  }
}
