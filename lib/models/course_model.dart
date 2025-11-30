// lib/models/course_model.dart
class CourseModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final double price;
  final bool isFree;
  final String instructor;
  final String duration;
  final String status;
  final String? videoUrl;
  final String? pdfUrl;
  final List<ChapterModel>? chapters;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.isFree,
    required this.instructor,
    required this.duration,
    required this.status,
    this.videoUrl,
    this.pdfUrl,
    this.chapters,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  // Create from Firestore
  factory CourseModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CourseModel(
      id: id,
      title: data['title'] ?? 'Sans titre',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      isFree: data['isFree'] ?? false,
      instructor: data['instructor'] ?? '',
      duration: data['duration'] ?? '',
      status: data['status'] ?? 'active',
      videoUrl: data['videoUrl'],
      pdfUrl: data['pdfUrl'],
      chapters: data['chapters'] != null
          ? (data['chapters'] as List)
          .map((ch) => ChapterModel.fromMap(ch))
          .toList()
          : null,
      createdBy: data['createdBy'],
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : null,
      updatedAt: data['updatedAt'] != null
          ? DateTime.parse(data['updatedAt'])
          : null,
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'isFree': isFree,
      'instructor': instructor,
      'duration': duration,
      'status': status,
      'videoUrl': videoUrl,
      'pdfUrl': pdfUrl,
      'chapters': chapters?.map((ch) => ch.toMap()).toList(),
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Calculate average rating (you'll need to get from reviews subcollection)
  double get rating => 0.0; // TODO: Calculate from reviews
}

class ChapterModel {
  final String id;
  final String title;
  final String description;
  final String? pdfUrl;
  final String? videoUrl;

  ChapterModel({
    required this.id,
    required this.title,
    required this.description,
    this.pdfUrl,
    this.videoUrl,
  });

  factory ChapterModel.fromMap(Map<String, dynamic> map) {
    return ChapterModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      pdfUrl: map['pdfUrl'],
      videoUrl: map['videoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pdfUrl': pdfUrl,
      'videoUrl': videoUrl,
    };
  }
}