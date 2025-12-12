import 'package:codelang/data/models/flashcard/flash_card.dart';
import 'package:equatable/equatable.dart';

enum FlashCardStatus { initial, loading, success, failure, loadingMore }

class FlashCardState extends Equatable {
  final FlashCardStatus status;
  final List<FlashCard> flashCards;
  final bool hasReachedMax;
  final int currentPage;
  final String? errorMessage;
  final bool isSpeaking;
  final String? speakingWord;
  final String? deckId;

  const FlashCardState({
    this.status = FlashCardStatus.initial,
    this.flashCards = const [],
    this.hasReachedMax = false,
    this.currentPage = 0,
    this.errorMessage,
    this.isSpeaking = false,
    this.speakingWord,
    this.deckId,
  });

  FlashCardState copyWith({
    FlashCardStatus? status,
    List<FlashCard>? flashCards,
    bool? hasReachedMax,
    int? currentPage,
    String? errorMessage,
    bool? isSpeaking,
    String? speakingWord,
    String? deckId,
  }) {
    return FlashCardState(
      status: status ?? this.status,
      flashCards: flashCards ?? this.flashCards,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage ?? this.errorMessage,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      speakingWord: speakingWord ?? this.speakingWord,
      deckId: deckId ?? this.deckId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    flashCards,
    hasReachedMax,
    currentPage,
    errorMessage,
    isSpeaking,
    speakingWord,
    deckId,
  ];
}