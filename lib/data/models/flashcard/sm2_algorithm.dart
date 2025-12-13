import 'user_flashcard_progress.dart';

/// SM-2 Spaced Repetition Algorithm Implementation
/// 
/// Based on the SuperMemo SM-2 algorithm by Piotr Wozniak.
/// 
/// Quality ratings:
/// - 0: Complete blackout, no memory
/// - 1: Wrong answer, but upon seeing correct answer, remembered
/// - 2: Wrong answer, but correct answer seemed easy to recall
/// - 3: Correct answer with serious difficulty
/// - 4: Correct answer after hesitation
/// - 5: Perfect response, instant recall
class SM2Algorithm {
  /// Minimum ease factor to prevent intervals from becoming too short
  static const double minEaseFactor = 1.3;

  /// Default ease factor for new cards
  static const double defaultEaseFactor = 2.5;

  /// Calculate the next review state based on quality of recall
  /// 
  /// [current] - The current progress state
  /// [quality] - Rating from 0-5 (0=forgot, 5=perfect)
  /// 
  /// Returns updated progress with new interval and next review date
  static UserFlashCardProgress calculateNextReview(
    UserFlashCardProgress current,
    int quality,
  ) {
    // Clamp quality to valid range
    quality = quality.clamp(0, 5);

    final now = DateTime.now();
    int newRepetitions;
    double newEaseFactor;
    int newInterval;
    CardStatus newStatus;

    if (quality < 3) {
      // Failed recall - reset to beginning
      newRepetitions = 0;
      newInterval = 1; // Review again tomorrow
      newEaseFactor = current.easeFactor; // Keep ease factor
      newStatus = CardStatus.learning;
    } else {
      // Successful recall - apply SM-2 formula
      newRepetitions = current.repetitions + 1;

      // Calculate new ease factor
      // EF' = EF + (0.1 - (5-q) * (0.08 + (5-q) * 0.02))
      newEaseFactor = current.easeFactor +
          (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));

      // Ensure minimum ease factor
      if (newEaseFactor < minEaseFactor) {
        newEaseFactor = minEaseFactor;
      }

      // Calculate interval
      if (newRepetitions == 1) {
        newInterval = 1; // First successful review: 1 day
      } else if (newRepetitions == 2) {
        newInterval = 6; // Second successful review: 6 days
      } else {
        // Subsequent reviews: previous interval * ease factor
        newInterval = (current.intervalDays * newEaseFactor).round();
      }

      // Determine status based on progress
      if (newRepetitions < 2) {
        newStatus = CardStatus.learning;
      } else if (newEaseFactor >= 2.5 && newInterval >= 21) {
        newStatus = CardStatus.mastered;
      } else {
        newStatus = CardStatus.reviewing;
      }
    }

    // Calculate next review date
    final nextReview = now.add(Duration(days: newInterval));

    return current.copyWith(
      repetitions: newRepetitions,
      easeFactor: newEaseFactor,
      intervalDays: newInterval,
      nextReviewDate: nextReview,
      lastReviewDate: now,
      status: newStatus,
    );
  }

  /// Convert button label to quality rating
  static int qualityFromButton(String button) {
    switch (button.toLowerCase()) {
      case 'again':
        return 0;
      case 'hard':
        return 3;
      case 'good':
        return 4;
      case 'easy':
        return 5;
      default:
        return 3;
    }
  }

  /// Get recommended interval text for display
  static String getIntervalText(int intervalDays) {
    if (intervalDays == 0) return 'Now';
    if (intervalDays == 1) return '1 day';
    if (intervalDays < 7) return '$intervalDays days';
    if (intervalDays < 30) return '${(intervalDays / 7).round()} weeks';
    if (intervalDays < 365) return '${(intervalDays / 30).round()} months';
    return '${(intervalDays / 365).round()} years';
  }

  /// Preview what intervals each button would result in
  static Map<String, int> previewIntervals(UserFlashCardProgress current) {
    return {
      'again': 1,
      'hard': calculateNextReview(current, 3).intervalDays,
      'good': calculateNextReview(current, 4).intervalDays,
      'easy': calculateNextReview(current, 5).intervalDays,
    };
  }
}
