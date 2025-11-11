// lib/models/exercise_model.dart
import 'package:equatable/equatable.dart';

class ReorderExercise extends Equatable {
  final String prompt;
  final String sourceSentence;
  final List<String> correctOrder;

  const ReorderExercise({
    required this.prompt,
    required this.sourceSentence,
    required this.correctOrder,
  });

  @override
  List<Object?> get props => [prompt, sourceSentence, correctOrder];
}

class WordBlock extends Equatable {
  final String id;
  final String text;

  const WordBlock({
    required this.id,
    required this.text,
  });

  @override
  List<Object?> get props => [id, text];

  WordBlock copyWith({
    String? id,
    String? text,
  }) {
    return WordBlock(
      id: id ?? this.id,
      text: text ?? this.text,
    );
  }
}