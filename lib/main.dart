// lib/main.dart
import 'package:edunet/views/app.dart';
import 'package:flutter/material.dart';
import 'firebase/firebase_config.dart'; // Import correct

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("🚀 [MAIN] Initialisation Firebase en cours...");
  try {
    await FirebaseConfig.initialize();
    print("✅ [MAIN] Firebase prêt !");
  } catch (e) {
    print("❌ [MAIN] ERREUR Firebase: $e");
  }

  print("🎬 [MAIN] Lancement de l'application...");
  runApp(const App());
}