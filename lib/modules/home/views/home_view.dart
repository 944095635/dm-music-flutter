import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;

import 'package:animate_do/animate_do.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:dm_music/core/audio/play_provider.dart';
import 'package:dm_music/core/models/music.dart';
import 'package:dm_music/core/models/playlist.dart';
import 'package:dm_music/core/network/error_message.dart';
import 'package:dm_music/modules/home/providers/home_provider.dart';
import 'package:dm_music/modules/home/widgets/music_cover_card.dart';
import 'package:dm_music/modules/home/widgets/now_playing_card.dart';
import 'package:dm_music/modules/home/widgets/player_controls.dart';
import 'package:dm_music/modules/home/widgets/player_curve_backdrop.dart';
import 'package:dm_music/modules/home/widgets/player_progress_slider.dart';
import 'package:dm_music/modules/home/widgets/section_title.dart';
import 'package:dm_music/shared/widgets/async_state_view.dart';
import 'package:dm_music/shared/widgets/blur_view.dart';
import 'package:dm_music/shared/widgets/empty_view.dart';
import 'package:dm_music/shared/widgets/error_view.dart';

/// 首页：展示新歌推荐与流行推荐两组数据。
///
/// 两组数据合并为一份异步状态，由单个 AsyncStateView 统一处理
/// 加载 / 数据 / 空 / 错误四态，共用一次重试。
class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  // 底部控制区高度（不含系统底部安全区）。
  static const double _controlHeight = 100;
  // 播放信息卡高度。
  static const double _infoCardHeight = 84;

  // 信息卡上滑动画的控制器，由 SlideInUp 创建并释放，这里只持引用驱动。
  AnimationController? _slideController;

  // 接收 SlideInUp 内部创建的控制器引用。
  void _captureSlideController(AnimationController controller) {
    _slideController = controller;
  }

  @override
  void initState() {
    super.initState();
    // 合并后的 Notifier 不在 build 时自动请求，进入页面时主动发起。
    ref.read(homeProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    _listenPlaying();

    final data = ref.watch(homeProvider).data;
    // 只订阅「有无曲目」的布尔值：切歌前后都是 true，HomeView 不会因此重建。
    // 当前曲目由 NowPlayingCard 自行订阅，把重建范围收在信息卡内。
    final hasMusic = ref.watch(
      playProvider.select((state) => state.currentMusic != null),
    );

    // 只订阅 padding 变化（键盘、旋转等），不因文本缩放等其它 MediaQuery 变化重建。
    // 一次读取，往下传参，避免多处重复 MediaQuery.of(context)。
    final viewPadding = MediaQuery.paddingOf(context);
    // 顶部让开状态栏 + AppBar（body 穿透到 AppBar 背后）。
    final topSafeHeight = viewPadding.top + kToolbarHeight;
    // 底部安全高度：iOS 为 0（系统手势区由系统自行处理），其余取系统底部 inset。
    final bottomSafeHeight = defaultTargetPlatform == TargetPlatform.iOS
        ? 0.0
        : viewPadding.bottom;
    // 蒙版覆盖控制区 + 安全区；控制条从安全区上方开始排布。
    final curveHeight = _controlHeight + bottomSafeHeight;
    // 播放区整体高度 = 信息卡 + 蒙版（控制区 + 安全区）。
    final playerAreaHeight = _infoCardHeight + curveHeight;

    return Scaffold(
      // 列表可滚到 AppBar 下方，由模糊遮罩压暗背景。
      appBar: AppBar(
        title: const Text('DMusic'),
        flexibleSpace: const BlurView(),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildAsyncContent(data, playerAreaHeight, topSafeHeight),
          if (hasMusic)
            _buildPlayerArea(playerAreaHeight, curveHeight, bottomSafeHeight),
        ],
      ),
    );
  }

  /// 播放状态变化时驱动信息卡上滑 / 下滑（与播放按钮动画同步）。
  void _listenPlaying() {
    ref.listen(playProvider.select((state) => state.playing), (_, playing) {
      final slideController = _slideController;
      if (slideController == null) return;
      if (playing) {
        slideController.forward();
      } else {
        slideController.reverse();
      }
    });
  }

  /// 加载 / 错误 / 空三态共用的居中容器：从 AppBar 下方开始算起。
  ///
  /// body 穿透到 AppBar 背后（extendBodyBehindAppBar=true），
  /// 直接 Center 会按整屏高度居中，视图会沉到 AppBar 下面。
  Widget _buildCenteredState(Widget child, double topSafeHeight) {
    return Padding(
      padding: EdgeInsets.only(top: topSafeHeight),
      child: Center(child: child),
    );
  }

  /// 铺满 body 的异步区：加载 / 错误 / 空居中显示，数据态才渲染滚动列表。
  Widget _buildAsyncContent(
    AsyncValue<HomeData> data,
    double playerAreaHeight,
    double topSafeHeight,
  ) {
    return Positioned.fill(
      child: AsyncStateView<HomeData>(
        value: data,
        // 加载 / 错误 / 空三态统一走 _buildCenteredState，避免重复布局。
        onLoading: () => _buildCenteredState(
          const CircularProgressIndicator(),
          topSafeHeight,
        ),
        onEmpty: () => _buildCenteredState(const EmptyView(), topSafeHeight),
        onError: (error, _) => _buildCenteredState(
          ErrorView(
            message: friendlyErrorMessage(error),
            onRetry: ref.read(homeProvider.notifier).reload,
          ),
          topSafeHeight,
        ),
        // 两组都为空才视为空；一组有数据就正常展示。
        isEmpty: (value) => value.newMusic.isEmpty && value.popular.isEmpty,
        data: (value) => CustomScrollView(
          slivers: _buildSlivers(value, playerAreaHeight, topSafeHeight),
        ),
      ),
    );
  }

  /// 列表 slivers：顶部让开状态栏 + AppBar，底部留出播放区高度，左右统一留 12 边距。
  List<Widget> _buildSlivers(
    HomeData data,
    double playerAreaHeight,
    double topSafeHeight,
  ) {
    return [
      SliverSafeArea(
        minimum: EdgeInsets.only(
          left: 12,
          right: 12,
          top: topSafeHeight,
          bottom: playerAreaHeight,
        ),
        sliver: SliverMainAxisGroup(
          slivers: [
            const SliverToBoxAdapter(child: SectionTitle('新歌推荐')),
            _buildNewMusicSliver(data.newMusic),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            const SliverToBoxAdapter(child: SectionTitle('流行推荐')),
            _buildPopularSliver(data.popular),
            // 歌单走 weapi，失败会降级为空列表；无数据时整节隐藏，不留空标题。
            if (data.playlists.isNotEmpty) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              const SliverToBoxAdapter(child: SectionTitle('推荐歌单')),
              _buildPlaylistSliver(data.playlists),
            ],
          ],
        ),
      ),
    ];
  }

  /// 新歌推荐：列表 sliver。左右边距由外层 SliverSafeArea.minimum 统一提供。
  Widget _buildNewMusicSliver(List<Music> items) {
    if (items.isEmpty) return const SliverToBoxAdapter(child: EmptyView());
    return SliverList.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final music = items[index];
        return SizedBox(
          height: 150,
          child: GestureDetector(
            onTap: () => ref
                .read(playProvider.notifier)
                .playFromList(items, index: index),
            child: MusicCoverCard(
              name: music.name,
              author: music.author,
              cover: music.cover,
            ),
          ),
        );
      },
    );
  }

  /// 流行推荐：网格 sliver。左右边距由外层 SliverSafeArea.minimum 统一提供。
  Widget _buildPopularSliver(List<Music> items) {
    if (items.isEmpty) return const SliverToBoxAdapter(child: EmptyView());
    return SliverGrid.builder(
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 3 / 3.5,
      ),
      itemBuilder: (context, index) {
        final music = items[index];
        return GestureDetector(
          onTap: () => ref
              .read(playProvider.notifier)
              .playFromList(items, index: index),
          child: MusicCoverCard(
            name: music.name,
            author: music.author,
            cover: music.cover,
          ),
        );
      },
    );
  }

  /// 推荐歌单：网格 sliver，复用音乐封面卡片展示封面 / 名称 / 作者。
  /// 左右边距由外层 SliverSafeArea.minimum 统一提供，2 列、比例与流行推荐一致。
  Widget _buildPlaylistSliver(List<Playlist> items) {
    return SliverGrid.builder(
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 3 / 3.5,
      ),
      itemBuilder: (context, index) {
        final playlist = items[index];
        return GestureDetector(
          onTap: () => ref.read(homeProvider.notifier).playPlaylist(playlist),
          child: MusicCoverCard(
            name: playlist.name,
            author: playlist.author,
            cover: playlist.cover,
          ),
        );
      },
    );
  }

  /// 底部播放区：信息卡 + 圆弧蒙版 + 进度条 + 控制条。
  Widget _buildPlayerArea(
    double playerAreaHeight,
    double curveHeight,
    double bottomSafeHeight,
  ) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: playerAreaHeight,
      child: Stack(
        children: [
          // 信息卡铺满播放区，随播放状态上滑显示 / 下滑隐藏。
          // 隔离切歌换封面/文字的 repaint，避免沿父链冒泡到根节点造成整屏重绘。
          // 注意：extendBodyBehindAppBar=true 时 AppBar 的 BlurView 会形成整屏合成层，
          // 整屏重绘发生在合成层级别，此 boundary 挡不住、会失效；
          // 只有 extendBodyBehindAppBar=false（paint 冒泡路径）时才有效。
          Positioned.fill(
            child: RepaintBoundary(
              child: SlideInUp(
                from: 105,
                controller: _captureSlideController,
                child: const NowPlayingCard(),
              ),
            ),
          ),
          // 蒙版贴屏幕底，覆盖控制区 + 安全区。
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: curveHeight,
            child: PlayerCurveBackdrop(
              size: Size.fromHeight(curveHeight),
              color: Colors.black,
            ),
          ),
          // 进度条贴控制条上沿：曲线模式，松手跳转。
          // 不给固定高度，让内容按自身高度贴 bottom 排布，
          // 开启时间文本时向上延展而不会压缩滑块的点击区域。
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomSafeHeight + 75,
            child: const PlayerProgressSlider(),
          ),
          // 控制条抬到安全区上方，避免被系统手势条 / Home Indicator 遮挡。
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomSafeHeight,
            height: _controlHeight,
            child: const PlayerControls(),
          ),
        ],
      ),
    );
  }
}
