import '../exercise/unified_exercise.dart';

class Course {
  final String id;
  final String name;
  final List<UnifiedExercise> exercises;

  const Course({
    required this.id,
    required this.name,
    required this.exercises,
  });
}
