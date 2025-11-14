// pubspec.yaml dependencies required:
// get: ^4.6.6
// google_fonts: ^6.1.0

// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lyno_cms/screens/dashboard_screen.dart';
import 'package:lyno_cms/screens/order_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
      home: DashboardScreen(),
    );
  }
}
