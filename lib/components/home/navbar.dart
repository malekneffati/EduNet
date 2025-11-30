// lib/components/home/navbar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:edunet/viewmodels/auth/auth_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && mounted) {
      // ✅ Use Future.microtask to avoid setState during build
      await Future.microtask(() {});
      if (mounted) {
        setState(() {
          _role = 'student'; // TODO: Get from Firestore
        });
      }
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    print("🚪 [NAVBAR] Logout requested");
    try {
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        setState(() {
          _role = null;
        });
      }

      print("✅ [NAVBAR] Logout successful - redirecting to login");

      // 🔥 ALWAYS redirect to login page after logout
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
              (route) => false,
        );
      }

    } catch (err) {
      print("❌ [NAVBAR] Logout error: $err");
    }
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        final user = authViewModel.user;

        // ✅ Use addPostFrameCallback instead of setState during build
        if (user != null && _role == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadUserRole();
          });
        } else if (user == null && _role != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _role = null;
              });
            }
          });
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 24,
                vertical: 12,
              ),
              child: isMobile
                  ? _buildMobileNavbar(context, user)
                  : _buildDesktopNavbar(context, user),
            ),
          ),
        );
      },
    );
  }

  // ✅ DESKTOP NAVBAR - ALWAYS SHOWS ALL LINKS
  Widget _buildDesktopNavbar(BuildContext context, User? user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/home'),
          child: Text(
            'EduNet',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
        ),

        // ALL LINKS - ALWAYS VISIBLE
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // ✅ ALWAYS SHOW THESE 3 LINKS
              _buildNavLink(context, 'Accueil', '/home'),
              _buildNavLink(context, 'Catalogue', '/catalog'),
              _buildNavLink(context, 'Abonnement', '/subscription'),

              // ✅ ADD "Mon Espace" ONLY IF LOGGED IN
              if (user != null && _role == 'student')
                _buildNavLink(context, 'Mon Espace', '/dashboard'),

              if (user != null && _role == 'admin')
                _buildNavLink(context, 'Admin', '/admin'),

              const SizedBox(width: 16),

              // ✅ AUTH BUTTON
              user != null
                  ? ElevatedButton(
                onPressed: () => _handleLogout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Se déconnecter'),
              )
                  : ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Se Connecter'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ MOBILE NAVBAR - ALWAYS SHOWS ALL LINKS IN MENU
  Widget _buildMobileNavbar(BuildContext context, User? user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/home'),
          child: Text(
            'EduNet',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
        ),

        // Hamburger menu
        IconButton(
          icon: const Icon(Icons.menu, size: 28),
          onPressed: () => _showMobileMenu(context, user),
        ),
      ],
    );
  }

  // ✅ MOBILE MENU - ALWAYS SHOWS ALL LINKS
  void _showMobileMenu(BuildContext context, User? user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ ALWAYS SHOW THESE 3 ITEMS
              _buildMobileMenuItem(context, 'Accueil', '/home', Icons.home),
              _buildMobileMenuItem(context, 'Catalogue', '/catalog', Icons.menu_book),
              _buildMobileMenuItem(context, 'Abonnement', '/subscription', Icons.card_membership),

              // ✅ ADD "Mon Espace" ONLY IF LOGGED IN
              if (user != null && _role == 'student')
                _buildMobileMenuItem(context, 'Mon Espace', '/dashboard', Icons.dashboard),

              if (user != null && _role == 'admin')
                _buildMobileMenuItem(context, 'Admin', '/admin', Icons.admin_panel_settings),

              const Divider(height: 32),

              // Auth button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: user != null
                    ? ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Close menu
                    _handleLogout(context);
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Se déconnecter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
                    : ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/login');
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Se Connecter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavLink(BuildContext context, String label, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, route),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileMenuItem(
      BuildContext context,
      String label,
      String route,
      IconData icon,
      ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1E3A8A)),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close menu
        Navigator.pushNamed(context, route);
      },
    );
  }
}