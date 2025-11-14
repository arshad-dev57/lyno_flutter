// lib/screens/catalogue_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/category_group.dart';
import '../controller/catalogue_controller.dart';

class CatalogueScreen extends StatelessWidget {
  CatalogueScreen({super.key});
  final c = Get.put(CatalogueController());

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 1080;

    return Scaffold(
      appBar: AppBar(title: const Text('Catalogue — Category Groups')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============= Left: Only Title + Image =============
            SizedBox(
              width: isWide ? 520 : 420,
              child: ListView(
                shrinkWrap: true,
                children: [
                  _SectionCard(
                    title: 'Basic',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Labeled(
                          label: 'Title',
                          child: TextField(
                            decoration: _inputDecor('Category Group Title'),
                            onChanged: (v) => c.title.value = v,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Hero Image',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Labeled(
                          label: 'Image URL (optional)',
                          child: TextField(
                            decoration: _inputDecor('https://…'),
                            onChanged: (v) => c.heroImageUrl.value = v,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => c.pickWebImage(),
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Pick from computer'),
                            ),
                            const SizedBox(width: 8),
                            Obx(
                              () => c.pickedBytesRx.value != null
                                  ? TextButton.icon(
                                      onPressed: () => c.clearPicked(),
                                      icon: const Icon(Icons.close),
                                      label: const Text('Clear'),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _ImagePreview(
                          heroUrlRx: c.heroImageUrl,
                          bytesRx: c.pickedBytesRx, // reactive web preview
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Note: Your backend requires a file when creating a group. URL is optional.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: c.saving.value
                            ? null
                            : () async {
                                if (c.title.value.trim().isEmpty) {
                                  Get.snackbar('Missing', 'Title is required');
                                  return;
                                }
                                await c.createGroup();
                              },
                        child: c.saving.value
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save Group'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // ============= Right: Groups Grid/List =============
            Expanded(
              child: Obx(() {
                if (c.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (c.groups.isEmpty) {
                  return const Center(child: Text('No category groups yet.'));
                }

                final cross = isWide ? 3 : 2;
                return GridView.builder(
                  padding: const EdgeInsets.all(4),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cross,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3.0,
                  ),
                  itemCount: c.groups.length,
                  itemBuilder: (_, i) {
                    final g = c.groups[i];
                    return _GroupCard(
                      g: g,
                      onToggle: () => c.updateGroup(
                        g,
                        newIsActive: !g.isActive,
                        withImage: false,
                      ),
                      onDelete: () => _confirmDelete(g, c),
                      onEdit: () => _openEditDialog(g, c),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ===== dialogs =====
  void _confirmDelete(CategoryGroup g, CatalogueController c) {
    Get.defaultDialog(
      title: 'Delete',
      middleText:
          'Delete "${g.title}"?\n(Note: backend blocks if categories exist)',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        await c.deleteGroup(g);
      },
    );
  }

  // Edit dialog: only Title + Image (supports: URL-only update or file replace)
  void _openEditDialog(CategoryGroup g, CatalogueController c) {
    final t = TextEditingController(text: g.title);
    final url = TextEditingController(text: g.heroImage ?? '');
    final urlVN = ValueNotifier<String>(url.text);
    url.addListener(() => urlVN.value = url.text);

    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (ctx, setSt) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Group',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextField(controller: t, decoration: _inputDecor('Title')),
                const SizedBox(height: 12),
                TextField(
                  controller: url,
                  decoration: _inputDecor('Hero Image URL'),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () async {
                      await c.pickWebImage();
                      setSt(() {}); // refresh dialog for picked image
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
                        onPressed: c.saving.value
                            ? null
                            : () async {
                                final hasPicked =
                                    c.pickedBytesRx.value != null &&
                                    c.pickedBytesRx.value!.isNotEmpty;
                                if (hasPicked) {
                                  await c.updateGroup(
                                    g,
                                    newTitle: t.text.trim(),
                                    withImage: true, // multipart override
                                  );
                                } else {}
                                c.clearPicked();
                                Get.back();
                              },
                        child: c.saving.value
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
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.2),
    ),
  );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFF9FAFB),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              padding: const EdgeInsets.all(14),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  final String label;
  final Widget child;
  final Widget? action;
  const _Labeled({required this.label, required this.child, this.action});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const Spacer(),
            if (action != null) action!,
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

// =================== Preview & Cards ===================

class _ImagePreview extends StatelessWidget {
  final RxString? heroUrlRx; // live URL (create form)
  final String? urlString; // static URL (not used here)
  final Rxn<Uint8List>? bytesRx; // reactive picked bytes for web

  const _ImagePreview({
    super.key,
    this.heroUrlRx,
    this.urlString,
    this.bytesRx,
  });

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
      // 1) picked file takes priority
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

      // 2) else show URL from RxString (create form)
      if (heroUrlRx != null) {
        final url = heroUrlRx!.value.trim();
        if (url.isNotEmpty) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              url,
              height: 140,
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

// A dialog-specific preview that watches a ValueNotifier<String> for URL changes.
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

class _GroupCard extends StatelessWidget {
  final CategoryGroup g;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _GroupCard({
    super.key,
    required this.g,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = g.isActive
        ? const Color(0xFF16A34A)
        : const Color(0xFF9CA3AF);
    final badgeText = g.isActive ? 'Active' : 'Inactive';

    return Card(
      elevation: 0.6,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: (g.heroImage != null && g.heroImage!.trim().isNotEmpty)
                      ? Image.network(g.heroImage!, fit: BoxFit.cover)
                      : Container(
                          color: const Color(0xFFF3F4F6),
                          child: const Icon(
                            Icons.image_outlined,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      g.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // if (g.slug.isNotEmpty)
                    //   Text(
                    //     '/${g.slug}',
                    //     maxLines: 1,
                    //     overflow: TextOverflow.ellipsis,
                    //     style: const TextStyle(
                    //       fontSize: 12,
                    //       color: Color(0xFF6B7280),
                    //     ),
                    //   ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: badgeColor.withOpacity(0.25)),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Edit',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 20),
                  ),
                  IconButton(
                    tooltip: g.isActive ? 'Deactivate' : 'Activate',
                    onPressed: onToggle,
                    icon: Icon(
                      g.isActive ? Icons.toggle_on : Icons.toggle_off,
                      size: 26,
                      color: g.isActive
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
