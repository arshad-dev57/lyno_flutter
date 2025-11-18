import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lyno_cms/controller/dashboard_controller.dart';
import 'package:lyno_cms/screens/Category_Screen.dart';
import 'package:lyno_cms/screens/catelogue_screen.dart';
import 'package:lyno_cms/screens/homescreen.dart';
import 'package:lyno_cms/screens/order_screen.dart';
import 'package:lyno_cms/screens/product_screen.dart';

class DashboardScreen extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());

  DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 250,
            color: Colors.white,
            child: Column(
              children: [
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
                // Menu Items
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
                      _buildMenuItem(Icons.grid_view_outlined, 'Category', 2),
                      _buildMenuItem(
                        Icons.grid_view_outlined,
                        'Sub Category',
                        3,
                      ),
                      _buildMenuItem(Icons.people_outline, 'products', 4),
                      // _buildMenuItem(
                      //   Icons.local_shipping_outlined,
                      //   'Shipping',
                      //   4,
                      // ),
                      _buildMenuItem(
                        Icons.settings_outlined,
                        'Configuration',
                        6,
                      ),
                    ],
                  ),
                ),
                // Storage Usage
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
          // Main Content
          Expanded(
            child: Obx(() {
              if (controller.selectedIndex.value == 1) {
                return OrdersScreen();
              }
              if (controller.selectedIndex.value == 2) {
                return CatalogueScreen();
              }
              if (controller.selectedIndex.value == 3) {
                return CategoryScreen();
              }
              if (controller.selectedIndex.value == 4) {
                return ProductScreen();
              }
              return HomeScreen();
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
