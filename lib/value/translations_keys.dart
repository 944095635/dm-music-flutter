import 'package:get/get.dart';

/// 语言翻译键
class TranslationsKeys extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'zh_CN': {
      'hello': 'Hallo Welt',
      'settings': '设置',
      'language': '语言',
      'theme': '主题',
      'recently_played': '最近播放',
      'new_releases': '新歌推荐',
      'popular': '流行推荐',
      'performance_mode': '性能模式',
      'performance_mode_note': '渐变质感非常考验设备性能，如遇卡顿可切换为磨砂质感',
      'performance_mode_1': '磨砂质感',
      'performance_mode_2': '渐变质感',
    },
    'en_US': {
      'hello': 'Hello World',
      'settings': 'Settings',
      'language': 'Language',
      'theme': 'Theme',
      'recently_played': 'RECENTLY PLAYED',
      'new_releases': 'NEW RELEASES',
      'popular': 'POPULAR',
      'performance_mode': 'Performance Mode',
      'performance_mode_note': 'Gradient blur is resource-intensive and may cause lag on some devices. Switch to matte texture for smoother performance.',
      'performance_mode_1': 'Matte Effect',
      'performance_mode_2': 'Gradient Blur',
    },
  };
}
