import 'package:dm_music/models/music_source.dart';
import 'package:dm_music/pages/init/init_logic.dart';
import 'package:dm_music/pages/init/widgets/init_item.dart';
import 'package:dm_music/values/strings.dart';
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "选择播放源",
                  style: theme.textTheme.bodyLarge,
                ),

                10.verticalSpace,

                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: InitItem(
                        "DMusic",
                        "assets/images/logo.png",
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
                        "Navidrome",
                        "assets/images/navidrome.png",
                        controller.type == MusicSourceType.navidrome,
                        onTap: () {
                          controller.changeMusicSource(
                            MusicSourceType.navidrome,
                          );
                        },
                      ),
                    ),
                    Spacer(),
                  ],
                ),

                40.verticalSpace,

                /// 选择了对应的播放源 - 显示对应的播放源提示
                switch (controller.type) {
                  null => SizedBox.shrink(),
                  MusicSourceType.dmusic => _buildDMusicInfo(theme),
                  MusicSourceType.navidrome => SizedBox.shrink(),
                },
              ],
            ),
          ),
        ),

        SliverFillRemaining(
          hasScrollBody: false,
          child: SafeArea(
            top: false,
            minimum: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FilledButton(
                onPressed: controller.type != null
                    ? controller.onTapStart
                    : null,
                child: Text("开始使用"),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// DMusic 播放源的信息
  Widget _buildDMusicInfo(ThemeData theme) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Strings.appName,
          style: theme.textTheme.bodyLarge,
        ),
        Text(
          "App官方数据源，支持本地音乐",
        ),
      ],
    );
  }
}
