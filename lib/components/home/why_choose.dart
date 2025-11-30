// lib/components/home/why_choose.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WhyChoose extends StatelessWidget {
  const WhyChoose({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F4F6),
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pourquoi choisir EduNet ?',
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Rejoignez une plateforme conçue pour maximiser votre apprentissage',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4B5563),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 768;

                if (isMobile) {
                  // Mobile: Stack vertically, no grid
                  return Column(
                    children: [
                      _buildCard(
                        icon: FontAwesomeIcons.award,
                        title: 'Qualité',
                        description: 'Cours créés par des experts reconnus',
                      ),
                      const SizedBox(height: 32),
                      _buildCard(
                        icon: FontAwesomeIcons.universalAccess,
                        title: 'Accessibilité',
                        description: 'Apprenez à votre rythme',
                      ),
                      const SizedBox(height: 32),
                      _buildCard(
                        icon: FontAwesomeIcons.chartBar,
                        title: 'Suivi',
                        description: 'Suivez votre progression',
                      ),
                    ],
                  );
                }

                // Desktop: Grid
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildCard(
                        icon: FontAwesomeIcons.award,
                        title: 'Qualité',
                        description: 'Cours créés par des experts reconnus dans leur domaine',
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: _buildCard(
                        icon: FontAwesomeIcons.universalAccess,
                        title: 'Accessibilité',
                        description: 'Apprenez à votre rythme, où que vous soyez',
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: _buildCard(
                        icon: FontAwesomeIcons.chartBar,
                        title: 'Suivi',
                        description: 'Suivez votre progression et obtenez des certificats',
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: Color(0xFFDBEAFE),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 32),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            color: Color(0xFF4B5563),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}