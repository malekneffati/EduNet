import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminSidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Vue d\'ensemble',
      'icon': Icons.dashboard,
      'route': '/admin',
    },
    {
      'title': 'Cours',
      'icon': Icons.school,
      'route': '/admin/courses',
    },
    {
      'title': 'Utilisateurs',
      'icon': Icons.people,
      'route': '/admin/users',
    },
    {
      'title': 'Paiements',
      'icon': Icons.payment,
      'route': '/admin/payments',
    },
    {
      'title': 'Promotions',
      'icon': Icons.local_offer,
      'route': '/admin/promotions',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFF1E293B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo/Header
          Container(
            padding: const EdgeInsets.all(24),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EduNet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Administration',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = widget.selectedIndex == index;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: Icon(
                      item['icon'],
                      color: isSelected ? Colors.white : Colors.grey[400],
                    ),
                    title: Text(
                      item['title'],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[400],
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
                      ),
                    ),
                    tileColor: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onTap: () {
                      widget.onItemSelected(index);
                      context.go(item['route']);
                    },
                  ),
                );
              },
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[800]!)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF4F46E5),
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Administrateur',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'admin@edunet.com',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.grey),
                  onPressed: () {
                    context.go('/');
                  },
                  tooltip: 'Déconnexion',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}