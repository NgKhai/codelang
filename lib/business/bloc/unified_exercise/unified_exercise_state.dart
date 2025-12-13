import 'package:equatable/equatable.dart';
import '../../../data/models/exercise/unified_exercise.dart';
import '../../../data/models/exercise/reorder_exercise.dart';

enum UnifiedExerciseStatus {
  initial,
  loading,
  loaded,
  checking,
  correct,
  incorrect,
  completed
}

enum FeedbackType {
  initial,
  info,
  warning,
  error,
  success
}

class UnifiedExerciseState extends Equatable {
  final UnifiedExerciseStatus status;
  final List<UnifiedExercise> exercises;
  final int currentIndex;
  final String feedbackMessage;
  final FeedbackType feedbackType;

  // For Reorder exercises
  final List<WordBlock> availableWords;
  final List<WordBlock?> currentSentence;

  // For Multiple Choice exercises
  final int? selectedOptionIndex;

  // For Fill in the Blank exercises
  final String userAnswer;

  const UnifiedExerciseState({
    this.status = UnifiedExerciseStatus.initial,
    this.exercises = const [],
    this.currentIndex = 0,
    this.feedbackMessage = '',
    this.feedbackType = FeedbackType.initial,
    this.availableWords = const [],
    this.currentSentence = const [],
    this.selectedOptionIndex,
    this.userAnswer = '',
  });

  UnifiedExercise? get currentExercise {
    if (exercises.isEmpty || currentIndex >= exercises.length) return null;
    return exercises[currentIndex];
  }

  bool get isLastExercise => currentIndex >= exercises.length - 1;

  bool get allSlotsFilled => currentSentence.every((word) => word != null);

  UnifiedExerciseState copyWith({
    UnifiedExerciseStatus? status,
    List<UnifiedExercise>? exercises,
    int? currentIndex,
    String? feedbackMessage,
    FeedbackType? feedbackType,
    List<WordBlock>? availableWords,
    List<WordBlock?>? currentSentence,
    int? selectedOptionIndex,
    bool clearSelectedOption = false,
    String? userAnswer,
  }) {
    return UnifiedExerciseState(
      status: status ?? this.status,
      exercises: exercises ?? this.exercises,
      currentIndex: currentIndex ?? this.currentIndex,
      feedbackMessage: feedbackMessage ?? this.feedbackMessage,
      feedbackType: feedbackType ?? this.feedbackType,
      availableWords: availableWords ?? this.availableWords,
      currentSentence: currentSentence ?? this.currentSentence,
      selectedOptionIndex: clearSelectedOption ? null : (selectedOptionIndex ?? this.selectedOptionIndex),
      userAnswer: userAnswer ?? this.userAnswer,
    );
  }

  @override
  List<Object?> get props => [
    status,
    exercises,
    currentIndex,
    feedbackMessage,
    feedbackType,
    availableWords,
    currentSentence,
    selectedOptionIndex,
    userAnswer,
  ];
}