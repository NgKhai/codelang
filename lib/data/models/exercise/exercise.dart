import 'unified_exercise.dart';

class Exercise {
  final String id;
  final String name;
  final List<UnifiedExercise> exercises;

  const Exercise({
    required this.id,
    required this.name,
    required this.exercises,
  });

  // // Optional: Add a toJson method for serialization
  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'name': name,
  //     'exercises': exercises.map((e) => e.toJson()).toList(),
  //   };
  // }
}