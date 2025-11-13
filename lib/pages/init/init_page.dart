import 'package:dm_music/pages/home/home_page.dart';
import 'package:dm_music/services/app_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled/size_extension.dart';
import 'package:get/get.dart';

/// 初始化页面
class InitPage extends StatelessWidget {
  const InitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        minimum: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Spacer(),
            FilledButton(
              onPressed: () {
                Get.find<AppService>().inited();
                Get.offAll(() => HomePage());
              },
              child: Text("START USE"),
            ),
            20.verticalSpace,
          ],
        ),
      ),
    );
  }
}
