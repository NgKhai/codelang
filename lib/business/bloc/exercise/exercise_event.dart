import 'package:equatable/equatable.dart';

import '../../../data/models/exercise.dart';

abstract class ExerciseEvent extends Equatable {
  const ExerciseEvent();

  @override
  List<Object?> get props => [];
}

class LoadExercises extends ExerciseEvent {}

class PlaceWordInSlot extends ExerciseEvent {
  final WordBlock word;
  final int targetIndex;

  const PlaceWordInSlot({required this.word, required this.targetIndex});

  @override
  List<Object?> get props => [word, targetIndex];
}

class ReorderWordsInSlot extends ExerciseEvent {
  final int sourceIndex;
  final int targetIndex;

  const ReorderWordsInSlot({
    required this.sourceIndex,
    required this.targetIndex,
  });

  @override
  List<Object?> get props => [sourceIndex, targetIndex];
}

class TapWord extends ExerciseEvent {
  final WordBlock word;

  const TapWord(this.word);

  @override
  List<Object?> get props => [word];
}

class ReturnWordToBank extends ExerciseEvent {
  final int slotIndex;

  const ReturnWordToBank(this.slotIndex);

  @override
  List<Object?> get props => [slotIndex];
}

class CheckAnswer extends ExerciseEvent {}

class NextExercise extends ExerciseEvent {}

class ResetExercise extends ExerciseEvent {}
