import 'package:flutter/material.dart';
import '../../../models/course_model.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizQuestionCard extends StatelessWidget {
  final QuestionModel question;
  final int? selectedAnswerIndex;
  final Function(int) onSelectAnswer;

  const QuizQuestionCard({
    super.key,
    required this.question,
    required this.selectedAnswerIndex,
    required this.onSelectAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question
          Text(
            question.question,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 32),

          // Options
          ...List.generate(question.options.length, (index) {
            final isSelected = selectedAnswerIndex == index;
            final optionLabel = String.fromCharCode(65 + index); // A, B, C...

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () => onSelectAnswer(index),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade50 : Colors.white,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade200,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Circle Letter
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey.shade300,
                          ),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          optionLabel,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Text
                      Expanded(
                        child: Text(
                          question.options[index],
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: isSelected ? Colors.blue.shade900 : Colors.black87,
                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: Colors.blue),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
