// lib/views/subscription_view.dart
import 'package:flutter/material.dart';

class SubscriptionView extends StatelessWidget {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    print("💰 [SUBSCRIPTION] Build SubscriptionView");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Abonnement'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Page Abonnement - À implémenter',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}