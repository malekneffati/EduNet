// lib/views/catalog_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/home/navbar.dart';
import '../components/home/footer.dart';
import '../viewmodels/courses/catalog_viewmodel.dart';
import '../components/catalog/course_card.dart';

class CatalogView extends StatefulWidget {
  const CatalogView({super.key});

  @override
  State<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<CatalogView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        print("🔥 [CATALOG] Creating CatalogViewModel and fetching courses...");
        final viewModel = CatalogViewModel();
        viewModel.fetchCourses();
        return viewModel;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Navbar(),
              _buildCatalogContent(),
              const Footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCatalogContent() {
    return Consumer<CatalogViewModel>(
      builder: (context, viewModel, child) {
        print("📊 [CATALOG] Building content - loading: ${viewModel.loading}, courses: ${viewModel.courses.length}, error: ${viewModel.error}");

        return Container(
          constraints: const BoxConstraints(minHeight: 400),
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width > 768 ? 48 : 16,
            vertical: 48,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Catalogue de Cours',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 8),

              if (!viewModel.loading)
                Text(
                  '${viewModel.courses.length} cours disponibles',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),

              const SizedBox(height: 32),

              // Loading State
              if (viewModel.loading)
                const SizedBox(
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Chargement des cours...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                )

              // Error State
              else if (viewModel.error.isNotEmpty)
                SizedBox(
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          viewModel.error,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            print("🔄 [CATALOG] Retry button clicked");
                            viewModel.fetchCourses();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )

              // Empty State
              else if (viewModel.courses.isEmpty)
                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucun cours disponible pour le moment',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )

                // Course Grid
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxisCount = width > 1200
                          ? 3
                          : width > 768
                          ? 2
                          : 1;

                      print("📐 [CATALOG] Grid width: $width, columns: $crossAxisCount");

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          childAspectRatio: 0.75,
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
        );
      },
    );
  }
}