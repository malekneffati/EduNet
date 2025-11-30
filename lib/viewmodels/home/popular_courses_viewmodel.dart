// lib/viewmodels/home/popular_courses_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edunet/models/course_model.dart';

class PopularCoursesViewModel extends ChangeNotifier {
  List<CourseModel> _courses = [];
  bool _loading = true;
  String? _error;

  List<CourseModel> get courses => _courses;
  bool get loading => _loading;
  String? get error => _error;

  PopularCoursesViewModel() {
    loadPopularCourses();
  }

  Future<void> loadPopularCourses() async {
    try {
      print("📚 [PopularCourses] Loading popular courses...");

      final snap = await FirebaseFirestore.instance
          .collection('courses')
          .where('status', isEqualTo: 'active')
          .get();

      final courseList = <CourseModel>[];

      for (final courseDoc in snap.docs) {
        final courseId = courseDoc.id;
        final courseData = courseDoc.data();

        // Try to get reviews for rating calculation
        double avgRating = 0.0;
        try {
          final reviewsSnap = await FirebaseFirestore.instance
              .collection('courses')
              .doc(courseId)
              .collection('reviews')
              .get();

          if (reviewsSnap.docs.isNotEmpty) {
            final reviews = reviewsSnap.docs
                .map((d) => (d.data()['rating'] as num).toDouble())
                .toList();
            avgRating = reviews.reduce((a, b) => a + b) / reviews.length;
          }
        } catch (e) {
          print("⚠️ [PopularCourses] No reviews for course $courseId");
          avgRating = 0.0;
        }

        // Create course model with all required fields
        final course = CourseModel(
          id: courseId,
          title: courseData['title'] ?? '',
          description: courseData['description'] ?? '',
          category: courseData['category'] ?? '',
          price: (courseData['price'] ?? 0).toDouble(),
          isFree: courseData['isFree'] ?? false,
          instructor: courseData['instructor'] ?? '',
          duration: courseData['duration'] ?? '',
          status: courseData['status'] ?? 'active',
          videoUrl: courseData['videoUrl'],
          pdfUrl: courseData['pdfUrl'],
          createdBy: courseData['createdBy'],
          createdAt: courseData['createdAt'] != null
              ? DateTime.parse(courseData['createdAt'])
              : null,
          updatedAt: courseData['updatedAt'] != null
              ? DateTime.parse(courseData['updatedAt'])
              : null,
        );

        courseList.add(course);
      }

      // Sort by rating (you can change this to sort by enrollment count, etc.)
      courseList.sort((a, b) => b.price.compareTo(a.price)); // Temporary sort by price

      _courses = courseList.take(3).toList();

      print("✅ [PopularCourses] Loaded ${_courses.length} popular courses");

    } catch (err) {
      print("❌ [PopularCourses] Error: $err");
      _error = 'Impossible de charger les cours populaires';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}