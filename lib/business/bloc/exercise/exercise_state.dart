import 'package:equatable/equatable.dart';

import '../../../data/models/exercise.dart';

enum ExerciseStatus { initial, loading, loaded, checking, correct, incorrect, completed }

enum FeedbackType { initial, info, warning, error, success }

class ExerciseState extends Equatable {
  final ExerciseStatus status;
  final List<ReorderExercise> exercises;
  final int currentIndex;
  final List<WordBlock> availableWords;
  final List<WordBlock?> currentSentence;
  final String feedbackMessage;
  final FeedbackType feedbackType;

  const ExerciseState({
    this.status = ExerciseStatus.initial,
    this.exercises = const [],
    this.currentIndex = 0,
    this.availableWords = const [],
    this.currentSentence = const [],
    this.feedbackMessage = 'Drag and drop words to form the sentence.',
    this.feedbackType = FeedbackType.initial,
  });

  ReorderExercise? get currentExercise {
    if (exercises.isEmpty || currentIndex >= exercises.length) return null;
    return exercises[currentIndex];
  }

  bool get isLastExercise => currentIndex >= exercises.length - 1;

  bool get allSlotsEmpty => currentSentence.every((word) => word == null);

  bool get allSlotsFilled => currentSentence.every((word) => word != null);

  ExerciseState copyWith({
    ExerciseStatus? status,
    List<ReorderExercise>? exercises,
    int? currentIndex,
    List<WordBlock>? availableWords,
    List<WordBlock?>? currentSentence,
    String? feedbackMessage,
    FeedbackType? feedbackType,
  }) {
    return ExerciseState(
      status: status ?? this.status,
      exercises: exercises ?? this.exercises,
      currentIndex: currentIndex ?? this.currentIndex,
      availableWords: availableWords ?? this.availableWords,
      currentSentence: currentSentence ?? this.currentSentence,
      feedbackMessage: feedbackMessage ?? this.feedbackMessage,
      feedbackType: feedbackType ?? this.feedbackType,
    );
  }

  @override
  List<Object?> get props => [
    status,
    exercises,
    currentIndex,
    availableWords,
    currentSentence,
    feedbackMessage,
    feedbackType,
  ];
}