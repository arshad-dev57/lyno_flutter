import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lyno_cms/controller/chat_controller.dart';
import 'package:lyno_cms/controller/dashboard_controller.dart';

import 'package:lyno_cms/screens/Category_Screen.dart';
import 'package:lyno_cms/screens/ads_screen.dart';
import 'package:lyno_cms/screens/banner_screen.dart';
import 'package:lyno_cms/screens/catelogue_screen.dart';
import 'package:lyno_cms/screens/chat_screen.dart';
import 'package:lyno_cms/screens/homescreen.dart';
import 'package:lyno_cms/screens/order_screen.dart';
import 'package:lyno_cms/screens/product_screen.dart';

class DashboardScreen extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());

  /// ChatController global register (permanent)
  /// YAHAN REAL TOKEN + USER ID SET KARO
  final ChatController chatController = Get.put(
    ChatController(
      token:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2OGY3MzVjOTlmZWZlMGM5ODAxMGNhMDYiLCJpYXQiOjE3NjM3MjM4ODF9._PNTp9-Y-9JBU1vfgmYVBxF_MnAu7WpwOS-cnjK5-jo",
      currentUserId: '68f735c99fefe0c98010ca06',
    ),
    permanent: true,
  );

  DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ---------------- LEFT SIDEBAR ----------------
          Container(
            width: 250,
            color: Colors.white,
            child: Column(
              children: [
                // Top profile / branding
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF008060),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.shopping_bag,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LYNO ADMIN',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Admin',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.keyboard_arrow_down, size: 20),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // ---------------- MENU ITEMS ----------------
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildMenuItem(Icons.dashboard_outlined, 'Dashboard', 0),
                      _buildMenuItem(
                        Icons.shopping_bag_outlined,
                        'Orders',
                        1,
                        true,
                      ),
                      _buildMenuItem(
                        Icons.chat_bubble_outline,
                        'Chats',
                        7,
                      ), // chat tab
                      _buildMenuItem(Icons.grid_view_outlined, 'Category', 2),
                      _buildMenuItem(
                        Icons.grid_view_outlined,
                        'Sub Category',
                        3,
                      ),
                      _buildMenuItem(Icons.people_outline, 'products', 4),
                      _buildMenuItem(Icons.grid_view_outlined, 'Banner', 5),
                      _buildMenuItem(Icons.grid_view_outlined, 'Ads', 6),
                      _buildMenuItem(
                        Icons.settings_outlined,
                        'Configuration',
                        8,
                      ),
                    ],
                  ),
                ),

                // ---------------- STORAGE USAGE ----------------
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Storage usage:',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            '25%',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.25,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF008060),
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ---------------- RIGHT MAIN CONTENT ----------------
          Expanded(
            child: Obx(() {
              switch (controller.selectedIndex.value) {
                case 1:
                  return OrdersScreen();
                case 2:
                  return CatalogueScreen();
                case 3:
                  return CategoryScreen();
                case 4:
                  return ProductScreen();
                case 5:
                  return BannerScreen();
                case 6:
                  return AdsScreen();
                case 7:
                  // 🔥 Chat Screen (GetX + Socket integrated)
                  return ChatScreen(
                    // token: chatController.token,
                    // currentUserId: chatController.currentUserId,
                  );
                default:
                  return HomeScreen();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    int index, [
    bool isSelected = false,
  ]) {
    return Obx(() {
      final selected = controller.selectedIndex.value == index;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: selected ? Colors.grey[100] : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            size: 20,
            color: selected ? Colors.black87 : Colors.grey[600],
          ),
          title: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? Colors.black87 : Colors.grey[700],
            ),
          ),
          dense: true,
          onTap: () => controller.changeScreen(index),
        ),
      );
    });
  }
}
