// lib/services/exercise_service.dart
// Updated to use REST API instead of direct MongoDB

import '../models/exercise/reorder_exercise.dart';
import 'api_service.dart';

class ExerciseService {
  static final ApiService _apiService = ApiService.instance;

  // Fetch exercises from API
  static Future<List<ReorderExercise>> getExercises() async {
    final data = await _apiService.fetchReorderExercises();
    return data.map((json) => ReorderExercise.fromJson(json)).toList();
  }

  static List<WordBlock> shuffleWords(List<String> words) {
    final wordBlocks = words.asMap().entries.map((entry) {
      return WordBlock(id: entry.key.toString(), text: entry.value);
    }).toList();

    wordBlocks.shuffle();
    return wordBlocks;
  }

  static bool checkAnswer({
    required List<WordBlock?> userAnswer,
    required List<String> correctAnswer,
  }) {
    if (userAnswer.contains(null)) {
      return false;
    }

    final userWords = userAnswer.map((w) => w!.text).toList();

    if (userWords.length != correctAnswer.length) {
      return false;
    }

    for (int i = 0; i < userWords.length; i++) {
      if (userWords[i] != correctAnswer[i]) {
        return false;
      }
    }

    return true;
  }
}
