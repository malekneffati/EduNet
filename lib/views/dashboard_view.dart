import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../components/home/navbar.dart';
import '../components/home/footer.dart';
import '../services/course_service.dart';
import '../models/course_model.dart';
import '../services/payment_service.dart';
import 'dart:async';


class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  bool _isLoading = true;
  String? _userRole;
  String _userName = '';
  int _enrolledCourses = 0;
  int _completedCourses = 0;
  double _averageProgress = 0.0;
  List<CourseModel> _myCourses = [];
  List<CourseModel> _recommendedCourses = [];
  StreamSubscription? _coursesSubscription;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _loadData();
  }

  @override
  void dispose() {
    _coursesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      if (mounted) context.go('/login');
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final role = userDoc.data()?['role'] ?? 'student';
        final name = userDoc.data()?['name'] ?? 'Étudiant';
        
        if (mounted) {
          if (role == 'admin') {
            context.go('/admin');
          } else {
            setState(() {
              _userRole = role;
              _userName = name;
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print('Erreur: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (mounted) setState(() => _isLoading = true);
      
      try {
        final courseService = CourseService();
        final paymentService = PaymentService();
        
        // 1. Get IDs of enrolled courses
        final enrolledIds = await paymentService.getEnrolledCourseIds(user.uid);

        // 2. Cancel previous subscription if any
        _coursesSubscription?.cancel();

        // 3. Listen to courses and filter
        _coursesSubscription = courseService.getCourses().listen((courses) {
           if (mounted) {
             setState(() {
               if (courses.isNotEmpty) {
                 _myCourses = courses.where((c) => enrolledIds.contains(c.id)).toList();
                 _recommendedCourses = courses.where((c) => !enrolledIds.contains(c.id)).toList();
                 
                 _enrolledCourses = _myCourses.length;
               } else {
                  _myCourses = [];
                  _recommendedCourses = [];
               }
               _isLoading = false;
             });
           }
        });
      } catch (e) {
        print('Error loading courses: $e');
         if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
          children: [
            const Navbar(),
            _buildDashboardContent(context, isMobile),
            const Footer(),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 48,
        vertical: 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Bienvenue, $_userName !',
            style: TextStyle(
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Continuez votre parcours d\'apprentissage',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Stats Cards
          _buildStatsCards(isMobile),
          const SizedBox(height: 32),

          // Cours en cours
          _buildSectionTitle('Mes cours en cours', isMobile),
          const SizedBox(height: 16),
          _buildContinueLearning(isMobile),
          const SizedBox(height: 32),

          // Cours recommandés
          _buildSectionTitle('Cours recommandés', isMobile),
          const SizedBox(height: 16),
          _buildRecommendedCourses(isMobile),
        ],
      ),
    );
  }

  Widget _buildStatsCards(bool isMobile) {
    return GridView.count(
      crossAxisCount: isMobile ? 1 : 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: isMobile ? 4 : 1.8,
      children: [
        _buildStatCard(
          'Cours inscrits',
          _enrolledCourses.toString(),
          Icons.book_outlined,
          const Color(0xFF4F46E5),
        ),
        _buildStatCard(
          'Cours complétés',
          _completedCourses.toString(),
          Icons.check_circle_outline,
          const Color(0xFF10B981),
        ),
        _buildStatCard(
          'Progression moyenne',
          '${_averageProgress.toInt()}%',
          Icons.trending_up,
          const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        TextButton(
          onPressed: () => context.go('/catalog'),
          child: const Text('Voir tout →'),
        ),
      ],
    );
  }

  Widget _buildContinueLearning(bool isMobile) {
    if (_myCourses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("Aucun cours inscrit pour le moment."),
      );
    }

    if (isMobile) {
      return Column(
        children: _myCourses.map((course) => _buildCourseCardVertical(course)).toList(),
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemCount: _myCourses.length,
        itemBuilder: (context, index) => _buildCourseCard(_myCourses[index]),
      );
    }
  }

  Widget _buildCourseCard(CourseModel course) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/course/${course.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4F46E5),
                    const Color(0xFF7C3AED),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Center(
                child: Icon(Icons.code, size: 48, color: Colors.white),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.instructor,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    // Progress bar (Simulated)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progression',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const Text(
                              '0%', // Waiting for real progress implementation
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const LinearProgressIndicator(
                          value: 0, 
                          backgroundColor: Color(0xFFEEEEEE),
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCardVertical(CourseModel course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/course/${course.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4F46E5),
                      const Color(0xFF7C3AED),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.code, size: 32, color: Colors.white),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.instructor,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    const LinearProgressIndicator(
                      value: 0,
                      backgroundColor: Color(0xFFEEEEEE),
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '0% complété',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF4F46E5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedCourses(bool isMobile) {
    if (_recommendedCourses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("Plus de cours bientôt disponibles !"),
      );
    }

    if (isMobile) {
      return Column(
        children: _recommendedCourses.map((course) => _buildRecommendedCardMobile(course)).toList(),
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
        ),
        itemCount: _recommendedCourses.length,
        itemBuilder: (context, index) => _buildRecommendedCard(_recommendedCourses[index]),
      );
    }
  }

  Widget _buildRecommendedCard(CourseModel course) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/course/${course.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.purple[700]!],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Center(
                child: Icon(Icons.school, size: 48, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.instructor,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      const Text(
                        '4.5', // Placeholder
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${course.price} TND)',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.isFree ? 'Gratuit' : '${course.price} TND',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedCardMobile(CourseModel course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/course/${course.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[700]!, Colors.purple[700]!],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.school, size: 28, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.star, size: 12, color: Colors.amber),
                        SizedBox(width: 2),
                        Text('4.5', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.isFree ? 'Gratuit' : '${course.price} TND',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}