// lib/data/services/fill_blank_service.dart
// Updated to use REST API instead of direct MongoDB

import '../models/exercise/fill_blank_exercise.dart';
import 'api_service.dart';

class FillBlankService {
  static final ApiService _apiService = ApiService.instance;

  static Future<List<FillBlankExercise>> getExercises() async {
    final data = await _apiService.fetchFillBlankExercises();
    return data.map((json) => FillBlankExercise.fromJson(json)).toList();
  }

  static bool checkAnswer({
    required String userAnswer,
    required FillBlankExercise exercise,
  }) {
    return exercise.isCorrect(userAnswer);
  }
}