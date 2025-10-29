import 'package:dm_music/pages/frame/frame_logic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 框架页面
class FramePage extends GetView<FrameLogic> {
  const FramePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FrameLogic());
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: controller.obx(
        (state) => _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return CustomScrollView(
      slivers: [
        
      ],
    );
  }
}
