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
  final QuizModel? quiz;

  ChapterModel({
    required this.id,
    required this.title,
    required this.description,
    this.pdfUrl,
    this.videoUrl,
    this.quiz,
  });

  factory ChapterModel.fromMap(Map<String, dynamic> map) {
    return ChapterModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      pdfUrl: map['pdfUrl'],
      videoUrl: map['videoUrl'],
      quiz: map['quiz'] != null ? QuizModel.fromMap(map['quiz']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pdfUrl': pdfUrl,
      'videoUrl': videoUrl,
      'quiz': quiz?.toMap(),
    };
  }
}

class QuizModel {
  final int passingScore;
  final List<QuestionModel> questions;

  QuizModel({
    required this.passingScore,
    required this.questions,
  });

  factory QuizModel.fromMap(Map<String, dynamic> map) {
    return QuizModel(
      passingScore: map['passingScore'] ?? 60,
      questions: map['questions'] != null
          ? (map['questions'] as List)
              .map((q) => QuestionModel.fromMap(q))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'passingScore': passingScore,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }
}

class QuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;

  QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswer: map['correctAnswer'] ?? 0,
      explanation: map['explanation'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }
}