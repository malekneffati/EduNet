import 'package:flutter/material.dart';
import '../../../models/course_model.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizResults extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final int percentage;
  final bool passed;
  final int passingScore;
  final List<QuestionModel> questions;
  final Map<String, int> selectedAnswers;
  final VoidCallback onRetry;
  final VoidCallback onBackToCourse;

  const QuizResults({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.passed,
    required this.passingScore,
    required this.questions,
    required this.selectedAnswers,
    required this.onRetry,
    required this.onBackToCourse,
  });

  @override
  State<QuizResults> createState() => _QuizResultsState();
}

class _QuizResultsState extends State<QuizResults> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Icon & Title
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: widget.passed ? Colors.green.shade50 : Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.passed ? Icons.emoji_events : Icons.refresh,
              size: 48,
              color: widget.passed ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.passed ? "Félicitations !" : "Continuez vos efforts !",
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: widget.passed ? Colors.green.shade800 : Colors.orange.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.passed 
              ? "Vous avez réussi le quiz avec succès !" 
              : "Vous n'avez pas atteint le score de passage de ${widget.passingScore}%",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          // Score Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.indigo.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  "${widget.percentage}%",
                  style: GoogleFonts.inter(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${widget.score} sur ${widget.totalQuestions} bonnes réponses",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Toggle Details
          OutlinedButton.icon(
            onPressed: () => setState(() => _showDetails = !_showDetails),
            icon: Icon(_showDetails ? Icons.expand_less : Icons.expand_more),
            label: Text(_showDetails ? "Masquer les détails" : "Voir réponses détaillées"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),

          if (_showDetails) ...[
            const SizedBox(height: 24),
            ...List.generate(widget.questions.length, (index) {
              final question = widget.questions[index];
              final userAnswer = widget.selectedAnswers[question.id];
              final isCorrect = userAnswer == question.correctAnswer;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                  border: Border.all(
                    color: isCorrect ? Colors.green.shade200 : Colors.red.shade200,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color: isCorrect ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Q${index + 1}: ${question.question}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("Votre réponse: ${question.options[userAnswer ?? 0]}"),
                    if (!isCorrect)
                      Text(
                        "Bonne réponse: ${question.options[question.correctAnswer]}",
                        style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                      ),
                    if (question.explanation != null)
                       Padding(
                         padding: const EdgeInsets.only(top: 8),
                         child: Text(
                           "💡 ${question.explanation}",
                           style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade700),
                         ),
                       ),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 32),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBackToCourse,
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text("Retour au cours"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onRetry,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue.shade600,
                  ),
                  child: const Text("Refaire le quiz", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
