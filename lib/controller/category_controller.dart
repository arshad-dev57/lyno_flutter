import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/category_model.dart';

class CategoryController extends GetxController {
  static const String baseUrl = 'http://192.168.100.189:5000';
  static const String categoriesEndpoint = '/api/category/categories';
  static const String groupsEndpoint = '/api/category/category-groups';

  final categories = <Category>[].obs;
  final groups = <CategoryGroupMin>[].obs;
  final groupById = <String, String>{}.obs;

  final isLoading = false.obs;
  final saving = false.obs;

  final title = ''.obs;
  final selectedGroupId = RxnString();
  final imageUrl = ''.obs;
  final order = 0.obs;
  final isActive = true.obs;

  final pickedBytesRx = Rxn<Uint8List>();
  String? pickedFilename;

  @override
  void onInit() {
    super.onInit();
    fetchGroups();
    fetchCategories();
  }

  Future<void> fetchGroups() async {
    try {
      final uri = Uri.parse(
        '$baseUrl$groupsEndpoint',
      ).replace(queryParameters: {'activeOnly': 'true'});
      final res = await http.get(uri);
      final data = _safeDecode(res.body);
      final List list = data['data'] ?? [];
      final parsed = list.map((e) => CategoryGroupMin.fromJson(e)).toList();
      groups.assignAll(parsed);
      groupById.assignAll({for (final g in parsed) g.id: g.title});
      if (selectedGroupId.value == null && groups.isNotEmpty) {
        selectedGroupId.value = groups.first.id;
      }
    } catch (e) {
      Get.snackbar('Groups Error', '$e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final uri = Uri.parse('$baseUrl$categoriesEndpoint');
      final res = await http.get(uri);
      final data = _safeDecode(res.body);
      final List list = data['data'] ?? [];
      categories.assignAll(list.map((e) => Category.fromJson(e)).toList());
    } catch (e) {
      Get.snackbar('Categories Error', '$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCategory() async {
    if ((title.value.trim().isEmpty) || selectedGroupId.value == null) {
      Get.snackbar('Missing', 'Title and Group are required');
      return;
    }

    try {
      saving.value = true;
      final uri = Uri.parse('$baseUrl$categoriesEndpoint');
      final req = http.MultipartRequest('POST', uri);

      // Fields
      req.fields['title'] = title.value.trim();
      req.fields['group'] = selectedGroupId.value!;
      req.fields['order'] = '${order.value}';
      req.fields['isActive'] = isActive.value ? 'true' : 'false';
      if (imageUrl.value.trim().isNotEmpty && pickedBytesRx.value == null) {
        req.fields['imageUrl'] = imageUrl.value.trim(); // backend fallback
      }

      // File field (must match router: upload.single('image'))
      if (pickedBytesRx.value != null && pickedBytesRx.value!.isNotEmpty) {
        req.files.add(
          http.MultipartFile.fromBytes(
            'image',
            pickedBytesRx.value!,
            filename: pickedFilename ?? 'image.jpg',
          ),
        );
      }

      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = _safeDecode(res.body);
        final cat = Category.fromJson(data['data']);
        categories.insert(0, cat);
        Get.snackbar('Success', 'Category created');
        resetForm();
      } else {
        final msg =
            _safeDecode(res.body)['message'] ??
            'Server error ${res.statusCode}';
        Get.snackbar('Create failed', '$msg');
      }
    } catch (e) {
      Get.snackbar('Error', '$e');
    } finally {
      saving.value = false;
    }
  }

  Future<void> deleteCategory(Category c) async {
    try {
      saving.value = true;
      final uri = Uri.parse('$baseUrl$categoriesEndpoint/${c.id}');
      final res = await http.delete(uri);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        // categories.removeWhere((x) => x.id == c.id);
        Get.snackbar('Deleted', 'Category removed');
      } else {
        final msg =
            _safeDecode(res.body)['message'] ??
            'Server error ${res.statusCode}';
        Get.snackbar('Delete failed', '$msg');
      }
    } catch (e) {
      Get.snackbar('Error', '$e');
    } finally {
      saving.value = false;
    }
  }

  // ====== Helpers ======
  Future<void> pickWebImage() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (r != null && r.files.isNotEmpty) {
      pickedBytesRx.value = r.files.first.bytes;
      pickedFilename = r.files.first.name;
      imageUrl.value = ''; // clear url when file chosen
    }
  }

  void clearPicked() {
    pickedBytesRx.value = null;
    pickedFilename = null;
  }

  void resetForm() {
    title.value = '';
    order.value = 0;
    isActive.value = true;
    imageUrl.value = '';
    clearPicked();
  }

  Map<String, dynamic> _safeDecode(String body) {
    try {
      final d = jsonDecode(body);
      if (d is Map<String, dynamic>) return d;
      return {'data': d};
    } catch (_) {
      return {'data': []};
    }
  }
}

class CategoryGroupMin {
  final String id;
  final String title;
  CategoryGroupMin({required this.id, required this.title});
  factory CategoryGroupMin.fromJson(Map<String, dynamic> j) => CategoryGroupMin(
    id: (j['_id'] ?? j['id']).toString(),
    title: (j['title'] ?? '').toString(),
  );
}
