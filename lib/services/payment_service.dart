import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Créer une demande de paiement
  Future<PaymentModel?> createPayment({
    required String userId,
    required double amount,
    required PaymentItemType itemType,
    required String itemId,
  }) async {
    try {
      final docRef = _firestore.collection('payments').doc();
      
      final payment = PaymentModel(
        id: docRef.id,
        userId: userId,
        amount: amount,
        currency: 'TND',
        status: PaymentStatus.pending,
        itemType: itemType,
        itemId: itemId,
        createdAt: DateTime.now(),
      );

      await docRef.set(payment.toFirestore());
      return payment;
    } catch (e) {
      print("[PaymentService] Error creating payment: $e");
      return null;
    }
  }

  // Simuler le processus de paiement Paymee
  Future<bool> processPayment(String paymentId) async {
    // Dans la réalité, ceci appellerait l'API Paymee ou lancerait la WebView
    // Ici, on simule une réussite après 2 secondes
    try {
      await Future.delayed(const Duration(seconds: 2));
      
      await _firestore.collection('payments').doc(paymentId).update({
        'status': 'completed',
        'paymeeTransactionId': 'SANDBOX_${DateTime.now().millisecondsSinceEpoch}',
        'completedAt': Timestamp.now(),
      });
      
      return true;
    } catch (e) {
      print("[PaymentService] Error processing payment: $e");
      return false;
    }
  }

  // Vérifier si un utilisateur a acheté un cours ou a un abonnement actif
  Future<bool> hasAccess(String userId, String? courseId) async {
    try {
      // 1. Vérifier abonnement premium actif
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final sub = userData['subscription'];
        final endDate = userData['subscriptionEndDate'] as Timestamp?;
        
        if (sub == 'premium' && endDate != null && endDate.toDate().isAfter(DateTime.now())) {
          return true;
        }
      }

      // 2. Si c'est pour un cours spécifique, vérifier l'achat unique
      if (courseId != null) {
        final query = await _firestore.collection('payments')
            .where('userId', isEqualTo: userId)
            .where('itemId', isEqualTo: courseId)
            .where('status', isEqualTo: 'completed')
            .limit(1)
            .get();
            
        if (query.docs.isNotEmpty) {
          return true;
        }
      }

      return false;
    } catch (e) {
      print("[PaymentService] Error checking access: $e");
      return false;
    }
  }
}
