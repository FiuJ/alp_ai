import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import '../services/classifier_service.dart';
import '../services/gemini_service.dart';
import '../models/trash_record.dart';

class HomeViewModel extends ChangeNotifier {
  final _classifier = ClassifierService();
  final _gemini = GeminiService();
  final _picker = ImagePicker();
  
  // 1. Variable to store the image for the preview in HomeScreen
  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  // 2. Changed isLoading to isProcessing to match your HomeScreen
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  TrashRecord? _currentResult;
  
  // 3. Getters for category and recommendation for the UI
  String? get classificationResult => _currentResult?.category;
  String? get geminiRecommendation => _currentResult?.recommendations;

  // 4. Renamed method to pickAndProcessImage to match your HomeScreen
  Future<void> pickAndProcessImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    // Set the image so the UI can show the preview
    _selectedImage = File(pickedFile.path);
    _isProcessing = true;
    notifyListeners();

    try {
      // Run AI Classification
      final category = await _classifier.classifyImage(_selectedImage!);
      
      // Get Gemini Recommendations
      final recommendations = await _gemini.getRecyclingSteps(category);

      _currentResult = TrashRecord(
        category: category,
        recommendations: recommendations,
        timestamp: DateTime.now(),
        imagePath: pickedFile.path,
      );

      // Save to Hive (Make sure 'history' box is opened in main.dart)
      final box = Hive.box<TrashRecord>('history');
      await box.add(_currentResult!);
      
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}