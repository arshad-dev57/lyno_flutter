// lib/controller/catalogue_controller.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/category_group.dart';

class CatalogueController extends GetxController {
  // ======= CONFIG =======
  // Apna base URL set karein (aapne pehle ApiService.baseUrl me 192.168... diya tha)
  static const String baseUrl = "http://192.168.100.189:5000";
  Uri _buildUri(String endpoint, [Map<String, dynamic>? query]) {
    final uri = Uri.parse("$baseUrl/$endpoint");
    if (query == null || query.isEmpty) return uri;
    final qp = query.map((k, v) => MapEntry(k, v?.toString()));
    return uri.replace(queryParameters: qp);
  }

  Map<String, String> get _jsonHeaders => {'Content-Type': 'application/json'};

  Map<String, dynamic>? _safeDecode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded};
    } catch (_) {
      return null;
    }
  }

  // ======= STATE =======
  final groups = <CategoryGroup>[].obs;

  final isLoading = false.obs;
  final saving = false.obs;

  // Form (Title + Image only; desc/order/active optional)
  final title = ''.obs;
  final description = ''.obs;
  final order = 0.obs;
  final isActive = true.obs;

  // Image
  final heroImageUrl = ''.obs; // (URL support; create ke liye file required)
  Uint8List? pickedBytes;
  String? pickedFilename;
  final pickedBytesRx = Rxn<Uint8List>();

  // Endpoints
  final _groupsBase = 'api/category/category-groups';
  String _singleGroup(String id) => 'api/category/category-groups/$id';
  final _catalog = 'api/category/category-groups/catalog'; // optional

  @override
  void onInit() {
    super.onInit();
    fetchGroups();
  }

  // ========= Image pick (web) =========
  Future<void> pickWebImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      pickedBytes = result.files.first.bytes;
      pickedFilename = result.files.first.name;
      heroImageUrl.value = '';
      pickedBytesRx.value = pickedBytes;
    }
  }

  void clearPicked() {
    pickedBytes = null;
    pickedFilename = null;
    pickedBytesRx.value = null;
  }

  void resetForm() {
    title.value = '';
    description.value = '';
    order.value = 0;
    isActive.value = true;
    heroImageUrl.value = '';
    clearPicked();
  }

  // ========= GET List =========
  Future<void> fetchGroups({
    bool includeCategories = false,
    bool activeOnly = false,
  }) async {
    try {
      isLoading.value = true;

      final res = await http.get(
        _buildUri(_groupsBase, {
          'includeCategories': includeCategories,
          'activeOnly': activeOnly,
        }),
        headers: _jsonHeaders,
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = _safeDecode(res.body);
        final List list = data?['data'] ?? [];
        groups.assignAll(list.map((e) => CategoryGroup.fromJson(e)).toList());
      } else {
        Get.snackbar('Error', 'Server ${res.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ========= CREATE (multipart, file field: "image") =========
  Future<void> createGroup() async {
    try {
      if (title.value.trim().isEmpty) {
        Get.snackbar('Missing', 'Title is required');
        return;
      }
      // Backend expects file via upload.single('image')
      if (pickedBytes == null ||
          (pickedFilename == null || pickedFilename!.isEmpty)) {
        Get.snackbar('Image required', 'Please pick an image file');
        return;
      }

      saving.value = true;

      final url = _buildUri(_groupsBase);
      final req = http.MultipartRequest('POST', url);

      // text fields
      req.fields['title'] = title.value.trim();
      if (description.value.trim().isNotEmpty) {
        req.fields['description'] = description.value.trim();
      }
      req.fields['order'] = order.value.toString();
      req.fields['isActive'] = isActive.value.toString(); // 'true' | 'false'

      // file field must be "image"
      req.files.add(
        http.MultipartFile.fromBytes(
          'image',
          pickedBytes!,
          filename: pickedFilename!,
          // Server side you transform formats; client-side contentType is fine generic:
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = _safeDecode(res.body);
        final item = data?['data'];
        if (item == null) {
          Get.snackbar('Error', 'Invalid server response');
          return;
        }
        final cg = CategoryGroup.fromJson(item as Map<String, dynamic>);
        groups.insert(0, cg);
        Get.snackbar('Success', 'Category Group created');
        resetForm();
      } else {
        Get.snackbar('Error', 'Server ${res.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      saving.value = false;
    }
  }

  // ========= UPDATE =========
  // A) Without new image: JSON PATCH
  // B) With new image: multipart + method-override (?_method=PATCH)  -> server me method-override enabled hona chahiye
  Future<void> updateGroup(
    CategoryGroup g, {
    String? newTitle,
    String? newDesc,
    int? newOrder,
    bool? newIsActive,
    bool withImage =
        false, // set true if you picked an image and want to replace
  }) async {
    try {
      saving.value = true;

      if (!withImage || pickedBytes == null) {
        // ---------- JSON PATCH ----------
        final body = <String, dynamic>{};
        if (newTitle != null) body['title'] = newTitle;
        if (newDesc != null) body['description'] = newDesc;
        if (newOrder != null) body['order'] = newOrder;
        if (newIsActive != null) body['isActive'] = newIsActive;

        final res = await http.patch(
          _buildUri(_singleGroup(g.id!)),
          headers: _jsonHeaders,
          body: jsonEncode(body),
        );

        if (res.statusCode >= 200 && res.statusCode < 300) {
          final data = _safeDecode(res.body);
          final item = data?['data'];
          if (item == null) {
            Get.snackbar('Error', 'Invalid server response');
            return;
          }
          final updated = CategoryGroup.fromJson(item as Map<String, dynamic>);
          final idx = groups.indexWhere((x) => x.id == g.id);
          if (idx >= 0) groups[idx] = updated;
          Get.snackbar('Updated', 'Category Group updated');
        } else {
          Get.snackbar('Error', 'Server ${res.statusCode}');
        }
        return;
      }

      // ---------- MULTIPART PATCH via method-override ----------
      final url = _buildUri("${_singleGroup(g.id!)}", {'_method': 'PATCH'});
      final req = http.MultipartRequest('POST', url);

      if (newTitle != null) req.fields['title'] = newTitle;
      if (newDesc != null) req.fields['description'] = newDesc;
      if (newOrder != null) req.fields['order'] = newOrder.toString();
      if (newIsActive != null) req.fields['isActive'] = newIsActive.toString();

      req.files.add(
        http.MultipartFile.fromBytes(
          'image',
          pickedBytes!,
          filename: pickedFilename ?? 'image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = _safeDecode(res.body);
        final item = data?['data'];
        if (item == null) {
          Get.snackbar('Error', 'Invalid server response');
          return;
        }
        final updated = CategoryGroup.fromJson(item as Map<String, dynamic>);
        final idx = groups.indexWhere((x) => x.id == g.id);
        if (idx >= 0) groups[idx] = updated;
        Get.snackbar('Updated', 'Category Group updated');
      } else {
        Get.snackbar('Error', 'Server ${res.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      saving.value = false;
      clearPicked();
    }
  }

  // ========= DELETE =========
  Future<void> deleteGroup(CategoryGroup g) async {
    try {
      saving.value = true;
      final res = await http.delete(_buildUri(_singleGroup(g.id!)));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        groups.removeWhere((x) => x.id == g.id);
        Get.snackbar('Deleted', 'Category Group deleted');
      } else {
        Get.snackbar('Error', 'Server ${res.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      saving.value = false;
    }
  }
}
