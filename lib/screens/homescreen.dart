// lib/screens/home_screen.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lyno_cms/controller/dashboard_controller.dart';
import 'package:lyno_cms/controller/order_controller.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final DashboardController c = Get.put(DashboardController());
  final OrdersController ordersController = Get.put(OrdersController());

  static const Color kBg = Color(0xFFF5F7FB);
  static const Color kCard = Colors.white;
  static const Color kPrimary = Color(0xFF4F46E5);
  static const Color kStroke = Color(0xFFE5E7EB);
  static const Color kMuted = Color(0xFF9CA3AF);
  static const Color kText = Color(0xFF111827);

  // shimmer colors
  static const Color kShimmerBase = Color(0xFFE5E7EB);
  static const Color kShimmerHighlight = Color(0xFFF3F4F6);

  // Sale Analytic + Recent Orders same height
  static const double kAnalyticsCardHeight = 320;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final bool isMobile = width < 700;
        final bool isTablet = width >= 700 && width < 1100;

        return Container(
          color: kBg,
          child: Column(
            children: [
              _topBar(isMobile: isMobile),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 12 : 24),
                  child: Obx(() {
                    if (c.isLoading.value) {
                      return _loadingSkeleton(isMobile: isMobile);
                    }
                    if (c.errorMessage.isNotEmpty) {
                      return Center(child: Text(c.errorMessage.value));
                    }

                    if (isMobile) return _bodyMobile();
                    if (isTablet) return _bodyTablet();
                    return _bodyDesktop();
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= BODY (DESKTOP) =================

  Widget _bodyDesktop() {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statsRow(), // 👈 API based
                const SizedBox(height: 24),
                SizedBox(
                  height: kAnalyticsCardHeight,
                  child: _salesAnalyticsCard(),
                ),
                const SizedBox(height: 24),
                _topSellingProductsCard(), // 👈 API based
              ],
            ),
          ),
          const SizedBox(width: 24),
          // RIGHT
          SizedBox(
            width: 290,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: kAnalyticsCardHeight,
                  child: _orderRecentlyCard(), // 👈 API based + scroll
                ),
                const SizedBox(height: 18),
                _monthlyProfitsCard(), // 👈 now DYNAMIC
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= BODY (TABLET) =================

  Widget _bodyTablet() {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statsRow(),
                const SizedBox(height: 20),
                SizedBox(
                  height: kAnalyticsCardHeight,
                  child: _salesAnalyticsCard(),
                ),
                const SizedBox(height: 20),
                _topSellingProductsCard(),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // RIGHT (slightly smaller)
          SizedBox(
            width: 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: kAnalyticsCardHeight,
                  child: _orderRecentlyCard(),
                ),
                const SizedBox(height: 16),
                _monthlyProfitsCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= BODY (MOBILE) =================

  Widget _bodyMobile() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _statsRowMobile(),
          const SizedBox(height: 16),
          SizedBox(height: kAnalyticsCardHeight, child: _salesAnalyticsCard()),
          const SizedBox(height: 16),
          SizedBox(height: kAnalyticsCardHeight, child: _orderRecentlyCard()),
          const SizedBox(height: 16),
          _monthlyProfitsCard(),
          const SizedBox(height: 16),
          _topSellingProductsCard(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ================= FULL PAGE LOADING SKELETON =================

  Widget _loadingSkeleton({required bool isMobile}) {
    if (isMobile) {
      // Mobile: stacked skeleton
      return SingleChildScrollView(
        child: Column(
          children: [
            // top stats 2x2 style
            Row(
              children: [
                Expanded(child: _shimmerCard(height: 80)),
                const SizedBox(width: 12),
                Expanded(child: _shimmerCard(height: 80)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _shimmerCard(height: 80)),
                const SizedBox(width: 12),
                Expanded(child: _shimmerCard(height: 80)),
              ],
            ),
            const SizedBox(height: 20),
            _shimmerCard(height: kAnalyticsCardHeight),
            const SizedBox(height: 16),
            _shimmerCard(height: kAnalyticsCardHeight),
            const SizedBox(height: 16),
            _shimmerCard(height: 200),
            const SizedBox(height: 16),
            _shimmerCard(height: 180),
          ],
        ),
      );
    }

    // Desktop / Tablet version (original)
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // top stats 4 cards
                Row(
                  children: List.generate(4, (index) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: index == 3 ? 0 : 16),
                        child: _shimmerCard(height: 80),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                _shimmerCard(height: kAnalyticsCardHeight),
                const SizedBox(height: 24),
                _shimmerCard(height: 140),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // RIGHT
          SizedBox(
            width: 290,
            child: Column(
              children: [
                _shimmerCard(height: kAnalyticsCardHeight),
                const SizedBox(height: 18),
                _shimmerCard(height: 200),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerCard({required double height}) {
    return Shimmer.fromColors(
      baseColor: kShimmerBase,
      highlightColor: kShimmerHighlight,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: kShimmerBase,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  Widget _shimmerBox({
    double height = 12,
    double width = double.infinity,
    BorderRadius? borderRadius,
  }) {
    return Shimmer.fromColors(
      baseColor: kShimmerBase,
      highlightColor: kShimmerHighlight,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: kShimmerBase,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }

  // ================= TOP BAR =================

  Widget _topBar({required bool isMobile}) {
    if (isMobile) {
      // Mobile: search on top, filters + icons below
      return Container(
        color: kCard,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search here',
                  hintStyle: GoogleFonts.inter(fontSize: 13, color: kMuted),
                  prefixIcon: const Icon(Icons.search, size: 18),
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kStroke),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: kMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'May–Nov 2025',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: kText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings_outlined, size: 20),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none_rounded, size: 22),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Desktop / Tablet top bar
    return Container(
      color: kCard,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 260,
            height: 40,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search here',
                hintStyle: GoogleFonts.inter(fontSize: 13, color: kMuted),
                prefixIcon: const Icon(Icons.search, size: 18),
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kStroke),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: kMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  'May–Nov 2025',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: kText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, size: 18, color: kMuted),
              ],
            ),
          ),
          const SizedBox(width: 14),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, size: 20),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, size: 22),
          ),
        ],
      ),
    );
  }

  // ================= TOP STATS (API DATA) =================

  Widget _statsRow() {
    return Obx(() {
      final sales = c.totalSales.value;
      final orders = c.totalOrders.value;
      final items = c.totalItems.value;
      final revenue = c.totalRevenue.value;
      final currency = c.stats.value?.currency ?? '\$';

      return Row(
        children: [
          _statCard(
            icon: Icons.shopping_bag_outlined,
            title: 'Total Sales',
            value: _formatCurrency(sales, currency),
            color: const Color(0xFFFFEEF1),
            iconColor: const Color(0xFFE11D48),
          ),
          const SizedBox(width: 16),
          _statCard(
            icon: Icons.receipt_long_outlined,
            title: 'Total Orders',
            value: _formatInt(orders),
            color: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF2563EB),
          ),
          const SizedBox(width: 16),
          _statCard(
            icon: Icons.inventory_2_outlined,
            title: 'Total Items',
            value: _formatInt(items),
            color: const Color(0xFFECFEFF),
            iconColor: const Color(0xFF0891B2),
          ),
          const SizedBox(width: 16),
          _statCard(
            icon: Icons.attach_money,
            title: 'Total Revenue',
            value: _formatCurrency(revenue, currency),
            color: const Color(0xFFEEF2FF),
            iconColor: kPrimary,
          ),
        ],
      );
    });
  }

  // Mobile version: 2x2 grid stats

  Widget _statsRowMobile() {
    return Obx(() {
      final sales = c.totalSales.value;
      final orders = c.totalOrders.value;
      final items = c.totalItems.value;
      final revenue = c.totalRevenue.value;
      final currency = c.stats.value?.currency ?? '\$';

      final card1 = _statCard(
        icon: Icons.shopping_bag_outlined,
        title: 'Total Sales',
        value: _formatCurrency(sales, currency),
        color: const Color(0xFFFFEEF1),
        iconColor: const Color(0xFFE11D48),
      );
      final card2 = _statCard(
        icon: Icons.receipt_long_outlined,
        title: 'Total Orders',
        value: _formatInt(orders),
        color: const Color(0xFFEFF6FF),
        iconColor: const Color(0xFF2563EB),
      );
      final card3 = _statCard(
        icon: Icons.inventory_2_outlined,
        title: 'Total Items',
        value: _formatInt(items),
        color: const Color(0xFFECFEFF),
        iconColor: const Color(0xFF0891B2),
      );
      final card4 = _statCard(
        icon: Icons.attach_money,
        title: 'Total Revenue',
        value: _formatCurrency(revenue, currency),
        color: const Color(0xFFEEF2FF),
        iconColor: kPrimary,
      );

      return Column(
        children: [
          Row(
            children: [
              Expanded(child: card1),
              const SizedBox(width: 8),
              Expanded(child: card2),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: card3),
              const SizedBox(width: 8),
              Expanded(child: card4),
            ],
          ),
        ],
      );
    });
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 11, color: kMuted),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= SALES ANALYTICS CARD =================

  Widget _salesAnalyticsCard() {
    final greenSpots = <FlSpot>[
      const FlSpot(0, 200),
      const FlSpot(1, 220),
      const FlSpot(2, 350),
      const FlSpot(3, 380),
      const FlSpot(4, 620),
      const FlSpot(5, 610),
      const FlSpot(6, 580),
      const FlSpot(7, 640),
      const FlSpot(8, 670),
      const FlSpot(9, 700),
      const FlSpot(10, 730),
      const FlSpot(11, 710),
    ];

    final blueSpots = <FlSpot>[
      const FlSpot(0, 180),
      const FlSpot(1, 190),
      const FlSpot(2, 210),
      const FlSpot(3, 250),
      const FlSpot(4, 300),
      const FlSpot(5, 280),
      const FlSpot(6, 320),
      const FlSpot(7, 340),
      const FlSpot(8, 360),
      const FlSpot(9, 390),
      const FlSpot(10, 410),
      const FlSpot(11, 430),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Sale Analytic',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: kText,
                ),
              ),
              const SizedBox(width: 16),
              _dotLabel(color: const Color(0xFF10B981), text: 'May'),
              const SizedBox(width: 8),
              _dotLabel(color: const Color(0xFF3B82F6), text: 'June'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      'May–Jun 2025',
                      style: GoogleFonts.inter(fontSize: 10, color: kMuted),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: kMuted,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 750,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 100,
                  getDrawingHorizontalLine: (v) => const FlLine(
                    color: Color.fromARGB(255, 243, 240, 240),
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: GoogleFonts.inter(fontSize: 8, color: kMuted),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const labels = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec',
                        ];
                        final i = v.toInt();
                        if (i < 0 || i >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            labels[i],
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              color: kMuted,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                betweenBarsData: [
                  BetweenBarsData(
                    fromIndex: 0,
                    toIndex: 1,
                    color: const Color(0xFF22C55E).withOpacity(0.10),
                  ),
                ],
                lineBarsData: [
                  LineChartBarData(
                    spots: blueSpots,
                    isCurved: true,
                    color: const Color(0xFF3B82F6),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: greenSpots,
                    isCurved: true,
                    color: const Color(0xFF22C55E),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dotLabel({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.inter(fontSize: 9, color: kMuted)),
      ],
    );
  }

  // ================= TOP SELLING PRODUCTS (API) =================

  Widget _topSellingProductsCard() {
    return Obx(() {
      if (c.topProductsLoading.value) {
        // shimmer version of table
        return _cardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerBox(height: 16, width: 140),
              const SizedBox(height: 16),
              _shimmerBox(height: 32, borderRadius: BorderRadius.circular(12)),
              const SizedBox(height: 8),
              ...List.generate(
                3,
                (_) => Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 4,
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 5, child: _shimmerBox(height: 14)),
                      const SizedBox(width: 8),
                      Expanded(flex: 2, child: _shimmerBox(height: 14)),
                      const SizedBox(width: 8),
                      Expanded(flex: 3, child: _shimmerBox(height: 14)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }

      if (c.topProductsError.isNotEmpty) {
        return _cardShell(
          child: Text(
            c.topProductsError.value,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.red),
          ),
        );
      }

      final products = c.dashboardTopProducts;
      if (products.isEmpty) {
        return _cardShell(
          child: Text(
            'No top products yet',
            style: GoogleFonts.inter(fontSize: 12, color: kMuted),
          ),
        );
      }

      return _cardShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Selling Products',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: kText,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      'Product',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: kMuted,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Sold',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: kMuted,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Revenue',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: kMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            ...products.map((row) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        row.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 12, color: kText),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        row.sold.toString(),
                        style: GoogleFonts.inter(fontSize: 12, color: kText),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        _formatCurrency(row.revenue, row.currency),
                        textAlign: TextAlign.right,
                        style: GoogleFonts.inter(fontSize: 12, color: kText),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      );
    });
  }

  // ================= RECENT ORDERS (API + IMAGE + SCROLL) =================

  Widget _orderRecentlyCard() {
    return Obx(() {
      if (c.recentOrdersLoading.value) {
        // shimmer recent orders list
        return _cardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerBox(height: 16, width: 120),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _shimmerBox(
                          height: 32,
                          width: 32,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _shimmerBox(height: 12, width: 110),
                              const SizedBox(height: 4),
                              _shimmerBox(height: 10, width: 80),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _shimmerBox(
                          height: 18,
                          width: 52,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        const SizedBox(width: 8),
                        _shimmerBox(height: 12, width: 38),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }

      if (c.recentOrdersError.isNotEmpty) {
        return _cardShell(
          child: Text(
            c.recentOrdersError.value,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.red),
          ),
        );
      }

      final orders = c.recentOrders;
      if (orders.isEmpty) {
        return _cardShell(
          child: Text(
            'No recent orders yet',
            style: GoogleFonts.inter(fontSize: 12, color: kMuted),
          ),
        );
      }

      return _cardShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Orders',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kText,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: orders.length,
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final o = orders[index];
                  final statusColor = _statusColor(o.status);

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // image
                      if (o.image != null && o.image!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            o.image!,
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 16,
                                  color: Color(0xFF9CA3AF),
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 16,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      const SizedBox(width: 8),

                      // order info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              o.orderNo,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: kText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              o.customerName.isNotEmpty
                                  ? o.customerName
                                  : o.customerPhone,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: kMuted,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // status chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _statusLabel(o.status),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // amount
                      Text(
                        _formatCurrency(o.grandTotal, "\$"),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: kText,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _cardShell({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'confirmed':
      case 'packed':
      case 'shipped':
        return const Color(0xFF3B82F6);
      case 'delivered':
        return const Color(0xFF22C55E);
      case 'cancelled':
      case 'returned':
        return const Color(0xFFEF4444);
      default:
        return kMuted;
    }
  }

  String _statusLabel(String status) {
    if (status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1);
  }

  // ================= MONTHLY PROFITS (DYNAMIC) =================
  Widget _monthlyProfitsCard() {
    return Obx(() {
      // loading
      if (c.monthlyProfitsLoading.value) {
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(top: 18),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerBox(height: 14, width: 120),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: Center(
                  child: _shimmerBox(
                    height: 120,
                    width: 120,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 6,
                children: List.generate(
                  4,
                  (_) => _shimmerBox(height: 10, width: 60),
                ),
              ),
            ],
          ),
        );
      }

      // error
      if (c.monthlyProfitsError.isNotEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(top: 18),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            c.monthlyProfitsError.value,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.red),
          ),
        );
      }

      final data = c.monthlyProfits;
      if (data.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(top: 18),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            'No monthly profits data',
            style: GoogleFonts.inter(fontSize: 12, color: kMuted),
          ),
        );
      }

      // currency & total
      final currency = c.stats.value?.currency ?? '\$';
      final total = data.fold<double>(0, (sum, item) => sum + item.value);

      // colors for slices
      final List<Color> colors = const [
        Color(0xFF4F46E5),
        Color(0xFF22C55E),
        Color(0xFFF97316),
        Color(0xFFEC4899),
        Color(0xFF06B6D4),
        Color(0xFF8B5CF6),
      ];

      final sections = List.generate(data.length, (index) {
        final item = data[index];
        final color = colors[index % colors.length];
        final radius = 30.0 + (index * 4);
        final percent = total > 0
            ? ((item.value / total) * 100).round()
            : 0; // %

        return PieChartSectionData(
          value: item.value,
          title: '$percent%',
          radius: radius,
          titleStyle: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          color: color,
        );
      });

      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(top: 18),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Profits',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kText,
              ),
            ),
            const SizedBox(height: 14),

            // 👇 Center total value inside chart
            SizedBox(
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sections: sections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                      startDegreeOffset: -90,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.inter(fontSize: 10, color: kMuted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatCurrency(total, currency),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: kText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Legend with label + amount
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: List.generate(data.length, (index) {
                final item = data[index];
                final color = colors[index % colors.length];
                final valueText = _formatCurrency(item.value, currency);

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: kText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          valueText,
                          style: GoogleFonts.inter(fontSize: 9, color: kMuted),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      );
    });
  }

  Widget _legendDot({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: kMuted)),
      ],
    );
  }

  String _formatCurrency(double value, String currency) {
    final rounded = value.round();
    final s = rounded.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = s.replaceAllMapped(reg, (m) => '${m[1]},');
    return '$currency$formatted';
  }

  String _formatInt(int value) => value.toString();
}
