import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/banner_model.dart';

class BannerController extends GetxController {
  final http.Client _client = http.Client();

  final RxList<BannerModel> banners = <BannerModel>[].obs;
  final RxBool isLoading = false.obs;

  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController linkCtrl = TextEditingController();
  final TextEditingController positionCtrl = TextEditingController(text: '0');

  final RxBool isActive = true.obs;
  final RxBool isSaving = false.obs;

  // image (file_picker)
  final Rxn<Uint8List> pickedBytes = Rxn<Uint8List>();
  final RxString pickedName = ''.obs;
  PlatformFile? _pickedFile;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    linkCtrl.dispose();
    positionCtrl.dispose();
    _client.close();
    super.onClose();
  }

  Uri _uri(String path) =>
      Uri.parse('https://lyno-shopping.vercel.app/api$path');

  Future<void> fetchBanners() async {
    try {
      isLoading.value = true;

      final res = await _client.get(_uri('/banners/getbanner'));

      if (res.statusCode != 200) {
        debugPrint('fetchBanners failed: ${res.statusCode} ${res.body}');
        Get.snackbar(
          'Error',
          'Failed to load banners',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final body = jsonDecode(res.body);
      debugPrint('banner data: $body');

      List rawList = [];

      // ✅ 1) direct array
      if (body is List) {
        rawList = body;
      }
      // ✅ 2) { success, data: [...] }
      else if (body is Map && body['data'] is List) {
        rawList = body['data'] as List;
      }
      // ✅ 3) { items: [...] }
      else if (body is Map && body['items'] is List) {
        rawList = body['items'] as List;
      }
      // ✅ 4) { banners: [...] }
      else if (body is Map && body['banners'] is List) {
        rawList = body['banners'] as List;
      }

      final mapped = rawList
          .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
          .toList();

      banners.assignAll(mapped);
    } catch (e) {
      debugPrint('fetchBanners error: $e');
      Get.snackbar(
        'Error',
        'Failed to load banners',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============ POST /banners/add ============
  Future<void> createBanner() async {
    if (titleCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Missing',
        'Title is required',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (_pickedFile == null) {
      Get.snackbar(
        'Missing',
        'Image is required',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isSaving.value = true;

      final uri = _uri('/banners/add');
      final req = http.MultipartRequest('POST', uri);

      final title = titleCtrl.text.trim();
      final link = linkCtrl.text.trim();
      final pos = int.tryParse(positionCtrl.text.trim()) ?? 0;

      req.fields['title'] = title;
      req.fields['isActive'] = "true";
      req.fields['position'] = "0";
      if (link.isNotEmpty) {
        req.fields['linkUrl'] = "link";
      }

      // file_picker se image
      if (_pickedFile!.bytes != null) {
        req.files.add(
          http.MultipartFile.fromBytes(
            'image', // <-- backend pe upload.single('image')
            _pickedFile!.bytes!,
            filename: _pickedFile!.name,
          ),
        );
      } else if (_pickedFile!.path != null) {
        req.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _pickedFile!.path!,
            filename: _pickedFile!.name,
          ),
        );
      }

      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode != 200 && res.statusCode != 201) {
        debugPrint('createBanner failed: ${res.statusCode} ${res.body}');
        Get.snackbar(
          'Error',
          'Failed to create banner',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final body = jsonDecode(res.body);

      // ✅ backend agar { success, data: {...} } bheje
      dynamic raw = body;
      if (body is Map && body['data'] != null) {
        raw = body['data'];
      }

      final created = BannerModel.fromJson(raw as Map<String, dynamic>);

      banners.insert(0, created);
      clearForm();

      Get.snackbar(
        'Success',
        'Banner created',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('createBanner error: $e');
      Get.snackbar(
        'Error',
        'Failed to create banner',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // ============ DELETE /banners/:id ============
  Future<void> deleteBanner(String id) async {
    try {
      // NOTE: yahan ':' nahi lagana URL me
      final res = await _client.delete(_uri('/banners/$id'));

      if (res.statusCode != 200 && res.statusCode != 204) {
        debugPrint('deleteBanner failed: ${res.statusCode} ${res.body}');
        Get.snackbar(
          'Error',
          'Failed to delete banner',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      banners.removeWhere((b) => b.id == id);
      Get.snackbar(
        'Deleted',
        'Banner removed',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('deleteBanner error: $e');
      Get.snackbar(
        'Error',
        'Failed to delete banner',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Add these methods to your BannerController
  Future<void> toggleActiveStatus(String id, bool isActive) async {
    try {
      final res = await _client.patch(
        _uri('/banners/$id'),
        body: {'isActive': isActive.toString()},
      );

      if (res.statusCode != 200) {
        debugPrint('toggleActive failed: ${res.statusCode} ${res.body}');
        return;
      }

      // Update local state
      final index = banners.indexWhere((banner) => banner.id == id);
      if (index != -1) {
        banners[index] = banners[index].copyWith(isActive: isActive);
        banners.refresh();
      }
    } catch (e) {
      debugPrint('toggleActive error: $e');
    }
  }

  Future<void> updateBanner(
    BannerModel banner, {
    String? newTitle,
    String? newLinkUrl,
    int? newPosition,
    bool? newIsActive,
    bool withImage = false,
  }) async {
    try {
      isSaving.value = true;

      final uri = _uri('/banners/${banner.id}');
      final req = http.MultipartRequest('PUT', uri);

      final title = newTitle ?? banner.title;
      final linkUrl = newLinkUrl ?? banner.linkUrl;
      final position = newPosition ?? banner.position;
      final isActive = newIsActive ?? banner.isActive;

      req.fields['title'] = title;
      req.fields['isActive'] = isActive.toString();
      req.fields['position'] = position.toString();
      if (linkUrl != null && linkUrl.isNotEmpty) {
        req.fields['linkUrl'] = linkUrl;
      }

      if (withImage && pickedBytes.value != null) {
        req.files.add(
          http.MultipartFile.fromBytes(
            'image',
            pickedBytes.value!,
            filename: 'banner_image.jpg',
          ),
        );
      }

      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode != 200) {
        debugPrint('updateBanner failed: ${res.statusCode} ${res.body}');
        Get.snackbar(
          'Error',
          'Failed to update banner',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Refresh the list
      await fetchBanners();
      clearPicked();

      Get.snackbar(
        'Success',
        'Banner updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('updateBanner error: $e');
      Get.snackbar(
        'Error',
        'Failed to update banner',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }
  // ============ IMAGE PICKER ============

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      _pickedFile = result.files.first;
      pickedBytes.value = _pickedFile!.bytes;
      pickedName.value = _pickedFile!.name;
    }
  }

  void clearPicked() {
    _pickedFile = null;
    pickedBytes.value = null;
    pickedName.value = '';
  }

  void clearForm() {
    titleCtrl.clear();
    linkCtrl.clear();
    positionCtrl.text = '0';
    isActive.value = true;
    clearPicked();
  }
}
