class Category {
  final String id;
  final String title;
  final String slug;
  final String group;
  final String? image;
  final int order;
  final bool isActive;
  final String? parent;

  Category({
    required this.id,
    required this.title,
    required this.slug,
    required this.group,
    this.image,
    required this.order,
    required this.isActive,
    this.parent,
  });

  factory Category.fromJson(Map<String, dynamic> j) => Category(
    id: (j['_id'] ?? j['id']).toString(),
    title: (j['title'] ?? '').toString(),
    slug: (j['slug'] ?? '').toString(),
    group: (j['group'] is Map ? j['group']['_id'] : j['group']).toString(),
    image: j['image']?.toString(),
    order: (j['order'] is int)
        ? j['order']
        : int.tryParse('${j['order'] ?? 0}') ?? 0,
    isActive: j['isActive'] == true || j['isActive']?.toString() == 'true',
    parent: j['parent']?.toString(),
  );
}
