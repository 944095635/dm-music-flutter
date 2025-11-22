import 'package:dm_music/models/music.dart';
import 'package:dm_music/services/play_service.dart';
import 'package:get/get.dart';
import 'package:dm_music/apis/navidrome_api.dart';
import 'package:dm_music/helpers/cache_helper.dart';
import 'package:dm_music/models/login_data/navidrome_data.dart';
import 'package:dm_music/models/music_source.dart';

/// 服务主页
class HomeNavidromeLogic extends GetxController with StateMixin {
  /// 播放服务
  final PlayService playService = Get.find();

  /// 专辑列表
  final List<Map> albumList = List.empty(growable: true);

  /// 当前的数据源
  NavidromeData? data;

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  /// 初始化数据
  void _initData() async {
    MusicSource? source = await CacheHelper.getSource();
    if (source != null) {
      data = NavidromeData.fromJson(source.data);
      // 加载专辑
      var result = await NavidromeApi.getAlbumList(
        data: data!,
        type: "newest", //"recent", // "newest",
      );
      if (result.status && result.data != null) {
        // 成功之后读取数据列表
        Map albumListMap = result.data!["albumList"];
        List<dynamic> albumMaps = albumListMap["album"];
        for (var albumMap in albumMaps) {
          String coverArt = albumMap["coverArt"];
          String cover = await NavidromeApi.getCoverUrl(data!, coverArt);
          albumMap["cover"] = cover;
          albumList.add(albumMap);
        }
      }
    }
    change(null, status: RxStatus.success());
  }

  /// 点击专辑
  void onTapAlbum(Map album) async {
    // 加载专辑
    String id = album["id"];
    var result = await NavidromeApi.getAlbum(data!, id: id);
    if (result.status && result.data != null) {
      // 成功之后读取数据列表
      Map album = result.data!["album"];
      List<dynamic> songMaps = album["song"];
      List<Music> musics = List.empty(growable: true);
      for (var songMap in songMaps) {
        Music music = Music();
        music.name = songMap["title"];
        String id = songMap["id"];
        String coverArt = songMap["coverArt"];
        music.author = songMap["artist"];
        music.source = await NavidromeApi.getStream(data!, id);
        music.cover = await NavidromeApi.getCoverUrl(data!, coverArt);
        musics.add(music);
      }
      playService.setPlaylist(musics);
    }
  }
}
