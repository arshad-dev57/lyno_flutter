// product_model.dart

class Money {
  final double mrp;
  final double sale;
  final String currency;
  final double taxPercent;
  final double discountPercent;

  Money({
    required this.mrp,
    required this.sale,
    this.currency = "\$",
    this.taxPercent = 0,
    this.discountPercent = 0,
  });

  factory Money.fromJson(Map<String, dynamic> json) {
    return Money(
      mrp: (json['mrp'] ?? 0).toDouble(),
      sale: (json['sale'] ?? 0).toDouble(),
      currency: json['currency'] ?? '\$',
      taxPercent: (json['taxPercent'] ?? 0).toDouble(),
      discountPercent: (json['discountPercent'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mrp': mrp,
      'sale': sale,
      'currency': currency,
      'taxPercent': taxPercent,
    };
  }
}

class ProductAttribute {
  final String key;
  final String value;

  ProductAttribute({required this.key, required this.value});

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(key: json['key'] ?? '', value: json['value'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'key': key, 'value': value};
  }
}

class Product {
  final String id;
  final String title;
  final String? sku;
  final String? brand;
  final String? shortDescription;
  final String? description;

  // SINGLE image (derived from backend images[])
  final String? imageUrl;
  final String? imageAlt;

  final Money price;

  final int stockQty;
  final int minOrderQty;
  final int maxOrderQty;

  final List<ProductAttribute> attributes;
  final List<String> tags;

  final String? seoTitle;
  final String? seoDescription;
  final int order;

  final String? category; // primary category id
  final List<String> categories; // all category ids
  final String? categorySlug;

  final List<double> embedding;

  Product({
    required this.id,
    required this.title,
    this.sku,
    this.brand,
    this.shortDescription,
    this.description,
    this.imageUrl,
    this.imageAlt,
    required this.price,
    this.stockQty = 0,
    this.minOrderQty = 1,
    this.maxOrderQty = 0,
    this.attributes = const [],
    this.tags = const [],
    this.seoTitle,
    this.seoDescription,
    this.order = 0,
    this.category,
    this.categories = const [],
    this.categorySlug,
    this.embedding = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final priceJson = json['price'] ?? {};
    final attrsJson = (json['attributes'] as List?) ?? [];
    final tagsJson = (json['tags'] as List?) ?? [];
    final catsJson = (json['categories'] as List?) ?? [];

    // backend images: []
    final imagesJson = (json['images'] as List?) ?? [];
    String? imageUrl;
    String? imageAlt;

    if (imagesJson.isNotEmpty) {
      Map<String, dynamic> primary = imagesJson.first as Map<String, dynamic>;

      for (final item in imagesJson) {
        final m = item as Map<String, dynamic>;
        if (m['isPrimary'] == true) {
          primary = m;
          break;
        }
      }

      imageUrl = primary['url']?.toString();
      imageAlt = primary['alt']?.toString();
    }

    return Product(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      sku: json['sku'],
      brand: json['brand'],
      shortDescription: json['shortDescription'],
      description: json['description'],
      imageUrl: imageUrl,
      imageAlt: imageAlt,
      price: Money.fromJson(priceJson as Map<String, dynamic>),
      stockQty: (json['stockQty'] ?? 0).toInt(),
      minOrderQty: (json['minOrderQty'] ?? 1).toInt(),
      maxOrderQty: (json['maxOrderQty'] ?? 0).toInt(),
      attributes: attrsJson
          .map((e) => ProductAttribute.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: tagsJson.map((e) => e.toString()).toList(),
      seoTitle: json['seoTitle'],
      seoDescription: json['seoDescription'],
      order: (json['order'] ?? 0).toInt(),
      category: json['category']?.toString(),
      categories: catsJson.map((e) => e.toString()).toList(),
      categorySlug: json['categorySlug'],
      embedding: _parseEmbedding(json['embedding']),
    );
  }

  static List<double> _parseEmbedding(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return raw
          .where((e) => e != null)
          .map((e) => (e as num).toDouble())
          .toList();
    }

    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) return [];
      final clean = trimmed.replaceAll('[', '').replaceAll(']', '');
      if (clean.trim().isEmpty) return [];
      return clean
          .split(',')
          .map((s) => double.tryParse(s.trim()))
          .where((v) => v != null)
          .map((v) => v!)
          .toList();
    }

    return [];
  }
}
