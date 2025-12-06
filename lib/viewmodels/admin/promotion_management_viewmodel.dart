import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/promotion_model.dart';

class PromotionManagementViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<PromotionModel> _promotions = [];
  bool _isLoading = false;
  String? _error;

  List<PromotionModel> get promotions => _promotions;
  List<PromotionModel> get activePromotions =>
      _promotions.where((p) => p.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPromotions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('promotions')
          .orderBy('createdAt', descending: true)
          .get();

      _promotions = snapshot.docs
          .map((doc) => PromotionModel.fromFirestore(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des promotions: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPromotion(PromotionModel promotion) async {
    try {
      await _firestore.collection('promotions').add(promotion.toFirestore());
      await loadPromotions();
      return true;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePromotion(PromotionModel promotion) async {
    try {
      await _firestore
          .collection('promotions')
          .doc(promotion.id)
          .update(promotion.toFirestore());
      await loadPromotions();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePromotion(String id) async {
    try {
      await _firestore.collection('promotions').doc(id).delete();
      _promotions.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleActive(String id) async {
    try {
      final promotion = _promotions.firstWhere((p) => p.id == id);
      await updatePromotion(promotion.copyWith(isActive: !promotion.isActive));
      return true;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour: $e';
      notifyListeners();
      return false;
    }
  }
}

final promotionManagementProvider =
    ChangeNotifierProvider<PromotionManagementViewModel>((ref) {
  return PromotionManagementViewModel();
});
