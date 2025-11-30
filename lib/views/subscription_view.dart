// lib/views/subscription_view.dart
import 'package:flutter/material.dart';
import '../components/home/navbar.dart';
import '../components/home/footer.dart';

class SubscriptionView extends StatelessWidget {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    print("💰 [SUBSCRIPTION] Build SubscriptionView");

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Navbar(),
            _buildSubscriptionContent(context),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 768 ? 48 : 16,
        vertical: 48,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Abonnement',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 32),
          const Center(
            child: Text(
              'Page Abonnement - À implémenter',
              style: TextStyle(fontSize: 18, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }
}