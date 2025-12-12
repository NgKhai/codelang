import 'dart:math';
import '../models/course/course.dart';
import '../models/exercise/unified_exercise.dart';
import '../models/exercise/reorder_exercise.dart';
import '../models/exercise/multiple_choice_exercise.dart';
import '../models/exercise/fill_blank_exercise.dart';
import 'mongo_service.dart';

class UnifiedExerciseService {
  static final MongoService _mongoService = MongoService.instance;

  // Get all courses for the home screen
  static Future<List<Course>> getAllCourses() async {
    final setsData = await _mongoService.fetchExerciseSets();
    final List<Course> courses = [];

    for (final setData in setsData) {
      final exercises = await _getExercisesForSet(setData);
      courses.add(Course(
        id: setData['setId'] as String,
        name: setData['name'] as String,
        exercises: exercises,
      ));
    }

    return courses;
  }

  // Helper to build exercises for a set
  static Future<List<UnifiedExercise>> _getExercisesForSet(Map<String, dynamic> setData) async {
    final exerciseRefs = setData['exercises'] as List;
    final List<UnifiedExercise> exercises = [];

    // Pre-fetch all exercise types
    final reorderData = await _mongoService.fetchReorderExercises();
    final mcData = await _mongoService.fetchMultipleChoiceExercises();
    final fbData = await _mongoService.fetchFillBlankExercises();

    for (int i = 0; i < exerciseRefs.length; i++) {
      final ref = exerciseRefs[i] as Map<String, dynamic>;
      final type = ref['type'] as String;
      final index = ref['index'] as int;

      switch (type) {
        case 'reorder':
          if (index < reorderData.length) {
            exercises.add(UnifiedExercise.reorder(
              id: '${setData['setId']}_reorder_$i',
              exercise: ReorderExercise.fromJson(reorderData[index]),
            ));
          }
          break;
        case 'multiple_choice':
          if (index < mcData.length) {
            exercises.add(UnifiedExercise.multipleChoice(
              id: '${setData['setId']}_mc_$i',
              exercise: MultipleChoiceExercise.fromJson(mcData[index]),
            ));
          }
          break;
        case 'fill_blank':
          if (index < fbData.length) {
            exercises.add(UnifiedExercise.fillBlank(
              id: '${setData['setId']}_fb_$i',
              exercise: FillBlankExercise.fromJson(fbData[index]),
            ));
          }
          break;
      }
    }

    return exercises;
  }

  // Get exercises for a specific exercise set
  static Future<List<UnifiedExercise>> getExercisesBySetId(String setId) async {
    final setData = await _mongoService.fetchExerciseSetById(setId);
    if (setData == null) {
      throw Exception('Exercise set not found: $setId');
    }
    return _getExercisesForSet(setData);
  }

  // Get all available exercises from all types (for random practice)
  static Future<List<UnifiedExercise>> getAllExercises() async {
    final allExercises = <UnifiedExercise>[];

    // Add Reorder exercises
    final reorderData = await _mongoService.fetchReorderExercises();
    for (int i = 0; i < reorderData.length; i++) {
      allExercises.add(UnifiedExercise.reorder(
        id: 'reorder_$i',
        exercise: ReorderExercise.fromJson(reorderData[i]),
      ));
    }

    // Add Multiple Choice exercises
    final mcData = await _mongoService.fetchMultipleChoiceExercises();
    for (int i = 0; i < mcData.length; i++) {
      allExercises.add(UnifiedExercise.multipleChoice(
        id: 'multiple_choice_$i',
        exercise: MultipleChoiceExercise.fromJson(mcData[i]),
      ));
    }

    // Add Fill in the Blank exercises
    final fbData = await _mongoService.fetchFillBlankExercises();
    for (int i = 0; i < fbData.length; i++) {
      allExercises.add(UnifiedExercise.fillBlank(
        id: 'fill_blank_$i',
        exercise: FillBlankExercise.fromJson(fbData[i]),
      ));
    }

    return allExercises;
  }

  // Get random exercises
  static Future<List<UnifiedExercise>> getRandomExercises({int count = 10}) async {
    final allExercises = await getAllExercises();

    if (allExercises.length <= count) {
      allExercises.shuffle(Random());
      return allExercises;
    }

    allExercises.shuffle(Random());
    return allExercises.take(count).toList();
  }
}