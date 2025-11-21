import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/banner_controller.dart';
import '../models/banner_model.dart';

class BannerScreen extends StatelessWidget {
  BannerScreen({super.key});
  final c = Get.put(BannerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Banners'),
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
                  tooltip: 'Add banner',
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
    return _buildBannersPane(isWide: false);
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
        Expanded(child: _buildBannersPane(isWide: isWide)),
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
          title: 'Create Banner',
          subtitle:
              'Add a banner with title, link and image for your home page.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel('Title'),
              const SizedBox(height: 6),
              TextField(
                controller: c.titleCtrl,
                decoration: _inputDecor('e.g. "Big Summer Sale"').copyWith(
                  prefixIcon: const Icon(
                    Icons.title,
                    size: 20,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
              // const SizedBox(height: 12),
              // const _FieldLabel('Link URL (optional)'),
              // const SizedBox(height: 6),
              // TextField(
              //   controller: c.linkCtrl,
              //   decoration: _inputDecor('https://yourshop.com/sale').copyWith(
              //     prefixIcon: const Icon(
              //       Icons.link,
              //       size: 20,
              //       color: Color(0xFF4B5563),
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 12),
              // Row(
              //   children: [
              //     Expanded(
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           const _FieldLabel('Position'),
              //           const SizedBox(height: 6),
              //           TextField(
              //             controller: c.positionCtrl,
              //             keyboardType: TextInputType.number,
              //             decoration: _inputDecor('0,1,2...'),
              //           ),
              //         ],
              //       ),
              //     ),
              //     const SizedBox(width: 12),
              //     Expanded(
              //       child: Obx(
              //         () => SwitchListTile.adaptive(
              //           contentPadding: EdgeInsets.zero,
              //           title: const Text(
              //             'Active',
              //             style: TextStyle(
              //               fontSize: 13,
              //               fontWeight: FontWeight.w600,
              //             ),
              //           ),
              //           value: c.isActive.value,
              //           onChanged: (val) => c.isActive.value = val,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _SectionCard(
          icon: Icons.image_outlined,
          title: 'Image',
          subtitle: 'Pick a banner image (recommended wide / hero size).',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel('Banner Image'),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: c.pickImage,
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
                  const SizedBox(width: 8),
                  Obx(
                    () => c.pickedBytes.value != null
                        ? TextButton.icon(
                            onPressed: c.clearPicked,
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Clear'),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _ImagePreview(controller: c),
              const SizedBox(height: 8),
              const Text(
                'Note: Image is required when creating a banner.',
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
                      if (c.titleCtrl.text.trim().isEmpty) {
                        Get.snackbar(
                          'Missing',
                          'Title is required',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }
                      if (c.pickedBytes.value == null) {
                        Get.snackbar(
                          'Missing',
                          'Image is required',
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
                c.isSaving.value ? '' : 'Save Banner',
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

  // ============= RIGHT: BANNERS GRID (REUSED) =============

  Widget _buildBannersPane({required bool isWide}) {
    return Obx(() {
      if (c.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (c.banners.isEmpty) {
        return const Center(child: Text('No banners yet.'));
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
        itemCount: c.banners.length,
        itemBuilder: (_, i) {
          final b = c.banners[i];
          return _BannerCard(
            banner: b,
            onToggle: () => c.toggleActiveStatus(b.id, !b.isActive),
            onDelete: () => _confirmDelete(b, c),
            onEdit: () => _openEditDialog(b, c),
          );
        },
      );
    });
  }

  // ===== dialogs =====
  void _confirmDelete(BannerModel b, BannerController c) {
    Get.defaultDialog(
      title: 'Delete',
      middleText: 'Delete "${b.title}"?',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        await c.deleteBanner(b.id);
      },
    );
  }

  void _openEditDialog(BannerModel b, BannerController c) {
    final titleController = TextEditingController(text: b.title);
    final linkController = TextEditingController(text: b.linkUrl ?? '');
    final positionController = TextEditingController(
      text: b.position.toString(),
    );
    final isActiveNotifier = ValueNotifier<bool>(b.isActive);

    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (ctx, setSt) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Banner',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: _inputDecor('Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: linkController,
                  decoration: _inputDecor('Link URL'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: positionController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecor('Position'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ValueListenableBuilder<bool>(
                        valueListenable: isActiveNotifier,
                        builder: (_, isActive, __) => SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          value: isActive,
                          onChanged: (val) => isActiveNotifier.value = val,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () async {
                      await c.pickImage();
                      setSt(() {});
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Pick file'),
                  ),
                ),
                _DialogImagePreview(
                  bytesRx: c.pickedBytes,
                  imageUrl: b.imageUrl,
                ),
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
                                final hasPicked = c.pickedBytes.value != null;
                                await c.updateBanner(
                                  b,
                                  newTitle: titleController.text.trim(),
                                  newLinkUrl: linkController.text.trim(),
                                  newPosition:
                                      int.tryParse(
                                        positionController.text.trim(),
                                      ) ??
                                      b.position,
                                  newIsActive: isActiveNotifier.value,
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
                // IMPORTANT: Expanded to avoid horizontal overflow
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
  final BannerController controller;
  const _ImagePreview({super.key, required this.controller});

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
      final Uint8List? bytes = controller.pickedBytes.value;
      if (bytes != null && bytes.isNotEmpty) {
        return Container(
          height: 170,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Image.memory(bytes, fit: BoxFit.cover),
        );
      }

      return box;
    });
  }
}

class _DialogImagePreview extends StatelessWidget {
  final Rxn<Uint8List>? bytesRx;
  final String imageUrl;

  const _DialogImagePreview({super.key, this.bytesRx, required this.imageUrl});

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

      // Show existing image if no new image picked
      if (imageUrl.isNotEmpty) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            imageUrl,
            height: 140,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => box,
          ),
        );
      }

      return box;
    });
  }
}

class _BannerCard extends StatelessWidget {
  final BannerModel banner;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _BannerCard({
    super.key,
    required this.banner,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: onEdit,
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
                child: banner.imageUrl.isNotEmpty
                    ? Image.network(
                        banner.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
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
                      )
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => onDelete(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            // color: banner.isActive
                            //     ? const Color(0xFFE7F8F0)
                            //     : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Color(0xFF16A34A),
                            size: 16,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Pos: ${banner.position}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
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
