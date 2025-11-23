// lib/components/home/footer.dart
import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    print("🦶 [FOOTER] Build Footer");

    return Container(
      color: const Color(0xFF1E3A8A),
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;

          return Container(
            constraints: const BoxConstraints(maxWidth: 1280),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: isMobile
                ? _buildMobileFooter(context)
                : _buildDesktopFooter(context),
          );
        },
      ),
    );
  }

  Widget _buildMobileFooter(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // IMPORTANT
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEduNetSection(),
        const SizedBox(height: 32),
        _buildQuickLinksSection(context),
        const SizedBox(height: 32),
        _buildContactSection(),
        const SizedBox(height: 32),
        _buildCopyrightSection(),
      ],
    );
  }

  Widget _buildDesktopFooter(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // IMPORTANT
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildEduNetSection()),
            const SizedBox(width: 48),
            Expanded(child: _buildQuickLinksSection(context)),
            const SizedBox(width: 48),
            Expanded(child: _buildContactSection()),
          ],
        ),
        const SizedBox(height: 48),
        _buildCopyrightSection(),
      ],
    );
  }

  Widget _buildEduNetSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EduNet',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Votre plateforme d\'apprentissage en ligne pour développer vos compétences et atteindre vos objectifs professionnels.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickLinksSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Liens rapides',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildFooterLink('Accueil', () {
          print("🧭 [FOOTER] Navigation vers Accueil");
          Navigator.pushNamed(context, '/');
        }),
        _buildFooterLink('Catalogue des cours', () {
          print("🧭 [FOOTER] Navigation vers Catalogue");
          Navigator.pushNamed(context, '/catalog');
        }),
        _buildFooterLink('Abonnement', () {
          print("🧭 [FOOTER] Navigation vers Abonnement");
          Navigator.pushNamed(context, '/subscription');
        }),
        _buildFooterLink('Connexion', () {
          print("🧭 [FOOTER] Navigation vers Connexion");
          Navigator.pushNamed(context, '/login');
        }),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contactez-nous',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'support@edunet.com',
          style: TextStyle(color: Colors.white70),
        ),
        const Text(
          '+216 12 345 678',
          style: TextStyle(color: Colors.white70),
        ),
        const Text(
          '123 Avenue de l\'Éducation, Tunis, Tunisie',
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildCopyrightSection() {
    return const Center(
      child: Text(
        '© 2025 EduNet. Tous droits réservés.',
        style: TextStyle(
          color: Colors.white60,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildFooterLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}