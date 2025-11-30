// lib/components/home/footer.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    print("🦶 [FOOTER] Build Footer");

    return Container(
      color: const Color(0xFF111827), // gray-900 to match website
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 768;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Main Footer Content
                isMobile
                    ? _buildMobileFooter(context)
                    : _buildDesktopFooter(context),

                // Divider
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Divider(color: Color(0xFF374151), height: 1),
                ),

                // Copyright
                _buildCopyrightSection(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileFooter(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCompanySection(),
        const SizedBox(height: 32),
        _buildQuickLinksSection(context),
        const SizedBox(height: 32),
        _buildContactSection(),
        const SizedBox(height: 32),
        _buildNewsletterSection(),
      ],
    );
  }

  Widget _buildDesktopFooter(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildCompanySection()),
        const SizedBox(width: 32),
        Expanded(child: _buildQuickLinksSection(context)),
        const SizedBox(width: 32),
        Expanded(child: _buildContactSection()),
        const SizedBox(width: 32),
        Expanded(child: _buildNewsletterSection()),
      ],
    );
  }

  // ✅ Section 1: Company Info + Social Media
  Widget _buildCompanySection() {
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
            color: Color(0xFF9CA3AF), // gray-400
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),

        // Social Media Icons
        Row(
          children: [
            _buildSocialIcon(FontAwesomeIcons.facebookF, 'https://facebook.com'),
            const SizedBox(width: 16),
            _buildSocialIcon(FontAwesomeIcons.twitter, 'https://twitter.com'),
            const SizedBox(width: 16),
            _buildSocialIcon(FontAwesomeIcons.linkedinIn, 'https://linkedin.com'),
            const SizedBox(width: 16),
            _buildSocialIcon(FontAwesomeIcons.instagram, 'https://instagram.com'),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, String url) {
    return GestureDetector(
      onTap: () {
        print("🔗 [FOOTER] Opening: $url");
        // TODO: Launch URL
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937), // gray-800
          shape: BoxShape.circle,
        ),
        child: Center(
          child: FaIcon(
            icon,
            size: 16,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }

  // ✅ Section 2: Quick Links
  Widget _buildQuickLinksSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Liens rapides',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildFooterLink(context, 'Accueil', '/home'),
        _buildFooterLink(context, 'Catalogue des cours', '/catalog'),
        _buildFooterLink(context, 'Abonnement', '/subscription'),
        _buildFooterLink(context, 'Connexion', '/login'),
      ],
    );
  }

  Widget _buildFooterLink(BuildContext context, String text, String route) {
    return GestureDetector(
      onTap: () {
        print("🔗 [FOOTER] Navigation to: $route");
        Navigator.pushNamed(context, route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 14,
            height: 1.8,
          ),
        ),
      ),
    );
  }

  // ✅ Section 3: Contact Info
  Widget _buildContactSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contactez-nous',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildContactItem(Icons.email, 'support@edunet.com'),
        _buildContactItem(Icons.phone, '+216 12 345 678'),
        _buildContactItem(Icons.location_on, '123 Avenue de l\'Éducation, Tunis, Tunisie'),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF3B82F6), // blue-500
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Section 4: Newsletter
  Widget _buildNewsletterSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Newsletter',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Inscrivez-vous pour recevoir les dernières mises à jour.',
          style: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),

        // Newsletter Form
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Entrez votre email',
                  hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                  filled: true,
                  fillColor: const Color(0xFF1F2937),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(8),
                    ),
                    borderSide: const BorderSide(color: Color(0xFF374151)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(8),
                    ),
                    borderSide: const BorderSide(color: Color(0xFF374151)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(8),
                    ),
                    borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                print("📧 [FOOTER] Newsletter subscription");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(8),
                  ),
                ),
                elevation: 0,
              ),
              child: const Text(
                'S\'abonner',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ✅ Copyright Section
  Widget _buildCopyrightSection() {
    return const Text(
      '© 2025 EduNet. Tous droits réservés.',
      style: TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 14,
      ),
      textAlign: TextAlign.center,
    );
  }
}