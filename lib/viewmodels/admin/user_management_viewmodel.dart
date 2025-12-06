import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

class UserManagementViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _roleFilter = 'all';
  String _subscriptionFilter = 'all';
  String _statusFilter = 'all';

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get roleFilter => _roleFilter;
  String get subscriptionFilter => _subscriptionFilter;
  String get statusFilter => _statusFilter;

  List<UserModel> get filteredUsers {
    var filtered = _users;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by role
    if (_roleFilter != 'all') {
      filtered = filtered.where((user) => user.role == _roleFilter).toList();
    }

    // Filter by subscription
    if (_subscriptionFilter != 'all') {
      filtered = filtered.where((user) {
        if (_subscriptionFilter == 'free') {
          return user.subscription == null;
        }
        return user.subscription == _subscriptionFilter;
      }).toList();
    }

    // Filter by status
    if (_statusFilter != 'all') {
      filtered = filtered.where((user) {
        final isActive = user.isActive;
        return _statusFilter == 'active' ? isActive : !isActive;
      }).toList();
    }

    return filtered;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setRoleFilter(String role) {
    _roleFilter = role;
    notifyListeners();
  }

  void setSubscriptionFilter(String subscription) {
    _subscriptionFilter = subscription;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('users').get();
      _users = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des utilisateurs: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
      });

      // Update local list
      final index = _users.indexWhere((user) => user.uid == userId);
      if (index != -1) {
        _users[index] = UserModel(
          uid: _users[index].uid,
          email: _users[index].email,
          name: _users[index].name,
          role: newRole,
          createdAt: _users[index].createdAt,
          subscription: _users[index].subscription,
          subscriptionEndDate: _users[index].subscriptionEndDate,
          isActive: _users[index].isActive,
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour du rôle: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleUserStatus(String userId) async {
    try {
      final index = _users.indexWhere((user) => user.uid == userId);
      if (index == -1) return false;

      final newStatus = !_users[index].isActive;

      await _firestore.collection('users').doc(userId).update({
        'isActive': newStatus,
      });

      _users[index] = UserModel(
        uid: _users[index].uid,
        email: _users[index].email,
        name: _users[index].name,
        role: _users[index].role,
        createdAt: _users[index].createdAt,
        subscription: _users[index].subscription,
        subscriptionEndDate: _users[index].subscriptionEndDate,
        isActive: newStatus,
      );
      notifyListeners();

      return true;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour du statut: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();

      // Remove from local list
      _users.removeWhere((user) => user.uid == userId);
      notifyListeners();

      return true;
    } catch (e) {
      _error = 'Erreur lors de la suppression de l\'utilisateur: $e';
      notifyListeners();
      return false;
    }
  }

  int get totalUsers => _users.length;
  int get totalStudents => _users.where((u) => u.role == 'student').length;
  int get totalAdmins => _users.where((u) => u.role == 'admin').length;
  int get activeUsers => _users.where((u) => u.isActive).length;
  int get premiumUsers => _users.where((u) => u.subscription == 'premium').length;
}

final userManagementProvider = ChangeNotifierProvider<UserManagementViewModel>((ref) {
  return UserManagementViewModel();
});
