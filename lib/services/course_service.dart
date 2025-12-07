import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';
import '../models/review_model.dart';


class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Cloudinary Config - A REMPLIR
  static const String cloudName = 'VOTRE_CLOUD_NAME'; 
  static const String uploadPreset = 'VOTRE_UPLOAD_PRESET'; 


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

  // Utils: Upload to Cloudinary
  Future<String?> _uploadToCloudinary(File file, String resourceType) async {
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);
        return jsonMap['secure_url'];
      } else {
        final responseData = await response.stream.toBytes();
        print('Cloudinary Error: ${response.statusCode} - ${String.fromCharCodes(responseData)}');
        return null;
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  // Upload PDF (uses Cloudinary 'raw' or 'image' depending on config, here 'auto' or 'raw')
  Future<String?> uploadPDF(File file, String courseId) async {
    // Note: resourceType 'raw' is often used for generic files like PDF, or 'image' if you want preview.
    // Let's try 'auto' or 'raw'.
    return await _uploadToCloudinary(file, 'raw'); 
  }

  // Upload Video
  Future<String?> uploadVideo(File file, String courseId) async {
    return await _uploadToCloudinary(file, 'video');
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

  // Get Reviews
  Stream<List<ReviewModel>> getReviews(String courseId) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Add Review
  Future<void> addReview(String courseId, ReviewModel review) async {
    try {
      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('reviews')
          .add(review.toMap());
    } catch (e) {
      print('Error adding review: $e');
      rethrow;
    }
  }
}
