import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<UserModel> getUserData(String uid) async {
    final docSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!docSnap.exists) {
      throw Exception('Utilisateur non trouvé');
    }

    final data = docSnap.data()!;
    return UserModel.fromFirestore(data, uid);
  }
}

// Provider for FirebaseAuthService
final authServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});
