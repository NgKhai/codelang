import 'package:equatable/equatable.dart';

abstract class FlashCardEvent extends Equatable {
  const FlashCardEvent();

  @override
  List<Object?> get props => [];
}

class LoadFlashCards extends FlashCardEvent {
  final String? deckId;

  const LoadFlashCards({this.deckId});

  @override
  List<Object?> get props => [deckId];
}

class LoadMoreFlashCards extends FlashCardEvent {
  const LoadMoreFlashCards();
}

class RefreshFlashCards extends FlashCardEvent {
  const RefreshFlashCards();
}

class SpeakFlashCardWord extends FlashCardEvent {
  final String word;
  final String? language;
  final double? speechRate;

  const SpeakFlashCardWord({
    required this.word,
    this.language,
    this.speechRate,
  });

  @override
  List<Object?> get props => [word, language, speechRate];
}

class StopSpeaking extends FlashCardEvent {
  const StopSpeaking();
}