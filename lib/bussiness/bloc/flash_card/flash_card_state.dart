import 'package:codelang/data/models/flash_card.dart';
import 'package:equatable/equatable.dart';

enum FlashCardStatus { initial, loading, success, failure, loadingMore }

class FlashCardState extends Equatable {
  final FlashCardStatus status;
  final List<FlashCard> flashCards;
  final bool hasReachedMax;
  final int currentPage;
  final String? errorMessage;

  const FlashCardState({
    this.status = FlashCardStatus.initial,
    this.flashCards = const [],
    this.hasReachedMax = false,
    this.currentPage = 0,
    this.errorMessage,
  });

  FlashCardState copyWith({
    FlashCardStatus? status,
    List<FlashCard>? flashCards,
    bool? hasReachedMax,
    int? currentPage,
    String? errorMessage,
  }) {
    return FlashCardState(
      status: status ?? this.status,
      flashCards: flashCards ?? this.flashCards,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    flashCards,
    hasReachedMax,
    currentPage,
    errorMessage,
  ];
}
