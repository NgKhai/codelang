import 'package:equatable/equatable.dart';

/// Aggregated statistics for a flashcard deck
class DeckStatistics extends Equatable {
  final String deckId;
  final String deckName;
  final int totalCards;
  final int newCount;
  final int learningCount;
  final int reviewingCount;
  final int masteredCount;
  final int dueForReviewCount;

  const DeckStatistics({
    required this.deckId,
    required this.deckName,
    required this.totalCards,
    required this.newCount,
    required this.learningCount,
    required this.reviewingCount,
    required this.masteredCount,
    required this.dueForReviewCount,
  });

  /// Empty statistics for a deck with no progress
  factory DeckStatistics.empty(String deckId, String deckName, int totalCards) {
    return DeckStatistics(
      deckId: deckId,
      deckName: deckName,
      totalCards: totalCards,
      newCount: totalCards,
      learningCount: 0,
      reviewingCount: 0,
      masteredCount: 0,
      dueForReviewCount: 0,
    );
  }

  /// Calculate completion percentage
  double get completionPercentage {
    if (totalCards == 0) return 0.0;
    return (masteredCount / totalCards) * 100;
  }

  /// Cards that need attention (due + learning + new)
  int get cardsToStudy => dueForReviewCount + learningCount;

  @override
  List<Object?> get props => [
    deckId,
    deckName,
    totalCards,
    newCount,
    learningCount,
    reviewingCount,
    masteredCount,
    dueForReviewCount,
  ];
}
