class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role;
  final DateTime createdAt;
  final String? subscription; // 'premium', 'basic', 'free', null
  final DateTime? subscriptionEndDate;
  final bool isActive; // Session active ou non

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    this.subscription,
    this.subscriptionEndDate,
    this.isActive = true,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      if (dateValue is DateTime) return dateValue;
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          return DateTime.now();
        }
      }
      // Firestore Timestamp
      if (dateValue.runtimeType.toString().contains('Timestamp')) {
        return (dateValue as dynamic).toDate();
      }
      return DateTime.now();
    }

    return UserModel(
      uid: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'student',
      createdAt: parseDate(data['createdAt']),
      subscription: data['subscription'],
      subscriptionEndDate: data['subscriptionEndDate'] != null
          ? parseDate(data['subscriptionEndDate'])
          : null,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'subscription': subscription,
      'subscriptionEndDate': subscriptionEndDate?.toIso8601String(),
      'isActive': isActive,
    };
  }

  String get subscriptionLabel {
    if (subscription == null) return 'Gratuit';
    switch (subscription) {
      case 'premium':
        return 'Premium';
      case 'basic':
        return 'Basic';
      default:
        return 'Gratuit';
    }
  }

  String get statusLabel {
    return isActive ? 'Actif' : 'Inactif';
  }

  bool get hasActiveSubscription {
    if (subscription == null) return false;
    if (subscriptionEndDate == null) return false;
    return subscriptionEndDate!.isAfter(DateTime.now());
  }
}