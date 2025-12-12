import '../models/exercise/multiple_choice_exercise.dart';
import 'mongo_service.dart';

class MultipleChoiceService {
  static final MongoService _mongoService = MongoService.instance;

  static Future<List<MultipleChoiceExercise>> getExercises() async {
    final data = await _mongoService.fetchMultipleChoiceExercises();
    return data.map((json) => MultipleChoiceExercise.fromJson(json)).toList();
  }

  static Future<List<MultipleChoiceExercise>> getExercisesByType(String practiceType) async {
    final data = await _mongoService.fetchMultipleChoiceByType(practiceType);
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