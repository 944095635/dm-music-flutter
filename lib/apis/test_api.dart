import 'package:dm_music/models/music.dart';

class TestApi {
  /// 最近播放
  static List<Music> getMusicList1() {
    List<Music> musics = List.empty(growable: true);

    //--------------------------------------------
    // 增加测试音频
    musics.add(
      Music()
        ..name = "When You (Lukas Termena's Balearic Remix)"
        ..author = "The Madison"
        ..source = "http://music.dmskin.com/music/wy.flac"
        ..cover = "http://music.dmskin.com/music/wy.jpg",
    );

    musics.add(
      Music()
        ..name = "Everyday（Remix）"
        ..author = "KRIK"
        ..source = "http://music.dmskin.com/music/eyd.mp3"
        ..cover = "http://music.dmskin.com/music/eyd.jpg",
    );

    musics.add(
      Music()
        ..name = "Stuck On Replay (Radio Edit)"
        ..author = "Scooter"
        ..source = "http://music.dmskin.com/music/sor.mp3"
        ..cover = "http://music.dmskin.com/music/ss.jpg",
    );

    musics.add(
      Music()
        ..name = "光年之外"
        ..author = "邓紫棋"
        ..source = "http://music.dmskin.com/music/gnzw.mp3"
        ..cover = "http://music.dmskin.com/music/gnzw.jpg",
    );

    musics.add(
      Music()
        ..name = "是一场烟火"
        ..author = "胡彦斌"
        ..source = "http://music.dmskin.com/music/sycyh.flac"
        ..cover = "http://music.dmskin.com/music/sycyh.jpg",
    );

    musics.add(
      Music()
        ..name = "你若是风"
        ..author = "胡彦斌"
        ..source = "http://music.dmskin.com/music/nrsf.flac"
        ..cover = "http://music.dmskin.com/music/sycyh.jpg",
    );

    return musics;
  }

  static List<Music> getMusicList() {
    List<Music> musics = List.empty(growable: true);

    //--------------------------------------------
    // 增加测试音频

    musics.add(
      Music()
        ..name = "Neon Tears"
        ..author = "Antent"
        ..source = "http://music.dmskin.com/music/Neon Tears by Antent.mp4"
        ..cover = "http://music.dmskin.com/music/Neon Tears.jpg",
    );

    musics.add(
      Music()
        ..name = "SHINE BRIGHT"
        ..author = "ANA"
        ..source = "http://music.dmskin.com/music/ANA%20-%20SHINE%20BRIGHT.mp3"
        ..cover = "http://music.dmskin.com/music/a2.jpg",
    );

    musics.add(
      Music()
        ..name = "M (Above & Beyond remix)"
        ..author = "浜崎あゆみ"
        ..source = "http://music.dmskin.com/music/M.m4a"
        ..cover = "http://music.dmskin.com/music/M (Above & Beyond remix).jpg",
    );

    musics.add(
      Music()
        ..name = "10 Out Of 10"
        ..author = "Oliver Heldens / Kylie Minogue"
        ..source = "http://music.dmskin.com/music/02.m4a"
        ..cover = "http://music.dmskin.com/music/2.jpg",
    );

    musics.add(
      Music()
        ..name = "Feels Like Home"
        ..author = "Andrew Rayel"
        ..source = "http://music.dmskin.com/music/01.m4a"
        ..cover = "http://music.dmskin.com/music/01.jpg",
    );

    musics.add(
      Music()
        ..name = "Nu"
        ..author = "DJ Project"
        ..source =
            "http://music.dmskin.com/music/DJ%20ProjectGiulia%20-%20Nu.flac"
        ..cover = "http://music.dmskin.com/music/djproject.jpg",
    );

    musics.add(
      Music()
        ..name = "Sólblóm 向日葵"
        ..author = "BRÍET"
        ..source = "http://music.dmskin.com/music/03.m4a"
        ..cover = "http://music.dmskin.com/music/xiangrikui.jpg",
    );

    musics.add(
      Music()
        ..name = "牛郎织女"
        ..author = "陈冠希"
        ..source = "http://music.dmskin.com/music/04.m4a"
        ..cover = "http://music.dmskin.com/music/04.jpg",
    );

    musics.add(
      Music()
        ..name = "Crazy Little Love"
        ..author = "Nuage"
        ..source = "http://music.dmskin.com/music/05.mp3"
        ..cover = "http://music.dmskin.com/music/05.jpg",
    );

    return musics;
  }
}
