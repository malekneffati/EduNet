import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/course_model.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get all courses
  Stream<List<CourseModel>> getCourses() {
    return _firestore.collection('courses').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CourseModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Get course by ID
  Future<CourseModel?> getCourseById(String id) async {
    try {
      final doc = await _firestore.collection('courses').doc(id).get();
      if (doc.exists) {
        return CourseModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting course: $e');
      return null;
    }
  }

  // Create course
  Future<String?> createCourse(CourseModel course) async {
    try {
      final docRef = await _firestore.collection('courses').add(course.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating course: $e');
      return null;
    }
  }

  // Update course
  Future<bool> updateCourse(String id, CourseModel course) async {
    try {
      await _firestore.collection('courses').doc(id).update(course.toMap());
      return true;
    } catch (e) {
      print('Error updating course: $e');
      return false;
    }
  }

  // Delete course
  Future<bool> deleteCourse(String id) async {
    try {
      await _firestore.collection('courses').doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting course: $e');
      return false;
    }
  }

  // Upload PDF
  Future<String?> uploadPDF(File file, String courseId) async {
    try {
      final ref = _storage.ref().child('courses/$courseId/document.pdf');
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading PDF: $e');
      return null;
    }
  }

  // Upload Video
  Future<String?> uploadVideo(File file, String courseId) async {
    try {
      final ref = _storage.ref().child('courses/$courseId/video.mp4');
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading video: $e');
      return null;
    }
  }

  // Search courses
  Future<List<CourseModel>> searchCourses(String query) async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return snapshot.docs
          .map((doc) => CourseModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error searching courses: $e');
      return [];
    }
  }

  // Get courses by category
  Future<List<CourseModel>> getCoursesByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .where('category', isEqualTo: category)
          .get();

      return snapshot.docs
          .map((doc) => CourseModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting courses by category: $e');
      return [];
    }
  }
}
