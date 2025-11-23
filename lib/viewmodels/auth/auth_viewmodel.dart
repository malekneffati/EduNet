// lib/viewmodels/auth/auth_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_auth_service.dart';
import '../../models/user_model.dart';

class AuthViewModel with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();

  UserModel? _user;
  bool _loading = true;
  String? _error;

  UserModel? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthViewModel() {
    _initAuthState();
  }

  void _initAuthState() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        _user = null;
        _loading = false;
        notifyListeners();
        return;
      }

      try {
        _user = await _authService.getUserData(firebaseUser.uid);  // Changed to public getUserData
      } catch (e) {
        _error = e.toString();
        _user = null;
      } finally {
        _loading = false;
        notifyListeners();
      }
    });
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}