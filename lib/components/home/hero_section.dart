// lib/components/home/hero_section.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1280),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 768;

            if (isMobile) {
              return Column(
                children: _buildMobileContent(context),
              );
            } else {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _buildDesktopContent(context),
              );
            }
          },
        ),
      ),
    );
  }

  List<Widget> _buildMobileContent(BuildContext context) {
    return [
      _buildTextContent(context),
      const SizedBox(height: 48),
      _buildStatsContent(),
    ];
  }

  List<Widget> _buildDesktopContent(BuildContext context) {
    return [
      Expanded(
        child: _buildTextContent(context),
      ),
      const SizedBox(width: 48),
      Expanded(
        child: _buildStatsContent(),
      ),
    ];
  }

  Widget _buildTextContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // IMPORTANT : éviter l'expansion infinie
      children: [
        Text(
          'Apprenez autrement avec EduNet.',
          style: GoogleFonts.poppins(
            fontSize: 44,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Découvrez des milliers de cours en ligne pour développer vos compétences et atteindre vos objectifs professionnels.',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/catalog');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E3A8A),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Explorer les cours'),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(width: 2, color: Colors.white),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('S\'abonner'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsContent() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(
              FontAwesomeIcons.graduationCap,
              size: 96,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            const Text(
              'Plus de 10,000 étudiants nous font confiance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}