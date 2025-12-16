import 'package:codelang/data/models/flashcard/flash_card.dart';
import 'package:equatable/equatable.dart';

abstract class FlashCardEvent extends Equatable {
  const FlashCardEvent();

  @override
  List<Object?> get props => [];
}

class LoadFlashCards extends FlashCardEvent {
  final String? deckId;
  final bool shuffle;

  const LoadFlashCards({this.deckId, this.shuffle = false});

  @override
  List<Object?> get props => [deckId, shuffle];
}

/// Event for loading pre-loaded flash cards (offline/view mode)
class LoadOfflineFlashCards extends FlashCardEvent {
  final List<FlashCard> flashCards;
  final bool shuffle;

  const LoadOfflineFlashCards({required this.flashCards, this.shuffle = false});

  @override
  List<Object?> get props => [flashCards, shuffle];
}

class LoadMoreFlashCards extends FlashCardEvent {
  final String? deckId;
  
  const LoadMoreFlashCards({this.deckId});

  @override
  List<Object?> get props => [deckId];
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