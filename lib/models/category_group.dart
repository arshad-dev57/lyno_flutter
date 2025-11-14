class CategoryGroup {
  final String? id;
  final String title;
  final String slug;
  final String? description;
  final String? heroImage;
  final int order;
  final bool isActive;

  CategoryGroup({
    this.id,
    required this.title,
    required this.slug,
    this.description,
    this.heroImage,
    this.order = 0,
    this.isActive = true,
  });

  factory CategoryGroup.fromJson(Map<String, dynamic> j) => CategoryGroup(
    id: j['_id']?.toString(),
    title: j['title'] ?? '',
    slug: j['slug'] ?? '',
    description: j['description'],
    heroImage: j['heroImage'],
    order: (j['order'] ?? 0) is int
        ? j['order']
        : int.tryParse('${j['order'] ?? 0}') ?? 0,
    isActive: j['isActive'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) '_id': id,
    'title': title,
    'slug': slug,
    'description': description,
    'heroImage': heroImage,
    'order': order,
    'isActive': isActive,
  };
}
