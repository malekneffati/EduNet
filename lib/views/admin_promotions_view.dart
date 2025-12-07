import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/admin/admin_header.dart';
import '../components/admin/admin_sidebar.dart';
import '../viewmodels/admin/admin_sidebar_viewmodel.dart';
import '../viewmodels/admin/promotion_management_viewmodel.dart';
import '../models/promotion_model.dart';

class AdminPromotionsView extends ConsumerStatefulWidget {
  const AdminPromotionsView({super.key});

  @override
  ConsumerState<AdminPromotionsView> createState() => _AdminPromotionsViewState();
}

class _AdminPromotionsViewState extends ConsumerState<AdminPromotionsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(promotionManagementProvider).loadPromotions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(promotionManagementProvider);
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
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestion des paiements',
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Bouton Nouvelle promotion
                        ElevatedButton.icon(
                          onPressed: () => _showPromotionDialog(context, null, vm),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Nouvelle promotion'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: isMobile
                              ? ListView(
                                  children: [
                                    _buildSectionTitle('Promotions actives'),
                                    _buildPromotionsList(vm),
                                    const SizedBox(height: 24),
                                    _buildSectionTitle('Options d\'abonnement'),
                                    _buildSubscriptionOptions(context),
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildSectionTitle('Promotions actives'),
                                          if (vm.isLoading)
                                            const Center(child: CircularProgressIndicator())
                                          else if (vm.promotions.isEmpty)
                                            const Center(child: Text('Aucune promotion.'))
                                          else
                                            Expanded(child: _buildPromotionsList(vm)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildSectionTitle('Options d\'abonnement'),
                                          _buildSubscriptionOptions(context),
                                        ],
                                      ),
                                    ),
                                  ],
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildSubscriptionOptions(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Abonnement annuel (Premium)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '200 TND/an',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Modification du prix à implémenter')));
              }, 
              child: const Text('Modifier le prix'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionsList(PromotionManagementViewModel vm) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: vm.promotions.length,
      itemBuilder: (context, index) {
        final promo = vm.promotions[index];
        return _buildSimplePromotionCard(promo, vm);
      },
    );
  }

  Widget _buildSimplePromotionCard(PromotionModel promo, PromotionManagementViewModel vm) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        promo.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (promo.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF10B981)),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    promo.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Expire le ${_formatDate(promo.createdAt.add(const Duration(days: 30)))}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') {
                  _showPromotionDialog(context, promo, vm);
                } else if (value == 'delete') {
                  _showDeleteDialog(context, promo, vm);
                } else if (value == 'toggle') {
                  vm.toggleActive(promo.id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Modifier'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(promo.isActive ? Icons.visibility_off : Icons.visibility, size: 18),
                      const SizedBox(width: 8),
                      Text(promo.isActive ? 'Désactiver' : 'Activer'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Supprimer', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildPromotionCard(PromotionModel promo, PromotionManagementViewModel vm) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: promo.isPopular
              ? Border.all(color: const Color(0xFFF59E0B), width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: promo.isActive
                    ? const Color(0xFF4F46E5).withOpacity(0.1)
                    : Colors.grey[200],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          promo.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                      if (promo.isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'POPULAIRE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${promo.price.toStringAsFixed(0)} TND',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '/${promo.period == 'monthly' ? 'mois' : 'an'}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Description & Features
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promo.description,
                      style: const TextStyle(color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: promo.features.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF10B981),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    promo.features[index],
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      promo.isActive ? Icons.visibility_off : Icons.visibility,
                      color: promo.isActive ? Colors.orange : Colors.green,
                    ),
                    onPressed: () => vm.toggleActive(promo.id),
                    tooltip: promo.isActive ? 'Désactiver' : 'Activer',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF4F46E5)),
                    onPressed: () => _showPromotionDialog(context, promo, vm),
                    tooltip: 'Modifier',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(context, promo, vm),
                    tooltip: 'Supprimer',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPromotionDialog(
    BuildContext context,
    PromotionModel? promo,
    PromotionManagementViewModel vm,
  ) {
    final titleController = TextEditingController(text: promo?.title ?? '');
    final descController = TextEditingController(text: promo?.description ?? '');
    final priceController =
        TextEditingController(text: promo?.price.toString() ?? '');
    String period = promo?.period ?? 'monthly';
    bool isPopular = promo?.isPopular ?? false;
    final List<String> features = List.from(promo?.features ?? []);
    final featureController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(promo == null ? 'Nouvelle promotion' : 'Modifier promotion'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Titre'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Prix (TND)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: period,
                  decoration: const InputDecoration(labelText: 'Période'),
                  items: const [
                    DropdownMenuItem(value: 'monthly', child: Text('Mensuel')),
                    DropdownMenuItem(value: 'yearly', child: Text('Annuel')),
                  ],
                  onChanged: (value) => setState(() => period = value!),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Marquer comme populaire'),
                  value: isPopular,
                  onChanged: (value) => setState(() => isPopular = value),
                ),
                const Divider(),
                const Text('Fonctionnalités',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...features.map((f) => ListTile(
                      dense: true,
                      title: Text(f),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, size: 18),
                        onPressed: () => setState(() => features.remove(f)),
                      ),
                    )),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: featureController,
                        decoration:
                            const InputDecoration(hintText: 'Nouvelle fonctionnalité'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (featureController.text.isNotEmpty) {
                          setState(() {
                            features.add(featureController.text);
                            featureController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newPromo = PromotionModel(
                id: promo?.id ?? '',
                title: titleController.text,
                description: descController.text,
                price: double.tryParse(priceController.text) ?? 0,
                period: period,
                features: features,
                isPopular: isPopular,
                isActive: promo?.isActive ?? true,
                createdAt: promo?.createdAt ?? DateTime.now(),
              );

              bool success;
              if (promo == null) {
                success = await vm.addPromotion(newPromo);
              } else {
                success = await vm.updatePromotion(newPromo);
              }

              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Enregistré !' : 'Erreur'),
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

  void _showDeleteDialog(
    BuildContext context,
    PromotionModel promo,
    PromotionManagementViewModel vm,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer'),
        content: Text('Supprimer "${promo.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final success = await vm.deletePromotion(promo.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Supprimé !' : 'Erreur'),
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
