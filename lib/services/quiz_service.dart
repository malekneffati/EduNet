import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/course_model.dart';

class QuizService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Récupère le quiz d'un chapitre spécifique
  Future<QuizModel?> getQuizForChapter(String courseId, String chapterId) async {
    try {
      final docSnapshot = await _db.collection('courses').doc(courseId).get();

      if (!docSnapshot.exists) {
        throw Exception("Cours introuvable");
      }

      final data = docSnapshot.data();
      if (data == null || data['chapters'] == null) return null;

      final chapters = (data['chapters'] as List).map((ch) => ChapterModel.fromMap(ch)).toList();
      
      try {
        final chapter = chapters.firstWhere((ch) => ch.id == chapterId);
        return chapter.quiz;
      } catch (e) {
        throw Exception("Chapitre introuvable");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erreur getQuizForChapter: $e");
      }
      rethrow;
    }
  }

  /// Enregistre le résultat d'un quiz pour un utilisateur
  Future<void> saveQuizResult({
    required String userId,
    required String courseId,
    required String chapterId,
    required int score,
    required int totalQuestions,
    required bool passed,
  }) async {
    try {
      final progressRef = _db
          .collection('users')
          .doc(userId)
          .collection('myCourses')
          .doc(courseId);

      final progressSnap = await progressRef.get();
      Map<String, dynamic> progressData = progressSnap.exists ? progressSnap.data()! : {};

      // Initialiser chaptersCompleted si inexistant
      Map<String, dynamic> chaptersCompleted = 
          progressData['chaptersCompleted'] != null 
          ? Map<String, dynamic>.from(progressData['chaptersCompleted'])
          : {};

      // Mettre à jour les données du chapitre
      chaptersCompleted[chapterId] = {
        'completedAt': Timestamp.now(),
        'quizScore': score,
        'quizTotalQuestions': totalQuestions,
        'quizPercentage': ((score / totalQuestions) * 100).round(),
        'passed': passed,
        'lastAttempt': Timestamp.now(),
      };

      // Sauvegarder dans Firestore avec merge: true pour ne pas écraser les autres champs
      await progressRef.set({
        'chaptersCompleted': chaptersCompleted
      }, SetOptions(merge: true));

    } catch (e) {
      if (kDebugMode) {
        print("Erreur saveQuizResult: $e");
      }
      rethrow;
    }
  }

  /// Récupère la progression d'un utilisateur pour un cours
  Future<Map<String, dynamic>> getUserProgress(String userId, String courseId) async {
    try {
      final progressRef = _db
          .collection('users')
          .doc(userId)
          .collection('myCourses')
          .doc(courseId);
          
      final progressSnap = await progressRef.get();

      if (!progressSnap.exists) {
        return {'chaptersCompleted': {}};
      }

      return progressSnap.data()!;
    } catch (e) {
      if (kDebugMode) {
        print("Erreur getUserProgress: $e");
      }
      rethrow;
    }
  }
}
