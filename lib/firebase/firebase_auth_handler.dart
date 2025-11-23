// lib/firebase/firebase_auth_handler.dart
// Clean + logs added everywhere

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthHandler {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------------------------------
  // REGISTER (Email + Password)
  // ---------------------------------------
  static Future<Map<String, dynamic>> handleRegister(
      String email, String password, String name) async {
    print("[AuthHandler] Starting registration...");

    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      print("[AuthHandler] Firebase user created: ${user.uid}");

      await _waitForAuthState();
      print("[AuthHandler] Auth state updated.");

      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'role': 'student',
        'createdAt': DateTime.now().toIso8601String(),
      });

      print("[AuthHandler] User saved to Firestore correctly.");

      return {'user': user, 'role': 'student'};
    } catch (e) {
      print("[AuthHandler] ERROR in handleRegister: $e");
      rethrow;
    }
  }

  // ---------------------------------------
  // LOGIN (Email + Password)
  // ---------------------------------------
  static Future<Map<String, dynamic>> handleLogin(
      String email, String password) async {
    print("[AuthHandler] Starting login...");

    try {
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      print("[AuthHandler] Logged in: ${user.uid}");

      final docSnap =
      await _firestore.collection('users').doc(user.uid).get();

      print("[AuthHandler] Firestore user exists = ${docSnap.exists}");

      if (!docSnap.exists) {
        print("[AuthHandler] ERROR: User not found in Firestore");
        throw Exception('Utilisateur non trouvé');
      }

      final role = docSnap.data()!['role'].toLowerCase();
      print("[AuthHandler] User role: $role");

      return {'user': user, 'role': role};
    } catch (e) {
      print("[AuthHandler] ERROR in handleLogin: $e");
      rethrow;
    }
  }

  // ---------------------------------------
  // GOOGLE AUTH
  // ---------------------------------------
  static Future<Map<String, dynamic>> handleGoogleAuth() async {
    print("[AuthHandler] Google Sign-In started...");

    try {
      final GoogleSignInAccount? googleUser =
      await GoogleSignIn().signIn();

      if (googleUser == null) {
        print("[AuthHandler] Google Sign-In cancelled.");
        throw Exception("Google sign-in cancelled");
      }

      print("[AuthHandler] Google user: ${googleUser.email}");

      final GoogleSignInAuthentication auth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      final result =
      await _auth.signInWithCredential(credential);

      final user = result.user!;
      print("[AuthHandler] Firebase logged with Google: ${user.uid}");

      final userRef = _firestore.collection('users').doc(user.uid);
      final userSnap = await userRef.get();

      if (!userSnap.exists) {
        print("[AuthHandler] Creating Firestore user...");
        await userRef.set({
          'name': user.displayName,
          'email': user.email,
          'role': 'student',
          'createdAt': DateTime.now().toIso8601String(),
        });
      }

      final userDoc = await userRef.get();
      final role = userDoc.data()!['role'].toLowerCase();

      print("[AuthHandler] Google auth role: $role");

      return {'user': user, 'role': role};
    } catch (e) {
      print("[AuthHandler] ERROR in handleGoogleAuth: $e");
      rethrow;
    }
  }

  // ---------------------------------------
  // WAIT FOR AUTH STATE
  // ---------------------------------------
  static Future<void> _waitForAuthState() async {
    print("[AuthHandler] Waiting for auth state...");
    await _auth.authStateChanges().first;
    print("[AuthHandler] Auth state received.");
  }
}
