import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dm_music/core/audio/play_provider.dart';
import 'package:dm_music/core/models/music.dart';
import 'package:dm_music/core/models/playlist.dart';
import 'package:dm_music/modules/home/repositories/home_cache.dart';
import 'package:dm_music/modules/home/repositories/home_repository.dart';

/// 首页数据访问实例。测试时可替换此 provider 注入模拟数据。
final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepository(),
);

/// 首页三组推荐数据，合并为一份供单一异步加载组件消费。
class HomeData {
  const HomeData({
    required this.newMusic,
    required this.popular,
    required this.playlists,
  });

  final List<Music> newMusic;
  final List<Music> popular;
  final List<Playlist> playlists;
}

/// 首页状态：两组推荐共用一份异步状态，统一加载 / 错误 / 重试。
class HomeState {
  const HomeState(this.data);

  final AsyncValue<HomeData> data;
}

/// 首页状态。首次由页面调用 [HomeNotifier.load] 发起请求。
final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState(AsyncLoading<HomeData>());

  /// 请求成功写缓存；失败时读缓存兜底，无缓存才保留错误状态。
  Future<AsyncValue<List<T>>> _loadGroup<T>(
    Future<List<T>> Function() fetch,
    String cacheKey,
    T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final cache = await ref.read(homeCacheProvider.future);
    final result = await AsyncValue.guard(fetch);
    if (result.hasValue) {
      // 缓存写入是尽力而为：写失败也不能让本次成功的数据展示不出来。
      try {
        await cache.write(cacheKey, result.value!, toJson);
      } catch (_) {
        // 忽略写入失败（如存储空间不足），不影响数据返回。
      }
      return result;
    }
    final cached = cache.read(cacheKey, fromJson);
    if (cached != null) return AsyncData(cached);
    return result;
  }

  /// 并发请求三组推荐，合并成一份异步状态。
  ///
  /// 新歌 / 流行保持严格策略：任一组失败（且无缓存兜底）整组进入错误态，
  /// 由统一组件提供重试。歌单走 weapi 加密接口，稳定性较差，
  /// 作为可选数据容错处理：失败时降级为空列表，不拖垮另外两组。
  Future<void> load() async {
    final repository = ref.read(homeRepositoryProvider);
    state = HomeState(
      await AsyncValue.guard(() async {
        final results = await Future.wait([
          _loadGroup<Music>(
            repository.fetchNewReleases,
            HomeCache.newReleasesKey,
            Music.fromJson,
            (item) => item.toJson(),
          ),
          _loadGroup<Music>(
            repository.fetchPopular,
            HomeCache.popularKey,
            Music.fromJson,
            (item) => item.toJson(),
          ),
          _loadGroup<Playlist>(
            repository.fetchPlaylists,
            HomeCache.playlistsKey,
            Playlist.fromJson,
            (item) => item.toJson(),
          ),
        ]);
        final newMusic = results[0] as AsyncValue<List<Music>>;
        final popular = results[1] as AsyncValue<List<Music>>;
        final playlists = results[2] as AsyncValue<List<Playlist>>;
        if (newMusic.hasError) throw newMusic.error!;
        if (popular.hasError) throw popular.error!;
        return HomeData(
          newMusic: newMusic.value ?? const <Music>[],
          popular: popular.value ?? const <Music>[],
          // 歌单失败或超时不阻断首页，降级为空列表。
          playlists: playlists.value ?? const <Playlist>[],
        );
      }),
    );
  }

  /// 统一重试两组推荐。
  Future<void> reload() => load();

  /// 拉取网易云歌单曲目并开始播放。
  ///
  /// 两步网络请求（详情 + 播放地址）期间静默处理，不展示加载态；
  /// 失败或无曲目时直接返回，不打扰用户。曲目顺序保持不变，
  /// 无播放地址的曲目 source 为空，由播放器跳过。
  Future<void> playPlaylist(Playlist playlist) async {
    try {
      final repository = ref.read(homeRepositoryProvider);
      final tracks = await repository.fetchPlaylistTracks(playlist.id);
      if (tracks.isEmpty) return;
      await ref.read(playProvider.notifier).playFromList(tracks);
    } catch (_) {
      // 静默处理：接口失效或网络异常时不打断浏览。
    }
  }
}
