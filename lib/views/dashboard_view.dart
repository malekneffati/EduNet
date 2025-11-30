// lib/views/dashboard_view.dart
import 'package:flutter/material.dart';
import '../components/home/navbar.dart';
import '../components/home/footer.dart';
import '../components/student/dashboard_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    print("📊 [DASHBOARD] Build DashboardView");

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Navbar(),
            _buildDashboardContent(context),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 768 ? 48 : 16,
        vertical: 48,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mon Espace',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 32),
          // TODO: Add dashboard content here
          const Center(
            child: Text(
              'Tableau de bord étudiant - À implémenter',
              style: TextStyle(fontSize: 18, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }
}