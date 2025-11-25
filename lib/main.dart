import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lyno_cms/screens/dashboard_screen.dart';
import 'package:lyno_cms/screens/login_screen.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // final prefs = await SharedPreferences.getInstance();

  // String? token = prefs.getString('token');
  // print(token);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String? token;

  const MyApp({Key? key, this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Body Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF008060),
        scaffoldBackgroundColor: const Color(0xFFF6F6F7),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: LoginPage(),
    );
  }
}
