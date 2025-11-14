import 'package:get/get.dart';

class DashboardController extends GetxController {
  // Sidebar index
  final RxInt selectedIndex = 0.obs;

  // Summary stats
  final RxDouble totalRevenue = 0.0.obs;
  final RxInt totalOrders = 0.obs;
  final RxInt pendingOrders = 0.obs;
  final RxInt deliveredOrders = 0.obs;
  final RxInt cancelledOrders = 0.obs;
  final RxInt totalCustomers = 0.obs;

  // Charts data
  final RxList<DashboardPoint> salesByDay = <DashboardPoint>[].obs;
  final RxList<StatusSlice> statusDistribution = <StatusSlice>[].obs;
  final RxList<TopProduct> topProducts = <TopProduct>[].obs;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard(); // abhi static data fill karega
  }

  void changeScreen(int index) {
    selectedIndex.value = index;
  }

  /// Static (demo) data – baad mein API se replace kar sakte ho
  Future<void> loadDashboard() async {
    isLoading.value = true;

    // -------- Summary (dummy) --------
    totalRevenue.value = 245000; // PKR
    totalOrders.value = 128;
    pendingOrders.value = 18;
    deliveredOrders.value = 96;
    cancelledOrders.value = 14;
    totalCustomers.value = 72;

    // -------- Sales by day (dummy last 7 days) --------
    salesByDay.assignAll([
      DashboardPoint(label: 'Mon', revenue: 22000, orders: 14),
      DashboardPoint(label: 'Tue', revenue: 18000, orders: 11),
      DashboardPoint(label: 'Wed', revenue: 32000, orders: 19),
      DashboardPoint(label: 'Thu', revenue: 28000, orders: 16),
      DashboardPoint(label: 'Fri', revenue: 41000, orders: 22),
      DashboardPoint(label: 'Sat', revenue: 56000, orders: 27),
      DashboardPoint(label: 'Sun', revenue: 48000, orders: 19),
    ]);

    // -------- Status distribution (pie) --------
    statusDistribution.assignAll([
      StatusSlice('Pending', pendingOrders.value, 0xFFF59E0B),
      StatusSlice('Delivered', deliveredOrders.value, 0xFF22C55E),
      StatusSlice('Cancelled', cancelledOrders.value, 0xFFEF4444),
    ]);

    // -------- Top products (dummy) --------
    topProducts.assignAll([
      TopProduct(
        title: 'Men’s Training Track Jacket - Navy (L)',
        sold: 34,
        revenue: 190000,
      ),
      TopProduct(
        title: 'Performance T-Shirt - Black (M)',
        sold: 22,
        revenue: 88000,
      ),
      TopProduct(title: 'Running Shoes Pro X', sold: 15, revenue: 120000),
      TopProduct(title: 'Gym Shorts - Grey (L)', sold: 18, revenue: 54000),
    ]);

    isLoading.value = false;
  }
}

/* ========== Helper Models ========== */

class DashboardPoint {
  final String label;
  final double revenue;
  final int orders;

  DashboardPoint({
    required this.label,
    required this.revenue,
    required this.orders,
  });
}

class StatusSlice {
  final String label;
  final int value;
  final int colorHex; // 0xFF...

  StatusSlice(this.label, this.value, this.colorHex);
}

class TopProduct {
  final String title;
  final int sold;
  final double revenue;

  TopProduct({required this.title, required this.sold, required this.revenue});
}
