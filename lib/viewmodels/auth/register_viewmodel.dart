// lib/viewmodels/auth/register_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../../firebase/firebase_auth_handler.dart';  // Correct import for FirebaseAuthHandler

class RegisterViewModel with ChangeNotifier {
  String _name = '';
  String _email = '';
  String _password = '';
  bool _loading = false;
  String? _error;

  String get name => _name;
  String get email => _email;
  String get password => _password;
  bool get loading => _loading;
  String? get error => _error;

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> register() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await FirebaseAuthHandler.handleRegister(
          _email, _password, _name);
      return result;
    } catch (err) {
      _error = err.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}