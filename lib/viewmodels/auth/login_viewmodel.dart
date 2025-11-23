// lib/viewmodels/auth/login_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../../firebase/firebase_auth_handler.dart';  // Correct import for FirebaseAuthHandler

class LoginViewModel with ChangeNotifier {
  String _email = '';
  String _password = '';
  bool _loading = false;
  String? _error;

  String get email => _email;
  String get password => _password;
  bool get loading => _loading;
  String? get error => _error;

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> login() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await FirebaseAuthHandler.handleLogin(_email, _password);
      return result;
    } catch (err) {
      _error = "Email ou mot de passe incorrect.";
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> loginWithGoogle() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await FirebaseAuthHandler.handleGoogleAuth();
      return result;
    } catch (err) {
      _error = "Échec de la connexion Google. Veuillez réessayer.";
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}