// lib/data/services/unified_exercise_service.dart
// Updated to use REST API instead of direct MongoDB

import 'dart:math';
import '../models/course/course.dart';
import '../models/exercise/unified_exercise.dart';
import '../models/exercise/reorder_exercise.dart';
import '../models/exercise/multiple_choice_exercise.dart';
import '../models/exercise/fill_blank_exercise.dart';
import 'api_service.dart';

class UnifiedExerciseService {
  static final ApiService _apiService = ApiService.instance;

  // Get all courses for the home screen
  static Future<List<Course>> getAllCourses() async {
    final coursesData = await _apiService.fetchAllCourses();
    final List<Course> courses = [];

    for (final courseData in coursesData) {
      final exercises = parseExercises(courseData['exercises'] as List);
      courses.add(Course(
        id: courseData['id'] as String,
        name: courseData['name'] as String,
        exercises: exercises,
      ));
    }

    return courses;
  }

  // Helper to parse exercises from API response or stored JSON
  // Made public for offline course parsing
  static List<UnifiedExercise> parseExercises(List exercisesData) {
    final List<UnifiedExercise> exercises = [];
    
    for (final exerciseData in exercisesData) {
      final type = exerciseData['type']?.toString() ?? '';
      final id = exerciseData['id']?.toString() ?? '';
      final data = Map<String, dynamic>.from((exerciseData['data'] as Map?) ?? {});
      
      switch (type) {
        case 'reorder':
          exercises.add(UnifiedExercise.reorder(
            id: id,
            exercise: ReorderExercise.fromJson(data),
          ));
          break;
        case 'multiple_choice':
          exercises.add(UnifiedExercise.multipleChoice(
            id: id,
            exercise: MultipleChoiceExercise.fromJson(data),
          ));
          break;
        case 'fill_blank':
          exercises.add(UnifiedExercise.fillBlank(
            id: id,
            exercise: FillBlankExercise.fromJson(data),
          ));
          break;
      }
    }
    
    return exercises;
  }

  // Helper to serialize exercises for offline storage
  static List<Map<String, dynamic>> serializeExercises(List<UnifiedExercise> exercises) {
    return exercises.map((e) {
      String typeStr = '';
      Map<String, dynamic> data = {};

      switch (e.type) {
        case ExerciseType.reorder:
          typeStr = 'reorder';
          if (e.reorderExercise != null) {
            data = {
              'prompt': e.reorderExercise!.prompt,
              'sourceSentence': e.reorderExercise!.sourceSentence,
              'correctOrder': e.reorderExercise!.correctOrder,
              'practiceType': e.reorderExercise!.practiceType,
            };
          }
          break;
        case ExerciseType.multipleChoice:
          typeStr = 'multiple_choice';
          if (e.multipleChoiceExercise != null) {
            data = {
              'prompt': e.multipleChoiceExercise!.prompt,
              'sentence': e.multipleChoiceExercise!.sentence,
              'blankWord': e.multipleChoiceExercise!.blankWord,
              'blankPosition': e.multipleChoiceExercise!.blankPosition,
              'options': e.multipleChoiceExercise!.options,
              'correctOptionIndex': e.multipleChoiceExercise!.correctOptionIndex,
              'imageUrl': e.multipleChoiceExercise!.imageUrl,
              'definition': e.multipleChoiceExercise!.definition,
              'practiceType': e.multipleChoiceExercise!.practiceType,
            };
          }
          break;
        case ExerciseType.fillBlank:
          typeStr = 'fill_blank';
          if (e.fillBlankExercise != null) {
            data = {
              'prompt': e.fillBlankExercise!.prompt,
              'sentence': e.fillBlankExercise!.sentence,
              'correctAnswer': e.fillBlankExercise!.correctAnswer,
              'blankPosition': e.fillBlankExercise!.blankPosition,
              'imageUrl': e.fillBlankExercise!.imageUrl,
              'definition': e.fillBlankExercise!.definition,
              'wordType': e.fillBlankExercise!.wordType,
              'hint': e.fillBlankExercise!.hint,
              'acceptableAnswers': e.fillBlankExercise!.acceptableAnswers,
            };
          }
          break;
      }

      return {
        'id': e.id,
        'type': typeStr,
        'data': data,
      };
    }).toList();
  }

  // Get exercises for a specific exercise set
  static Future<List<UnifiedExercise>> getExercisesBySetId(String setId) async {
    final setData = await _apiService.fetchExerciseSetById(setId);
    if (setData == null) {
      throw Exception('Exercise set not found: $setId');
    }
    return parseExercises(setData['exercises'] as List);
  }

  // Get random exercises
  static Future<List<UnifiedExercise>> getRandomExercises({int count = 10}) async {
    final exercisesData = await _apiService.fetchRandomExercises(count: count);
    return parseExercises(exercisesData);
  }

  // Get all available exercises from all types (for random practice)
  static Future<List<UnifiedExercise>> getAllExercises() async {
    final allExercises = <UnifiedExercise>[];

    // Fetch all exercise types in parallel
    final results = await Future.wait([
      _apiService.fetchReorderExercises(),
      _apiService.fetchMultipleChoiceExercises(),
      _apiService.fetchFillBlankExercises(),
    ]);

    final reorderData = results[0];
    final mcData = results[1];
    final fbData = results[2];

    // Add Reorder exercises
    for (int i = 0; i < reorderData.length; i++) {
      allExercises.add(UnifiedExercise.reorder(
        id: 'reorder_$i',
        exercise: ReorderExercise.fromJson(reorderData[i]),
      ));
    }

    // Add Multiple Choice exercises
    for (int i = 0; i < mcData.length; i++) {
      allExercises.add(UnifiedExercise.multipleChoice(
        id: 'multiple_choice_$i',
        exercise: MultipleChoiceExercise.fromJson(mcData[i]),
      ));
    }

    // Add Fill in the Blank exercises
    for (int i = 0; i < fbData.length; i++) {
      allExercises.add(UnifiedExercise.fillBlank(
        id: 'fill_blank_$i',
        exercise: FillBlankExercise.fromJson(fbData[i]),
      ));
    }

    return allExercises;
  }
}