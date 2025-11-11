import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/exercise.dart';
import '../../../data/services/exercise_service.dart';
import 'exercise_event.dart';
import 'exercise_state.dart';

class ExerciseBloc extends Bloc<ExerciseEvent, ExerciseState> {
  ExerciseBloc() : super(const ExerciseState()) {
    on<LoadExercises>(_onLoadExercises);
    on<PlaceWordInSlot>(_onPlaceWordInSlot);
    on<ReorderWordsInSlot>(_onReorderWordsInSlot);
    on<TapWord>(_onTapWord);
    on<ReturnWordToBank>(_onReturnWordToBank);
    on<CheckAnswer>(_onCheckAnswer);
    on<NextExercise>(_onNextExercise);
    on<ResetExercise>(_onResetExercise);
  }

  void _onLoadExercises(LoadExercises event, Emitter<ExerciseState> emit) {
    emit(state.copyWith(status: ExerciseStatus.loading));

    final exercises = ExerciseService.getExercises();

    if (exercises.isEmpty) {
      emit(state.copyWith(
        status: ExerciseStatus.loaded,
        feedbackMessage: 'No exercises available.',
        feedbackType: FeedbackType.error,
      ));
      return;
    }

    final firstExercise = exercises[0];
    final shuffledWords = ExerciseService.shuffleWords(firstExercise.correctOrder);
    final emptySlots = List<WordBlock?>.filled(firstExercise.correctOrder.length, null);

    emit(state.copyWith(
      status: ExerciseStatus.loaded,
      exercises: exercises,
      currentIndex: 0,
      availableWords: shuffledWords,
      currentSentence: emptySlots,
      feedbackMessage: 'Tap or drag words to build the translation.',
      feedbackType: FeedbackType.initial,
    ));
  }

  void _onPlaceWordInSlot(PlaceWordInSlot event, Emitter<ExerciseState> emit) {
    final updatedAvailable = List<WordBlock>.from(state.availableWords);
    updatedAvailable.removeWhere((w) => w.id == event.word.id);

    final updatedSentence = List<WordBlock?>.from(state.currentSentence);

    // If slot has a word, return it to bank
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

  void _onReorderWordsInSlot(ReorderWordsInSlot event, Emitter<ExerciseState> emit) {
    if (event.sourceIndex == event.targetIndex) return;

    final updatedSentence = List<WordBlock?>.from(state.currentSentence);
    final sourceWord = updatedSentence[event.sourceIndex];
    final targetWord = updatedSentence[event.targetIndex];

    if (sourceWord == null) return;

    if (targetWord == null) {
      // Move to empty slot
      updatedSentence[event.targetIndex] = sourceWord;
      updatedSentence[event.sourceIndex] = null;
    } else {
      // Swap
      updatedSentence[event.targetIndex] = sourceWord;
      updatedSentence[event.sourceIndex] = targetWord;
    }

    emit(state.copyWith(
      currentSentence: updatedSentence,
      feedbackMessage: 'Words reordered!',
      feedbackType: FeedbackType.success,
    ));
  }

  void _onTapWord(TapWord event, Emitter<ExerciseState> emit) {
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

  void _onReturnWordToBank(ReturnWordToBank event, Emitter<ExerciseState> emit) {
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

  void _onCheckAnswer(CheckAnswer event, Emitter<ExerciseState> emit) {
    if (!state.allSlotsFilled) {
      emit(state.copyWith(
        feedbackMessage: 'Fill all the slots before checking!',
        feedbackType: FeedbackType.error,
        status: ExerciseStatus.loaded,
      ));
      return;
    }

    final currentExercise = state.currentExercise;
    if (currentExercise == null) return;

    emit(state.copyWith(status: ExerciseStatus.checking));

    final isCorrect = ExerciseService.checkAnswer(
      userAnswer: state.currentSentence,
      correctAnswer: currentExercise.correctOrder,
    );

    if (isCorrect) {
      emit(state.copyWith(
        status: ExerciseStatus.correct,
        feedbackMessage: '⭐ Correct! Great job!',
        feedbackType: FeedbackType.success,
      ));
    } else {
      emit(state.copyWith(
        status: ExerciseStatus.incorrect,
        feedbackMessage: '🚫 Incorrect. The correct answer was: ${currentExercise.correctOrder.join(' ')}',
        feedbackType: FeedbackType.error,
      ));
    }
  }

  void _onNextExercise(NextExercise event, Emitter<ExerciseState> emit) {
    if (state.isLastExercise) {
      emit(state.copyWith(
        status: ExerciseStatus.completed,
        feedbackMessage: '🎉 Lesson Complete! Hit Reset to start over.',
        feedbackType: FeedbackType.success,
      ));
      return;
    }

    final nextIndex = state.currentIndex + 1;
    final nextExercise = state.exercises[nextIndex];
    final shuffledWords = ExerciseService.shuffleWords(nextExercise.correctOrder);
    final emptySlots = List<WordBlock?>.filled(nextExercise.correctOrder.length, null);

    emit(state.copyWith(
      status: ExerciseStatus.loaded,
      currentIndex: nextIndex,
      availableWords: shuffledWords,
      currentSentence: emptySlots,
      feedbackMessage: 'Tap or drag words to build the translation.',
      feedbackType: FeedbackType.initial,
    ));
  }

  void _onResetExercise(ResetExercise event, Emitter<ExerciseState> emit) {
    final currentExercise = state.currentExercise;
    if (currentExercise == null) return;

    final shuffledWords = ExerciseService.shuffleWords(currentExercise.correctOrder);
    final emptySlots = List<WordBlock?>.filled(currentExercise.correctOrder.length, null);

    emit(state.copyWith(
      status: ExerciseStatus.loaded,
      availableWords: shuffledWords,
      currentSentence: emptySlots,
      feedbackMessage: 'Exercise reset. Try again!',
      feedbackType: FeedbackType.initial,
    ));
  }
}