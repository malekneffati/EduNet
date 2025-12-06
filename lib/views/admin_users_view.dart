import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../components/admin/admin_header.dart';
import '../components/admin/admin_sidebar.dart';
import '../components/admin/stat_card.dart';
import '../viewmodels/admin/user_management_viewmodel.dart';
import '../viewmodels/admin/admin_sidebar_viewmodel.dart';

class AdminUsersView extends ConsumerStatefulWidget {
  const AdminUsersView({super.key});

  @override
  ConsumerState<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends ConsumerState<AdminUsersView> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userManagementProvider).loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = ref.watch(userManagementProvider);
    final sidebarViewModel = ref.watch(adminSidebarProvider);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final isTablet = width >= 768 && width < 1024;

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
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
                    child: isMobile
                        ? ListView(
                            children: [
                              Text(
                                'Gestion des utilisateurs',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildStatsSection(userViewModel, isMobile, isTablet),
                              const SizedBox(height: 20),
                              _buildFilters(userViewModel, isMobile),
                              const SizedBox(height: 16),
                              _buildUsersList(userViewModel, isMobile, shrinkWrap: true),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gestion des utilisateurs',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildStatsSection(userViewModel, isMobile, isTablet),
                              const SizedBox(height: 20),
                              _buildFilters(userViewModel, isMobile),
                              const SizedBox(height: 16),
                              Expanded(
                                child: _buildUsersList(userViewModel, isMobile),
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

  Widget _buildStatsSection(
    UserManagementViewModel vm,
    bool isMobile,
    bool isTablet,
  ) {
    int crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 5);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: isMobile ? 1.3 : 1.6,
      children: [
        StatCard(
          title: 'Total',
          value: vm.totalUsers.toString(),
          icon: Icons.people,
          color: const Color(0xFF4F46E5),
          isLoading: vm.isLoading,
        ),
        StatCard(
          title: 'Étudiants',
          value: vm.totalStudents.toString(),
          icon: Icons.school,
          color: const Color(0xFF10B981),
          isLoading: vm.isLoading,
        ),
        StatCard(
          title: 'Admins',
          value: vm.totalAdmins.toString(),
          icon: Icons.admin_panel_settings,
          color: const Color(0xFFEF4444),
          isLoading: vm.isLoading,
        ),
        StatCard(
          title: 'Actifs',
          value: vm.activeUsers.toString(),
          icon: Icons.check_circle,
          color: const Color(0xFF8B5CF6),
          isLoading: vm.isLoading,
        ),
        StatCard(
          title: 'Premium',
          value: vm.premiumUsers.toString(),
          icon: Icons.workspace_premium,
          color: const Color(0xFFF59E0B),
          isLoading: vm.isLoading,
        ),
      ],
    );
  }

  Widget _buildFilters(UserManagementViewModel vm, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          TextField(
            onChanged: vm.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Rechercher...',
              hintStyle: const TextStyle(fontSize: 14),
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: vm.roleFilter,
                  isDense: true,
                  decoration: InputDecoration(
                    labelText: 'Rôle',
                    labelStyle: const TextStyle(fontSize: 12),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Tous', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'student', child: Text('Étudiants', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'admin', child: Text('Admins', style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (value) => vm.setRoleFilter(value!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: vm.statusFilter,
                  isDense: true,
                  decoration: InputDecoration(
                    labelText: 'Statut',
                    labelStyle: const TextStyle(fontSize: 12),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Tous', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'active', child: Text('Actifs', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactifs', style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (value) => vm.setStatusFilter(value!),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              onChanged: vm.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Rechercher par nom ou email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: vm.roleFilter,
              decoration: InputDecoration(
                labelText: 'Rôle',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Tous')),
                DropdownMenuItem(value: 'student', child: Text('Étudiants')),
                DropdownMenuItem(value: 'admin', child: Text('Admins')),
              ],
              onChanged: (value) => vm.setRoleFilter(value!),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: vm.subscriptionFilter,
              decoration: InputDecoration(
                labelText: 'Abonnement',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Tous')),
                DropdownMenuItem(value: 'free', child: Text('Gratuit')),
                DropdownMenuItem(value: 'premium', child: Text('Premium')),
              ],
              onChanged: (value) => vm.setSubscriptionFilter(value!),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildFilterChip(
    String label,
    String currentValue,
    List<(String, String)> options,
    Function(String) onChanged,
  ) {
    return PopupMenuButton<String>(
      child: Chip(
        label: Text('$label: ${options.firstWhere((o) => o.$1 == currentValue).$2}'),
        deleteIcon: const Icon(Icons.arrow_drop_down, size: 18),
        onDeleted: () {},
      ),
      itemBuilder: (context) => options
          .map((opt) => PopupMenuItem(
                value: opt.$1,
                child: Text(opt.$2),
              ))
          .toList(),
      onSelected: onChanged,
    );
  }

  Widget _buildUsersList(UserManagementViewModel vm, bool isMobile, {bool shrinkWrap = false}) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(vm.error!),
            ElevatedButton(
              onPressed: () => vm.loadUsers(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    final users = vm.filteredUsers;

    if (users.isEmpty) {
      return const Center(
        child: Text('Aucun utilisateur trouvé'),
      );
    }

    if (isMobile) {
      return ListView.builder(
        shrinkWrap: shrinkWrap,
        physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
        itemCount: users.length,
        itemBuilder: (context, index) => _buildMobileUserCard(users[index], vm),
      );
    } else {
      return SingleChildScrollView(
        child: _buildDesktopTable(users, vm),
      );
    }
  }

  Widget _buildMobileUserCard(user, UserManagementViewModel vm) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: user.isActive
                      ? const Color(0xFF4F46E5)
                      : Colors.grey,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildBadge(user.role == 'admin' ? 'Admin' : 'Étudiant',
                    user.role == 'admin' ? Colors.red : Colors.blue),
                _buildBadge(user.subscriptionLabel, Colors.orange),
                _buildBadge(
                    user.statusLabel, user.isActive ? Colors.green : Colors.grey),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Inscrit le: ${_dateFormat.format(user.createdAt)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    user.isActive ? Icons.block : Icons.check_circle,
                    size: 20,
                    color: user.isActive ? Colors.red : Colors.green,
                  ),
                  onPressed: () => _toggleStatus(user.uid, vm),
                  tooltip: user.isActive ? 'Désactiver' : 'Activer',
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _showEditDialog(user, vm),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () => _showDeleteDialog(user, vm),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTable(List users, UserManagementViewModel vm) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          columns: const [
            DataColumn(label: Text('Nom')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Rôle')),
            DataColumn(label: Text('Abonnement')),
            DataColumn(label: Text('Inscription')),
            DataColumn(label: Text('Statut')),
            DataColumn(label: Text('Actions')),
          ],
          rows: users.map<DataRow>((user) {
            return DataRow(cells: [
              DataCell(Text(user.name)),
              DataCell(Text(user.email)),
              DataCell(_buildBadge(
                user.role == 'admin' ? 'Admin' : 'Étudiant',
                user.role == 'admin' ? Colors.red : Colors.blue,
              )),
              DataCell(_buildBadge(user.subscriptionLabel, Colors.orange)),
              DataCell(Text(_dateFormat.format(user.createdAt))),
              DataCell(_buildBadge(
                user.statusLabel,
                user.isActive ? Colors.green : Colors.grey,
              )),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      user.isActive ? Icons.block : Icons.check_circle,
                      size: 18,
                      color: user.isActive ? Colors.red : Colors.green,
                    ),
                    onPressed: () => _toggleStatus(user.uid, vm),
                    tooltip: user.isActive ? 'Désactiver' : 'Activer',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () => _showEditDialog(user, vm),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    onPressed: () => _showDeleteDialog(user, vm),
                  ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.withOpacity(0.9),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _toggleStatus(String userId, UserManagementViewModel vm) async {
    final success = await vm.toggleUserStatus(userId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Statut mis à jour'
              : 'Erreur lors de la mise à jour'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showEditDialog(user, UserManagementViewModel vm) {
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Modifier ${user.name}'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                title: const Text('Étudiant'),
                value: 'student',
                groupValue: selectedRole,
                onChanged: (value) => setState(() => selectedRole = value!),
              ),
              RadioListTile(
                title: const Text('Administrateur'),
                value: 'admin',
                groupValue: selectedRole,
                onChanged: (value) => setState(() => selectedRole = value!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await vm.updateUserRole(user.uid, selectedRole);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Rôle mis à jour' : 'Erreur'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(user, UserManagementViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer'),
        content: Text('Supprimer "${user.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final success = await vm.deleteUser(user.uid);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Utilisateur supprimé' : 'Erreur'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
