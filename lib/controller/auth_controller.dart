import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lyno_cms/screens/dashboard_screen.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final String apiUrl = "https://lyno-shopping.vercel.app";

  Future<void> Login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/api/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String token = data['token'];
        print(token);
        SharedPreferences preferences = await SharedPreferences.getInstance();
        final saved = preferences.setString("token", token);
        print("saved token $saved");
        Get.to(DashboardScreen());
      } else {
        Get.snackbar(
          'Error',
          'Invalid credentials, please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
