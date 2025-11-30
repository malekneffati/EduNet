// lib/viewmodels/auth/login_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginViewModel extends ChangeNotifier {
  String _email = '';
  String _password = '';
  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

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

  Future<Map<String, dynamic>?> login() async {
    print("🔐 [LoginViewModel] Login attempt: $_email");

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.trim(),
        password: _password,
      );

      print("✅ [LoginViewModel] Login successful: ${credential.user?.email}");

      // Get user role from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      final role = userDoc.data()?['role'] ?? 'student';

      _loading = false;
      notifyListeners();

      return {'role': role, 'user': credential.user};
    } on FirebaseAuthException catch (e) {
      print("❌ [LoginViewModel] Error: ${e.code}");

      switch (e.code) {
        case 'user-not-found':
          _error = 'Aucun utilisateur trouvé avec cet email.';
          break;
        case 'wrong-password':
          _error = 'Mot de passe incorrect.';
          break;
        case 'invalid-email':
          _error = 'Email invalide.';
          break;
        default:
          _error = 'Erreur de connexion: ${e.message}';
      }

      _loading = false;
      notifyListeners();
      return null;
    } catch (e) {
      print("❌ [LoginViewModel] Unexpected error: $e");
      _error = 'Une erreur est survenue.';
      _loading = false;
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, dynamic>?> loginWithGoogle() async {
    print("🔐 [LoginViewModel] Google login attempt");

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        _loading = false;
        notifyListeners();
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Check if user exists in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      String role = 'student';

      if (!userDoc.exists) {
        // Create new user document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': userCredential.user!.email,
          'name': userCredential.user!.displayName,
          'role': 'student',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        role = userDoc.data()?['role'] ?? 'student';
      }

      print("✅ [LoginViewModel] Google login successful");

      _loading = false;
      notifyListeners();

      return {'role': role, 'user': userCredential.user};
    } catch (e) {
      print("❌ [LoginViewModel] Google login error: $e");
      _error = 'Erreur lors de la connexion avec Google.';
      _loading = false;
      notifyListeners();
      return null;
    }
  }
}