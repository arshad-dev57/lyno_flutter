// lib/controller/product_controller.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:lyno_cms/models/product_model.dart';

class ProductController extends GetxController {
  static const String baseUrl = "https://lyno-shopping.vercel.app";

  // observables
  final products = <Product>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  // ==== Text field controllers ====
  final titleCtrl = TextEditingController();
  final skuCtrl = TextEditingController();
  final brandCtrl = TextEditingController();

  final shortDescCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  final mrpCtrl = TextEditingController();
  final saleCtrl = TextEditingController();
  final currencyCtrl = TextEditingController(text: "\$");
  final taxPercentCtrl = TextEditingController(text: "0");

  final stockQtyCtrl = TextEditingController(text: "95");
  final minOrderQtyCtrl = TextEditingController(text: "1");
  final maxOrderQtyCtrl = TextEditingController(text: "0");

  final tagsCtrl = TextEditingController();
  final seoTitleCtrl = TextEditingController();
  final seoDescCtrl = TextEditingController();
  final orderCtrl = TextEditingController(text: "0");

  // category from dropdown
  final selectedCategoryId = RxnString();

  // ==== Attributes dynamic list ====
  final attrKeyCtrls = <TextEditingController>[].obs;
  final attrValCtrls = <TextEditingController>[].obs;

  // ==== Primary image (file picker) ====
  final pickedImageBytes = Rx<Uint8List?>(null);
  final pickedImageName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _ensureDynamicDefaults();
    fetchProducts();
  }

  void _ensureDynamicDefaults() {
    if (attrKeyCtrls.isEmpty) {
      addAttributeField();
    }
  }

  @override
  void onClose() {
    // main controllers
    titleCtrl.dispose();
    skuCtrl.dispose();
    brandCtrl.dispose();
    shortDescCtrl.dispose();
    descCtrl.dispose();
    mrpCtrl.dispose();
    saleCtrl.dispose();
    currencyCtrl.dispose();
    taxPercentCtrl.dispose();
    stockQtyCtrl.dispose();
    minOrderQtyCtrl.dispose();
    maxOrderQtyCtrl.dispose();
    tagsCtrl.dispose();
    seoTitleCtrl.dispose();
    seoDescCtrl.dispose();
    orderCtrl.dispose();

    // attribute controllers (ONLY yahan dispose honge)
    for (final c in attrKeyCtrls) {
      c.dispose();
    }
    for (final c in attrValCtrls) {
      c.dispose();
    }

    super.onClose();
  }

  // ================= API: FETCH =================

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;

      final resp = await http.get(Uri.parse("$baseUrl/api/product/get"));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final list = (data['data'] as List<dynamic>)
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();

        products.assignAll(list);
      } else {
        Get.snackbar(
          'Error',
          'Failed to load products (${resp.statusCode})',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load products: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ================= ATTRIBUTES HELPERS =================

  void addAttributeField() {
    attrKeyCtrls.add(TextEditingController());
    attrValCtrls.add(TextEditingController());
  }

  void removeAttributeField(int index) {
    if (index < 0 || index >= attrKeyCtrls.length) return;

    // ❗ Yahan dispose NAHI kar rahe, sirf list se nikal rahe
    attrKeyCtrls.removeAt(index);
    attrValCtrls.removeAt(index);

    // hamesha kam se kam 1 row rahe
    if (attrKeyCtrls.isEmpty) {
      addAttributeField();
    }
  }

  // ================= IMAGE PICKER HELPERS =================

  Future<void> pickPrimaryImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      pickedImageBytes.value = file.bytes;
      pickedImageName.value = file.name;
    }
  }

  void clearPickedImage() {
    pickedImageBytes.value = null;
    pickedImageName.value = '';
  }

  // ================= UTILITIES =================

  List<String> _csvToList(String input) {
    return input
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  // ================= ADD PRODUCT (multipart + 1 image) =================

  Future<void> addProduct() async {
    final title = titleCtrl.text.trim();
    final sku = skuCtrl.text.trim();
    final brand = brandCtrl.text.trim();
    final shortDesc = shortDescCtrl.text.trim();
    final desc = descCtrl.text.trim();

    final mrpText = mrpCtrl.text.trim();
    final saleText = saleCtrl.text.trim();
    final currency = currencyCtrl.text.trim().isEmpty
        ? "\$"
        : currencyCtrl.text.trim();
    final taxText = taxPercentCtrl.text.trim();

    final stockText = stockQtyCtrl.text.trim();
    final minQtyText = minOrderQtyCtrl.text.trim();
    final maxQtyText = maxOrderQtyCtrl.text.trim();

    final tagsText = tagsCtrl.text.trim();
    final seoTitle = seoTitleCtrl.text.trim();
    final seoDesc = seoDescCtrl.text.trim();
    final orderText = orderCtrl.text.trim();

    if (title.isEmpty || mrpText.isEmpty || saleText.isEmpty) {
      Get.snackbar(
        'Validation',
        'Title, MRP aur Sale price required hain',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedCategoryId.value == null) {
      Get.snackbar(
        'Validation',
        'Category select karna zaroori hai',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final mrp = double.tryParse(mrpText) ?? 0;
    final sale = double.tryParse(saleText) ?? 0;
    final taxPercent = double.tryParse(taxText) ?? 0;
    final stockQty = int.tryParse(stockText) ?? 0;
    final minOrderQty = int.tryParse(minQtyText) ?? 1;
    final maxOrderQty = int.tryParse(maxQtyText) ?? 0;
    final order = int.tryParse(orderText) ?? 0;

    final tags = _csvToList(tagsText);

    // build attributes
    final attributes = <Map<String, String>>[];
    for (var i = 0; i < attrKeyCtrls.length; i++) {
      final k = attrKeyCtrls[i].text.trim();
      final v = attrValCtrls[i].text.trim();
      if (k.isEmpty && v.isEmpty) continue;
      if (k.isEmpty || v.isEmpty) continue;
      attributes.add({'key': k, 'value': v});
    }

    final String catId = selectedCategoryId.value!;

    final Map<String, dynamic> body = {
      "title": title,
      "sku": sku.isEmpty ? null : sku,
      "brand": brand.isEmpty ? null : brand,
      "shortDescription": shortDesc,
      "description": desc,
      "price": {
        "mrp": mrp,
        "sale": sale,
        "currency": currency,
        "taxPercent": taxPercent,
      },
      "stockQty": stockQty,
      "minOrderQty": minOrderQty,
      "maxOrderQty": maxOrderQty,
      "attributes": attributes,
      "tags": tags,
      "seoTitle": seoTitle.isEmpty ? null : seoTitle,
      "seoDescription": seoDesc.isEmpty ? null : seoDesc,
      "order": order,
      "category": catId,
      "categories": [catId],
    };

    try {
      isSubmitting.value = true;

      final hasImage = pickedImageBytes.value != null;

      http.Response resp;

      if (hasImage) {
        final uri = Uri.parse("$baseUrl/api/product/add");
        final request = http.MultipartRequest('POST', uri);

        body.forEach((key, value) {
          if (value == null) return;
          if (value is String || value is num || value is bool) {
            request.fields[key] = value.toString();
          } else {
            request.fields[key] = jsonEncode(value);
          }
        });

        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            pickedImageBytes.value!,
            filename: pickedImageName.value.isEmpty
                ? 'product.jpg'
                : pickedImageName.value,
            contentType: MediaType('image', 'jpeg'),
          ),
        );

        final streamed = await request.send();
        resp = await http.Response.fromStream(streamed);
      } else {
        resp = await http.post(
          Uri.parse("$baseUrl/api/product/add"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );
      }

      if (resp.statusCode == 201) {
        final data = jsonDecode(resp.body);
        final createdJson = data['data'] as Map<String, dynamic>;
        final createdProduct = Product.fromJson(createdJson);

        products.insert(0, createdProduct);
        clearForm();

        Get.snackbar(
          'Success',
          'Product add ho gaya',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to add product (${resp.statusCode})',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add product: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearForm() {
    titleCtrl.clear();
    skuCtrl.clear();
    brandCtrl.clear();
    shortDescCtrl.clear();
    descCtrl.clear();

    mrpCtrl.clear();
    saleCtrl.clear();
    currencyCtrl.text = "\$";
    taxPercentCtrl.text = "0";

    stockQtyCtrl.text = "95";
    minOrderQtyCtrl.text = "1";
    maxOrderQtyCtrl.text = "0";

    tagsCtrl.clear();
    seoTitleCtrl.clear();
    seoDescCtrl.clear();
    orderCtrl.text = "0";

    selectedCategoryId.value = null;

    // attributes: sirf text clear karo, controllers zinda rakho
    for (final c in attrKeyCtrls) {
      c.clear();
    }
    for (final c in attrValCtrls) {
      c.clear();
    }
    if (attrKeyCtrls.isEmpty) {
      addAttributeField();
    }

    clearPickedImage();
  }
}
