import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
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



  // Initialise Payment via Node.js Backend
  Future<String?> initBackendPayment({
    required double amount,
    required String orderId,
    required String email,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    // 10.0.2.2 pour l'émulateur Android accédant au localhost du PC
    const String backendUrl = 'http://10.0.2.2:10000/createPayment';
    
    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'note': 'Paiement EduNet $orderId',
          'firstName': firstName ?? 'Etudiant',
          'lastName': lastName ?? 'EduNet',
          'email': email,
          'phone': phone ?? '00000000',
          'orderId': orderId,
          'returnUrl': 'edunet://payment/success',
          'cancelUrl': 'edunet://payment/cancel',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['payment_url']; // Retourne l'URL de paiement Paymee
      } else {
        print("Erreur Backend Paymee: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Erreur connexion Backend: $e");
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

  // Check access using Web logic + Subscription + Legacy Payments
  Future<bool> hasAccess(String userId, String? courseId) async {
    try {
      // 1. Check active subscription
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final sub = userData['subscription'];
        final endDate = userData['subscriptionEndDate'] as Timestamp?;
        
        if (sub == 'premium' && endDate != null && endDate.toDate().isAfter(DateTime.now())) {
          return true;
        }

        // Check array/map in user doc (Web Logic Legacy/Fallback)
        if (courseId != null) {
           final coursesBought = List<dynamic>.from(userData['coursesBought'] ?? []);
           if (coursesBought.contains(courseId)) return true;

           // Check myCourses map field if exists
           final myCoursesMap = userData['myCourses']; 
           if (myCoursesMap is Map && myCoursesMap.containsKey(courseId)) return true;
        }
      }

      if (courseId != null) {
        // 2. Check subcollection 'myCourses' (Standard Web Logic)
        final subDoc = await _firestore.collection('users').doc(userId).collection('myCourses').doc(courseId).get();
        if (subDoc.exists) return true;

        // 3. Fallback to 'payments' collection
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

  // Grant access (Enrollment)
  Future<void> grantAccess(String userId, String courseId) async {
    try {
       // Add to subcollection
       await _firestore.collection('users').doc(userId).collection('myCourses').doc(courseId).set({
         'enrolledAt': FieldValue.serverTimestamp(),
         'progress': 0,
         'lastAccessed': FieldValue.serverTimestamp(),
       });

       // Add to array for redundancy/legacy
       await _firestore.collection('users').doc(userId).update({
         'coursesBought': FieldValue.arrayUnion([courseId])
       });
    } catch (e) {
      print("[PaymentService] Error granting access: $e");
      // If doc doesn't exist, create it ? Usually exists for authenticated user.
    }
  }

  // Get all enrolled course IDs
  Future<List<String>> getEnrolledCourseIds(String userId) async {
    final Set<String> courseIds = {};

    try {
      // 1. From 'coursesBought' array and 'myCourses' map logic
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null) {
           if (data['coursesBought'] != null) {
              courseIds.addAll(List<String>.from(data['coursesBought']));
           }
           // Check myCourses map keys if it exists as a Map (Legacy)
           if (data['myCourses'] is Map) {
              courseIds.addAll((data['myCourses'] as Map).keys.cast<String>());
           }
        }
      }

      // 2. From 'myCourses' subcollection (Standard Web)
      final subCol = await _firestore.collection('users').doc(userId).collection('myCourses').get();
      courseIds.addAll(subCol.docs.map((d) => d.id));

      // 3. Fallback from payments collection
      final payments = await _firestore.collection('payments')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'completed')
        .get();
      
      for (var doc in payments.docs) {
        if (doc.data()['itemId'] != null) {
           courseIds.add(doc.data()['itemId'] as String);
        }
      }

    } catch (e) {
      print('Error fetching enrolled courses: $e');
    }

    return courseIds.toList();
  }

  // Admin: Get all payments
  Stream<List<PaymentModel>> getAllPayments() {
    return _firestore.collection('payments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }
}
