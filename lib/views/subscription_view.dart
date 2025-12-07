import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/home/navbar.dart';
import '../components/home/footer.dart';
import '../viewmodels/admin/promotion_management_viewmodel.dart';
import '../models/promotion_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/payment_service.dart';

class SubscriptionView extends ConsumerStatefulWidget {
  const SubscriptionView({super.key});

  @override
  ConsumerState<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends ConsumerState<SubscriptionView> {
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
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Navbar(),
            _buildSubscriptionContent(vm, isMobile),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionContent(
      PromotionManagementViewModel vm, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 48,
        vertical: 48,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Abonnement illimité EduNet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 28 : 40,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Accédez à tous nos cours pour un prix mensuel fixe',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 14 : 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 48),

          // Plans
          if (vm.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (vm.activePromotions.isEmpty)
            _buildFallbackPlans(isMobile)
          else
            _buildSubscriptionPlans(vm.activePromotions, isMobile),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlans(List<PromotionModel> promotions, bool isMobile) {
    if (isMobile) {
      return Column(
        children: promotions.map((promo) => _buildPlanCard(promo, isMobile)).toList(),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: promotions
            .map((promo) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _buildPlanCard(promo, isMobile),
                  ),
                ))
            .toList(),
      );
    }
  }

  Widget _buildPlanCard(PromotionModel promo, bool isMobile) {
    final isPopular = promo.isPopular;

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 24 : 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            elevation: isPopular ? 8 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: isPopular
                  ? const BorderSide(color: Color(0xFFF59E0B), width: 2)
                  : BorderSide.none,
            ),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: isPopular
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF4F46E5).withOpacity(0.05),
                          Colors.white,
                        ],
                      )
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promo.title,
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 28,
                      fontWeight: FontWeight.bold,
                      color: isPopular
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${promo.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: isMobile ? 40 : 48,
                          fontWeight: FontWeight.bold,
                          color: isPopular
                              ? const Color(0xFF4F46E5)
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'TND /${promo.period == 'monthly' ? 'mois' : 'an'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    promo.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  
                  // Features
                  ...promo.features.map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: isPopular
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF4F46E5),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                feature,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      )),
                  
                  const SizedBox(height: 32),
                  
                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _handleSubscribe(promo),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPopular
                            ? const Color(0xFF4F46E5)
                            : Colors.white,
                        foregroundColor: isPopular
                            ? Colors.white
                            : const Color(0xFF4F46E5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: !isPopular
                              ? const BorderSide(color: Color(0xFF4F46E5))
                              : BorderSide.none,
                        ),
                        elevation: isPopular ? 4 : 0,
                      ),
                      child: Text(
                        promo.price == 0 ? 'Déjà actif' : 'S\'abonner maintenant',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Popular badge
          if (isPopular)
            Positioned(
              top: -12,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'POPULAIRE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackPlans(bool isMobile) {
    // Plans par défaut si aucune promotion n'est active
    final fallbackPlans = [
      PromotionModel(
        id: 'free',
        title: 'Accès Gratuit',
        description: 'Cours gratuits uniquement',
        price: 0,
        period: 'monthly',
        features: [
          'Cours gratuits uniquement',
          'Accès limité aux ressources',
          'Pas de certificats',
          'Support limité',
        ],
        isPopular: false,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      PromotionModel(
        id: 'premium',
        title: 'Abonnement Premium',
        description: 'Accès illimité à tous les cours',
        price: 30,
        period: 'monthly',
        features: [
          'Accès illimité à tous les cours',
          'Téléchargement des ressources',
          'Certificats de complétion',
          'Suivi des quiz et progression',
          'Support prioritaire',
          'Nouveaux cours en avant-première',
        ],
        isPopular: true,
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];

    return _buildSubscriptionPlans(fallbackPlans, isMobile);
  }

  Future<void> _handleSubscribe(PromotionModel promo) async {
    if (promo.price == 0) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vous connecter pour vous abonner')),
      );
      // context.go('/login'); // Si vous avez cette route
      return;
    }

    // Confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Abonnement'),
        content: Text(
          'Vous allez être redirigé vers Paymee pour payer ${promo.price} TND.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
            ),
            child: const Text('Payer maintenant'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final paymentService = PaymentService();
      final orderId = 'SUB_${promo.id}_${DateTime.now().millisecondsSinceEpoch}';
      
      final paymentUrl = await paymentService.initBackendPayment(
        amount: promo.price,
        orderId: orderId,
        email: user.email ?? 'etudiant@edunet.com',
        firstName: user.displayName?.split(' ').first,
        lastName: user.displayName?.split(' ').last,
      );

      // Fermer le loading
      if (mounted) Navigator.pop(context);

      if (paymentUrl != null) {
        final uri = Uri.parse(paymentUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
             if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Impossible d\'ouvrir le lien de paiement')),
              );
             }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de l\'initialisation du paiement'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading if error
      print('Erreur paiement: $e');
    }
  }
}