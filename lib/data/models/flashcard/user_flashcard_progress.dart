import 'package:equatable/equatable.dart';

/// Card learning status for SM-2 algorithm
enum CardStatus {
  newCard,     // Never reviewed
  learning,    // In initial learning phase (repetitions < 2)
  reviewing,   // In spaced repetition cycle
  mastered,    // EF >= 2.5 and interval >= 21 days
}

/// Tracks a user's progress on a specific flashcard using SM-2 algorithm
class UserFlashCardProgress extends Equatable {
  final String odId;
  final String odUserId;
  final String deckId;
  final String flashCardId;
  final CardStatus status;
  final int repetitions;       // n in SM-2 (number of successful reviews)
  final double easeFactor;     // EF in SM-2 (2.5 default, min 1.3)
  final int intervalDays;      // Days until next review
  final DateTime nextReviewDate;
  final DateTime lastReviewDate;

  const UserFlashCardProgress({
    required this.odId,
    required this.odUserId,
    required this.deckId,
    required this.flashCardId,
    required this.status,
    required this.repetitions,
    required this.easeFactor,
    required this.intervalDays,
    required this.nextReviewDate,
    required this.lastReviewDate,
  });

  /// Creates a new progress record for a card that hasn't been reviewed yet
  factory UserFlashCardProgress.initial({
    required String odUserId,
    required String deckId,
    required String flashCardId,
  }) {
    final now = DateTime.now();
    return UserFlashCardProgress(
      odId: '',
      odUserId: odUserId,
      deckId: deckId,
      flashCardId: flashCardId,
      status: CardStatus.newCard,
      repetitions: 0,
      easeFactor: 2.5,
      intervalDays: 0,
      nextReviewDate: now,
      lastReviewDate: now,
    );
  }

  factory UserFlashCardProgress.fromJson(Map<String, dynamic> json) {
    return UserFlashCardProgress(
      odId: json['_id']?.toString() ?? json['odId'] ?? '',
      odUserId: json['odUserId'] ?? '',
      deckId: json['deckId'] ?? '',
      flashCardId: json['flashCardId'] ?? '',
      status: CardStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CardStatus.newCard,
      ),
      repetitions: json['repetitions'] ?? 0,
      easeFactor: (json['easeFactor'] ?? 2.5).toDouble(),
      intervalDays: json['intervalDays'] ?? 0,
      nextReviewDate: json['nextReviewDate'] != null
          ? DateTime.parse(json['nextReviewDate'])
          : DateTime.now(),
      lastReviewDate: json['lastReviewDate'] != null
          ? DateTime.parse(json['lastReviewDate'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'odUserId': odUserId,
      'deckId': deckId,
      'flashCardId': flashCardId,
      'status': status.name,
      'repetitions': repetitions,
      'easeFactor': easeFactor,
      'intervalDays': intervalDays,
      'nextReviewDate': nextReviewDate.toIso8601String(),
      'lastReviewDate': lastReviewDate.toIso8601String(),
    };
  }

  /// Check if card is due for review
  bool get isDueForReview => DateTime.now().isAfter(nextReviewDate);

  UserFlashCardProgress copyWith({
    String? odId,
    String? odUserId,
    String? deckId,
    String? flashCardId,
    CardStatus? status,
    int? repetitions,
    double? easeFactor,
    int? intervalDays,
    DateTime? nextReviewDate,
    DateTime? lastReviewDate,
  }) {
    return UserFlashCardProgress(
      odId: odId ?? this.odId,
      odUserId: odUserId ?? this.odUserId,
      deckId: deckId ?? this.deckId,
      flashCardId: flashCardId ?? this.flashCardId,
      status: status ?? this.status,
      repetitions: repetitions ?? this.repetitions,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
    );
  }

  @override
  List<Object?> get props => [
    odId,
    odUserId,
    deckId,
    flashCardId,
    status,
    repetitions,
    easeFactor,
    intervalDays,
    nextReviewDate,
    lastReviewDate,
  ];
}
