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

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String token = data['token'];
        String userId =
            data['user']['id']; // Extracting user id from the response

        print('Token received: $token');
        print('User ID received: $userId');

        SharedPreferences preferences = await SharedPreferences.getInstance();
        await preferences.setString("token", token);
        await preferences.setString("userId", userId); // Save userId

        print("Saved token: $token");
        print("Saved userId: $userId");
        Get.to(DashboardScreen());
      } else {
        print('Login failed with status code: ${response.statusCode}');
        Get.snackbar(
          'Error',
          'Invalid credentials, please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      Get.snackbar(
        'Error $e',
        'An error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
