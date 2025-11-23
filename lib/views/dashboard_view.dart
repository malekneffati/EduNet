// lib/views/dashboard_view.dart
import 'package:flutter/material.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    print("📊 [DASHBOARD] Build DashboardView");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Espace'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Tableau de bord étudiant',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}