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
    final isWide = MediaQuery.of(context).size.width > 1140;

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
              'Catalogue — Categories',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= Left: FORM =================
              SizedBox(
                width: isWide ? 520 : 440,
                child: ListView(
                  children: [
                    _Pane(
                      title: 'Create Category',
                      subtitle:
                          'Add a category with title, group, sort order and image.',
                      leading: const Icon(Icons.add_box_outlined),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Title'),
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
                                    (g) => DropdownMenuItem(
                                      value: g.id,
                                      child: Text(g.title),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => c.selectedGroupId.value = v,
                              decoration: _inputDecor('Select group').copyWith(
                                prefixIcon: const Icon(Icons.folder_open),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Row(
                          //   children: [
                          //     Expanded(
                          //       child: Column(
                          //         crossAxisAlignment: CrossAxisAlignment.start,
                          //         children: [
                          //           _FieldLabel('Order'),
                          //           TextField(
                          //             decoration: _inputDecor('0').copyWith(
                          //               prefixIcon: const Icon(
                          //                 Icons.filter_list,
                          //               ),
                          //             ),
                          //             keyboardType: TextInputType.number,
                          //             onChanged: (v) =>
                          //                 c.order.value = int.tryParse(v) ?? 0,
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //     const SizedBox(width: 12),
                          //     Expanded(
                          //       child: Column(
                          //         crossAxisAlignment: CrossAxisAlignment.start,
                          //         children: [
                          //           // _FieldLabel('Status'),
                          //           // _SegmentSwitch(
                          //           //   valueListenable: c.isActive,
                          //           //   onChanged: (v) => c.isActive.value = v,
                          //           // ),
                          //         ],
                          //       ),
                          //     ),
                          //   ],
                          // ),
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
                          // _FieldLabel('Image URL (optional)'),
                          // TextField(
                          //   decoration: _inputDecor(
                          //     'https://…',
                          //   ).copyWith(prefixIcon: const Icon(Icons.link)),
                          //   onChanged: (v) => c.imageUrl.value = v,
                          // ),
                          // const SizedBox(height: 10),
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
                          _ImagePreview(
                            bytesRx: c.pickedBytesRx,
                            urlRx: c.imageUrl,
                          ),
                          const SizedBox(height: 8),
                          // const _HelpText(
                          //   'Backend expects the file field name "image". If no file is picked, URL will be used.',
                          // ),
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
                                    Get.snackbar(
                                      'Missing',
                                      'Title and Group are required',
                                    );
                                    return;
                                  }
                                  await c.createCategory();
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
                ),
              ),

              const SizedBox(width: 16),

              // ================= Right: GRID =================
              Expanded(
                child: Obx(() {
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
                            groupName: c.groupById[cat.group] ?? '—',
                            onDelete: () => _confirmDelete(cat, c),
                          );
                        },
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
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

// class _SegmentSwitch extends StatelessWidget {
//   final RxBool valueListenable;
//   final ValueChanged<bool> onChanged;
//   const _SegmentSwitch({
//     super.key,
//     required this.valueListenable,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final v = valueListenable.value;
//       return Container(
//         height: 44,
//         decoration: BoxDecoration(
//           color: const Color(0xFFF8FAFC),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: const Color(0xFFDDDFE3)),
//         ),
//         child: Row(
//           children: [
//             _segItem(
//               label: 'Active',
//               icon: Icons.check_circle,
//               selected: v,
//               onTap: () => onChanged(true),
//             ),
//             _segItem(
//               label: 'Inactive',
//               icon: Icons.pause_circle_filled_rounded,
//               selected: !v,
//               onTap: () => onChanged(false),
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   Expanded _segItem({
//     required String label,
//     required IconData icon,
//     required bool selected,
//     required VoidCallback onTap,
//   }) {
//     return Expanded(
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 160),
//           padding: const EdgeInsets.symmetric(horizontal: 10),
//           decoration: BoxDecoration(
//             color: selected ? Colors.black : Colors.transparent,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 icon,
//                 size: 18,
//                 color: selected ? Colors.white : const Color(0xFF6B7280),
//               ),
//               const SizedBox(width: 6),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontWeight: FontWeight.w700,
//                   color: selected ? Colors.white : const Color(0xFF6B7280),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

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
  final String groupName;
  final VoidCallback onDelete;

  const _CategoryCardPro({
    super.key,
    required this.c,
    required this.groupName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = c.isActive;

    return Material(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFDDDFE3)),
      ),
      child: Container(
        height: 486,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          hoverColor: const Color(0xFFF6F7F9),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                // thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 80,
                    height: 80,
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

                // info
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                IconButton(
                  tooltip: 'Delete',
                  onPressed: onDelete,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF1F2),
                  ),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
