import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:dm_music/core/audio/play_provider.dart';
import 'package:dm_music/core/models/music.dart';
import 'package:dm_music/modules/home/widgets/player_controls.dart';
import 'package:dm_music/modules/home/widgets/player_progress_slider.dart';
import 'package:dm_music/shared/widgets/blur_view.dart';
import 'package:dm_music/shared/widgets/empty_view.dart';

/// 全屏播放页：模糊封面背景铺满上半屏，中央大封面，底部为曲目信息、
/// 进度条与播放控制。
///
/// 进度、时长、播放状态统一来自 [playProvider]，页面本身只在切歌时重建；
/// 进度推进由 PlayerProgressSlider 内部局部更新，不带动本页 rebuild。
class PlayView extends ConsumerWidget {
  const PlayView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final music = ref.watch(
      playProvider.select((state) => state.currentMusic),
    );

    return Scaffold(
      appBar: AppBar(),
      // 让内容延伸到 AppBar 背后，模糊背景铺满整屏。
      extendBodyBehindAppBar: true,
      body: music == null
          ? const EmptyView()
          : LayoutBuilder(
              builder: (context, constraints) => _buildBody(music, constraints),
            ),
    );
  }

  Widget _buildBody(Music music, BoxConstraints constraints) {
    // 封面按屏宽的 65% 取值，与旧版一致；模糊背景只占上方 80% 高度。
    final imageSize = constraints.maxWidth * 0.65;
    final backdropHeight = constraints.maxHeight * 0.8;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 模糊背景：低分辨率封面拉伸铺满上半屏，再叠加大半径模糊形成氛围底色。
        if (music.cover.isNotEmpty) ...[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: backdropHeight,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: music.cover,
                width: imageSize,
                height: imageSize,
                // 极小内存缓存：原图只用于模糊，保留细节没有意义。
                memCacheWidth: 20,
                memCacheHeight: 20,
                fit: BoxFit.fill,
              ),
            ),
          ),
          // sigma 150 做氛围模糊，color 传 null 不叠装饰层，与旧版播放页一致。
          const BlurView(sigmaX: 150, sigmaY: 150, color: null),
        ],
        // 前景：大封面 + 曲目信息 + 进度 + 控制。
        Column(
          children: [
            const Spacer(),
            if (music.cover.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: music.cover,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  memCacheWidth: 600,
                ),
              ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 30,
                  right: 30,
                  bottom: 80,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildMusicTitle(music),
                    const SizedBox(height: 10),
                    const PlayerProgressSlider(
                      showTimeText: true,
                      sliderType: .line,
                    ),
                    const SizedBox(height: 20),
                    const PlayerControls(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMusicTitle(Music music) {
    return Row(
      children: [
        Expanded(
          child: Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                music.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 20, fontWeight: .bold),
              ),
              Text(
                music.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        // 歌词入口：暂未实现，先占位保留 UI 结构。
        IconButton(onPressed: () {}, icon: const Text('词')),
      ],
    );
  }
}
