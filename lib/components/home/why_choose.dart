// lib/components/home/why_choose.dart
import 'package:flutter/material.dart';

class WhyChoose extends StatelessWidget {
  const WhyChoose({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1280),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 48),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 768;

                return isMobile
                    ? _buildMobileFeatures()
                    : _buildDesktopFeatures();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Text(
          'Pourquoi choisir EduNet ?',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Rejoignez une plateforme conçue pour maximiser votre apprentissage',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDesktopFeatures() {
    return const Row(
      children: [
        Expanded(child: _FeatureItem(
          icon: Icons.emoji_events,
          title: 'Qualité',
          description: 'Cours créés par des experts reconnus dans leur domaine',
        )),
        SizedBox(width: 32),
        Expanded(child: _FeatureItem(
          icon: Icons.accessibility,
          title: 'Accessibilité',
          description: 'Apprenez à votre rythme, où que vous soyez',
        )),
        SizedBox(width: 32),
        Expanded(child: _FeatureItem(
          icon: Icons.analytics,
          title: 'Suivi',
          description: 'Suivez votre progression et obtenez des certificats',
        )),
      ],
    );
  }

  Widget _buildMobileFeatures() {
    return const Column(
      children: [
        _FeatureItem(
          icon: Icons.emoji_events,
          title: 'Qualité',
          description: 'Cours créés par des experts reconnus dans leur domaine',
        ),
        SizedBox(height: 32),
        _FeatureItem(
          icon: Icons.accessibility,
          title: 'Accessibilité',
          description: 'Apprenez à votre rythme, où que vous soyez',
        ),
        SizedBox(height: 32),
        _FeatureItem(
          icon: Icons.analytics,
          title: 'Suivi',
          description: 'Suivez votre progression et obtenez des certificats',
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.blue[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 32,
            color: Colors.blue[600],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}