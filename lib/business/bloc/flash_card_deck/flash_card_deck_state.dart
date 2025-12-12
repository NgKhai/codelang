import 'package:equatable/equatable.dart';
import '../../../data/models/flashcard/flash_card_deck.dart';

enum FlashCardDeckStatus { initial, loading, success, failure }

class FlashCardDeckState extends Equatable {
  final FlashCardDeckStatus status;
  final List<FlashCardDeck> decks;
  final String? errorMessage;

  const FlashCardDeckState({
    this.status = FlashCardDeckStatus.initial,
    this.decks = const [],
    this.errorMessage,
  });

  FlashCardDeckState copyWith({
    FlashCardDeckStatus? status,
    List<FlashCardDeck>? decks,
    String? errorMessage,
  }) {
    return FlashCardDeckState(
      status: status ?? this.status,
      decks: decks ?? this.decks,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, decks, errorMessage];
}
