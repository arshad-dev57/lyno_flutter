import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lyno_cms/controller/dashboard_controller.dart';
import 'package:lyno_cms/controller/order_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final DashboardController c = Get.find<DashboardController>();
  final OrdersController ordersController = Get.put(OrdersController());
  static const Color kBg = Color(0xFFF5F7FB);
  static const Color kCard = Colors.white;
  static const Color kPrimary = Color(0xFF4F46E5);
  static const Color kStroke = Color(0xFFE5E7EB);
  static const Color kMuted = Color(0xFF9CA3AF);
  static const Color kText = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBg,
      child: Column(
        children: [
          _topBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Obx(
                () => c.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : _body(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= BODY LAYOUT =================

  Widget _body() {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== LEFT: main column =====
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // _overviewHeader(),
                // const SizedBox(height: 18),
                _statsRow(),
                const SizedBox(height: 24),
                _salesAnalyticsCard(),
                const SizedBox(height: 24),
                _topSellingProductsCard(),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // ===== RIGHT: side column =====
          SizedBox(
            width: 290,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _orderRecentlyCard(),
                const SizedBox(height: 18),
                _monthlyProfitsCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= TOP BAR =================

  Widget _topBar() {
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
                  'May–Nov 2022',
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

  // ================= OVERVIEW HEADER =================

  Widget _overviewHeader() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: kText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '03 January 2023',
              style: GoogleFonts.inter(fontSize: 11, color: kMuted),
            ),
          ],
        ),
      ],
    );
  }

  // ================= TOP STATS ROW =================

  Widget _statsRow() {
    return Row(
      children: [
        _statCard(
          icon: Icons.shopping_bag_outlined,
          title: 'Total Sales',
          value: '\$1,210,387',
          color: const Color(0xFFFFEEF1),
          iconColor: const Color(0xFFE11D48),
        ),
        const SizedBox(width: 16),
        _statCard(
          icon: Icons.receipt_long_outlined,
          title: 'Total Orders',
          value: '3211',
          color: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
        ),
        const SizedBox(width: 16),
        _statCard(
          icon: Icons.inventory_2_outlined,
          title: 'Total Items',
          value: '543',
          color: const Color(0xFFECFEFF),
          iconColor: const Color(0xFF0891B2),
        ),
        const SizedBox(width: 16),
        _statCard(
          icon: Icons.attach_money,
          title: 'Total Revenue',
          value: '\$1,210,387',
          color: const Color(0xFFEEF2FF),
          iconColor: kPrimary,
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
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
      ),
    );
  }

  // ================= SALES ANALYTIC CHART =================

  Widget _salesAnalyticsCard() {
    // static line data
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
          // header row
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
                      'May-Jun 2025',
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
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 700,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 100,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: const Color.fromARGB(255, 243, 240, 240),
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
                          return SizedBox.shrink();
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

                // 👇 yeh important hai: do lines ke beech ka fill
                betweenBarsData: [
                  BetweenBarsData(
                    fromIndex: 0, // neeche wali line ka index
                    toIndex: 1, // upar wali line ka index
                    color: const Color(0xFF22C55E).withOpacity(0.10),
                    // agar tum gradient chaho to:
                    // colors: [
                    //   const Color(0xFF22C55E).withOpacity(0.14),
                    //   const Color(0xFF22C55E).withOpacity(0.02),
                    // ],
                  ),
                ],

                lineBarsData: [
                  // 0: neeche wali blue line
                  LineChartBarData(
                    spots: blueSpots,
                    isCurved: true,
                    color: const Color(0xFF3B82F6),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),

                  // 1: upar wali green line
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

  // ================= TOP SELLING PRODUCTS TABLE =================

  Widget _topSellingProductsCard() {
    final rows = [
      _TopProductRow(
        name: 'Nike Airforce 1',
        status: 'Live',
        statusColor: const Color(0xFF22C55E),
        sales: '456',
        earning: '\$247,000',
      ),
      _TopProductRow(
        name: 'Thi Visibly Clear Spot Proofing Scrub',
        status: 'Live',
        statusColor: const Color(0xFF22C55E),
        sales: '1098',
        earning: '\$147,000',
      ),
      _TopProductRow(
        name: 'Duffle Royal Blue Alpha',
        status: 'Draft',
        statusColor: const Color(0xFFF97316),
        sales: '1043',
        earning: '\$173,000',
      ),
      _TopProductRow(
        name: 'Blue Sweatshirt',
        status: 'Live',
        statusColor: const Color(0xFF22C55E),
        sales: '652',
        earning: '\$434,700',
      ),
    ];

    return Container(
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
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Text(
                  'Top Selling Products',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kText,
                  ),
                ),
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
                        'Nov 2022',
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
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            color: const Color(0xFFF9FAFB),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Checkbox(
                    value: false,
                    onChanged: (_) {},
                    visualDensity: VisualDensity.compact,
                    side: const BorderSide(color: kStroke),
                  ),
                ),
                const SizedBox(width: 12),
                _headerCell('Product', flex: 3),
                _headerCell('Status'),
                _headerCell('Sales'),
                _headerCell('Earning'),
              ],
            ),
          ),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Checkbox(
                      value: false,
                      onChanged: (_) {},
                      visualDensity: VisualDensity.compact,
                      side: const BorderSide(color: kStroke),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Text(
                      r.name,
                      style: GoogleFonts.inter(fontSize: 12, color: kText),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: r.statusColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          r.status,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            color: r.statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      r.sales,
                      style: GoogleFonts.inter(fontSize: 11, color: kText),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: Text(
                      r.earning,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: kText,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: kMuted,
        ),
      ),
    );
  }

  // ================= RIGHT: ORDER RECENTLY =================

  Widget _orderRecentlyCard() {
    final items = [
      _RecentOrderItem('Heavy Bag', 'Bag', '\$123.00', 'Item: 6'),
      _RecentOrderItem('Cheetos', 'Food', '\$2.00', 'Item: 3'),
      _RecentOrderItem('Airpod', 'Bag', '\$69.00', 'Item: 13'),
      _RecentOrderItem('Rattle', 'Toy', '\$32.00', 'Item: 12'),
      _RecentOrderItem('Bicycle', 'Bag', '\$303.00', 'Item: 6'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Text(
                'Order Recently',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kText,
                ),
              ),
            ],
          ),
          // Replace your old snippet with this:
          const SizedBox(height: 12),
          Obx(() {
            if (ordersController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final orders = ordersController.orders; // RxList

            if (orders.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.inbox_outlined,
                        size: 18,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'No orders yet',
                      style: GoogleFonts.inter(fontSize: 12, color: kMuted),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              shrinkWrap:
                  true, // so it can live inside a Column/SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final order = orders[index];
                final orderNo = order.address;
                final category = order.deliveryFee;
                final meta = order.status;

                return Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 18,
                        color: kMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order No
                          Text(
                            "orderNo",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: kText,
                            ),
                          ),
                          // Category
                          Text(
                            "category",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: kMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Price
                        Text(
                          "category",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                        // Meta (e.g., items count / date)
                        Text(
                          meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 9, color: kMuted),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          }),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'View All',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: kPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= RIGHT: MONTHLY PROFITS (DONUT) =================
  Widget _monthlyProfitsCard() {
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
          SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ---- BACKGROUND GREY RING ----
                PieChart(
                  PieChartData(
                    startDegreeOffset: -90,
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        value: 100,
                        color: const Color(0xFFF3F4F6), // light grey ring
                        radius: 34,
                        title: '',
                      ),
                    ],
                  ),
                ),

                // ---- COLORED ARCS OVERLAY (ONLINE + SHOP) ----
                PieChart(
                  PieChartData(
                    startDegreeOffset: -90,
                    sectionsSpace: 4, // gap between blue & purple
                    centerSpaceRadius: 40,
                    // yaha sirf 35 + 35 = 70, baqi 30% grey ring dikhega
                    sections: [
                      PieChartSectionData(
                        value: 35,
                        color: Color(0xFF60A5FA), // blue
                        radius: 34,
                        title: '',
                      ),
                      PieChartSectionData(
                        value: 35,
                        color: Color(0xFFA855F7), // purple
                        radius: 34,
                        title: '',
                      ),
                    ],
                  ),
                ),

                // ---- CENTER TEXT ----
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.inter(fontSize: 10, color: kMuted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$284,562',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _legendDot(const Color(0xFF60A5FA), 'Online 35%'),
              const SizedBox(width: 8),
              _legendDot(const Color(0xFFA855F7), 'Shop 35%'),
              const SizedBox(width: 8),
              _legendDot(const Color(0xFFF3F4F6), 'Other 30%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 9, color: kMuted)),
      ],
    );
  }

  // Widget _legendDot(Color color, String label) {
  //   return Row(
  //     children: [
  //       Container(
  //         width: 8,
  //         height: 8,
  //         decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  //       ),
  //       const SizedBox(width: 4),
  //       Text(label, style: GoogleFonts.inter(fontSize: 8, color: kMuted)),
  //     ],
  //   );
  // }

  // ================= HELPERS / MODELS =================

  String _formatCurrency(double value) {
    return '\$${value.toStringAsFixed(0)}';
  }
}

class _TopProductRow {
  final String name;
  final String status;
  final Color statusColor;
  final String sales;
  final String earning;

  _TopProductRow({
    required this.name,
    required this.status,
    required this.statusColor,
    required this.sales,
    required this.earning,
  });
}

class _RecentOrderItem {
  final String title;
  final String category;
  final String price;
  final String meta;

  _RecentOrderItem(this.title, this.category, this.price, this.meta);
}
