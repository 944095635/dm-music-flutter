import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginLogic extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void onTapLogin() async {
    var state = formKey.currentState?.validate();
    if (state is bool && state) {
      String userName = usernameController.text.trim();
      String password = passwordController.text.trim();

      const String _baseUrl = '110.42.51.36:4533';
      const String _apiPath = '/rest';

      var url = Uri.http('110.42.51.36:4533', '/auth/login');
      var data = {
        "username": userName,
        "password": password,
        // "v": "1.16.1",
        // "c": "dmusic",
        // "f": "json",
      };
      var response = await http.post(url, body: json.encode(data));
      if (response.statusCode == 200) {
        debugPrint(response.body);
        String jsonBody = response.body;
        Map map = json.decode(jsonBody);
        if (map.containsKey("token")) {
          String token = map["token"];
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("token", token);
          prefs.setString("name", map["name"]);
          prefs.setString("username", map["username"]);
          Get.back(result: true);
        }
      }
    }
  }
}
