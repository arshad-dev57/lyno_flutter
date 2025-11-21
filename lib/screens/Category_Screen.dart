import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lyno_cms/models/category_model.dart';
import '../controller/category_controller.dart';

class CategoryScreen extends StatelessWidget {
  CategoryScreen({super.key});
  final c = Get.put(CategoryController());

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final bool isMobile = width < 700;
        final bool isDesktop = width >= 1140; // desktop only

        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            titleSpacing: 0,
            title: Row(
              children: const [
                SizedBox(width: 16),
                Icon(Icons.category_outlined, size: 22),
                SizedBox(width: 8),
                Text(
                  'SubCategories',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            actions: [
              if (!isDesktop)
                IconButton(
                  tooltip: 'Add category',
                  icon: const Icon(Icons.add),
                  onPressed: () => _openCategoryDialog(context),
                )
              else ...[
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _HeaderStatChip(
                      icon: Icons.folder_outlined,
                      label: 'Groups',
                      value: '${c.groups.length}',
                    ),
                  ),
                ),
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _HeaderStatChip(
                      icon: Icons.list_alt_outlined,
                      label: 'Categories',
                      value: '${c.categories.length}',
                    ),
                  ),
                ),
              ],
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: isDesktop
                  ? _buildDesktopLayout()
                  : _buildCompactLayout(isMobile: isMobile),
            ),
          ),
        );
      },
    );
  }

  // ============= LAYOUTS =============

  /// Mobile + Tablet: sirf categories pane full-width,
  /// add ke liye AppBar ka + button dialog open karega
  Widget _buildCompactLayout({required bool isMobile}) {
    return _buildCategoriesPane(isWide: false);
  }

  /// Desktop: left form, right grid
  Widget _buildDesktopLayout() {
    const bool isWide = true; // desktop per 3 columns etc.

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= Left: FORM =================
        const SizedBox(width: 520, child: _FormPaneWrapper()),

        const SizedBox(width: 16),

        // ================= Right: GRID =================
        Expanded(child: _buildCategoriesPane(isWide: isWide)),
      ],
    );
  }

  // ============= CATEGORY DIALOG (MOBILE + TABLET) =============

  void _openCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        final w = MediaQuery.of(dialogCtx).size.width;
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
                child: _buildFormPaneColumn(
                  // dialog mein save hone ke baad close bhi ho jaaye
                  onSaved: () => Navigator.of(dialogCtx).pop(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============= LEFT FORM CONTENT (REUSED) =============

  /// ye pure create + image + save wala column hai
  /// desktop pe side me, mobile/tablet pe dialog ke andar reuse hoga
  Widget _buildFormPaneColumn({VoidCallback? onSaved}) {
    return Column(
      children: [
        _Pane(
          title: 'Create Category',
          subtitle: 'Add a category with title, group, sort order and image.',
          leading: const Icon(Icons.add_box_outlined),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel('Title'),
              TextField(
                decoration: _inputDecor(
                  'e.g. “Fiction Books”',
                ).copyWith(prefixIcon: const Icon(Icons.title)),
                onChanged: (v) => c.title.value = v,
              ),
              const SizedBox(height: 14),

              Obx(
                () => _FieldLabelRow(
                  'Group',
                  trailing: c.groups.isEmpty
                      ? const _SoftBadge(
                          icon: Icons.info_outline_rounded,
                          text: 'No groups found',
                        )
                      : null,
                ),
              ),
              Obx(
                () => DropdownButtonFormField<String>(
                  value: c.selectedGroupId.value,
                  items: c.groups
                      .map(
                        (g) =>
                            DropdownMenuItem(value: g.id, child: Text(g.title)),
                      )
                      .toList(),
                  onChanged: (v) => c.selectedGroupId.value = v,
                  decoration: _inputDecor(
                    'Select group',
                  ).copyWith(prefixIcon: const Icon(Icons.folder_open)),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),

        const SizedBox(height: 16),

        _Pane(
          title: 'Image',
          subtitle: 'Upload a file or paste a direct URL.',
          leading: const Icon(Icons.image_outlined),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => c.pickWebImage(),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Choose File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
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
              _ImagePreview(bytesRx: c.pickedBytesRx, urlRx: c.imageUrl),
              const SizedBox(height: 8),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Obx(
          () => SizedBox(
            height: 46,
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: c.saving.value
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                c.saving.value ? 'Saving…' : 'Save Category',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              onPressed: c.saving.value
                  ? null
                  : () async {
                      if (c.title.value.trim().isEmpty ||
                          c.selectedGroupId.value == null) {
                        Get.snackbar('Missing', 'Title and Group are required');
                        return;
                      }
                      await c.createCategory();
                      // dialog ke case me close, desktop me null hoga to ignore
                      onSaved?.call();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============= RIGHT CATEGORIES PANE (REUSED) =============

  Widget _buildCategoriesPane({required bool isWide}) {
    return Obx(() {
      if (c.isLoading.value) {
        return const _Pane(
          title: 'Loading',
          subtitle: 'Fetching categories…',
          child: SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }
      if (c.categories.isEmpty) {
        return const _Pane(
          title: 'Categories',
          subtitle: 'No categories yet',
          child: _EmptyState(),
        );
      }

      // Grid columns: wide desktop = 3, otherwise 2
      final cross = isWide ? 3 : 2;

      return SingleChildScrollView(
        child: _Pane(
          title: 'Categories',
          subtitle: 'All categories listed below',
          leading: const Icon(Icons.view_module_outlined),
          trailing: _SoftBadge(
            icon: Icons.countertops_outlined,
            text: 'Total: ${c.categories.length}',
          ),
          child: GridView.builder(
            padding: const EdgeInsets.all(4),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 106,
            ),
            itemCount: c.categories.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, i) {
              final cat = c.categories[i];
              return _CategoryCardPro(
                c: cat,
                onDelete: () => _confirmDelete(cat, c),
              );
            },
          ),
        ),
      );
    });
  }

  void _confirmDelete(Category cat, CategoryController ctrl) {
    Get.defaultDialog(
      title: 'Delete',
      middleText: 'Delete "${cat.title}"?',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        await ctrl.deleteCategory(cat);
      },
    );
  }
}

/// ============ Helper widget: form in desktop left pane ============
class _FormPaneWrapper extends StatelessWidget {
  const _FormPaneWrapper();

  @override
  Widget build(BuildContext context) {
    final screen = context.findAncestorWidgetOfExactType<CategoryScreen>();
    // CategoryScreen ke instance se controller already GetX pe global hai,
    // isliye direct new instance nahi banana, sirf helper call karna hai.
    return ListView(
      children: [if (screen != null) screen._buildFormPaneColumn()],
    );
  }
}

/// ============ Reusable bits ============

InputDecoration _inputDecor(String hint) => InputDecoration(
  hintText: hint,
  filled: true,
  fillColor: Colors.white,
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFFDDDFE3)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFFDDDFE3)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Colors.black, width: 1.2),
  ),
);

class _Pane extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  const _Pane({
    required this.title,
    required this.child,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFDDDFE3)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (leading != null) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: leading!,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _HeaderStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _HeaderStatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFDDDFE3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF475569)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFDDDFE3)),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 2),
              ],
            ),
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
        ],
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
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }
}

class _FieldLabelRow extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const _FieldLabelRow(this.text, {this.trailing});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FieldLabel(text),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _SoftBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SoftBadge({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFDDDFE3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class _HelpText extends StatelessWidget {
  final String text;
  const _HelpText(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final Rxn<Uint8List> bytesRx;
  final RxString urlRx;
  const _ImagePreview({super.key, required this.bytesRx, required this.urlRx});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bytes = bytesRx.value;
      final url = urlRx.value.trim();
      if (bytes != null && bytes.isNotEmpty) {
        return _imgFrame(Image.memory(bytes, fit: BoxFit.cover));
      }
      if (url.isNotEmpty) {
        return _imgFrame(Image.network(url, fit: BoxFit.cover));
      }
      return _imgFrame(
        const Center(
          child: Text(
            'No image selected',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ),
        empty: true,
      );
    });
  }

  Widget _imgFrame(Widget child, {bool empty = false}) {
    return Container(
      height: 150,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: empty ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDDFE3)),
      ),
      child: child,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDDFE3)),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 34, color: Color(0xFF94A3B8)),
            SizedBox(height: 8),
            Text(
              'Nothing here yet',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCardPro extends StatelessWidget {
  final Category c;
  final VoidCallback onDelete;

  const _CategoryCardPro({super.key, required this.c, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFDDDFE3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        hoverColor: const Color(0xFFF6F7F9),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              // image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 64,
                  height: 64,
                  color: const Color(0xFFF2F3F5),
                  child: (c.image != null && c.image!.trim().isNotEmpty)
                      ? Image.network(c.image!, fit: BoxFit.cover)
                      : const Icon(
                          Icons.image_outlined,
                          color: Color(0xFF9CA3AF),
                        ),
                ),
              ),
              const SizedBox(width: 10),

              // title
              Expanded(
                child: Text(
                  c.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // delete
              IconButton(
                tooltip: 'Delete',
                onPressed: onDelete,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF1F2),
                  minimumSize: const Size(32, 32),
                  padding: EdgeInsets.zero,
                ),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
