import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/course_model.dart';
import '../../services/course_service.dart';

class CourseFormViewModel extends ChangeNotifier {
  final CourseService _courseService;

  // Form controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController instructorController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String _selectedCategory = 'Développement';
  bool _isFree = false;
  File? _pdfFile;
  File? _videoFile;
  String? _pdfFileName;
  String? _videoFileName;
  bool _isLoading = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  CourseModel? _editingCourse;
  
  // Chapters
  final List<ChapterFormState> _chapters = [];

  CourseFormViewModel(this._courseService);

  String get selectedCategory => _selectedCategory;
  bool get isFree => _isFree;
  File? get pdfFile => _pdfFile;
  File? get videoFile => _videoFile;
  String? get pdfFileName => _pdfFileName;
  String? get videoFileName => _videoFileName;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  CourseModel? get editingCourse => _editingCourse;
  List<ChapterFormState> get chapters => _chapters;

  final List<String> categories = [
    'Développement',
    'Marketing',
    'Design',
    'Business',
    'Finance',
    'Langues',
  ];

  // Set category
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Toggle free course
  void toggleFree(bool value) {
    _isFree = value;
    if (value) {
      priceController.text = '0';
    }
    notifyListeners();
  }

  // Pick PDF file
  Future<void> pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        _pdfFile = File(result.files.single.path!);
        _pdfFileName = result.files.single.name;
        notifyListeners();
      }
    } catch (e) {
      print('Error picking PDF: $e');
    }
  }

  // Pick video file
  Future<void> pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
      );

      if (result != null && result.files.single.path != null) {
        _videoFile = File(result.files.single.path!);
        _videoFileName = result.files.single.name;
        notifyListeners();
      }
    } catch (e) {
      print('Error picking video: $e');
    }
  }

  // Remove PDF
  void removePDF() {
    _pdfFile = null;
    _pdfFileName = null;
    notifyListeners();
  }

  // Remove video
  void removeVideo() {
    _videoFile = null;
    _videoFileName = null;
    notifyListeners();
  }
  
  // --- Chapter Methods ---
  
  void addChapter() {
    _chapters.add(ChapterFormState(
      title: '',
      description: '',
    ));
    notifyListeners();
  }
  
  void removeChapter(int index) {
    if (_chapters.length > 0) {
        _chapters[index].dispose();
        _chapters.removeAt(index);
        notifyListeners();
    }
  }
  
  Future<void> pickChapterPDF(int index) async {
      try {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['pdf'],
          );
    
          if (result != null && result.files.single.path != null) {
            _chapters[index].pdfFile = File(result.files.single.path!);
            _chapters[index].pdfFileName = result.files.single.name;
            notifyListeners();
          }
        } catch (e) {
          print('Error picking chapter PDF: $e');
        }
  }
  
  Future<void> pickChapterVideo(int index) async {
       try {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.video,
          );
    
          if (result != null && result.files.single.path != null) {
            _chapters[index].videoFile = File(result.files.single.path!);
            _chapters[index].videoFileName = result.files.single.name;
            notifyListeners();
          }
        } catch (e) {
          print('Error picking chapter Video: $e');
        }
  }
  
  void removeChapterPDF(int index) {
      _chapters[index].pdfFile = null;
      _chapters[index].pdfFileName = null;
      _chapters[index].pdfUrl = null;
      notifyListeners();
  }
  
   void removeChapterVideo(int index) {
      _chapters[index].videoFile = null;
      _chapters[index].videoFileName = null;
      _chapters[index].videoUrl = null;
      notifyListeners();
  }

  // Load course for editing
  Future<void> loadCourse(String courseId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final course = await _courseService.getCourseById(courseId);
      if (course != null) {
        _editingCourse = course;
        titleController.text = course.title;
        descriptionController.text = course.description;
        instructorController.text = course.instructor;
        durationController.text = course.duration;
        priceController.text = course.price.toString();
        _selectedCategory = course.category;
        _isFree = course.isFree;
        _pdfFileName = course.pdfUrl?.split('/').last;
        _videoFileName = course.videoUrl?.split('/').last;
        
        // Load chapters
        if (course.chapters != null) {
          _chapters.clear();
          for (var chapter in course.chapters!) {
            _chapters.add(ChapterFormState(
              title: chapter.title,
              description: chapter.description,
              pdfUrl: chapter.pdfUrl,
              videoUrl: chapter.videoUrl,
            ));
          }
        } else {
             // Initialize with one empty chapter if none
             if (_chapters.isEmpty) addChapter();
        }
      }
    } catch (e) {
      print('Error loading course: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Validate form
  bool validateForm() {
    if (titleController.text.trim().isEmpty) {
      return false;
    }
    if (descriptionController.text.trim().isEmpty) {
      return false;
    }
    if (instructorController.text.trim().isEmpty) {
      return false;
    }
    if (durationController.text.trim().isEmpty) {
      return false;
    }
    if (!_isFree && priceController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  // Save course
  Future<bool> saveCourse() async {
    if (!validateForm()) {
      return false;
    }

    _isLoading = true;
    _isUploading = true;
    notifyListeners();

    try {
      String? pdfUrl = _editingCourse?.pdfUrl;
      String? videoUrl = _editingCourse?.videoUrl;

      // Generate temporary ID for uploads if creating new course
      final tempId = _editingCourse?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

      // Upload PDF if selected
      if (_pdfFile != null) {
        _uploadProgress = 0.3;
        notifyListeners();
        pdfUrl = await _courseService.uploadPDF(_pdfFile!, tempId);
      }

      // Upload video if selected
      if (_videoFile != null) {
        _uploadProgress = 0.6;
        notifyListeners();
        videoUrl = await _courseService.uploadVideo(_videoFile!, tempId);
      }

      _uploadProgress = 0.9;
      notifyListeners();

        // Upload chapter files
        List<ChapterModel> savedChapters = [];
        for (int i = 0; i < _chapters.length; i++) {
            var chapterState = _chapters[i];
            
            // Upload PDF if new file selected
            if (chapterState.pdfFile != null) {
                chapterState.pdfUrl = await _courseService.uploadPDF(chapterState.pdfFile!, '${tempId}_ch$i');
            }
            
            // Upload Video if new file selected
            if (chapterState.videoFile != null) {
                chapterState.videoUrl = await _courseService.uploadVideo(chapterState.videoFile!, '${tempId}_ch$i');
            }
            
            savedChapters.add(ChapterModel(
                id: 'ch_$i', // Generate real ID if needed
                title: chapterState.titleController.text.trim(),
                description: chapterState.descriptionController.text.trim(),
                pdfUrl: chapterState.pdfUrl,
                videoUrl: chapterState.videoUrl,
            ));
        }

        // Create course object
      final course = CourseModel(
        id: _editingCourse?.id ?? '',
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        category: _selectedCategory,
        price: _isFree ? 0 : double.tryParse(priceController.text) ?? 0,
        isFree: _isFree,
        instructor: instructorController.text.trim(),
        duration: durationController.text.trim(),
        status: 'active',
        videoUrl: videoUrl,
        pdfUrl: pdfUrl,
        chapters: savedChapters,
        createdAt: _editingCourse?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      bool success;
      if (_editingCourse != null) {
        success = await _courseService.updateCourse(_editingCourse!.id, course);
      } else {
        final courseId = await _courseService.createCourse(course);
        success = courseId != null;
      }

      _uploadProgress = 1.0;
      notifyListeners();

      return success;
    } catch (e) {
      print('Error saving course: $e');
      return false;
    } finally {
      _isLoading = false;
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
    }
  }

  // Reset form
  void resetForm() {
    titleController.clear();
    descriptionController.clear();
    instructorController.clear();
    durationController.clear();
    priceController.clear();
    _selectedCategory = 'Développement';
    _isFree = false;
    _pdfFile = null;
    _videoFile = null;
    _pdfFileName = null;
    _videoFileName = null;
    _editingCourse = null;
    for (var ch in _chapters) ch.dispose();
    _chapters.clear();
    addChapter(); // Reset to one empty chapter
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    instructorController.dispose();
    durationController.dispose();
    priceController.dispose();
    for (var ch in _chapters) ch.dispose();
    super.dispose();
  }
}

final courseFormProvider = ChangeNotifierProvider.autoDispose<CourseFormViewModel>((ref) {
  final courseService = ref.watch(courseServiceProvider);
  return CourseFormViewModel(courseService);
});

// Provider for course service (reuse from course_management_viewmodel)
final courseServiceProvider = Provider<CourseService>((ref) {
  return CourseService();
});

class ChapterFormState {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  File? pdfFile;
  String? pdfFileName;
  String? pdfUrl;
  File? videoFile;
  String? videoFileName;
  String? videoUrl;

  ChapterFormState({
    required String title,
    required String description,
    this.pdfUrl,
    this.videoUrl,
  }) : titleController = TextEditingController(text: title),
       descriptionController = TextEditingController(text: description) {
    if (pdfUrl != null) pdfFileName = pdfUrl!.split('/').last;
    if (videoUrl != null) videoFileName = videoUrl!.split('/').last;
  }

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
  }
}
