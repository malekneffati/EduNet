import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../components/admin/admin_header.dart';
import '../components/admin/admin_sidebar.dart';
import '../viewmodels/admin/admin_sidebar_viewmodel.dart';
import '../viewmodels/admin/course_form_viewmodel.dart';

class CourseFormView extends ConsumerStatefulWidget {
  final String? courseId;

  const CourseFormView({super.key, this.courseId});

  @override
  ConsumerState<CourseFormView> createState() => _CourseFormViewState();
}

class _CourseFormViewState extends ConsumerState<CourseFormView> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.courseId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(courseFormProvider).loadCourse(widget.courseId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(courseFormProvider);
    final sidebarViewModel = ref.watch(adminSidebarProvider);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return Scaffold(
      drawer: isMobile
          ? Drawer(
              child: AdminSidebar(
                selectedIndex: 1, // Cours
                onItemSelected: (index) {
                  sidebarViewModel.selectItem(index);
                  Navigator.pop(context);
                },
              ),
            )
          : null,
      body: Row(
        children: [
          // Sidebar (Desktop only)
          if (!isMobile)
            AdminSidebar(
              selectedIndex: 1, // Cours
              onItemSelected: (index) {
                sidebarViewModel.selectItem(index);
              },
            ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                AdminHeader(isMobile: isMobile),

                // Content
                Expanded(
                  child: viewModel.isLoading && widget.courseId != null
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                // Header
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back),
                                      onPressed: () => context.pop(),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.courseId != null
                                          ? 'Modifier le cours'
                                          : 'Ajouter un cours',
                                      style: const TextStyle(
                                        fontSize: 24, // Légèrement réduit pour mobile
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 32),

                                // Course Title
                                const Text(
                                  'Titre du cours *',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: viewModel.titleController,
                                  decoration: InputDecoration(
                                    hintText: 'Ex: Développement Web Complet',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Le titre est requis';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 24),

                                // Description
                                const Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: viewModel.descriptionController,
                                  maxLines: 6,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Décrivez le contenu du cours...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'La description est requise';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 24),

                                // Category and Instructor Row
                                Row(
                                  children: [
                                    // Category
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Catégorie',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          DropdownButtonFormField<String>(
                                            value: viewModel.selectedCategory,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                            items: viewModel.categories
                                                .map((category) =>
                                                    DropdownMenuItem(
                                                      value: category,
                                                      child: Text(category),
                                                    ))
                                                .toList(),
                                            onChanged: (value) {
                                              if (value != null) {
                                                viewModel.setCategory(value);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 16),

                                    // Instructor
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Instructeur',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            controller:
                                                viewModel.instructorController,
                                            decoration: InputDecoration(
                                              hintText: 'Ex: Malek Neffati',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.trim().isEmpty) {
                                                return 'L\'instructeur est requis';
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Duration
                                const Text(
                                  'Durée',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: viewModel.durationController,
                                  decoration: InputDecoration(
                                    hintText: 'Ex: 12h',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'La durée est requise';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 24),

                                // Free Course Checkbox
                                Row(
                                  children: [
                                    Checkbox(
                                      value: viewModel.isFree,
                                      onChanged: (value) {
                                        viewModel.toggleFree(value ?? false);
                                      },
                                    ),
                                    const Text(
                                      'Cours gratuit',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Price
                                if (!viewModel.isFree) ...[
                                  const Text(
                                    'Prix (TND)',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: viewModel.priceController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: 'Ex: 10',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    validator: (value) {
                                      if (!viewModel.isFree &&
                                          (value == null ||
                                              value.trim().isEmpty)) {
                                        return 'Le prix est requis';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                ],

                                // PDF Upload
                                const Text(
                                  'Document PDF',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: viewModel.pickPDF,
                                  child: Container(
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        style: BorderStyle.solid,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey[50],
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.picture_as_pdf,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          viewModel.pdfFileName ??
                                              'Cliquer pour uploader un PDF',
                                          style: TextStyle(
                                            color: viewModel.pdfFileName != null
                                                ? Colors.black
                                                : Colors.grey[600],
                                          ),
                                        ),
                                        if (viewModel.pdfFileName != null) ...[
                                          const SizedBox(height: 8),
                                          TextButton(
                                            onPressed: viewModel.removePDF,
                                            child: const Text('Supprimer'),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Video Upload
                                const Text(
                                  'Vidéo du cours',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: viewModel.pickVideo,
                                  child: Container(
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        style: BorderStyle.solid,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey[50],
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.videocam,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          viewModel.videoFileName ??
                                              'Changer la vidéo',
                                          style: TextStyle(
                                            color:
                                                viewModel.videoFileName != null
                                                    ? Colors.black
                                                    : Colors.grey[600],
                                          ),
                                        ),
                                        if (viewModel.videoFileName != null) ...[
                                          const SizedBox(height: 8),
                                          TextButton(
                                            onPressed: viewModel.removeVideo,
                                            child: const Text('Supprimer'),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Upload Progress
                                if (viewModel.isUploading) ...[
                                  LinearProgressIndicator(
                                    value: viewModel.uploadProgress,
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Action Buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: viewModel.isLoading
                                          ? null
                                          : () {
                                              context.pop();
                                            },
                                      child: const Text('Annuler'),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: viewModel.isLoading
                                          ? null
                                          : () async {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                final success = await viewModel
                                                    .saveCourse();
                                                if (context.mounted) {
                                                  if (success) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Cours enregistré avec succès',
                                                        ),
                                                        backgroundColor:
                                                            Colors.green,
                                                      ),
                                                    );
                                                    context.go(
                                                        '/admin/courses');
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Erreur lors de l\'enregistrement',
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF4F46E5),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: viewModel.isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : const Text('Mettre à jour'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Provider for admin sidebar
final adminSidebarProvider = ChangeNotifierProvider<AdminSidebarViewModel>((ref) {
  return AdminSidebarViewModel();
});
