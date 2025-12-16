import 'package:equatable/equatable.dart';

abstract class FlashCardStatsEvent extends Equatable {
  const FlashCardStatsEvent();

  @override
  List<Object?> get props => [];
}

/// Load statistics for a specific deck
class LoadDeckStats extends FlashCardStatsEvent {
  final String deckId;
  final String deckName;

  const LoadDeckStats({
    required this.deckId,
    required this.deckName,
  });

  @override
  List<Object?> get props => [deckId, deckName];
}

/// Update a card's progress after review
class UpdateCardProgress extends FlashCardStatsEvent {
  final String deckId;
  final String flashCardId;
  final int quality; // 0-5 rating

  const UpdateCardProgress({
    required this.deckId,
    required this.flashCardId,
    required this.quality,
  });

  @override
  List<Object?> get props => [deckId, flashCardId, quality];
}


