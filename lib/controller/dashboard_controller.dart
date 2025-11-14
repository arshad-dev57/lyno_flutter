import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lyno_cms/models/dashboard_model.dart';

class DashboardController extends GetxController {
  // API ka base URL
  static const String _baseUrl = 'http://192.168.100.189:5000';

  // endpoints
  static const String _statsEndpoint = '/api/dashboard/stats';
  static const String _recentOrdersEndpoint = '/api/dashboard/recent';
  static const String _topProductsEndpoint = '/api/dashboard/top-products';

  // ========== COMMON STATE ==========

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Pure JSON model for stats endpoint
  final stats = Rxn<DashboardStats>();

  // Sidebar index
  final RxInt selectedIndex = 0.obs;

  // ==== Summary stats (top 4 cards) ====
  final RxDouble totalSales = 0.0.obs;
  final RxDouble totalRevenue = 0.0.obs;
  final RxInt totalOrders = 0.obs;
  final RxInt totalItems = 0.obs;

  // future ke liye placeholders
  final RxInt pendingOrders = 0.obs;
  final RxInt deliveredOrders = 0.obs;
  final RxInt cancelledOrders = 0.obs;
  final RxInt totalCustomers = 0.obs;

  // ==== Charts data (abhi dummy) ====
  final RxList<DashboardPoint> salesByDay = <DashboardPoint>[].obs;
  final RxList<StatusSlice> statusDistribution = <StatusSlice>[].obs;

  // ==== Dashboard-specific lists ====
  final recentOrders = <DashboardRecentOrder>[].obs;
  final recentOrdersLoading = false.obs;
  final recentOrdersError = ''.obs;

  final dashboardTopProducts = <DashboardTopProduct>[].obs;
  final topProductsLoading = false.obs;
  final topProductsError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardStats();
    fetchRecentOrdersForDashboard();
    fetchTopProductsForDashboard();
  }

  void changeScreen(int index) {
    selectedIndex.value = index;
  }

  // ================== STATS API ==================

  Future<void> fetchDashboardStats() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final uri = Uri.parse('$_baseUrl$_statsEndpoint');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;

        final dashboard = DashboardStats.fromJson(data);
        stats.value = dashboard;

        totalSales.value = dashboard.totalSales;
        totalRevenue.value = dashboard.totalRevenue;
        totalOrders.value = dashboard.totalOrders;
        totalItems.value = dashboard.totalItems;

        _loadDummyCharts();
      } else {
        errorMessage.value =
            'Failed to load stats (code: ${response.statusCode})';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load stats: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ================== RECENT ORDERS API ==================

  Future<void> fetchRecentOrdersForDashboard() async {
    try {
      recentOrdersLoading.value = true;
      recentOrdersError.value = '';

      final uri = Uri.parse('$_baseUrl$_recentOrdersEndpoint');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;

        if (body['success'] == true && body['data'] is List) {
          final List list = body['data'] as List;
          final mapped = list
              .map(
                (e) => DashboardRecentOrder.fromJson(e as Map<String, dynamic>),
              )
              .toList();
          recentOrders.assignAll(mapped);
        } else {
          recentOrdersError.value = 'Invalid recent orders response';
        }
      } else {
        recentOrdersError.value =
            'Failed to load recent orders (code: ${response.statusCode})';
      }
    } catch (e) {
      recentOrdersError.value = 'Failed to load recent orders: $e';
    } finally {
      recentOrdersLoading.value = false;
    }
  }

  // ================== TOP PRODUCTS API ==================

  Future<void> fetchTopProductsForDashboard() async {
    try {
      topProductsLoading.value = true;
      topProductsError.value = '';

      final uri = Uri.parse('$_baseUrl$_topProductsEndpoint');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;

        if (body['success'] == true && body['data'] is List) {
          final List list = body['data'] as List;
          final mapped = list
              .map(
                (e) => DashboardTopProduct.fromJson(e as Map<String, dynamic>),
              )
              .toList();
          dashboardTopProducts.assignAll(mapped);
        } else {
          topProductsError.value = 'Invalid top products response';
        }
      } else {
        topProductsError.value =
            'Failed to load top products (code: ${response.statusCode})';
      }
    } catch (e) {
      topProductsError.value = 'Failed to load top products: $e';
    } finally {
      topProductsLoading.value = false;
    }
  }

  // ================= DUMMY CHART DATA =================

  void _loadDummyCharts() {
    salesByDay.assignAll([
      DashboardPoint(label: 'Mon', revenue: 22000, orders: 14),
      DashboardPoint(label: 'Tue', revenue: 18000, orders: 11),
      DashboardPoint(label: 'Wed', revenue: 32000, orders: 19),
      DashboardPoint(label: 'Thu', revenue: 28000, orders: 16),
      DashboardPoint(label: 'Fri', revenue: 41000, orders: 22),
      DashboardPoint(label: 'Sat', revenue: 56000, orders: 27),
      DashboardPoint(label: 'Sun', revenue: 48000, orders: 19),
    ]);

    statusDistribution.assignAll([
      StatusSlice('Pending', pendingOrders.value, 0xFFF59E0B),
      StatusSlice('Delivered', deliveredOrders.value, 0xFF22C55E),
      StatusSlice('Cancelled', cancelledOrders.value, 0xFFEF4444),
    ]);
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

/// Recent orders model (dashboard)
class DashboardRecentOrder {
  final String id;
  final String orderNo;
  final String customerName;
  final String customerPhone;
  final String status;
  final double grandTotal;
  final String currency;
  final DateTime? createdAt;

  /// 👇 image (usually first item image)
  final String? image;

  DashboardRecentOrder({
    required this.id,
    required this.orderNo,
    required this.customerName,
    required this.customerPhone,
    required this.status,
    required this.grandTotal,
    required this.currency,
    required this.createdAt,
    this.image,
  });

  factory DashboardRecentOrder.fromJson(Map<String, dynamic> json) {
    return DashboardRecentOrder(
      id: (json['id'] ?? '').toString(),
      orderNo: (json['orderNo'] ?? '').toString(),
      customerName: (json['customerName'] ?? '').toString(),
      customerPhone: (json['customerPhone'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0,
      currency: (json['currency'] ?? '\$').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      image: json['image']?.toString(),
    );
  }
}

/// Top selling products model (dashboard)
class DashboardTopProduct {
  final String productId;
  final String title;
  final String sku;
  final String? image;
  final int sold;
  final double revenue;
  final String currency;

  DashboardTopProduct({
    required this.productId,
    required this.title,
    required this.sku,
    required this.image,
    required this.sold,
    required this.revenue,
    required this.currency,
  });

  factory DashboardTopProduct.fromJson(Map<String, dynamic> json) {
    return DashboardTopProduct(
      productId: (json['productId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      sku: (json['sku'] ?? '').toString(),
      image: json['image']?.toString(),
      sold: (json['sold'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      currency: (json['currency'] ?? '\$').toString(),
    );
  }
}
