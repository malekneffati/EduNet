// lib/components/home/navbar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:edunet/viewmodels/home/navbar_viewmodel.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavbarViewModel(),
      child: Consumer<NavbarViewModel>(
        builder: (context, viewModel, child) {
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
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1280),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'EduNet',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                  Row(
                    children: [
                      ...viewModel.commonLinks.map((link) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, link['to']!);
                          },
                          child: Text(
                            link['name']!,
                            style: const TextStyle(
                              color: Color(0xFF374151),
                              fontSize: 14,
                              fontWeight: FontWeight.w500, // CORRIGÉ : medium -> w500
                            ),
                          ),
                        ),
                      )),
                      ...viewModel.roleLinks.map((link) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, link['to']!);
                          },
                          child: Text(
                            link['name']!,
                            style: const TextStyle(
                              color: Color(0xFF374151),
                              fontSize: 14,
                              fontWeight: FontWeight.w500, // CORRIGÉ : medium -> w500
                            ),
                          ),
                        ),
                      )),
                    ],
                  ),
                  if (viewModel.user != null)
                    ElevatedButton(
                      onPressed: viewModel.handleLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Déconnexion'), // CORRIGÉ : Déconnexion
                    )
                  else
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Se Connecter'), // CORRIGÉ : Connecter
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}