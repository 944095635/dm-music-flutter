import 'package:dm_music/themes/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled/size_extension.dart';
import 'package:get/get.dart';
import 'package:dm_music/pages/frame/frame_end_drawer_item.dart';
import 'package:dm_music/values/strings.dart';
import 'package:dm_music/widgets/blur_widget.dart';

/// 首页右侧菜单
class FrameEndDrawer extends StatelessWidget {
  const FrameEndDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlurWidget(
      radius: BorderRadius.circular(15),
      child: Drawer(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return CustomScrollView(
      slivers: [
        SliverSafeArea(
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.pagePadding),
              child: Column(
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
                    false,
                    tag: "测试数据",
                    onTap: () {
                      Get.back();
                      //Get.to(() => LoginPage());
                      //Get.to(() => InitPage());
                      Get.toNamed('/step2', id: 1);
                    },
                  ),
                  20.verticalSpace,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
