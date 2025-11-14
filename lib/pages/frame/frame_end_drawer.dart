import 'package:dm_music/pages/frame/frame_end_drawer_item.dart';
import 'package:dm_music/services/app_service.dart';
import 'package:dm_music/values/strings.dart';
import 'package:dm_music/widgets/blur_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled/size_extension.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 首页右侧菜单
class FrameEndDrawer extends StatelessWidget {
  const FrameEndDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    AppService appService = Get.find();
    return BlurWidget(
      radius: BorderRadius.circular(15),
      child: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              FrameEndDrawerItem(
                Strings.appName,
                "assets/images/logo.png",
                true,
                tag: "官方播放源 V2.0.7",
                onTap: () {
                  Get.back();
                  //Get.to(() => LoginPage());
                  //Get.to(() => InitPage());
                  Get.toNamed('/home', id: 1);
                },
              ),
              10.verticalSpace,

              FrameEndDrawerItem(
                "Navidrome",
                "assets/images/navidrome.png",
                true,
                tag: "测试数据",
                onTap: () {
                  Get.back();
                  //Get.to(() => LoginPage());
                  //Get.to(() => InitPage());
                  Get.toNamed('/step2', id: 1);
                },
              ),
              20.verticalSpace,

              if (appService.isLogin) ...{
                Text(appService.name),
                FilledButton(
                  onPressed: () async {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.clear();
                  },
                  child: Text("Logout"),
                ),
              } else
                ...{},
            ],
          ),
        ),
      ),
    );
  }
}
