import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lyno_cms/controller/category_controller.dart';
import 'package:lyno_cms/controller/product_controller.dart';

import '../models/product_model.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductController controller = Get.put(ProductController());
  final CategoryController catController = Get.put(CategoryController());

  // UI state
  final TextEditingController _searchCtrl = TextEditingController();
  String _stockFilter = 'All';
  String _sortOption = 'Newest';
  int _currentPage = 1;
  static const int _pageSize = 15;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Product> _applyFilters(List<Product> products) {
    final query = _searchCtrl.text.trim().toLowerCase();

    List<Product> filtered = products.where((p) {
      final title = p.title.toLowerCase();
      final brand = (p.brand ?? '').toLowerCase();
      final short = (p.shortDescription ?? '').toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          title.contains(query) ||
          brand.contains(query) ||
          short.contains(query);

      final isOutOfStock = p.stockQty <= 0;
      bool matchesStock = true;
      if (_stockFilter == 'In stock') {
        matchesStock = !isOutOfStock;
      } else if (_stockFilter == 'Out of stock') {
        matchesStock = isOutOfStock;
      }

      return matchesSearch && matchesStock;
    }).toList();

    // sorting (adjust if you have createdAt etc)
    if (_sortOption == 'Price: Low to High') {
      filtered.sort((a, b) => a.price.sale.compareTo(b.price.sale));
    } else if (_sortOption == 'Price: High to Low') {
      filtered.sort((a, b) => b.price.sale.compareTo(a.price.sale));
    } else if (_sortOption == 'Stock: Low to High') {
      filtered.sort((a, b) => a.stockQty.compareTo(b.stockQty));
    } else if (_sortOption == 'Stock: High to Low') {
      filtered.sort((a, b) => b.stockQty.compareTo(a.stockQty));
    }
    // "Newest" rakha hai default – agar tumhare model me createdAt ho to
    // yahan us hisaab se sort kar sakte ho.

    return filtered;
  }

  void _openAddProductDialog() {
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(24),
        backgroundColor: Colors.transparent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final theme = Theme.of(context);
            final double dialogHeight = constraints.maxHeight * 0.85;

            InputDecoration crmInput(String label, {String? hint}) {
              return InputDecoration(
                labelText: label,
                hintText: hint,
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.4,
                  ),
                ),
              );
            }

            return Center(
              child: SizedBox(
                width: 820,
                height: dialogHeight,
                child: Obx(() {
                  final categories = catController.categories;

                  return Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                          color: Colors.black.withOpacity(0.10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // ---------- HEADER ----------
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Add Product',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Create a new catalog item for your store',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'New',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.close),
                                splashRadius: 20,
                                onPressed: () => Get.back(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Divider(color: Colors.grey.shade200),
                          const SizedBox(height: 8),

                          // ---------- BODY (SCROLLABLE) ----------
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // === Basic Info ===
                                  const Text(
                                    'Basic information',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  TextField(
                                    controller: controller.titleCtrl,
                                    decoration: crmInput(
                                      'Title *',
                                      hint: 'e.g. Xiaomi Smart Smoke Detector',
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: controller.skuCtrl,
                                          decoration: crmInput(
                                            'SKU',
                                            hint: 'Internal code',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller: controller.brandCtrl,
                                          decoration: crmInput(
                                            'Brand',
                                            hint: 'e.g. Xiaomi',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  DropdownButtonFormField<String>(
                                    value: controller.selectedCategoryId.value,
                                    items: categories.map((c) {
                                      return DropdownMenuItem<String>(
                                        value: c.id,
                                        child: Text(c.title),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      controller.selectedCategoryId.value = val;
                                    },
                                    decoration: crmInput('Category *'),
                                  ),
                                  const SizedBox(height: 12),

                                  TextField(
                                    controller: controller.shortDescCtrl,
                                    maxLines: 2,
                                    decoration: crmInput(
                                      'Short description',
                                      hint:
                                          'This appears on cards and listing pages',
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: controller.descCtrl,
                                    maxLines: 4,
                                    decoration: crmInput(
                                      'Full description',
                                      hint: 'Detailed product information',
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  // === Pricing ===
                                  const Text(
                                    'Pricing',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: controller.mrpCtrl,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          decoration: crmInput(
                                            'MRP *',
                                            hint: 'Regular price',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller: controller.saleCtrl,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          decoration: crmInput(
                                            'Sale price *',
                                            hint: 'Offer price',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: controller.currencyCtrl,
                                          decoration: crmInput(
                                            'Currency',
                                            hint: 'e.g. QAR, USD',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller: controller.taxPercentCtrl,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          decoration: crmInput(
                                            'Tax %',
                                            hint: 'e.g. 5',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 18),

                                  // === Inventory ===
                                  const Text(
                                    'Inventory',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: controller.stockQtyCtrl,
                                          keyboardType: TextInputType.number,
                                          decoration: crmInput(
                                            'Stock quantity',
                                            hint: 'Available units',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller:
                                              controller.minOrderQtyCtrl,
                                          keyboardType: TextInputType.number,
                                          decoration: crmInput(
                                            'Min order qty',
                                            hint: 'Default 1',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller:
                                              controller.maxOrderQtyCtrl,
                                          keyboardType: TextInputType.number,
                                          decoration: crmInput(
                                            'Max order qty (0 = no limit)',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  TextField(
                                    controller: controller.orderCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: crmInput(
                                      'Sort order',
                                      hint: 'Lower number = higher in listing',
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  // === SEO & Tags ===
                                  const Text(
                                    'SEO & tags',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  TextField(
                                    controller: controller.tagsCtrl,
                                    decoration: crmInput(
                                      'Tags',
                                      hint: 'Comma separated tags',
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: controller.seoTitleCtrl,
                                    decoration: crmInput(
                                      'SEO title',
                                      hint: 'Optional meta title',
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: controller.seoDescCtrl,
                                    maxLines: 2,
                                    decoration: crmInput(
                                      'SEO description',
                                      hint: 'Optional meta description',
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  // === Media & Attributes ===
                                  const Text(
                                    'Media & attributes',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  _ImagePickerSection(controller: controller),
                                  const SizedBox(height: 14),
                                  _AttributesSection(controller: controller),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // ---------- FOOTER ----------
                          Container(
                            padding: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade200),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: controller.isSubmitting.value
                                      ? null
                                      : () {
                                          controller.clearForm();
                                          Get.back();
                                        },
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: controller.isSubmitting.value
                                      ? null
                                      : () async {
                                          await controller.addProduct();
                                          if (!controller.isSubmitting.value) {
                                            Get.back();
                                          }
                                        },
                                  icon: controller.isSubmitting.value
                                      ? const SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.save_outlined,
                                          size: 18,
                                        ),
                                  label: controller.isSubmitting.value
                                      ? const SizedBox.shrink()
                                      : const Text('Save product'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 22,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color kBg = Color(0xFFF5F7FB);
    const Color kPrimary = Color(0xFF4F46E5);

    InputDecoration pillInput({
      required String hint,
      Widget? prefix,
      Widget? suffix,
    }) {
      return InputDecoration(
        hintText: hint,
        prefixIcon: prefix,
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: kPrimary, width: 1.4),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        toolbarHeight: 0, // AppBar hidden – like screenshot
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            if (controller.isLoading.value || catController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.products.isEmpty) {
              return const Center(
                child: Text(
                  'No products yet',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              );
            }

            final allProducts = controller.products;
            final filtered = _applyFilters(allProducts);
            final total = filtered.length;
            final totalPages = math.max(1, (total / _pageSize).ceil());
            final currentPage = _currentPage.clamp(1, totalPages);

            final startIndex = (currentPage - 1) * _pageSize;
            final endIndex = math.min(startIndex + _pageSize, total);
            final pageItems = filtered.sublist(startIndex, endIndex);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- TOP TITLE ROW ----------
                Row(
                  children: [
                    const Text(
                      'Products',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF4FF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$total',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add Product
                    ElevatedButton.icon(
                      onPressed: _openAddProductDialog,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Product'),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Refresh
                    OutlinedButton.icon(
                      onPressed: () {
                        // TODO: yahan apna refresh logic lagao
                        // e.g. controller.fetchProducts();
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Refresh'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ---------- SEARCH + FILTERS ----------
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (_) {
                          setState(() {
                            _currentPage = 1;
                          });
                        },
                        decoration: pillInput(
                          hint: 'Search name, brand, status...',
                          prefix: const Icon(Icons.search),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: _PillDropdown(
                        value: _stockFilter,
                        items: const ['All', 'In stock', 'Out of stock'],
                        icon: Icons.filter_alt_outlined,
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() {
                            _stockFilter = val;
                            _currentPage = 1;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: _PillDropdown(
                        value: _sortOption,
                        items: const [
                          'Newest',
                          'Price: Low to High',
                          'Price: High to Low',
                          'Stock: Low to High',
                          'Stock: High to Low',
                        ],
                        icon: Icons.sort,
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() {
                            _sortOption = val;
                            _currentPage = 1;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ---------- TABLE HEADER ----------
                _TableHeaderRow(),

                const SizedBox(height: 8),

                // ---------- LIST + PAGINATION ----------
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          itemCount: pageItems.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final product = pageItems[index];
                            return _ProductRow(product: product);
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      _PaginationFooter(
                        totalItems: total,
                        currentPage: currentPage,
                        totalPages: totalPages,
                        onPageChanged: (page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _PillDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _PillDropdown({
    required this.value,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          onChanged: onChanged,
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Row(
                    children: [
                      Icon(icon, size: 18, color: const Color(0xFF6B7280)),
                      const SizedBox(width: 6),
                      Flexible(child: Text(e, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _TableHeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Color(0xFF6B7280),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text('Name / Brand', style: headerStyle)),
          Expanded(flex: 2, child: Text('Price', style: headerStyle)),
          Expanded(flex: 2, child: Text('Stock', style: headerStyle)),
          Expanded(flex: 2, child: Text('Status', style: headerStyle)),
          SizedBox(
            width: 70,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('Actions', style: headerStyle),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final Product product;

  const _ProductRow({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String initials = '';
    if (product.title.isNotEmpty) {
      initials = product.title.trim()[0].toUpperCase();
    }

    final bool isOutOfStock = product.stockQty <= 0;
    final mrp = product.price.mrp;
    final sale = product.price.sale;
    final bool hasDiscount = sale < mrp && mrp > 0;
    final discountPercent = hasDiscount
        ? ((mrp - sale) / mrp * 100).clamp(0, 99).round()
        : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Name / Brand cell
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF111827),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      product.imageUrl!,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.brand?.isNotEmpty == true
                            ? product.brand!
                            : 'Product',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Price
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sale.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (hasDiscount) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        mrp.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '-$discountPercent%',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Stock
          Expanded(
            flex: 2,
            child: Text(
              'Stock: ${product.stockQty}',
              style: TextStyle(
                fontSize: 12,
                color: isOutOfStock
                    ? Colors.redAccent
                    : const Color(0xFF374151),
              ),
            ),
          ),

          // Status
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isOutOfStock
                        ? Colors.redAccent
                        : const Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isOutOfStock
                        ? const Color(0xFFFFE4E6)
                        : const Color(0xFFE7F8F0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isOutOfStock ? 'Out of stock' : 'In stock',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isOutOfStock
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFF16A34A),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Actions
          SizedBox(
            width: 70,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Color(0xFF9CA3AF),
                  ),
                  onPressed: () {
                    // TODO: yahan apni deleteProduct logic lagao
                    // e.g. controller.deleteProduct(product.id);
                  },
                  padding: EdgeInsets.zero,
                  splashRadius: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const _PaginationFooter({
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  List<int> _visiblePages() {
    if (totalPages <= 7) {
      return List.generate(totalPages, (i) => i + 1);
    }

    final List<int> pages = [1];
    if (currentPage > 3) pages.add(-1); // ellipsis

    final start = math.max(2, currentPage - 1);
    final end = math.min(totalPages - 1, currentPage + 1);
    for (int p = start; p <= end; p++) {
      pages.add(p);
    }

    if (currentPage < totalPages - 2) pages.add(-1);
    pages.add(totalPages);

    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final pages = _visiblePages();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Total : $totalItems',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: currentPage > 1
                ? () => onPageChanged(currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
            splashRadius: 18,
          ),
          ...pages.map((p) {
            if (p == -1) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Text('...'),
              );
            }
            final bool isActive = p == currentPage;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => onPageChanged(p),
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF4F46E5) : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    '$p',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : const Color(0xFF374151),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
          IconButton(
            onPressed: currentPage < totalPages
                ? () => onPageChanged(currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
            splashRadius: 18,
          ),
          const SizedBox(width: 16),
          const Text(
            'Go to Page:',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(width: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: currentPage,
              onChanged: (val) {
                if (val != null) onPageChanged(val);
              },
              items: List.generate(
                totalPages,
                (i) => DropdownMenuItem<int>(
                  value: i + 1,
                  child: Text('${i + 1}'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePickerSection extends StatelessWidget {
  final ProductController controller;

  const _ImagePickerSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bytes = controller.pickedImageBytes.value;
      final name = controller.pickedImageName.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Primary Image (file picker)',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: controller.pickPrimaryImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Pick from gallery'),
              ),
              const SizedBox(width: 12),
              if (bytes == null)
                const Text(
                  'No image selected',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                )
              else
                Row(
                  children: [
                    Text(
                      name.isEmpty ? 'Image selected' : name,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: controller.clearPickedImage,
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (bytes != null)
            SizedBox(
              height: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(bytes, fit: BoxFit.cover),
              ),
            ),
        ],
      );
    });
  }
}

class _AttributesSection extends StatelessWidget {
  final ProductController controller;

  const _AttributesSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Attributes',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton.icon(
                onPressed: controller.addAttributeField,
                icon: const Icon(Icons.add),
                label: const Text('Add Attribute'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: List.generate(controller.attrKeyCtrls.length, (index) {
              final keyCtrl = controller.attrKeyCtrls[index];
              final valCtrl = controller.attrValCtrls[index];

              return Padding(
                key: ValueKey(keyCtrl),
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: ValueKey('attr_key_$index'),
                        controller: keyCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Key',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        key: ValueKey('attr_val_$index'),
                        controller: valCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Value',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: controller.attrKeyCtrls.length == 1
                          ? null
                          : () => controller.removeAttributeField(index),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      );
    });
  }
}
