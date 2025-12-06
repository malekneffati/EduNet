import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/admin/admin_dashboard_viewmodel.dart';

class AdminHeader extends ConsumerWidget {
  final bool isMobile;

  const AdminHeader({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Menu button pour mobile
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),

          // Title and user info
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Text(
                  isMobile ? 'Dashboard' : 'Dashboard Administrateur',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Connecté en tant que admin@edunet.com',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final viewModel = ref.watch(adminDashboardProvider);
                  return IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => viewModel.refreshData(),
                    tooltip: 'Actualiser',
                  );
                },
              ),
              if (!isMobile) const SizedBox(width: 8),
              const CircleAvatar(
                backgroundColor: Color(0xFF4F46E5),
                radius: 18,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}