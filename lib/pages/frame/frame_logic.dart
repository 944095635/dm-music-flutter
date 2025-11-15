import 'package:dm_music/helpers/cache_helper.dart';
import 'package:dm_music/models/music_source.dart';
import 'package:get/get.dart';

/// 框架导航页逻辑
class FrameLogic extends GetxController {
  /// 当前数据源
  String? sourceId;

  /// 数据源列表
  List<MusicSource> sourceList = List.empty(growable: true);

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  void _initData() async {
    sourceId = await CacheHelper.getSourceId();
    // 添加默认数据
    sourceList.add(
      MusicSource(id: MusicSourceType.dmusic.id, type: MusicSourceType.dmusic),
    );
    List<MusicSource>? newSourceList = await CacheHelper.getSourceList();
    if (newSourceList != null) {
      sourceList.addAll(newSourceList);
      update();
    }

    String route = Get.arguments["route"];
    Get.toNamed(route, id: 1);
  }

  /// 切换播放源
  void changeSource(MusicSource source) async {
    await CacheHelper.setSourceId(source.id);
    sourceId = source.id;
    Get.back();
    Get.toNamed(source.type.route, id: 1);
  }
}
