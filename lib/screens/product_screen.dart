// lib/screens/product_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lyno_cms/controller/category_controller.dart';
import 'package:lyno_cms/controller/product_controller.dart';

import '../models/product_model.dart';

class ProductScreen extends StatelessWidget {
  ProductScreen({super.key});

  final ProductController controller = Get.put(ProductController());
  final CategoryController catController = Get.put(CategoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FB),
      appBar: AppBar(
        title: const Text('Products'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFF5F5FB),
      ),
      body: Padding(
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

          final products = controller.products;

          return LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 1;
              double aspectRatio = 0.9;

              if (constraints.maxWidth >= 1200) {
                crossAxisCount = 4;
                aspectRatio = 1.0;
              } else if (constraints.maxWidth >= 900) {
                crossAxisCount = 3;
                aspectRatio = 0.9;
              } else if (constraints.maxWidth >= 600) {
                crossAxisCount = 2;
                aspectRatio = 0.8;
              }

              return GridView.builder(
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: aspectRatio,
                ),
                itemBuilder: (context, index) {
                  final p = products[index];
                  return _ProductCard(product: p);
                },
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddProductDialog(),
        label: const Text('Add Product'),
        icon: const Icon(Icons.add),
      ),
    );
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
                width: 820, // thora wide CRM feel
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
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
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
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String? fullImageUrl;
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      if (product.imageUrl!.startsWith('http')) {
        fullImageUrl = product.imageUrl!;
      } else {
        final path = product.imageUrl!.replaceFirst(RegExp(r'^/'), '');
        fullImageUrl = '${ProductController.baseUrl}/$path';
      }
    }

    final double mrp = product.price.mrp;
    final double sale = product.price.sale;
    final bool hasDiscount = sale < mrp && mrp > 0;
    final double discountPercent = hasDiscount
        ? ((mrp - sale) / mrp * 100).clamp(0, 99.0)
        : 0;
    final bool isOutOfStock = product.stockQty <= 0;

    return Card(
      elevation: 4,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // IMAGE + BADGES
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Positioned.fill(
                  child: fullImageUrl != null
                      ? Image.network(
                          fullImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade100,
                            child: Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade100,
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                        ),
                ),
                if (hasDiscount)
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        "-${discountPercent.toStringAsFixed(0)}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (isOutOfStock)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Out of stock',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // TEXT CONTENT
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // brand
                  if (product.brand != null && product.brand!.isNotEmpty)
                    Text(
                      product.brand!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                      ),
                    ),

                  const SizedBox(height: 6),

                  // short description
                  Text(
                    product.shortDescription ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.black87),
                  ),

                  const Spacer(),

                  // price row
                  Row(
                    children: [
                      Text(
                        "${sale.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (hasDiscount)
                        Text(
                          mrp.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // stock row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Stock: ${product.stockQty}",
                        style: TextStyle(
                          fontSize: 10,
                          color: isOutOfStock
                              ? Colors.redAccent
                              : Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        "Min: ${product.minOrderQty}",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
