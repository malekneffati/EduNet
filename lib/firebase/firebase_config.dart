// lib/firebase/firebase_config.dart
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    print("🔧 [FirebaseConfig] Vérification des apps Firebase existantes...");

    if (Firebase.apps.isNotEmpty) {
      print("⚠️ [FirebaseConfig] Firebase déjà initialisé. Aucun besoin de réinitialiser.");
      return;
    }

    print("🔧 [FirebaseConfig] Initialisation Firebase.initializeApp...");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ [FirebaseConfig] Firebase initialisé !");
  }
}
