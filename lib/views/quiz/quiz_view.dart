import 'package:flutter/material.dart';
import '../../viewmodels/quiz_viewmodel.dart';
import 'components/quiz_question_card.dart';
import 'components/quiz_results.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizView extends StatefulWidget {
  final String courseId;
  final String chapterId;

  const QuizView({
    super.key,
    required this.courseId,
    required this.chapterId,
  });

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  late QuizViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = QuizViewModel(
      courseId: widget.courseId,
      chapterId: widget.chapterId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        if (_viewModel.state == QuizState.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_viewModel.state == QuizState.error) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      "Erreur",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _viewModel.error ?? "Une erreur inconnue est survenue",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Retour"),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (_viewModel.state == QuizState.intro) {
          return _buildIntro();
        }

        if (_viewModel.state == QuizState.results) {
          return Scaffold(
            body: SafeArea(
              child: QuizResults(
                score: _viewModel.score,
                totalQuestions: _viewModel.quiz!.questions.length,
                percentage: _viewModel.percentage,
                passed: _viewModel.passed,
                passingScore: _viewModel.quiz!.passingScore,
                questions: _viewModel.quiz!.questions,
                selectedAnswers: _viewModel.selectedAnswers,
                onRetry: _viewModel.retryQuiz,
                onBackToCourse: () => Navigator.pop(context),
              ),
            ),
          );
        }

        // QuizState.questions
        return _buildQuestionScreen();
      },
    );
  }

  Widget _buildIntro() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CloseButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.assignment_turned_in, size: 64, color: Colors.blue),
            ),
            const SizedBox(height: 32),
            Text(
              "Quiz du chapitre",
              style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Testez vos connaissances sur ce chapitre. Prenez votre temps, il n'y a pas de limite.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildInfoRow(Icons.help_outline, "${_viewModel.quiz!.questions.length} Questions"),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.check_circle_outline, "Score requis : ${_viewModel.quiz!.passingScore}%"),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _viewModel.startQuiz,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                child: const Text("Commencer le quiz", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildQuestionScreen() {
    final question = _viewModel.currentQuestion!;
    final total = _viewModel.quiz!.questions.length;
    final index = _viewModel.currentQuestionIndex;

    return Scaffold(
      appBar: AppBar(
        title: Text("Question ${index + 1} / $total"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Quitter"),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (index + 1) / total,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: QuizQuestionCard(
              question: question,
              selectedAnswerIndex: _viewModel.selectedAnswers[question.id],
              onSelectAnswer: (ans) => _viewModel.selectAnswer(question.id, ans),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous Button
                TextButton(
                  onPressed: index > 0 ? _viewModel.previousQuestion : null,
                  child: const Text("Précédent"),
                ),

                // Next / Submit Button
                if (index < total - 1)
                  ElevatedButton(
                    onPressed: _viewModel.nextQuestion,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Suivant"),
                  )
                else
                  ElevatedButton(
                    onPressed: _viewModel.submitting ? null : () => _viewModel.submitQuiz(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _viewModel.submitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Soumettre"),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
