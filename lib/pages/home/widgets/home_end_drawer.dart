import 'package:dm_music/pages/login/login_page.dart';
import 'package:dm_music/services/app_service.dart';
import 'package:dm_music/widgets/blur_widget.dart';
import 'package:flutter/material.dart';
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
              } else ...{
                FilledButton(
                  onPressed: () {
                    Get.back();
                    Get.to(() => LoginPage());
                  },
                  child: Text("Login"),
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}
