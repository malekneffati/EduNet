// lib/views/home_view.dart
// Création d'un HomeView dummy pour tester la navigation post-auth.
// Vous pouvez le remplacer plus tard par le vrai Home.js converti.
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EduNet - Accueil')),
      body: const Center(
        child: Text('Bienvenue sur EduNet ! Authentification réussie.'),
      ),
    );
  }
}