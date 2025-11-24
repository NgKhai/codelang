// lib/business/bloc/unified_exercise/unified_exercise_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/exercise/reorder_exercise.dart';
import '../../../data/models/exercise/unified_exercise.dart';
import '../../../data/services/unified_exercise_service.dart';
import '../../../data/services/exercise_service.dart';
import '../../../data/services/multiple_choice_service.dart';
import '../../../data/services/fill_blank_service.dart';
import '../shared/feedback_type.dart';
import 'unified_exercise_event.dart';
import 'unified_exercise_state.dart';

class UnifiedExerciseBloc extends Bloc<UnifiedExerciseEvent, UnifiedExerciseState> {
  UnifiedExerciseBloc() : super(const UnifiedExerciseState()) {
    on<LoadUnifiedExercises>(_onLoadExercises);
    on<CheckAnswer>(_onCheckAnswer);
    on<NextExercise>(_onNextExercise);
    on<ResetCurrentExercise>(_onResetExercise);

    // Reorder events
    on<PlaceWordInSlot>(_onPlaceWordInSlot);
    on<ReorderWordsInSlot>(_onReorderWordsInSlot);
    on<TapWord>(_onTapWord);
    on<ReturnWordToBank>(_onReturnWordToBank);

    // Multiple Choice events
    on<SelectOption>(_onSelectOption);

    // Fill Blank events
    on<UpdateAnswer>(_onUpdateAnswer);
    on<ShowAnswer>(_onShowAnswer);
  }

  void _onLoadExercises(LoadUnifiedExercises event, Emitter<UnifiedExerciseState> emit) {
    emit(state.copyWith(status: UnifiedExerciseStatus.loading));

    // Get exercises either by set ID or random
    final exercises = event.exerciseSetId != null && event.exerciseSetId != 'random'
        ? UnifiedExerciseService.getExercisesBySetId(event.exerciseSetId!)
        : UnifiedExerciseService.getRandomExercises(count: event.count);

    if (exercises.isEmpty) {
      emit(state.copyWith(
        status: UnifiedExerciseStatus.loaded,
        feedbackMessage: 'No exercises available.',
        feedbackType: FeedbackType.error,
      ));
      return;
    }

    _loadExerciseAtIndex(0, exercises, emit);
  }

  void _loadExerciseAtIndex(int index, List<UnifiedExercise> exercises, Emitter<UnifiedExerciseState> emit) {
    final exercise = exercises[index];

    switch (exercise.type) {
      case ExerciseType.reorder:
        _loadReorderExercise(exercise, exercises, index, emit);
        break;
      case ExerciseType.multipleChoice:
        _loadMultipleChoiceExercise(exercise, exercises, index, emit);
        break;
      case ExerciseType.fillBlank:
        _loadFillBlankExercise(exercise, exercises, index, emit);
        break;
    }
  }

  void _loadReorderExercise(UnifiedExercise exercise, List<UnifiedExercise> exercises, int index, Emitter<UnifiedExerciseState> emit) {
    final reorderEx = exercise.reorderExercise!;
    final shuffledWords = ExerciseService.shuffleWords(reorderEx.correctOrder);
    final emptySlots = List<WordBlock?>.filled(reorderEx.correctOrder.length, null);

    emit(state.copyWith(
      status: UnifiedExerciseStatus.loaded,
      exercises: exercises,
      currentIndex: index,
      availableWords: shuffledWords,
      currentSentence: emptySlots,
      selectedOptionIndex: null,
      userAnswer: '',
      feedbackMessage: 'Tap or drag words to build the translation.',
      feedbackType: FeedbackType.initial,
    ));
  }

  void _loadMultipleChoiceExercise(UnifiedExercise exercise, List<UnifiedExercise> exercises, int index, Emitter<UnifiedExerciseState> emit) {
    emit(state.copyWith(
      status: UnifiedExerciseStatus.loaded,
      exercises: exercises,
      currentIndex: index,
      availableWords: [],
      currentSentence: [],
      clearSelectedOption: true,
      userAnswer: '',
      feedbackMessage: 'Select the correct option.',
      feedbackType: FeedbackType.initial,
    ));
  }

  void _loadFillBlankExercise(UnifiedExercise exercise, List<UnifiedExercise> exercises, int index, Emitter<UnifiedExerciseState> emit) {
    emit(state.copyWith(
      status: UnifiedExerciseStatus.loaded,
      exercises: exercises,
      currentIndex: index,
      availableWords: [],
      currentSentence: [],
      selectedOptionIndex: null,
      userAnswer: '',
      feedbackMessage: 'Type your answer in the text field.',
      feedbackType: FeedbackType.initial,
    ));
  }

  // Reorder exercise handlers
  void _onPlaceWordInSlot(PlaceWordInSlot event, Emitter<UnifiedExerciseState> emit) {
    final updatedAvailable = List<WordBlock>.from(state.availableWords);
    updatedAvailable.removeWhere((w) => w.id == event.word.id);

    final updatedSentence = List<WordBlock?>.from(state.currentSentence);
    final existingWord = updatedSentence[event.targetIndex];
    if (existingWord != null) {
      updatedAvailable.add(existingWord);
      updatedAvailable.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
    }

    updatedSentence[event.targetIndex] = event.word;

    emit(state.copyWith(
      availableWords: updatedAvailable,
      currentSentence: updatedSentence,
      feedbackMessage: 'Keep going! Construct the sentence.',
      feedbackType: FeedbackType.info,
    ));
  }

  void _onReorderWordsInSlot(ReorderWordsInSlot event, Emitter<UnifiedExerciseState> emit) {
    if (event.sourceIndex == event.targetIndex) return;

    final updatedSentence = List<WordBlock?>.from(state.currentSentence);
    final sourceWord = updatedSentence[event.sourceIndex];
    final targetWord = updatedSentence[event.targetIndex];

    if (sourceWord == null) return;

    if (targetWord == null) {
      updatedSentence[event.targetIndex] = sourceWord;
      updatedSentence[event.sourceIndex] = null;
    } else {
      updatedSentence[event.targetIndex] = sourceWord;
      updatedSentence[event.sourceIndex] = targetWord;
    }

    emit(state.copyWith(
      currentSentence: updatedSentence,
      feedbackMessage: 'Words reordered!',
      feedbackType: FeedbackType.success,
    ));
  }

  void _onTapWord(TapWord event, Emitter<UnifiedExerciseState> emit) {
    final firstEmptyIndex = state.currentSentence.indexWhere((w) => w == null);

    if (firstEmptyIndex != -1) {
      add(PlaceWordInSlot(word: event.word, targetIndex: firstEmptyIndex));
    } else {
      emit(state.copyWith(
        feedbackMessage: 'All slots are filled! Tap a word above to remove it first.',
        feedbackType: FeedbackType.warning,
      ));
    }
  }

  void _onReturnWordToBank(ReturnWordToBank event, Emitter<UnifiedExerciseState> emit) {
    final updatedSentence = List<WordBlock?>.from(state.currentSentence);
    final wordToReturn = updatedSentence[event.slotIndex];

    if (wordToReturn == null) return;

    updatedSentence[event.slotIndex] = null;

    final updatedAvailable = List<WordBlock>.from(state.availableWords);
    updatedAvailable.add(wordToReturn);
    updatedAvailable.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));

    emit(state.copyWith(
      currentSentence: updatedSentence,
      availableWords: updatedAvailable,
      feedbackMessage: 'Word returned to the bank.',
      feedbackType: FeedbackType.warning,
    ));
  }

  // Multiple Choice handlers
  void _onSelectOption(SelectOption event, Emitter<UnifiedExerciseState> emit) {
    emit(state.copyWith(
      selectedOptionIndex: event.optionIndex,
      feedbackMessage: 'Option selected. Check your answer!',
      feedbackType: FeedbackType.info,
    ));
  }

  // Fill Blank handlers
  void _onUpdateAnswer(UpdateAnswer event, Emitter<UnifiedExerciseState> emit) {
    emit(state.copyWith(
      userAnswer: event.answer,
      feedbackMessage: 'Type your answer and check when ready.',
      feedbackType: FeedbackType.info,
    ));
  }

  void _onShowAnswer(ShowAnswer event, Emitter<UnifiedExerciseState> emit) {
    final exercise = state.currentExercise?.fillBlankExercise;
    if (exercise == null) return;

    emit(state.copyWith(
      status: UnifiedExerciseStatus.correct,
      feedbackMessage: 'The correct answer is: ${exercise.correctAnswer}',
      feedbackType: FeedbackType.info,
    ));
  }

  // Check Answer handler
  void _onCheckAnswer(CheckAnswer event, Emitter<UnifiedExerciseState> emit) {
    final currentExercise = state.currentExercise;
    if (currentExercise == null) return;

    emit(state.copyWith(status: UnifiedExerciseStatus.checking));

    bool isCorrect = false;
    String feedbackMessage = '';

    switch (currentExercise.type) {
      case ExerciseType.reorder:
        if (!state.allSlotsFilled) {
          emit(state.copyWith(
            feedbackMessage: 'Fill all the slots before checking!',
            feedbackType: FeedbackType.error,
            status: UnifiedExerciseStatus.loaded,
          ));
          return;
        }
        isCorrect = ExerciseService.checkAnswer(
          userAnswer: state.currentSentence,
          correctAnswer: currentExercise.reorderExercise!.correctOrder,
        );
        feedbackMessage = isCorrect
            ? '⭐ Correct! Great job!'
            : '🚫 Incorrect. The correct answer was: ${currentExercise.reorderExercise!.correctOrder.join(' ')}';
        break;

      case ExerciseType.multipleChoice:
        if (state.selectedOptionIndex == null) {
          emit(state.copyWith(
            feedbackMessage: 'Please select an option first!',
            feedbackType: FeedbackType.warning,
            status: UnifiedExerciseStatus.loaded,
          ));
          return;
        }
        isCorrect = MultipleChoiceService.checkAnswer(
          selectedIndex: state.selectedOptionIndex!,
          correctIndex: currentExercise.multipleChoiceExercise!.correctOptionIndex,
        );
        final correctAnswer = currentExercise.multipleChoiceExercise!
            .options[currentExercise.multipleChoiceExercise!.correctOptionIndex];
        feedbackMessage = isCorrect
            ? '⭐ Correct! Well done!'
            : '🚫 Incorrect. The correct answer is: $correctAnswer';
        break;

      case ExerciseType.fillBlank:
        if (state.userAnswer.trim().isEmpty) {
          emit(state.copyWith(
            feedbackMessage: 'Please type an answer first!',
            feedbackType: FeedbackType.warning,
            status: UnifiedExerciseStatus.loaded,
          ));
          return;
        }
        isCorrect = FillBlankService.checkAnswer(
          userAnswer: state.userAnswer,
          exercise: currentExercise.fillBlankExercise!,
        );
        feedbackMessage = isCorrect
            ? '⭐ Correct! Excellent work!'
            : '🚫 Incorrect. Try again or tap "Show Answer".';
        break;
    }

    emit(state.copyWith(
      status: isCorrect ? UnifiedExerciseStatus.correct : UnifiedExerciseStatus.incorrect,
      feedbackMessage: feedbackMessage,
      feedbackType: isCorrect ? FeedbackType.success : FeedbackType.error,
    ));
  }

  // Next Exercise handler
  void _onNextExercise(NextExercise event, Emitter<UnifiedExerciseState> emit) {
    if (state.isLastExercise) {
      emit(state.copyWith(
        status: UnifiedExerciseStatus.completed,
        feedbackMessage: '🎉 Lesson Complete! All exercises finished!',
        feedbackType: FeedbackType.success,
      ));
      return;
    }

    final nextIndex = state.currentIndex + 1;
    _loadExerciseAtIndex(nextIndex, state.exercises, emit);
  }

  // Reset Exercise handler
  void _onResetExercise(ResetCurrentExercise event, Emitter<UnifiedExerciseState> emit) {
    _loadExerciseAtIndex(state.currentIndex, state.exercises, emit);
  }
}