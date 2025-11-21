// // lib/screens/banner_list_screen.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controller/banner_controller.dart';
// import '../models/banner_model.dart';

// class BannerListScreen extends StatelessWidget {
//   BannerListScreen({super.key});

//   final BannerController c = Get.put(BannerController());

//   @override
//   Widget build(BuildContext context) {
//     const bg = Color(0xFFF5F7FB);

//     return Scaffold(
//       backgroundColor: bg,
//       appBar: AppBar(
//         backgroundColor: bg,
//         elevation: 0,
//         title: const Text(
//           'Banners',
//           style: TextStyle(
//             fontWeight: FontWeight.w700,
//             color: Colors.black,
//           ),
//         ),
//         actions: [
//           IconButton(
//             tooltip: 'Refresh',
//             icon: const Icon(Icons.refresh),
//             onPressed: c.fetchBanners,
//           ),
//           const SizedBox(width: 8),
//         ],
//       ),
//       // floatingActionButton: FloatingActionButton.extended(
//       //   onPressed: () {
//       //     Get.to(() => BannerScreen());
//       //   },
//       //   icon: const Icon(Icons.add),
//       //   label: const Text('Add Banner'),
//       // ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Obx(() {
//             if (c.isLoading.value) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             if (c.banners.isEmpty) {
//               return const _EmptyState();
//             }

//             final banners = c.banners;

//             return ListView.separated(
//               itemCount: banners.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 10),
//               itemBuilder: (_, i) {
//                 final b = banners[i];
//                 return _BannerCard(
//                   banner: b,
//                   onDelete: () => _confirmDelete(b),
//                 );
//               },
//             );
//           }),
//         ),
//       ),
//     );
//   }

//   void _confirmDelete(BannerModel b) {
//     Get.defaultDialog(
//       title: 'Delete',
//       middleText: 'Delete "${b.title}" ?',
//       textCancel: 'Cancel',
//       textConfirm: 'Delete',
//       confirmTextColor: Colors.white,
//       onConfirm: () async {
//         Get.back();
//         await c.deleteBanner(b);
//       },
//     );
//   }
// }

// class _EmptyState extends StatelessWidget {
//   const _EmptyState();

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Container(
//         height: 220,
//         decoration: BoxDecoration(
//           color: const Color(0xFFFAFAFA),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: const Color(0xFFE5E7EB)),
//         ),
//         child: const Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.image_outlined, size: 40, color: Color(0xFF9CA3AF)),
//               SizedBox(height: 8),
//               Text(
//                 'No banners yet',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Color(0xFF6B7280),
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 'Tap “Add Banner” to create one',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Color(0xFF9CA3AF),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _BannerCard extends StatelessWidget {
//   final BannerModel banner;
//   final VoidCallback onDelete;

//   const _BannerCard({
//     super.key,
//     required this.banner,
//     required this.onDelete,
//   });

//   String _typeLabel(String? t) {
//     switch (t) {
//       case 'hero':
//         return 'Hero Slider';
//       case 'home':
//         return 'Home Section';
//       case 'center':
//         return 'In-App Ad';
//       default:
//         return 'Banner';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final typeText = _typeLabel(banner.type);
//     final isActive = banner.isActive ?? true;

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFFE5E7EB)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.02),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // image (desktop)
//           ClipRRect(
//             borderRadius: const BorderRadius.horizontal(
//               left: Radius.circular(16),
//             ),
//             child: SizedBox(
//               width: 120,
//               height: 80,
//               child: banner.imageUrl != null &&
//                       banner.imageUrl!.trim().isNotEmpty
//                   ? Image.network(
//                       banner.imageUrl!,
//                       fit: BoxFit.cover,
//                     )
//                   : Container(
//                       color: const Color(0xFFF3F4F6),
//                       child: const Icon(
//                         Icons.image_outlined,
//                         color: Color(0xFF9CA3AF),
//                       ),
//                     ),
//             ),
//           ),

//           Expanded(
//             child: Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // title + type
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           banner.title,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 2,
//                         ),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF1F5F9),
//                           borderRadius: BorderRadius.circular(999),
//                         ),
//                         child: Text(
//                           typeText,
//                           style: const TextStyle(
//                             fontSize: 10,
//                             color: Color(0xFF475569),
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   if (banner.link != null && banner.link!.isNotEmpty)
//                     Text(
//                       banner.link!,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         fontSize: 11,
//                         color: Color(0xFF6B7280),
//                       ),
//                     ),
//                   const SizedBox(height: 6),

//                   Row(
//                     children: [
//                       // active chip
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 3,
//                         ),
//                         decoration: BoxDecoration(
//                           color: isActive
//                               ? const Color(0xFFE7F8F0)
//                               : const Color(0xFFFFE4E6),
//                           borderRadius: BorderRadius.circular(999),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Container(
//                               width: 6,
//                               height: 6,
//                               decoration: BoxDecoration(
//                                 color: isActive
//                                     ? const Color(0xFF16A34A)
//                                     : const Color(0xFFB91C1C),
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               isActive ? 'Active' : 'Inactive',
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w500,
//                                 color: isActive
//                                     ? const Color(0xFF15803D)
//                                     : const Color(0xFFB91C1C),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       if (banner.position != null)
//                         Text(
//                           'Position: ${banner.position}',
//                           style: const TextStyle(
//                             fontSize: 11,
//                             color: Color(0xFF9CA3AF),
//                           ),
//                         ),
//                       const Spacer(),
//                       IconButton(
//                         tooltip: 'Delete',
//                         icon: const Icon(
//                           Icons.delete_outline,
//                           color: Color(0xFFEF4444),
//                           size: 20,
//                         ),
//                         onPressed: onDelete,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
