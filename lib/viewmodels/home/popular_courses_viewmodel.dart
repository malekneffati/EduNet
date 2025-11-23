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
      final snap = await FirebaseFirestore.instance.collection('courses').get();

      final courseList = <CourseModel>[];

      for (final courseDoc in snap.docs) {
        final courseId = courseDoc.id;
        final courseData = courseDoc.data();

        final reviewsSnap = await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('reviews')
            .get();

        final reviews = reviewsSnap.docs.map((d) => d.data()['rating'] as num).toList();

        final avgRating = reviews.isNotEmpty
            ? (reviews.reduce((a, b) => a + b) / reviews.length).toStringAsFixed(1)
            : '0.0';

        courseList.add(CourseModel(
          id: courseId,
          title: courseData['title'] ?? '',
          description: courseData['description'] ?? '',
          price: (courseData['price'] ?? 0).toDouble(),
          rating: double.parse(avgRating),
          // Add other fields if needed
        ));
      }

      courseList.sort((a, b) => b.rating.compareTo(a.rating));
      _courses = courseList.take(3).toList();
    } catch (err) {
      _error = 'Impossible de charger les cours populaires';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}