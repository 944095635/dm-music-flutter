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
      'blur': '模糊',
      'recently_played': '最近播放',
      'new_releases': '新歌推荐',
      'popular': '流行推荐',
    },
    'en_US': {
      'hello': 'Hello World',
      'settings': 'Settings',
      'language': 'Language',
      'theme': 'Theme',
      'blur': 'Blur',
      'recently_played': 'RECENTLY PLAYED',
      'new_releases': 'NEW RELEASES',
      'popular': 'POPULAR',
    },
  };
}
