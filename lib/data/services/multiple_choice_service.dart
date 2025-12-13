// lib/data/services/multiple_choice_service.dart
// Updated to use REST API instead of direct MongoDB

import '../models/exercise/multiple_choice_exercise.dart';
import 'api_service.dart';

class MultipleChoiceService {
  static final ApiService _apiService = ApiService.instance;

  static Future<List<MultipleChoiceExercise>> getExercises() async {
    final data = await _apiService.fetchMultipleChoiceExercises();
    return data.map((json) => MultipleChoiceExercise.fromJson(json)).toList();
  }

  static Future<List<MultipleChoiceExercise>> getExercisesByType(String practiceType) async {
    final data = await _apiService.fetchMultipleChoiceByType(practiceType);
    return data.map((json) => MultipleChoiceExercise.fromJson(json)).toList();
  }

  static bool checkAnswer({
    required int selectedIndex,
    required int correctIndex,
  }) {
    return selectedIndex == correctIndex;
  }

  static List<OptionChoice> getOptionsWithIndices(List<String> options) {
    return options
        .asMap()
        .entries
        .map((entry) => OptionChoice(
      index: entry.key,
      text: entry.value,
    ))
        .toList();
  }
}