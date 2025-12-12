// lib/services/exercise_service.dart

import '../models/exercise/reorder_exercise.dart';
import 'mongo_service.dart';

class ExerciseService {
  static final MongoService _mongoService = MongoService.instance;

  // Fetch exercises from MongoDB
  static Future<List<ReorderExercise>> getExercises() async {
    final data = await _mongoService.fetchReorderExercises();
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
