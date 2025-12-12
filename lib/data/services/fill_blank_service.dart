import '../models/exercise/fill_blank_exercise.dart';
import 'mongo_service.dart';

class FillBlankService {
  static final MongoService _mongoService = MongoService.instance;

  static Future<List<FillBlankExercise>> getExercises() async {
    final data = await _mongoService.fetchFillBlankExercises();
    return data.map((json) => FillBlankExercise.fromJson(json)).toList();
  }

  static bool checkAnswer({
    required String userAnswer,
    required FillBlankExercise exercise,
  }) {
    return exercise.isCorrect(userAnswer);
  }
}