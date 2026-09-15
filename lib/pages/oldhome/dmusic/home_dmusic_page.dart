import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dm_music/pages/oldhome/dmusic/home_dmusic_logic.dart';

/// DMUSIC - 主页
class HomeDmusicPage extends GetView<HomeDmusicLogic> {
  const HomeDmusicPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeDmusicLogic());

    /// 底部安全区域 48
    final double bottomSafeHeight = MediaQuery.of(context).padding.bottom;

    // 底部容器整体高度 180 + 48
    final double barSafeHeight = 180 + bottomSafeHeight;
    return Scaffold(
      body: controller.obx(
        (state) => _buildBody(barSafeHeight),
      ),
    );
  }

  /// Body
  Widget _buildBody(double bottomHeight) {
    return CustomScrollView(
      slivers: [
        SliverSafeArea(
          minimum: EdgeInsets.only(
            // left: 15,
            // right: 15,
            bottom: bottomHeight + 20,
          ),
          sliver: SliverMainAxisGroup(
            slivers: [
             
            ],
          ),
        ),
      ],
    );
  }
}
