import 'package:equatable/equatable.dart';

abstract class OfflineEvent extends Equatable {
  const OfflineEvent();

  @override
  List<Object?> get props => [];
}

/// Load all downloaded content
class LoadDownloadedContent extends OfflineEvent {
  const LoadDownloadedContent();
}

/// Download a course for offline use
class DownloadCourse extends OfflineEvent {
  final String courseId;
  final String courseName;
  final List<Map<String, dynamic>> exercisesData;

  const DownloadCourse({
    required this.courseId,
    required this.courseName,
    required this.exercisesData,
  });

  @override
  List<Object?> get props => [courseId, courseName, exercisesData];
}

/// Delete a downloaded course
class DeleteCourse extends OfflineEvent {
  final String courseId;

  const DeleteCourse({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

/// Download a flash card deck for offline use
class DownloadDeck extends OfflineEvent {
  final String deckId;
  final String deckName;
  final List<Map<String, dynamic>> cardsData;

  const DownloadDeck({
    required this.deckId,
    required this.deckName,
    required this.cardsData,
  });

  @override
  List<Object?> get props => [deckId, deckName, cardsData];
}

/// Delete a downloaded deck
class DeleteDeck extends OfflineEvent {
  final String deckId;

  const DeleteDeck({required this.deckId});

  @override
  List<Object?> get props => [deckId];
}

/// Check if specific items have updates available
class CheckForUpdates extends OfflineEvent {
  final Map<String, String> courseVersions; // id -> serverVersion
  final Map<String, String> deckVersions;   // id -> serverVersion

  const CheckForUpdates({
    this.courseVersions = const {},
    this.deckVersions = const {},
  });

  @override
  List<Object?> get props => [courseVersions, deckVersions];
}
