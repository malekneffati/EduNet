// lib/viewmodels/courses/catalog_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/course_model.dart';

class CatalogViewModel extends ChangeNotifier {
  List<CourseModel> _courses = [];
  bool _loading = false;
  String _error = '';

  List<CourseModel> get courses => _courses;
  bool get loading => _loading;
  String get error => _error;

  Future<void> fetchCourses() async {
    print("📚 [CatalogViewModel] Fetching courses from Firebase...");

    try {
      _loading = true;
      _error = '';
      notifyListeners();

      final querySnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .where('status', isEqualTo: 'active') // Changed from 'published' to 'status'
          .get();

      print("📦 [CatalogViewModel] Received ${querySnapshot.docs.length} documents");

      _courses = querySnapshot.docs.map((doc) {
        final data = doc.data();
        print("📄 [CatalogViewModel] Processing course: ${data['title']}");

        return CourseModel.fromFirestore(data, doc.id);
      }).toList();

      print("✅ [CatalogViewModel] Loaded ${_courses.length} courses");

    } catch (e, stackTrace) {
      _error = 'Erreur lors du chargement des cours: $e';
      print("❌ [CatalogViewModel] Error: $e");
      print("📍 [CatalogViewModel] Stack trace: $stackTrace");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Filter by category
  List<CourseModel> getCoursesByCategory(String category) {
    return _courses.where((c) => c.category == category).toList();
  }

  // Get free courses
  List<CourseModel> getFreeCourses() {
    return _courses.where((c) => c.isFree).toList();
  }

  // Get paid courses
  List<CourseModel> getPaidCourses() {
    return _courses.where((c) => !c.isFree).toList();
  }
}