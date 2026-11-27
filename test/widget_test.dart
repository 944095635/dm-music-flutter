import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dm_music/app/app.dart';
import 'package:dm_music/core/models/music.dart';
import 'package:dm_music/core/models/playlist.dart';
import 'package:dm_music/modules/home/providers/home_provider.dart';
import 'package:dm_music/modules/home/repositories/home_cache.dart';
import 'package:dm_music/modules/home/repositories/home_repository.dart';
import 'package:dm_music/modules/splash/views/splash_view.dart';
import 'package:dm_music/shared/widgets/error_view.dart';

const List<Music> _newReleases = [
  Music(id: 'new1', name: '新歌一', author: '', source: '', cover: ''),
];
const List<Music> _popular = [
  Music(id: 'pop1', name: '流行一', author: '', source: '', cover: ''),
];

/// 测试用首页数据源：返回固定数据，不发起真实 HTTP 请求。
class _FakeHomeRepository extends HomeRepository {
  @override
  Future<List<Music>> fetchNewReleases() async => _newReleases;

  @override
  Future<List<Music>> fetchPopular() async => _popular;

  @override
  Future<List<Playlist>> fetchPlaylists() async => const [];
}

/// 可手动控制完成时机的数据源，用于验证加载阶段行为。
class _DelayedHomeRepository extends HomeRepository {
  final newReleases = Completer<List<Music>>();
  final popular = Completer<List<Music>>();

  @override
  Future<List<Music>> fetchNewReleases() => newReleases.future;

  @override
  Future<List<Music>> fetchPopular() => popular.future;

  @override
  Future<List<Playlist>> fetchPlaylists() async => const [];
}

/// 流行推荐始终失败的数据源。
class _PopularFailureRepository extends HomeRepository {
  int popularRequests = 0;

  @override
  Future<List<Music>> fetchNewReleases() async => _newReleases;

  @override
  Future<List<Music>> fetchPopular() async {
    popularRequests++;
    throw StateError('模拟失败');
  }

  @override
  Future<List<Playlist>> fetchPlaylists() async => const [];
}

/// 推进若干帧，让异步数据链路走完。
///
/// 首页加载态有无限旋转的 CircularProgressIndicator，不能用 pumpAndSettle。
Future<void> _flush(WidgetTester tester, [int frames = 5]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump();
  }
}

/// 推进到首页，返回后首页处于请求发起后的状态。
Future<void> _enterHome(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
  // 首页路由配有渐显过渡，推进到过渡结束。
  await tester.pump(const Duration(seconds: 1));
  await _flush(tester);
}

Future<void> _pumpApp(WidgetTester tester, HomeRepository repository) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [homeRepositoryProvider.overrideWithValue(repository)],
      child: const App(),
    ),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('启动页跳转首页后展示新歌与流行推荐', (tester) async {
    await _pumpApp(tester, _FakeHomeRepository());

    expect(find.byType(SplashView), findsOneWidget);

    await _enterHome(tester);

    expect(find.byType(SplashView), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('新歌推荐'), findsOneWidget);
    expect(find.text('新歌一'), findsOneWidget);
    expect(find.text('流行推荐'), findsOneWidget);
    expect(find.text('流行一'), findsOneWidget);
  });

  testWidgets('两组请求都结束前只显示一个加载指示器，结束后才显示列表', (tester) async {
    final repo = _DelayedHomeRepository();
    await _pumpApp(tester, repo);

    await _enterHome(tester);
    expect(find.byType(SplashView), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('新歌推荐'), findsNothing);
    expect(find.text('流行推荐'), findsNothing);

    // 只完成新歌一组，仍需等待流行组，列表仍不显示。
    repo.newReleases.complete(_newReleases);
    await _flush(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('新歌推荐'), findsNothing);

    // 两组都完成后才渲染列表。
    repo.popular.complete(_popular);
    await _flush(tester);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('新歌一'), findsOneWidget);
    expect(find.text('流行一'), findsOneWidget);
  });

  testWidgets('一组失败且无缓存时，整页进入错误态并提供重试', (tester) async {
    final repo = _PopularFailureRepository();
    await _pumpApp(tester, repo);

    await _enterHome(tester);

    // 任一组失败且无缓存兜底，整组进入错误态：不展示列表。
    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('新歌推荐'), findsNothing);
    expect(find.text('新歌一'), findsNothing);
    // 非 Dio 异常走统一兜底文案。
    expect(find.text('未知错误，请稍后重试'), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget);

    // 点击重试会重新发起请求。
    await tester.tap(find.text('重试'));
    await _flush(tester);
    expect(repo.popularRequests, 2);
  });

  testWidgets('一组失败但有缓存时，用缓存兜底展示列表', (tester) async {
    const cachedPopular = [
      Music(id: 'cached1', name: '缓存流行', author: '', source: '', cover: ''),
    ];
    SharedPreferences.setMockInitialValues({
      HomeCache.newReleasesKey: jsonEncode(
        _newReleases.map((music) => music.toJson()).toList(),
      ),
      HomeCache.popularKey: jsonEncode(
        cachedPopular.map((music) => music.toJson()).toList(),
      ),
    });
    await _pumpApp(tester, _PopularFailureRepository());

    await _enterHome(tester);

    expect(find.byType(ErrorView), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('新歌一'), findsOneWidget);
    expect(find.text('缓存流行'), findsOneWidget);
  });
}
