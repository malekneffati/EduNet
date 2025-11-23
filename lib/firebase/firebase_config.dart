// lib/firebase/firebase_config.dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // IMPORT CORRIGÉ : ../ pour remonter d'un niveau

class FirebaseConfig {
  static Future<void> initialize() async {
    print("🔧 [FirebaseConfig] Vérification des apps Firebase existantes...");

    try {
      // Vérifier si Firebase est déjà initialisé
      if (Firebase.apps.isEmpty) {
        print("🔧 [FirebaseConfig] Initialisation Firebase.initializeApp...");
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        print("✅ [FirebaseConfig] Firebase initialisé avec succès !");
      } else {
        print("✅ [FirebaseConfig] Firebase déjà initialisé, réutilisation...");
      }
    } catch (e) {
      print("❌ [FirebaseConfig] ERREUR Firebase: $e");
      rethrow;
    }
  }
}