import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lyno_cms/controller/order_controller.dart';
import 'package:lyno_cms/models/order_model.dart';

class OrdersScreen extends StatefulWidget {
  OrdersScreen({Key? key}) : super(key: key);

  static const Color kBg = Color(0xFFF6F6F7);
  static const Color kCard = Colors.white;
  static const Color kPrimary = Color(0xFF6366F1);
  static const Color kStroke = Color(0xFFE5E7EB);
  static const Color kMuted = Color(0xFF6B7280);
  static const double kRadius = 12;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrdersController controller = Get.put(OrdersController());

  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  // Thoda wide so horizontal scroll smooth lage
  static const double _tableMinWidth = 2400;

  // columns width (important: header + row same)
  static const double _wId = 90;
  static const double _wOrderNo = 140;
  static const double _wCustomer = 160;
  static const double _wPhone = 130;
  static const double _wAddress = 320;
  static const double _wItems = 320;
  static const double _wPayment = 110;
  static const double _wPayStatus = 120;
  static const double _wOrderStatus = 180;
  static const double _wSubtotal = 110;
  static const double _wDelivery = 90;
  static const double _wService = 90;
  static const double _wTax = 80;
  static const double _wGrand = 130;
  static const double _wCreated = 160;
  static const double _wActions = 50;

  @override
  void initState() {
    super.initState();
    controller.ordersList();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrdersScreen.kBg,
      appBar: _topAppBar(),
      body: Column(
        children: [
          _pageHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _ordersTableCard(),
            ),
          ),
        ],
      ),
    );
  }

  // ================== APP BAR ==================

  PreferredSizeWidget _topAppBar() {
    return AppBar(
      backgroundColor: OrdersScreen.kCard,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search…',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: OrdersScreen.kMuted,
                    ),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: OrdersScreen.kStroke),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: OrdersScreen.kStroke),
                    ),
                  ),
                  onChanged: (v) => controller.searchQuery.value = v,
                ),
              ),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text('View your shop'),
              style: TextButton.styleFrom(
                foregroundColor: OrdersScreen.kPrimary,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Notifications',
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: OrdersScreen.kStroke),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFFE5E7EB),
                    child: Icon(Icons.person, size: 16, color: Colors.black54),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Dawid Jankowski',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== PAGE HEADER ==================

  Widget _pageHeader() {
    return Container(
      color: OrdersScreen.kCard,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Row(
        children: [
          Text(
            'Orders',
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.help_outline, size: 18),
            label: const Text('Help'),
            style: _outlined(),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: () {},
            style: _outlined(),
            child: const Text('Order statistics'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: OrdersScreen.kPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('New customer'),
          ),
        ],
      ),
    );
  }

  // ================== ORDERS TABLE CARD ==================

  Widget _ordersTableCard() {
    return Container(
      decoration: BoxDecoration(
        color: OrdersScreen.kCard,
        borderRadius: BorderRadius.circular(OrdersScreen.kRadius),
        border: Border.all(color: OrdersScreen.kStroke),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _tableToolbar(),
          const Divider(height: 1, color: OrdersScreen.kStroke),
          Expanded(
            child: Obx(() {
              final orders = controller.filteredOrders;
              if (orders.isEmpty) {
                return const Center(child: Text('No orders found'));
              }

              return Scrollbar(
                controller: _horizontalController,
                thumbVisibility: true,
                notificationPredicate: (n) => n.metrics.axis == Axis.horizontal,
                child: SingleChildScrollView(
                  controller: _horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: _tableMinWidth,
                    child: Column(
                      children: [
                        _tableHeader(),
                        const Divider(height: 1, color: OrdersScreen.kStroke),
                        Expanded(
                          child: Scrollbar(
                            controller: _verticalController,
                            thumbVisibility: true,
                            notificationPredicate: (n) =>
                                n.metrics.axis == Axis.vertical,
                            child: ListView.separated(
                              controller: _verticalController,
                              itemCount: orders.length,
                              separatorBuilder: (_, __) => const Divider(
                                height: 1,
                                color: OrdersScreen.kStroke,
                              ),
                              itemBuilder: (context, i) {
                                final order = orders[i];
                                final isSelected = controller.selectedOrders
                                    .contains(order.id);
                                final zebra = i.isEven
                                    ? Colors.white
                                    : const Color(0xFFFCFCFD);

                                final shortId = order.id.length > 8
                                    ? '${order.id.substring(0, 6)}…'
                                    : order.id;

                                final addr = order.address;
                                final addressLine = addr == null
                                    ? '-'
                                    : [
                                            addr.line1,
                                            addr.city,
                                            addr.state,
                                            addr.country,
                                          ]
                                          .where((e) => e.trim().isNotEmpty)
                                          .join(', ');

                                final itemsSummary = _itemsSummary(order.items);
                                final payMethod =
                                    order.payment?.method?.toUpperCase() ?? '-';
                                final payStatus = order.payment?.status ?? '-';
                                final created = order.createdAt
                                    .toLocal()
                                    .toString()
                                    .split('.')
                                    .first;

                                return MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: InkWell(
                                    onTap: () => _showOrderDetails(order),
                                    hoverColor: const Color(0xFFF3F4F6),
                                    child: Container(
                                      color: isSelected
                                          ? const Color(0xFFF0F7FF)
                                          : zebra,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 14,
                                      ),
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            value: isSelected,
                                            onChanged: (_) => controller
                                                .toggleOrderSelection(order.id),
                                            side: const BorderSide(
                                              color: Color(0xFF9CA3AF),
                                            ),
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),

                                          _cell(shortId, _wId),
                                          _cell(order.orderNo, _wOrderNo),
                                          _cell(addr?.name ?? '-', _wCustomer),
                                          _cell(addr?.phone ?? '-', _wPhone),

                                          // Address
                                          _cell(addressLine, _wAddress),

                                          const SizedBox(width: 16),

                                          // Items (visual gap between address & items)
                                          _cell(itemsSummary, _wItems),

                                          _cell(payMethod, _wPayment),
                                          _cell(payStatus, _wPayStatus),

                                          // Order status + dropdown
                                          SizedBox(
                                            width: _wOrderStatus,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: _statusChip(
                                                    order.status,
                                                    double.infinity,
                                                  ),
                                                ),
                                                PopupMenuButton<String>(
                                                  tooltip: 'Change status',
                                                  onSelected: (value) {
                                                    controller
                                                        .updateOrderStatus(
                                                          orderId: order.id,
                                                          status: value,
                                                        );
                                                  },
                                                  itemBuilder: (_) => const [
                                                    PopupMenuItem(
                                                      value: 'pending',
                                                      child: Text('Pending'),
                                                    ),
                                                    PopupMenuItem(
                                                      value: 'completed',
                                                      child: Text('Completed'),
                                                    ),
                                                  ],
                                                  child: const Icon(
                                                    Icons.arrow_drop_down,
                                                    size: 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          _cell(
                                            _formatCurrency(
                                              order.currency,
                                              order.subTotal,
                                            ),
                                            _wSubtotal,
                                            isMono: true,
                                          ),
                                          _cell(
                                            order.deliveryFee.toString(),
                                            _wDelivery,
                                          ),
                                          _cell(
                                            order.serviceFee.toString(),
                                            _wService,
                                          ),
                                          _cell(order.tax.toString(), _wTax),
                                          _cell(
                                            _formatCurrency(
                                              order.currency,
                                              order.grandTotal,
                                            ),
                                            _wGrand,
                                            isMono: true,
                                          ),
                                          _cell(created, _wCreated),
                                          SizedBox(
                                            width: _wActions,
                                            child: IconButton(
                                              tooltip: 'View',
                                              icon: const Icon(
                                                Icons.more_vert_rounded,
                                                size: 20,
                                              ),
                                              onPressed: () =>
                                                  _showOrderDetails(order),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          _paginationBar(),
        ],
      ),
    );
  }

  // ================== ORDER DETAILS DIALOG ==================

  void _showOrderDetails(Datum order) {
    final addr = order.address;
    final addressLine = addr == null
        ? '-'
        : [
            addr.line1,
            addr.city,
            addr.state,
            addr.country,
          ].where((e) => e.trim().isNotEmpty).join(', ');
    final created = order.createdAt.toLocal().toString().split('.').first;

    showDialog(
      context: context,
      builder: (context) {
        final isCompletedUi = order.status.toLowerCase() == 'delivered';

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 80,
            vertical: 40,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 650),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order ${order.orderNo}',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${order.id}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: OrdersScreen.kMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Placed on $created',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: OrdersScreen.kMuted,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _statusChip(order.status, 120),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: isCompletedUi ? 'completed' : 'pending',
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: 'pending',
                            child: Text('Pending'),
                          ),
                          DropdownMenuItem(
                            value: 'completed',
                            child: Text('Completed'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          controller.updateOrderStatus(
                            orderId: order.id,
                            status: v,
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Top info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customer',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              addr?.name ?? '-',
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              addr?.phone ?? '-',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: OrdersScreen.kMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              addressLine,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: OrdersScreen.kMuted,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 24),

                      // Payment
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Method: ${order.payment?.method?.toUpperCase() ?? '-'}',
                              style: GoogleFonts.inter(fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Status: ${order.payment?.status ?? '-'}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: OrdersScreen.kMuted,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Wallet used: ${order.walletUsed}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: OrdersScreen.kMuted,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 24),

                      // Totals
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Totals',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _totalRow(
                              'Subtotal',
                              _formatCurrency(order.currency, order.subTotal),
                            ),
                            _totalRow(
                              'Delivery fee',
                              order.deliveryFee.toString(),
                            ),
                            _totalRow(
                              'Service fee',
                              order.serviceFee.toString(),
                            ),
                            _totalRow('Tax', order.tax.toString()),
                            const Divider(height: 14),
                            _totalRow(
                              'Grand total',
                              _formatCurrency(order.currency, order.grandTotal),
                              bold: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Items
                  Text(
                    'Items (${order.items.length})',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: OrdersScreen.kStroke),
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: order.items.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 12,
                          color: OrdersScreen.kStroke,
                        ),
                        itemBuilder: (context, i) {
                          final item = order.items[i];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: item.image.isNotEmpty
                                    ? Image.network(
                                        item.image,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 48,
                                        height: 48,
                                        color: const Color(0xFFF3F4F6),
                                        child: const Icon(
                                          Icons.image_outlined,
                                          size: 20,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'SKU: ${item.sku}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: OrdersScreen.kMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'x${item.qty}',
                                style: GoogleFonts.inter(fontSize: 13),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatCurrency(
                                      item.currency,
                                      item.priceSale,
                                    ),
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Subtotal: ${_formatCurrency(item.currency, item.priceSale * item.qty)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: OrdersScreen.kMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ================== TOOLBAR / HEADER / PAGINATION ==================

  Widget _tableToolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Obx(
            () => Text(
              'Orders (${controller.orders.length})',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Obx(() {
            final count = controller.selectedOrders.length;
            if (count == 0) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: OrdersScreen.kStroke),
              ),
              child: Text(
                '$count selected',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: OrdersScreen.kMuted,
                ),
              ),
            );
          }),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.filter_list, size: 18),
            label: const Text('Filters (6)'),
            style: _outlinedDense(),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 260,
            height: 38,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search orders…',
                hintStyle: GoogleFonts.inter(
                  fontSize: 13,
                  color: OrdersScreen.kMuted,
                ),
                prefixIcon: const Icon(Icons.search, size: 18),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: OrdersScreen.kStroke),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: OrdersScreen.kStroke),
                ),
              ),
              onChanged: (v) => controller.searchQuery.value = v,
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Export table'),
            style: _outlinedDense(),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Obx(() {
            final allSelected =
                controller.orders.isNotEmpty &&
                controller.selectedOrders.length == controller.orders.length;
            return Checkbox(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: allSelected,
              onChanged: (_) => controller.toggleAllOrders(),
              side: const BorderSide(color: Color(0xFF9CA3AF)),
              visualDensity: VisualDensity.compact,
            );
          }),
          _head('ID', _wId),
          _head('Order #', _wOrderNo),
          _head('Customer', _wCustomer),
          _head('Phone', _wPhone),
          _head('Address', _wAddress),
          _head('Items', _wItems),
          _head('Payment', _wPayment),
          _head('Pay. status', _wPayStatus),
          _head('Order status', _wOrderStatus),
          _head('Subtotal', _wSubtotal),
          _head('Delivery', _wDelivery),
          _head('Service', _wService),
          _head('Tax', _wTax),
          _head('Grand total', _wGrand),
          _head('Created at', _wCreated),
          const SizedBox(width: _wActions),
        ],
      ),
    );
  }

  Widget _paginationBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: OrdersScreen.kStroke)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Obx(() {
            final total = controller.orders.length;
            final page = controller.currentPage.value;
            final per = controller.pageSize.value;
            final start = total == 0 ? 0 : ((page - 1) * per) + 1;
            final end = (page * per).clamp(0, total);
            return Text(
              '$start–$end of $total',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: OrdersScreen.kMuted,
              ),
            );
          }),
          const Spacer(),
          Text('Items per page', style: GoogleFonts.inter(fontSize: 13)),
          const SizedBox(width: 8),
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: OrdersScreen.kStroke),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Obx(
              () => DropdownButton<int>(
                value: controller.pageSize.value,
                underline: const SizedBox(),
                isDense: true,
                items: const [7, 10, 20, 50]
                    .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    controller.setPageSize(v);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Prev',
            icon: const Icon(Icons.chevron_left),
            onPressed: () => controller.prevPage(),
          ),
          IconButton(
            tooltip: 'Next',
            icon: const Icon(Icons.chevron_right),
            onPressed: () => controller.nextPage(),
          ),
        ],
      ),
    );
  }

  // ================== HELPERS ==================

  ButtonStyle _outlined() => OutlinedButton.styleFrom(
    foregroundColor: Colors.black87,
    side: const BorderSide(color: OrdersScreen.kStroke),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  ButtonStyle _outlinedDense() => OutlinedButton.styleFrom(
    foregroundColor: Colors.black87,
    side: const BorderSide(color: OrdersScreen.kStroke),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  Widget _head(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _cell(String text, double width, {bool isMono = false}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.black87,
          fontFeatures: isMono
              ? const [FontFeature.tabularFigures()]
              : const [],
        ),
      ),
    );
  }

  Widget _statusChip(String status, double width) {
    late Color bg;
    late Color fg;
    final s = status.toLowerCase();

    if (s == 'delivered' || s == 'completed') {
      bg = const Color(0xFF10B981).withOpacity(.12);
      fg = const Color(0xFF059669);
    } else if (s == 'pending') {
      bg = const Color(0xFFF59E0B).withOpacity(.14);
      fg = const Color(0xFFD97706);
    } else if (s == 'cancelled' || s == 'failed' || s == 'returned') {
      bg = const Color(0xFFEF4444).withOpacity(.12);
      fg = const Color(0xFFDC2626);
    } else {
      bg = const Color(0xFFE5E7EB);
      fg = const Color(0xFF6B7280);
    }

    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          status,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }

  String _itemsSummary(List<Item> items) {
    if (items.isEmpty) return '-';
    final first = items.first;
    final title = first.title;
    final qty = first.qty;
    if (items.length == 1) {
      return '$title (x$qty)';
    }
    final more = items.length - 1;
    return '$title (x$qty) + $more more';
  }

  String _formatCurrency(Currency currency, num value) {
    final prefix = currency == Currency.PKR ? 'PKR ' : '\$';
    return '$prefix${value.toStringAsFixed(2)}';
  }

  Widget _totalRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: OrdersScreen.kMuted),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
