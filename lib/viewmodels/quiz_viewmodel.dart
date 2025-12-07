import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/course_model.dart';
import '../services/quiz_service.dart';

enum QuizState { loading, error, intro, questions, results }

class QuizViewModel extends ChangeNotifier {
  final QuizService _quizService = QuizService();
  final String courseId;
  final String chapterId;

  QuizModel? _quiz;
  QuizModel? get quiz => _quiz;

  QuizState _state = QuizState.loading;
  QuizState get state => _state;

  String? _error;
  String? get error => _error;

  int _currentQuestionIndex = 0;
  int get currentQuestionIndex => _currentQuestionIndex;

  Map<String, int> _selectedAnswers = {};
  Map<String, int> get selectedAnswers => _selectedAnswers;

  int _score = 0;
  int get score => _score;
  
  bool _passed = false;
  bool get passed => _passed;

  bool _submitting = false;
  bool get submitting => _submitting;

  QuizViewModel({required this.courseId, required this.chapterId}) {
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      _state = QuizState.loading;
      notifyListeners();

      final quizData = await _quizService.getQuizForChapter(courseId, chapterId);

      if (quizData == null || quizData.questions.isEmpty) {
        _error = "Aucun quiz disponible pour ce chapitre";
        _state = QuizState.error;
      } else {
        _quiz = quizData;
        _state = QuizState.intro;
      }
    } catch (e) {
      _error = e.toString();
      _state = QuizState.error;
    } finally {
      notifyListeners();
    }
  }

  void startQuiz() {
    _currentQuestionIndex = 0;
    _selectedAnswers = {};
    _score = 0;
    _state = QuizState.questions;
    notifyListeners();
  }

  void selectAnswer(String questionId, int answerIndex) {
    _selectedAnswers[questionId] = answerIndex;
    notifyListeners();
  }

  void nextQuestion() {
    if (_quiz != null && _currentQuestionIndex < _quiz!.questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  Future<void> submitQuiz(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vous devez être connecté pour soumettre le quiz")),
      );
      return;
    }

    // Vérifier réponses manquantes
    final unansweredCount = _quiz!.questions.where((q) => !_selectedAnswers.containsKey(q.id)).length;
    if (unansweredCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez répondre à toutes les questions ($unansweredCount restantes)")),
      );
      return;
    }

    _submitting = true;
    notifyListeners();

    try {
      // Calcul du score
      int correctAnswers = 0;
      for (var question in _quiz!.questions) {
        if (_selectedAnswers[question.id] == question.correctAnswer) {
          correctAnswers++;
        }
      }

      _score = correctAnswers;
      final totalQuestions = _quiz!.questions.length;
      final percentage = (_score / totalQuestions) * 100;
      _passed = percentage >= _quiz!.passingScore;

      // Sauvegarde
      await _quizService.saveQuizResult(
        userId: user.uid,
        courseId: courseId,
        chapterId: chapterId,
        score: _score,
        totalQuestions: totalQuestions,
        passed: _passed,
      );

      _state = QuizState.results;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la soumission: $e")),
      );
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  void retryQuiz() {
    startQuiz();
  }

  QuestionModel? get currentQuestion => 
      _quiz != null && _quiz!.questions.isNotEmpty 
      ? _quiz!.questions[_currentQuestionIndex] 
      : null;
      
  int get totalQuestions => _quiz?.questions.length ?? 0;
  
  int get percentage => 
      totalQuestions > 0 ? ((_score / totalQuestions) * 100).round() : 0;
}
