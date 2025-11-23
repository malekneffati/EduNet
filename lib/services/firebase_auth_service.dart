import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirebaseAuthService {
  Stream<User?> get authStateChanges =>
      FirebaseAuth.instance.authStateChanges();

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
