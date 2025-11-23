// lib/components/home/popular_courses.dart
// CORRIGÉ : lib/components/home/popular_courses.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:edunet/viewmodels/home/popular_courses_viewmodel.dart';
// AJOUTER cet import :
import 'package:edunet/models/course_model.dart';
// REMPLACER cette ligne :
// import 'package:edunet/components/catalog/course_card.dart';
// PAR (si course_card n'existe pas encore) :
import 'package:edunet/components/catalog/course_card.dart';
class PopularCourses extends StatelessWidget {
  const PopularCourses({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PopularCoursesViewModel(),
      child: Consumer<PopularCoursesViewModel>(
        builder: (context, viewModel, child) {
          return Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 64),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1280),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(
                    'Cours populaires',
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Découvrez les cours les mieux notés par nos apprenants',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4B5563),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  if (viewModel.loading)
                    const Center(child: Text('Chargement des cours...'))
                  else if (viewModel.error != null)
                    Center(
                      child: Text(
                        viewModel.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        bool isMobile = constraints.maxWidth < 768;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isMobile ? 1 : 3,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 32,
                            mainAxisSpacing: 32,
                          ),
                          itemCount: viewModel.courses.length,
                          itemBuilder: (context, index) {
                            final course = viewModel.courses[index];
                            return CourseCard(course: course);
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}