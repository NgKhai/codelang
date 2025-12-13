import 'package:equatable/equatable.dart';
import '../../../data/models/flashcard/deck_statistics.dart';

enum FlashCardStatsStatus { initial, loading, success, failure }

class FlashCardStatsState extends Equatable {
  final FlashCardStatsStatus status;
  final DeckStatistics? stats;
  final String? errorMessage;

  const FlashCardStatsState({
    this.status = FlashCardStatsStatus.initial,
    this.stats,
    this.errorMessage,
  });

  FlashCardStatsState copyWith({
    FlashCardStatsStatus? status,
    DeckStatistics? stats,
    String? errorMessage,
  }) {
    return FlashCardStatsState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, stats, errorMessage];
}
