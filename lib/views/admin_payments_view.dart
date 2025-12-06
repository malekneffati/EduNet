import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/admin/admin_header.dart';
import '../components/admin/admin_sidebar.dart';
import '../viewmodels/admin/admin_sidebar_viewmodel.dart';

class AdminPaymentsView extends ConsumerWidget {
  const AdminPaymentsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebarViewModel = ref.watch(adminSidebarProvider);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return Scaffold(
      drawer: isMobile
          ? Drawer(
              child: AdminSidebar(
                selectedIndex: sidebarViewModel.selectedIndex,
                onItemSelected: (index) {
                  sidebarViewModel.selectItem(index);
                  Navigator.pop(context);
                },
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            AdminSidebar(
              selectedIndex: sidebarViewModel.selectedIndex,
              onItemSelected: (index) {
                sidebarViewModel.selectItem(index);
              },
            ),
          Expanded(
            child: Column(
              children: [
                AdminHeader(isMobile: isMobile),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payment,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Gestion des paiements',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cette fonctionnalité sera bientôt disponible',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
