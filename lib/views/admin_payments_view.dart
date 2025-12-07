import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/admin/admin_header.dart';
import '../components/admin/admin_sidebar.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';
import '../viewmodels/admin/admin_sidebar_viewmodel.dart';

class AdminPaymentsView extends ConsumerWidget {
  const AdminPaymentsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebarViewModel = ref.watch(adminSidebarProvider);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final service = ref.watch(paymentServiceProvider);

    return Scaffold(
      drawer: isMobile
          ? Drawer(
              child: AdminSidebar(
                selectedIndex: 3, // Paiements
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
              selectedIndex: 3,
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
                        // Section title
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Gestion des paiements',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              StreamBuilder<List<PaymentModel>>(
                                stream: service.getAllPayments(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  
                                  if (snapshot.hasError) {
                                    return Center(child: Text('Erreur: ${snapshot.error}'));
                                  }

                                  final payments = snapshot.data ?? [];

                                  if (payments.isEmpty) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(40.0),
                                        child: Text('Aucun paiement trouvé.'),
                                      ),
                                    );
                                  }

                                  // Layout Responsive
                                  if (isMobile) {
                                    return ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: payments.length,
                                      separatorBuilder: (_, __) => const Divider(),
                                      itemBuilder: (context, index) {
                                        final p = payments[index];
                                        return _buildMobilePaymentCard(p);
                                      },
                                    );
                                  }

                                  return _buildPaymentTable(payments);
                                },
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

  Widget _buildPaymentTable(List<PaymentModel> payments) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
        columns: const [
          DataColumn(
            label: Text(
              'Utilisateur',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Montant',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Date',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Cours/Abonnement',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Statut',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: payments.map((p) {
          return DataRow(
            cells: [
              DataCell(
                FutureBuilder<String>(
                  future: _getUserName(p.userId),
                  builder: (context, snapshot) {
                    return Text(snapshot.data ?? 'Chargement...');
                  },
                ),
              ),
              DataCell(
                Text(
                  '${p.amount.toStringAsFixed(0)} ${p.currency}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              DataCell(
                Text(DateFormat('dd/MM/yyyy').format(p.createdAt)),
              ),
              DataCell(
                FutureBuilder<String>(
                  future: _getItemName(p.itemType, p.itemId),
                  builder: (context, snapshot) {
                    return Text(snapshot.data ?? 'Chargement...');
                  },
                ),
              ),
              DataCell(_buildStatusChip(p.status)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobilePaymentCard(PaymentModel p) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FutureBuilder<String>(
                future: _getUserName(p.userId),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? 'Chargement...',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                },
              ),
              _buildStatusChip(p.status),
            ],
          ),
          const SizedBox(height: 8),
          Text('Montant: ${p.amount} ${p.currency}'),
          Text('Date: ${DateFormat('dd/MM/yyyy').format(p.createdAt)}'),
          FutureBuilder<String>(
            future: _getItemName(p.itemType, p.itemId),
            builder: (context, snapshot) {
              return Text('Item: ${snapshot.data ?? "Chargement..."}');
            },
          ),
        ],
      ),
    );
  }

  Future<String> _getUserName(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        final data = userDoc.data();
        return data?['displayName'] ?? data?['email'] ?? 'Utilisateur ${userId.substring(0, 6)}';
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
    return 'Utilisateur ${userId.substring(0, 6)}';
  }

  Future<String> _getItemName(PaymentItemType type, String? itemId) async {
    if (type == PaymentItemType.subscription) {
      return 'Abonnement Premium';
    }
    
    if (itemId == null) return 'Cours inconnu';
    
    try {
      final courseDoc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(itemId)
          .get();
      
      if (courseDoc.exists) {
        return courseDoc.data()?['title'] ?? 'Cours ${itemId.substring(0, 6)}';
      }
    } catch (e) {
      print('Error fetching course: $e');
    }
    return 'Cours ${itemId.substring(0, 6)}';
  }

  Widget _buildStatusChip(PaymentStatus status) {
    Color color;
    String label;

    switch (status) {
      case PaymentStatus.completed:
        color = Colors.green;
        label = 'Complété';
        break;
      case PaymentStatus.pending:
        color = Colors.orange;
        label = 'En attente';
        break;
      case PaymentStatus.failed:
        color = Colors.red;
        label = 'Échoué';
        break;
      default:
        color = Colors.grey;
        label = status.toString().split('.').last;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

// Payment Service Provider
final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});
