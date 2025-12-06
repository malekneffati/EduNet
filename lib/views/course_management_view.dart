import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../components/admin/admin_header.dart';
import '../components/admin/admin_sidebar.dart';
import '../viewmodels/admin/admin_sidebar_viewmodel.dart';
import '../viewmodels/admin/course_management_viewmodel.dart';

class CourseManagementView extends ConsumerStatefulWidget {
  const CourseManagementView({super.key});

  @override
  ConsumerState<CourseManagementView> createState() => _CourseManagementViewState();
}

class _CourseManagementViewState extends ConsumerState<CourseManagementView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(courseManagementProvider).loadCourses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(courseManagementProvider);
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
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        if (isMobile)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Gestion des cours',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.push('/admin/courses/add');
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Ajouter un cours'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Gestion des cours',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.push('/admin/courses/add');
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Ajouter un cours'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 24),

                        // Search Bar
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Rechercher un cours...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          onChanged: (value) {
                            viewModel.searchCourses(value);
                          },
                        ),

                        const SizedBox(height: 24),

                        // Courses Table
                        Expanded(
                          child: viewModel.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : viewModel.courses.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.school_outlined,
                                            size: 64,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Aucun cours trouvé',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : isMobile
                                      ? ListView.builder(
                                          itemCount: viewModel.courses.length,
                                          itemBuilder: (context, index) {
                                            final course = viewModel.courses[index];
                                            return Card(
                                              margin: const EdgeInsets.only(bottom: 8),
                                              elevation: 1,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: ListTile(
                                                contentPadding: const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 8,
                                                ),
                                                title: Text(
                                                  course.title,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                subtitle: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 4),
                                                    Text(course.category),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      course.price > 0
                                                          ? '${course.price.toStringAsFixed(2)} TND'
                                                          : 'Gratuit',
                                                      style: const TextStyle(
                                                        color: Color(0xFF10B981),
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                trailing: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.edit, size: 20),
                                                      onPressed: () {
                                                        context.push('/admin/courses/edit/${course.id}');
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                                      onPressed: () => _showDeleteDialog(
                                                          context, course.id, course.title),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : Card(
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                        children: [
                                          // Table Header
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(12),
                                                topRight: Radius.circular(12),
                                              ),
                                            ),
                                            child: const Row(
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    'Titre',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    'Catégorie',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'Prix',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    'Créé le',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    'Actions',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Table Body
                                          Expanded(
                                            child: ListView.builder(
                                              itemCount: viewModel.courses.length,
                                              itemBuilder: (context, index) {
                                                final course = viewModel.courses[index];
                                                return Container(
                                                  padding: const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        color: Colors.grey[200]!,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 3,
                                                        child: Text(
                                                          course.title,
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text(course.category),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Text(
                                                          course.isFree
                                                              ? 'Gratuit'
                                                              : '${course.price.toStringAsFixed(0)} TND',
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                          course.createdAt != null
                                                              ? DateFormat('dd/MM/yyyy')
                                                                  .format(course.createdAt!)
                                                              : '-',
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.center,
                                                          children: [
                                                            TextButton(
                                                              onPressed: () {
                                                                context.push(
                                                                  '/admin/courses/edit/${course.id}',
                                                                );
                                                              },
                                                              child: const Text('Modifier'),
                                                            ),
                                                            const SizedBox(width: 8),
                                                            TextButton(
                                                              onPressed: () {
                                                                _showDeleteDialog(
                                                                  context,
                                                                  course.id,
                                                                  course.title,
                                                                );
                                                              },
                                                              style: TextButton.styleFrom(
                                                                foregroundColor: Colors.red,
                                                              ),
                                                              child: const Text('Supprimer'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                        ),
                      ],
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

  void _showDeleteDialog(BuildContext context, String courseId, String courseTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le cours "$courseTitle" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success =
                  await ref.read(courseManagementProvider).deleteCourse(courseId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Cours supprimé avec succès'
                          : 'Erreur lors de la suppression',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
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
