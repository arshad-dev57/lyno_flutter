// lib/models/dashboard_stats_model.dart

class DashboardStats {
  final String currency;
  final double totalSales;
  final int totalOrders;
  final int totalItems;
  final double totalRevenue;

  DashboardStats({
    required this.currency,
    required this.totalSales,
    required this.totalOrders,
    required this.totalItems,
    required this.totalRevenue,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is int) return v.toDouble();
      if (v is double) return v;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return DashboardStats(
      currency: json['currency']?.toString() ?? '\$',
      totalSales: _toDouble(json['totalSales']),
      totalOrders: _toInt(json['totalOrders']),
      totalItems: _toInt(json['totalItems']),
      totalRevenue: _toDouble(json['totalRevenue']),
    );
  }

  Map<String, dynamic> toJson() => {
    'currency': currency,
    'totalSales': totalSales,
    'totalOrders': totalOrders,
    'totalItems': totalItems,
    'totalRevenue': totalRevenue,
  };
}
