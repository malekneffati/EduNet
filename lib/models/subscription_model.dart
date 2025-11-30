// lib/models/subscription_model.dart
class SubscriptionModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String billingPeriod; // "month" or "year"
  final bool active;

  SubscriptionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.billingPeriod,
    required this.active,
  });

  factory SubscriptionModel.fromFirestore(Map<String, dynamic> data, String id) {
    return SubscriptionModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      billingPeriod: data['billingPeriod'] ?? 'month',
      active: data['active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'billingPeriod': billingPeriod,
      'active': active,
    };
  }

  // Helper getters
  String get priceDisplay => '${price.toStringAsFixed(0)} TND';

  String get periodDisplay {
    switch (billingPeriod) {
      case 'year':
        return 'par an';
      case 'month':
      default:
        return 'par mois';
    }
  }
}