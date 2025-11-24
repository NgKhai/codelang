import 'package:equatable/equatable.dart';
import '../../../data/models/exercise/reorder_exercise.dart';

abstract class UnifiedExerciseEvent extends Equatable {
  const UnifiedExerciseEvent();

  @override
  List<Object?> get props => [];
}

// General events
class LoadUnifiedExercises extends UnifiedExerciseEvent {
  final int count;
  final String? exerciseSetId; // null means random

  const LoadUnifiedExercises({
    this.count = 10,
    this.exerciseSetId,
  });

  @override
  List<Object?> get props => [count, exerciseSetId];
}

class CheckAnswer extends UnifiedExerciseEvent {}

class NextExercise extends UnifiedExerciseEvent {}

class ResetCurrentExercise extends UnifiedExerciseEvent {}

// Reorder exercise events
class PlaceWordInSlot extends UnifiedExerciseEvent {
  final WordBlock word;
  final int targetIndex;

  const PlaceWordInSlot({required this.word, required this.targetIndex});

  @override
  List<Object?> get props => [word, targetIndex];
}

class ReorderWordsInSlot extends UnifiedExerciseEvent {
  final int sourceIndex;
  final int targetIndex;

  const ReorderWordsInSlot({
    required this.sourceIndex,
    required this.targetIndex,
  });

  @override
  List<Object?> get props => [sourceIndex, targetIndex];
}

class TapWord extends UnifiedExerciseEvent {
  final WordBlock word;

  const TapWord(this.word);

  @override
  List<Object?> get props => [word];
}

class ReturnWordToBank extends UnifiedExerciseEvent {
  final int slotIndex;

  const ReturnWordToBank(this.slotIndex);

  @override
  List<Object?> get props => [slotIndex];
}

// Multiple Choice events
class SelectOption extends UnifiedExerciseEvent {
  final int optionIndex;

  const SelectOption(this.optionIndex);

  @override
  List<Object?> get props => [optionIndex];
}

// Fill in the Blank events
class UpdateAnswer extends UnifiedExerciseEvent {
  final String answer;

  const UpdateAnswer(this.answer);

  @override
  List<Object?> get props => [answer];
}

class ShowAnswer extends UnifiedExerciseEvent {}