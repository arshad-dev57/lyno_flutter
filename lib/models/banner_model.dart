// lib/models/banner_model.dart
class BannerModel {
  final String id;
  final String title;
  final String imageUrl; // backend => image
  final String? linkUrl;
  final int position;
  final bool isActive;

  BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.linkUrl,
    this.position = 0,
    this.isActive = true,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '') as String,
      imageUrl: (json['image'] ?? json['imageUrl'] ?? '') as String,
      linkUrl: json['linkUrl'] as String?,
      position: _parseInt(json['position']),
      isActive: _parseBool(json['isActive'] ?? json['active'] ?? true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
      'position': position,
      'isActive': isActive,
    };
  }

  BannerModel copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? linkUrl,
    int? position,
    bool? isActive,
  }) {
    return BannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      linkUrl: linkUrl ?? this.linkUrl,
      position: position ?? this.position,
      isActive: isActive ?? this.isActive,
    );
  }

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final v = value.toLowerCase();
      if (v == 'true' || v == '1' || v == 'yes') return true;
      if (v == 'false' || v == '0' || v == 'no') return false;
    }
    if (value is num) return value != 0;
    return false;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BannerModel &&
        other.id == id &&
        other.title == title &&
        other.imageUrl == imageUrl &&
        other.linkUrl == linkUrl &&
        other.position == position &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        imageUrl.hashCode ^
        linkUrl.hashCode ^
        position.hashCode ^
        isActive.hashCode;
  }

  @override
  String toString() {
    return 'BannerModel(id: $id, title: $title, imageUrl: $imageUrl, linkUrl: $linkUrl, position: $position, isActive: $isActive)';
  }
}
