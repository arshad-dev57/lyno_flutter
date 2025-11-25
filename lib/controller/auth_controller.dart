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
        print('Token received: $token');

        SharedPreferences preferences = await SharedPreferences.getInstance();
        final saved = await preferences.setString("token", token);
        print("Saved token: $saved");

        // Navigate to Dashboard after successful login
        Get.offAll(
          () => DashboardScreen(),
        ); // Use offAll to clear the stack and go to Dashboard
      } else {
        // Print the error details for debugging
        print('Login failed with status code: ${response.statusCode}');
        Get.snackbar(
          'Error',
          'Invalid credentials, please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      // Print the error for debugging
      print('Error occurred: $e');
      Get.snackbar(
        'Error $e',
        'An error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
