import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/course_model.dart';
import '../../../services/quiz_service.dart';
import '../quiz_view.dart';

class QuizCard extends StatefulWidget {
  final String courseId;
  final ChapterModel chapter;

  const QuizCard({
    super.key,
    required this.courseId,
    required this.chapter,
  });

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  final QuizService _quizService = QuizService();
  Map<String, dynamic>? _progress;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    // Vérifier si le chapitre a un quiz valide
    if (user == null || widget.chapter.quiz == null || widget.chapter.quiz!.questions.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final userProgress = await _quizService.getUserProgress(user.uid, widget.courseId);
      final chapterProgress = userProgress['chaptersCompleted']?[widget.chapter.id];
      
      if (mounted) {
        setState(() {
          _progress = chapterProgress != null ? Map<String, dynamic>.from(chapterProgress) : null;
          _loading = false;
        });
      }
    } catch (e) {
      print("Erreur chargement progression quiz: $e");
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startQuiz() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizView(
          courseId: widget.courseId,
          chapterId: widget.chapter.id,
        ),
      ),
    );
    // Recharger la progression au retour
    _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    // Si pas de quiz, on n'affiche rien
    if (widget.chapter.quiz == null || widget.chapter.quiz!.questions.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_loading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
        child: const Center(child: LinearProgressIndicator()),
      );
    }

    final bool hasPassed = _progress?['passed'] ?? false;
    final int? percentage = _progress?['quizPercentage'];

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                "Quiz du chapitre",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              if (_progress != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasPassed ? Colors.green.shade100 : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasPassed ? Icons.check_circle : Icons.warning,
                        size: 16,
                        color: hasPassed ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasPassed ? "Réussi ($percentage%)" : "Dernier score: $percentage%",
                        style: TextStyle(
                          color: hasPassed ? Colors.green.shade800 : Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Testez vos connaissances avec ${widget.chapter.quiz!.questions.length} questions",
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: Text(_progress != null ? "Refaire le quiz" : "Passer le quiz"),
            ),
          ),
        ],
      ),
    );
  }
}
