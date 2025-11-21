// lib/controller/ads_controller.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lyno_cms/models/Ads_Models.dart';

class AdsController extends GetxController {
  final http.Client _client = http.Client();

  final RxList<AdsModels> ads = <AdsModels>[].obs;
  final RxBool isLoading = false.obs;

  // Properties for UI binding
  final RxString adTitle = ''.obs;
  final RxString adImageUrl = ''.obs;
  final Rxn<Uint8List> pickedBytesRx = Rxn<Uint8List>();
  final RxBool isSaving = false.obs;
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController linkCtrl = TextEditingController();
  final TextEditingController positionCtrl = TextEditingController(text: '0');
  final RxBool isActive = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAds();
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

  Future<void> fetchAds() async {
    try {
      isLoading.value = true;

      final res = await _client.get(_uri('/ads/getads'));

      if (res.statusCode != 200) {
        debugPrint('fetchAds failed: ${res.statusCode} ${res.body}');
        Get.snackbar(
          'Error',
          'Failed to load ads',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final body = jsonDecode(res.body);
      debugPrint('ads data: $body');

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
      // ✅ 4) { ads: [...] }
      else if (body is Map && body['ads'] is List) {
        rawList = body['ads'] as List;
      }

      final mapped = rawList
          .map((e) => AdsModels.fromJson(e as Map<String, dynamic>))
          .toList();

      ads.assignAll(mapped);
    } catch (e) {
      debugPrint('fetchAds error: $e');
      Get.snackbar(
        'Error',
        'Failed to load ads',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============ CREATE AD ============
  Future<void> createBanner() async {
    if (adTitle.value.trim().isEmpty) {
      Get.snackbar(
        'Missing',
        'Title is required',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isSaving.value = true;

      final uri = _uri('/ads/add');
      final req = http.MultipartRequest('POST', uri);

      final title = adTitle.value.trim();
      final imageUrl = "";

      req.fields['title'] = title;
      req.fields['isActive'] = "true";

      if (imageUrl.isNotEmpty) {
        req.fields['imageUrl'] = imageUrl;
      }

      if (pickedBytesRx.value != null) {
        req.files.add(
          http.MultipartFile.fromBytes(
            'image',
            pickedBytesRx.value!,
            filename: 'ad_image.jpg',
          ),
        );
      }

      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode != 200 && res.statusCode != 201) {
        debugPrint('createAd failed: ${res.statusCode} ${res.body}');
        Get.snackbar(
          'Error',
          'Failed to create ad',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final body = jsonDecode(res.body);
      dynamic raw = body;
      if (body is Map && body['data'] != null) {
        raw = body['data'];
      }

      final created = AdsModels.fromJson(raw as Map<String, dynamic>);
      ads.insert(0, created);
      clearForm();

      Get.snackbar(
        'Success',
        'Ad created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('createAd error: $e');
      Get.snackbar(
        'Error',
        'Failed to create ad',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateAd(
    AdsModels ad, {
    String? newTitle,
    bool withImage = false,
  }) async {
    try {
      isSaving.value = true;

      final uri = _uri('/ads/${ad.id}');
      final req = http.MultipartRequest('PUT', uri);

      final title = newTitle ?? ad.title;
      req.fields['title'] = title;

      if (withImage && pickedBytesRx.value != null) {
        req.files.add(
          http.MultipartFile.fromBytes(
            'image',
            pickedBytesRx.value!,
            filename: 'ad_image.jpg',
          ),
        );
      }

      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode != 200) {
        debugPrint('updateAd failed: ${res.statusCode} ${res.body}');
        Get.snackbar(
          'Error',
          'Failed to update ad',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await fetchAds();
      clearPicked();

      Get.snackbar(
        'Success',
        'Ad updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('updateAd error: $e');
      Get.snackbar(
        'Error',
        'Failed to update ad',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteAd(String id) async {
    try {
      final res = await _client.delete(_uri('/ads/$id'));

      if (res.statusCode != 200 && res.statusCode != 204) {
        debugPrint('deleteAd failed: ${res.statusCode} ${res.body}');
        Get.snackbar(
          'Error',
          'Failed to delete ad',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      ads.removeWhere((ad) => ad.id == id);
      Get.snackbar(
        'Deleted',
        'Ad removed successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('deleteAd error: $e');
      Get.snackbar(
        'Error',
        'Failed to delete ad',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============ TOGGLE ACTIVE STATUS ============
  Future<void> toggleActiveStatus(String id, bool isActive) async {
    try {
      final res = await _client.patch(
        _uri('/ads/$id'),
        body: {'isActive': isActive.toString()},
      );

      if (res.statusCode != 200) {
        debugPrint('toggleActive failed: ${res.statusCode} ${res.body}');
        return;
      }

      // Update local state
      final index = ads.indexWhere((ad) => ad.id == id);
      if (index != -1) {
        ads[index] = ads[index].copyWith(isActive: isActive);
        ads.refresh();
      }
    } catch (e) {
      debugPrint('toggleActive error: $e');
    }
  }

  // ============ IMAGE PICKER ============
  Future<void> pickWebImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      pickedBytesRx.value = result.files.first.bytes;
    }
  }

  void clearPicked() {
    pickedBytesRx.value = null;
  }

  void clearForm() {
    adTitle.value = '';
    adImageUrl.value = '';
    clearPicked();
  }
}
