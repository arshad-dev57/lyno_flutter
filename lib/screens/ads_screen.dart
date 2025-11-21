// lib/screens/catalogue_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lyno_cms/models/Ads_Models.dart';
import '../controller/ads_controller.dart';

class AdsScreen extends StatelessWidget {
  AdsScreen({super.key});
  final c = Get.put(AdsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Ads'),
        elevation: 0,
        backgroundColor: const Color(0xFFF5F5F7),
        foregroundColor: Colors.black,
        actions: [
          LayoutBuilder(
            builder: (context, constraints) {
              final width = MediaQuery.of(context).size.width;
              final bool isDesktop = width >= 1080;
              if (!isDesktop) {
                return IconButton(
                  tooltip: 'Add ad',
                  icon: const Icon(Icons.add),
                  onPressed: () => _openCreateDialog(context),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final bool isDesktop = width >= 1080;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: isDesktop ? _buildDesktopLayout() : _buildCompactLayout(),
          );
        },
      ),
    );
  }

  // ============= LAYOUTS =============

  Widget _buildCompactLayout() {
    return _buildAdsPane(isWide: false);
  }

  Widget _buildDesktopLayout() {
    const bool isWide = true;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 520,
          child: ListView(shrinkWrap: true, children: [_buildFormColumn()]),
        ),
        const SizedBox(width: 16),
        Expanded(child: _buildAdsPane(isWide: isWide)),
      ],
    );
  }

  // ============= CREATE DIALOG (MOBILE + TABLET) =============

  void _openCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final w = MediaQuery.of(ctx).size.width;
        final bool small = w < 500;
        final inset = EdgeInsets.symmetric(
          horizontal: small ? 16 : 80,
          vertical: small ? 24 : 40,
        );

        return Dialog(
          insetPadding: inset,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: SingleChildScrollView(
                child: _buildFormColumn(onSaved: () => Navigator.of(ctx).pop()),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============= LEFT FORM CONTENT (REUSED) =============

  Widget _buildFormColumn({VoidCallback? onSaved}) {
    return Column(
      children: [
        _SectionCard(
          icon: Icons.add_box_outlined,
          title: 'Create Ad',
          subtitle: 'Add a new ad with title and image.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel('Title'),
              const SizedBox(height: 6),
              TextField(
                decoration: _inputDecor('e.g. "Summer Sale"').copyWith(
                  prefixIcon: const Icon(
                    Icons.title,
                    size: 20,
                    color: Color(0xFF4B5563),
                  ),
                ),
                onChanged: (v) => c.adTitle.value = v,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _SectionCard(
          icon: Icons.image_outlined,
          title: 'Image',
          subtitle: 'Upload a file or paste a direct URL for the ad image.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const _FieldLabel('Image URL (optional)'),
              // const SizedBox(height: 6),
              // TextField(
              //   decoration: _inputDecor('https://…').copyWith(
              //     prefixIcon: const Icon(
              //       Icons.link,
              //       size: 20,
              //       color: Color(0xFF4B5563),
              //     ),
              //   ),
              //   onChanged: (v) => c.adImageUrl.value = v,
              // ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => c.pickWebImage(),
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: const Text(
                      'Choose File',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Obx(
                    () => c.pickedBytesRx.value != null
                        ? TextButton.icon(
                            onPressed: () => c.clearPicked(),
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Clear'),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _ImagePreview(heroUrlRx: c.adImageUrl, bytesRx: c.pickedBytesRx),
              const SizedBox(height: 8),
              const Text(
                'Note: Image is required when creating an ad.',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Obx(
          () => SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: c.isSaving.value
                  ? null
                  : () async {
                      if (c.adTitle.value.trim().isEmpty) {
                        Get.snackbar(
                          'Missing',
                          'Title is required',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }
                      await c.createBanner();
                      onSaved?.call();
                    },
              icon: c.isSaving.value
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: Text(
                c.isSaving.value ? '' : 'Save Ad',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============= RIGHT: ADS GRID (REUSED) =============

  Widget _buildAdsPane({required bool isWide}) {
    return Obx(() {
      if (c.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (c.ads.isEmpty) {
        return const Center(child: Text('No ads yet.'));
      }

      final cross = isWide ? 3 : 2;

      return GridView.builder(
        padding: const EdgeInsets.all(4),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cross,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.82,
        ),
        itemCount: c.ads.length,
        itemBuilder: (_, i) {
          final ad = c.ads[i];
          return _AdCard(
            ad: ad,
            onToggle: () => c.toggleActiveStatus(ad.id, !ad.isActive),
            onDelete: () => _confirmDelete(ad, c),
            onEdit: () => _openEditDialog(ad, c),
          );
        },
      );
    });
  }

  // ===== dialogs =====
  void _confirmDelete(AdsModels ad, AdsController c) {
    Get.defaultDialog(
      title: 'Delete',
      middleText: 'Delete "${ad.title}"?',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        await c.deleteAd(ad.id);
      },
    );
  }

  void _openEditDialog(AdsModels ad, AdsController c) {
    final titleController = TextEditingController(text: ad.title);
    final urlController = TextEditingController(text: ad.imageUrl ?? '');
    final urlVN = ValueNotifier<String>(urlController.text);
    urlController.addListener(() => urlVN.value = urlController.text);

    // Set current values to controller
    c.adTitle.value = ad.title;
    c.adImageUrl.value = ad.imageUrl ?? '';

    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (ctx, setSt) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Ad',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: _inputDecor('Title'),
                  onChanged: (v) => c.adTitle.value = v,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: _inputDecor('Image URL'),
                  onChanged: (v) => c.adImageUrl.value = v,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () async {
                      await c.pickWebImage();
                      setSt(() {});
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Pick file'),
                  ),
                ),
                _DialogImagePreview(dialogUrl: urlVN, bytesRx: c.pickedBytesRx),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        c.clearPicked();
                        Get.back();
                      },
                      child: const Text('Cancel'),
                    ),
                    const Spacer(),
                    Obx(
                      () => ElevatedButton(
                        onPressed: c.isSaving.value
                            ? null
                            : () async {
                                final hasPicked = c.pickedBytesRx.value != null;
                                await c.updateAd(
                                  ad,
                                  newTitle: titleController.text.trim(),
                                  withImage: hasPicked,
                                );
                                c.clearPicked();
                                Get.back();
                              },
                        child: c.isSaving.value
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =================== UI Helpers ===================

InputDecoration _inputDecor(String hint) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF7F7F8),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.black, width: 1.2),
    ),
  );
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: const Color(0xFF111827)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Color(0xFF111827),
      ),
    );
  }
}

// =================== Preview & Cards ===================

class _ImagePreview extends StatelessWidget {
  final RxString? heroUrlRx;
  final String? urlString;
  final Rxn<Uint8List>? bytesRx;

  const _ImagePreview({
    super.key,
    this.heroUrlRx,
    this.urlString,
    this.bytesRx,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      height: 170,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: const Text(
        'No image selected',
        style: TextStyle(color: Color(0xFF9CA3AF)),
      ),
    );

    return Obx(() {
      final picked = bytesRx?.value;
      if (picked != null && picked.isNotEmpty) {
        return Container(
          height: 170,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Image.memory(picked, fit: BoxFit.cover),
        );
      }

      if (heroUrlRx != null) {
        final url = heroUrlRx!.value.trim();
        if (url.isNotEmpty) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              url,
              height: 170,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          );
        }
      }

      return box;
    });
  }
}

class _DialogImagePreview extends StatelessWidget {
  final ValueNotifier<String> dialogUrl;
  final Rxn<Uint8List>? bytesRx;

  const _DialogImagePreview({super.key, required this.dialogUrl, this.bytesRx});

  @override
  Widget build(BuildContext context) {
    final box = Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Text(
        'No image selected',
        style: TextStyle(color: Color(0xFF6B7280)),
      ),
    );

    return Obx(() {
      final picked = bytesRx?.value;
      if (picked != null && picked.isNotEmpty) {
        return Container(
          height: 140,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Image.memory(picked, fit: BoxFit.cover),
        );
      }

      return ValueListenableBuilder<String>(
        valueListenable: dialogUrl,
        builder: (_, url, __) {
          final u = url.trim();
          if (u.isNotEmpty) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                u,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            );
          }
          return box;
        },
      );
    });
  }
}

class _AdCard extends StatelessWidget {
  final AdsModels ad;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _AdCard({
    super.key,
    required this.ad,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      onDoubleTap: onToggle,
      onLongPress: onDelete,
      child: Card(
        elevation: 0,
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: (ad.imageUrl != null && ad.imageUrl!.trim().isNotEmpty)
                    ? Image.network(ad.imageUrl!, fit: BoxFit.cover)
                    : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFE5E7EB), Color(0xFFF4F4F5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: Color(0xFF9CA3AF),
                            size: 32,
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ad.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  InkWell(
                    onTap: onDelete,
                    child: Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
