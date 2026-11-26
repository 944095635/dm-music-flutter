import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:dm_music/app/app.dart';
import 'package:dm_music/core/models/music.dart';
import 'package:dm_music/modules/home/providers/home_provider.dart';
import 'package:dm_music/modules/home/repositories/home_repository.dart';
import 'package:dm_music/modules/splash/views/splash_view.dart';

/// 测试用首页数据源，返回固定数据，避免发起真实 HTTP 请求。
class _FakeHomeRepository extends HomeRepository {
  @override
  Future<List<Music>> fetchNewReleases() async => const [
        Music(
          name: '新歌一',
          author: '歌手甲',
          source: '',
          cover: '',
        ),
      ];

  @override
  Future<List<Music>> fetchPopular() async => const [
        Music(
          name: '流行一',
          author: '歌手乙',
          source: '',
          cover: '',
        ),
      ];
}

/// 可手动控制完成时机的数据源，用于验证加载阶段行为。
class _DelayedHomeRepository extends HomeRepository {
  final newReleases = Completer<List<Music>>();
  final popular = Completer<List<Music>>();

  @override
  Future<List<Music>> fetchNewReleases() => newReleases.future;

  @override
  Future<List<Music>> fetchPopular() => popular.future;
}

/// 一组成功一组失败的数据源，用于验证失败组单独展示错误视图。
class _PartialFailureRepository extends HomeRepository {
  @override
  Future<List<Music>> fetchNewReleases() async => const [
        Music(name: '新歌一', author: '歌手甲', source: '', cover: ''),
      ];

  @override
  Future<List<Music>> fetchPopular() async => throw StateError('模拟失败');
}

/// 推进到首页，返回后首页处于请求发起后的状态。
Future<void> _enterHome(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
  // 首页此时可能在展示加载指示器（无限动画），用定时推进代替 pumpAndSettle。
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump();
}

void main() {
  testWidgets('启动页跳转首页后展示新歌与流行推荐', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeRepositoryProvider.overrideWithValue(_FakeHomeRepository()),
        ],
        child: const App(),
      ),
    );

    expect(find.byType(SplashView), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(SplashView), findsNothing);
    expect(find.text('新歌推荐'), findsOneWidget);
    expect(find.text('新歌一'), findsOneWidget);
    expect(find.text('流行推荐'), findsOneWidget);
    expect(find.text('流行一'), findsOneWidget);
  });

  testWidgets('两组请求都结束前只显示一个加载指示器，结束后才显示列表', (tester) async {
    final repo = _DelayedHomeRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [homeRepositoryProvider.overrideWithValue(repo)],
        child: const App(),
      ),
    );

    await _enterHome(tester);
    expect(find.byType(SplashView), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('新歌推荐'), findsNothing);
    expect(find.text('流行推荐'), findsNothing);

    // 只完成新歌一组，仍需等待流行组，列表仍不显示。
    repo.newReleases.complete(const [
      Music(name: '新歌一', author: '歌手甲', source: '', cover: ''),
    ]);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('新歌推荐'), findsNothing);

    // 两组都完成后才渲染列表。
    repo.popular.complete(const [
      Music(name: '流行一', author: '歌手乙', source: '', cover: ''),
    ]);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('新歌一'), findsOneWidget);
    expect(find.text('流行一'), findsOneWidget);
  });

  testWidgets('一组失败时列表仍显示，失败组单独显示错误视图', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeRepositoryProvider.overrideWithValue(_PartialFailureRepository()),
        ],
        child: const App(),
      ),
    );

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // 列表区域正常显示，失败组显示错误视图与重试按钮。
    expect(find.text('新歌一'), findsOneWidget);
    expect(find.text('流行一'), findsNothing);
    expect(find.textContaining('加载失败'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });
}
