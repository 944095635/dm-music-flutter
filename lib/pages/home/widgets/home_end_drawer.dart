import 'package:dm_music/pages/init/init_page.dart';
import 'package:dm_music/pages/init/widgets/init_item.dart';
import 'package:dm_music/pages/login/login_page.dart';
import 'package:dm_music/services/app_service.dart';
import 'package:dm_music/values/strings.dart';
import 'package:dm_music/widgets/blur_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled/size_extension.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 首页右侧菜单
class HomeEndDrawer extends StatelessWidget {
  const HomeEndDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    AppService appService = Get.find();
    return BlurWidget(
      radius: BorderRadius.circular(15),
      child: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            children: [
              Row(
                spacing: 10,
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    width: 48,
                    height: 48,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Strings.appName,
                      ),
                      Text(
                        "v2.0.6",
                      ),
                    ],
                  ),
                ],
              ),
              20.verticalSpace,

              FilledButton(
                onPressed: () {
                  Get.back();
                  //Get.to(() => LoginPage());
                  Get.to(() => InitPage());
                },
                child: Text("更换播放源"),
              ),

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
