import 'reorder_exercise.dart';
import 'multiple_choice_exercise.dart';
import 'fill_blank_exercise.dart';

enum ExerciseType {
  reorder,
  multipleChoice,
  fillBlank,
}

class UnifiedExercise {
  final String id;
  final ExerciseType type;
  final ReorderExercise? reorderExercise;
  final MultipleChoiceExercise? multipleChoiceExercise;
  final FillBlankExercise? fillBlankExercise;

  const UnifiedExercise({
    required this.id,
    required this.type,
    this.reorderExercise,
    this.multipleChoiceExercise,
    this.fillBlankExercise,
  });

  // Factory constructors for each type
  factory UnifiedExercise.reorder({
    required String id,
    required ReorderExercise exercise,
  }) {
    return UnifiedExercise(
      id: id,
      type: ExerciseType.reorder,
      reorderExercise: exercise,
    );
  }

  factory UnifiedExercise.multipleChoice({
    required String id,
    required MultipleChoiceExercise exercise,
  }) {
    return UnifiedExercise(
      id: id,
      type: ExerciseType.multipleChoice,
      multipleChoiceExercise: exercise,
    );
  }

  factory UnifiedExercise.fillBlank({
    required String id,
    required FillBlankExercise exercise,
  }) {
    return UnifiedExercise(
      id: id,
      type: ExerciseType.fillBlank,
      fillBlankExercise: exercise,
    );
  }

  String getTypeName() {
    switch (type) {
      case ExerciseType.reorder:
        return 'Sentence Reorder';
      case ExerciseType.multipleChoice:
        return 'Multiple Choice';
      case ExerciseType.fillBlank:
        return 'Fill in the Blank';
    }
  }
}