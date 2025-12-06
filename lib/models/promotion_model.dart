import 'package:cloud_firestore/cloud_firestore.dart';

class PromotionModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String period; // 'monthly', 'yearly'
  final List<String> features;
  final bool isPopular;
  final bool isActive;
  final DateTime createdAt;

  PromotionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.period,
    required this.features,
    this.isPopular = false,
    this.isActive = true,
    required this.createdAt,
  });

  factory PromotionModel.fromFirestore(Map<String, dynamic> data, String id) {
    return PromotionModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      period: data['period'] ?? 'monthly',
      features: List<String>.from(data['features'] ?? []),
      isPopular: data['isPopular'] ?? false,
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'period': period,
      'features': features,
      'isPopular': isPopular,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  PromotionModel copyWith({
    String? title,
    String? description,
    double? price,
    String? period,
    List<String>? features,
    bool? isPopular,
    bool? isActive,
  }) {
    return PromotionModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      period: period ?? this.period,
      features: features ?? this.features,
      isPopular: isPopular ?? this.isPopular,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
