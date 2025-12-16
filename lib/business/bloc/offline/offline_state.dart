import 'package:equatable/equatable.dart';
import '../../../data/models/offline/offline_course.dart';
import '../../../data/models/offline/offline_flash_card_deck.dart';

enum OfflineStatus {
  initial,
  loading,
  loaded,
  downloading,
  deleting,
  error,
}

class OfflineState extends Equatable {
  final OfflineStatus status;
  final List<OfflineCourse> downloadedCourses;
  final List<OfflineFlashCardDeck> downloadedDecks;
  final Set<String> coursesWithUpdates; // IDs of courses with available updates
  final Set<String> decksWithUpdates;   // IDs of decks with available updates
  final String? downloadingId;          // Currently downloading item ID
  final String? errorMessage;

  const OfflineState({
    this.status = OfflineStatus.initial,
    this.downloadedCourses = const [],
    this.downloadedDecks = const [],
    this.coursesWithUpdates = const {},
    this.decksWithUpdates = const {},
    this.downloadingId,
    this.errorMessage,
  });

  /// Check if a course is downloaded
  bool isCourseDownloaded(String courseId) {
    return downloadedCourses.any((c) => c.id == courseId);
  }

  /// Check if a deck is downloaded
  bool isDeckDownloaded(String deckId) {
    return downloadedDecks.any((d) => d.deckId == deckId);
  }

  /// Check if a course has an update available
  bool courseHasUpdate(String courseId) {
    return coursesWithUpdates.contains(courseId);
  }

  /// Check if a deck has an update available
  bool deckHasUpdate(String deckId) {
    return decksWithUpdates.contains(deckId);
  }

  /// Check if currently downloading a specific item
  bool isDownloading(String id) {
    return status == OfflineStatus.downloading && downloadingId == id;
  }

  OfflineState copyWith({
    OfflineStatus? status,
    List<OfflineCourse>? downloadedCourses,
    List<OfflineFlashCardDeck>? downloadedDecks,
    Set<String>? coursesWithUpdates,
    Set<String>? decksWithUpdates,
    String? downloadingId,
    String? errorMessage,
    bool clearDownloading = false,
    bool clearError = false,
  }) {
    return OfflineState(
      status: status ?? this.status,
      downloadedCourses: downloadedCourses ?? this.downloadedCourses,
      downloadedDecks: downloadedDecks ?? this.downloadedDecks,
      coursesWithUpdates: coursesWithUpdates ?? this.coursesWithUpdates,
      decksWithUpdates: decksWithUpdates ?? this.decksWithUpdates,
      downloadingId: clearDownloading ? null : (downloadingId ?? this.downloadingId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    downloadedCourses,
    downloadedDecks,
    coursesWithUpdates,
    decksWithUpdates,
    downloadingId,
    errorMessage,
  ];
}
