import 'package:dm_music/pages/login/login_logic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends GetView<LoginLogic> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LoginLogic());
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: controller.usernameController,
                decoration: const InputDecoration(
                  labelText: '用户名',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? '请输入用户名' : null,
              ),
              TextFormField(
                controller: controller.passwordController,
                decoration: const InputDecoration(
                  labelText: '密码',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (v) => (v == null || v.isEmpty) ? '请输入密码' : null,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: controller.onTapLogin,
                child: const Text('登录'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      // 记住我/切换逻辑可在此处实现
                    },
                    child: const Text('记住我'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('忘记密码？'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
