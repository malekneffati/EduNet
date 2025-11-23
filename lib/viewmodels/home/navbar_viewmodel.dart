// lib/viewmodels/home/navbar_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NavbarViewModel extends ChangeNotifier {
  User? _user;
  String? _role;

  User? get user => _user;

  List<Map<String, String>> get commonLinks => [
    {'name': 'Accueil', 'to': '/'},
    {'name': 'Catalogue des cours', 'to': '/catalog'},
    {'name': 'Abonnement', 'to': '/subscription'},
  ];

  List<Map<String, String>> get roleLinks => _role == 'student'
      ? [{'name': 'Mon espace', 'to': '/dashboard'}]
      : _role == 'admin'
      ? [{'name': 'Admin', 'to': '/admin'}]
      : [];

  NavbarViewModel() {
    print("🔄 [NAVBAR_VM] Initialisation NavbarViewModel");

    FirebaseAuth.instance.authStateChanges().listen((currentUser) {
      print("👤 [NAVBAR_VM] Changement d'état auth: ${currentUser?.email}");
      _user = currentUser;
      _role = 'student'; // Temporairement fixé
      print("🎯 [NAVBAR_VM] Role défini: $_role");
      notifyListeners();
    });
  }

  Future<void> handleLogout() async {
    print("🚪 [NAVBAR_VM] Déconnexion demandée");
    try {
      await FirebaseAuth.instance.signOut();
      _user = null;
      _role = null;
      print("✅ [NAVBAR_VM] Déconnexion réussie");
      notifyListeners();
    } catch (err) {
      print("❌ [NAVBAR_VM] Erreur déconnexion: $err");
    }
  }

  void navigateTo(BuildContext context, String route) {
    print("🧭 [NAVBAR_VM] Navigation vers: $route");
    Navigator.pushNamed(context, route);
  }
}