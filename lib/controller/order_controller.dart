import 'dart:convert';

import 'package:get/get.dart';
import 'package:lyno_cms/models/order_model.dart';
import 'package:lyno_cms/services/api_services.dart';
import 'package:http/http.dart' as http;

class OrdersController extends GetxController {
  final RxList<Datum> orders = <Datum>[].obs;

  final RxSet<String> selectedOrders = <String>{}.obs;
  final isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt pageSize = 7.obs;

  List<Datum> get filteredOrders {
    final q = searchQuery.value.trim().toLowerCase();

    final List<Datum> base;
    if (q.isEmpty) {
      base = orders;
    } else {
      base = orders.where((o) {
        final addrName = o.address?.name ?? '';
        final addrPhone = o.address?.phone ?? '';
        final paymentMethod = o.payment?.method ?? '';
        final status = o.status;
        return o.orderNo.toLowerCase().contains(q) ||
            o.id.toLowerCase() == q ||
            o.user.toLowerCase().contains(q) ||
            addrName.toLowerCase().contains(q) ||
            addrPhone.toLowerCase().contains(q) ||
            paymentMethod.toLowerCase().contains(q) ||
            status.toLowerCase().contains(q);
      }).toList();
    }

    final start = ((currentPage.value - 1) * pageSize.value).clamp(
      0,
      base.length,
    );
    final end = (start + pageSize.value).clamp(0, base.length);
    return base.sublist(start, end);
  }

  // ===== selection =====

  void toggleOrderSelection(String id) {
    if (selectedOrders.contains(id)) {
      selectedOrders.remove(id);
    } else {
      selectedOrders.add(id);
    }
    selectedOrders.refresh();
  }

  void toggleAllOrders() {
    if (selectedOrders.length == orders.length) {
      selectedOrders.clear();
    } else {
      selectedOrders
        ..clear()
        ..addAll(orders.map((e) => e.id));
    }
    selectedOrders.refresh();
  }

  // ===== pagination =====

  void nextPage() {
    final total = orders.length;
    final maxPage = (total / pageSize.value).ceil().clamp(1, 999999);
    if (currentPage.value < maxPage) currentPage.value++;
  }

  void prevPage() {
    if (currentPage.value > 1) currentPage.value--;
  }

  void setPageSize(int v) {
    pageSize.value = v;
    currentPage.value = 1;
  }

  // ===== fetch =====

  Future<void> ordersList() async {
    try {
      final response = await ApiService.getRequest(
        context: Get.context!,
        endpoint: "api/orders/all", // tumhara existing
      );

      if (response?.statusCode == 200) {
        final decoded = ApiService.safeDecode(response!.body);
        final List<dynamic> rawList = decoded['data'] ?? [];
        final parsed = rawList
            .map((e) => Datum.fromJson(e as Map<String, dynamic>))
            .toList();
        orders.assignAll(parsed);
      } else {
        print("ordersList failed: ${response?.statusCode}");
      }
    } catch (e) {
      print("ordersList error: $e");
    }
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      if (!['pending', 'completed'].contains(status)) {
        print('Invalid status: $status');
        return;
      }

      final uri = Uri.parse("${ApiService.baseUrl}/api/orders/update/$orderId");

      final res = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token', // agar route protected ho
        },
        body: jsonEncode({'status': status}),
      );

      if (res.statusCode == 200) {
        final decoded = ApiService.safeDecode(res.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final updated = Datum.fromJson(decoded['data']);
          final index = orders.indexWhere((o) => o.id == updated.id);
          if (index != -1) {
            orders[index] = updated;
            orders.refresh();
          }
        }
      } else {
        print("updateOrderStatus failed: ${res.statusCode} => ${res.body}");
      }
    } catch (e) {
      print("updateOrderStatus error: $e");
    }
  }
}
