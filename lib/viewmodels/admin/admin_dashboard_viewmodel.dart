import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firebase_auth_service.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService;

  int _totalUsers = 0;
  int _totalCourses = 0;
  double _totalRevenue = 0;
  int _activeSubscriptions = 0;

  AdminDashboardViewModel(this._authService);

  int get totalUsers => _totalUsers;
  int get totalCourses => _totalCourses;
  double get totalRevenue => _totalRevenue;
  int get activeSubscriptions => _activeSubscriptions;

  Future<void> loadDashboardData() async {
    // Simuler le chargement des données
    // À remplacer avec Firestore/Firebase
    await Future.delayed(const Duration(seconds: 1));

    _totalUsers = 1234;
    _totalCourses = 45;
    _totalRevenue = 12450.0;
    _activeSubscriptions = 567;

    notifyListeners();
  }

  Future<void> refreshData() async {
    await loadDashboardData();
  }

  String getCurrentUserEmail() {
    return _authService.getCurrentUser()?.email ?? 'admin@edunet.com';
  }
}

final adminDashboardProvider = ChangeNotifierProvider<AdminDashboardViewModel>(
      (ref) {
    final authService = ref.watch(authServiceProvider);
    return AdminDashboardViewModel(authService);
  },
);