import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentStatus { pending, completed, failed }
enum PaymentItemType { subscription, course }

class PaymentModel {
  final String id;
  final String userId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final PaymentItemType itemType;
  final String itemId; // courseId or 'subscription_premium'
  final String? paymeeTransactionId;
  final DateTime createdAt;
  final DateTime? completedAt;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.amount,
    this.currency = 'TND',
    required this.status,
    required this.itemType,
    required this.itemId,
    this.paymeeTransactionId,
    required this.createdAt,
    this.completedAt,
  });

  factory PaymentModel.fromFirestore(Map<String, dynamic> data, String id) {
    return PaymentModel(
      id: id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'TND',
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (data['status'] ?? 'pending'),
        orElse: () => PaymentStatus.pending,
      ),
      itemType: PaymentItemType.values.firstWhere(
        (e) => e.toString().split('.').last == (data['itemType'] ?? 'course'),
        orElse: () => PaymentItemType.course,
      ),
      itemId: data['itemId'] ?? '',
      paymeeTransactionId: data['paymeeTransactionId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'status': status.toString().split('.').last,
      'itemType': itemType.toString().split('.').last,
      'itemId': itemId,
      'paymeeTransactionId': paymeeTransactionId,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  PaymentModel copyWith({
    PaymentStatus? status,
    String? paymeeTransactionId,
    DateTime? completedAt,
  }) {
    return PaymentModel(
      id: id,
      userId: userId,
      amount: amount,
      currency: currency,
      status: status ?? this.status,
      itemType: itemType,
      itemId: itemId,
      paymeeTransactionId: paymeeTransactionId ?? this.paymeeTransactionId,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
