// lib/viewmodels/auth/register_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterViewModel extends ChangeNotifier {
  String _name = '';
  String _email = '';
  String _password = '';
  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  void setName(String value) {
    _name = value;
    _error = null;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    _error = null;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    _error = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> register() async {
    print("📝 [RegisterViewModel] Registration attempt: $_email");

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Create user in Firebase Auth
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.trim(),
        password: _password,
      );

      // Create user document in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'name': _name,
        'email': _email.trim(),
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("✅ [RegisterViewModel] Registration successful: ${credential.user?.email}");

      _loading = false;
      notifyListeners();

      return {'role': 'student', 'user': credential.user};
    } on FirebaseAuthException catch (e) {
      print("❌ [RegisterViewModel] Error: ${e.code}");

      switch (e.code) {
        case 'weak-password':
          _error = 'Le mot de passe est trop faible.';
          break;
        case 'email-already-in-use':
          _error = 'Un compte existe déjà avec cet email.';
          break;
        case 'invalid-email':
          _error = 'Email invalide.';
          break;
        default:
          _error = 'Erreur d\'inscription: ${e.message}';
      }

      _loading = false;
      notifyListeners();
      return null;
    } catch (e) {
      print("❌ [RegisterViewModel] Unexpected error: $e");
      _error = 'Une erreur est survenue.';
      _loading = false;
      notifyListeners();
      return null;
    }
  }
}