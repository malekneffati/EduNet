// lib/viewmodels/auth/auth_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthViewModel extends ChangeNotifier {
  bool _loading = true;
  bool _isAuthenticated = false;
  User? _user;

  bool get loading => _loading;
  bool get isAuthenticated => _isAuthenticated;
  User? get user => _user;

  AuthViewModel() {
    print("🔐 [AuthViewModel] Initialisation...");
    _initAuthListener();
  }

  void _initAuthListener() {
    print("👂 [AuthViewModel] Démarrage écouteur auth...");

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      print("🔄 [AuthViewModel] Changement d'état auth: ${user?.email}");

      _user = user;
      _isAuthenticated = user != null;
      _loading = false;

      print("📊 [AuthViewModel] Nouvel état - loading: $_loading, isAuth: $_isAuthenticated, user: ${_user?.email}");

      notifyListeners();
    }, onError: (error) {
      print("❌ [AuthViewModel] Erreur écouteur auth: $error");
      _loading = false;
      notifyListeners();
    });
  }

  // Forcer le refresh si nécessaire
  void checkAuthStatus() {
    print("🔍 [AuthViewModel] Vérification manuelle du statut auth");
    _user = FirebaseAuth.instance.currentUser;
    _isAuthenticated = _user != null;
    _loading = false;
    notifyListeners();
  }
}