import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/course_model.dart';
import '../../services/course_service.dart';

class CourseManagementViewModel extends ChangeNotifier {
  final CourseService _courseService;

  List<CourseModel> _courses = [];
  List<CourseModel> _filteredCourses = [];
  bool _isLoading = false;
  String _searchQuery = '';

  CourseManagementViewModel(this._courseService);

  List<CourseModel> get courses => _filteredCourses;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  // Load all courses
  Future<void> loadCourses() async {
    _isLoading = true;
    notifyListeners();

    try {
      // For now, we'll use a stream subscription
      _courseService.getCourses().listen((courseList) {
        _courses = courseList;
        _filteredCourses = courseList;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      print('Error loading courses: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search courses
  void searchCourses(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredCourses = _courses;
    } else {
      _filteredCourses = _courses
          .where((course) =>
              course.title.toLowerCase().contains(query.toLowerCase()) ||
              course.category.toLowerCase().contains(query.toLowerCase()) ||
              course.instructor.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // Delete course
  Future<bool> deleteCourse(String courseId) async {
    try {
      final success = await _courseService.deleteCourse(courseId);
      if (success) {
        _courses.removeWhere((course) => course.id == courseId);
        _filteredCourses.removeWhere((course) => course.id == courseId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error deleting course: $e');
      return false;
    }
  }

  // Refresh courses
  Future<void> refreshCourses() async {
    await loadCourses();
  }
}

final courseServiceProvider = Provider<CourseService>((ref) {
  return CourseService();
});

final courseManagementProvider =
    ChangeNotifierProvider<CourseManagementViewModel>((ref) {
  final courseService = ref.watch(courseServiceProvider);
  return CourseManagementViewModel(courseService);
});
