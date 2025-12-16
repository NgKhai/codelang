import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/offline/offline_course.dart';
import '../../../data/models/offline/offline_flash_card_deck.dart';
import '../../../data/services/offline_storage_service.dart';
import 'offline_event.dart';
import 'offline_state.dart';

class OfflineBloc extends Bloc<OfflineEvent, OfflineState> {
  OfflineBloc() : super(const OfflineState()) {
    on<LoadDownloadedContent>(_onLoadDownloadedContent);
    on<DownloadCourse>(_onDownloadCourse);
    on<DeleteCourse>(_onDeleteCourse);
    on<DownloadDeck>(_onDownloadDeck);
    on<DeleteDeck>(_onDeleteDeck);
    on<CheckForUpdates>(_onCheckForUpdates);
  }

  Future<void> _onLoadDownloadedContent(
    LoadDownloadedContent event,
    Emitter<OfflineState> emit,
  ) async {
    emit(state.copyWith(status: OfflineStatus.loading));

    try {
      final courses = OfflineStorageService.getAllCourses();
      final decks = OfflineStorageService.getAllDecks();

      emit(state.copyWith(
        status: OfflineStatus.loaded,
        downloadedCourses: courses,
        downloadedDecks: decks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OfflineStatus.error,
        errorMessage: 'Failed to load downloaded content: $e',
      ));
    }
  }

  Future<void> _onDownloadCourse(
    DownloadCourse event,
    Emitter<OfflineState> emit,
  ) async {
    emit(state.copyWith(
      status: OfflineStatus.downloading,
      downloadingId: event.courseId,
    ));

    try {
      final offlineCourse = OfflineCourse.fromServerData(
        id: event.courseId,
        name: event.courseName,
        exercisesData: event.exercisesData,
      );

      await OfflineStorageService.saveCourse(offlineCourse);

      // Update state with new course list
      final courses = OfflineStorageService.getAllCourses();
      
      // Remove from updates set if it was there
      final updatedCoursesWithUpdates = Set<String>.from(state.coursesWithUpdates)
        ..remove(event.courseId);

      emit(state.copyWith(
        status: OfflineStatus.loaded,
        downloadedCourses: courses,
        coursesWithUpdates: updatedCoursesWithUpdates,
        clearDownloading: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OfflineStatus.error,
        errorMessage: 'Failed to download course: $e',
        clearDownloading: true,
      ));
    }
  }

  Future<void> _onDeleteCourse(
    DeleteCourse event,
    Emitter<OfflineState> emit,
  ) async {
    emit(state.copyWith(status: OfflineStatus.deleting));

    try {
      await OfflineStorageService.deleteCourse(event.courseId);

      final courses = OfflineStorageService.getAllCourses();
      
      // Remove from updates set
      final updatedCoursesWithUpdates = Set<String>.from(state.coursesWithUpdates)
        ..remove(event.courseId);

      emit(state.copyWith(
        status: OfflineStatus.loaded,
        downloadedCourses: courses,
        coursesWithUpdates: updatedCoursesWithUpdates,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OfflineStatus.error,
        errorMessage: 'Failed to delete course: $e',
      ));
    }
  }

  Future<void> _onDownloadDeck(
    DownloadDeck event,
    Emitter<OfflineState> emit,
  ) async {
    emit(state.copyWith(
      status: OfflineStatus.downloading,
      downloadingId: event.deckId,
    ));

    try {
      final offlineDeck = OfflineFlashCardDeck.fromServerData(
        deckId: event.deckId,
        name: event.deckName,
        cardsData: event.cardsData,
      );

      await OfflineStorageService.saveDeck(offlineDeck);

      // Update state with new deck list
      final decks = OfflineStorageService.getAllDecks();
      
      // Remove from updates set if it was there
      final updatedDecksWithUpdates = Set<String>.from(state.decksWithUpdates)
        ..remove(event.deckId);

      emit(state.copyWith(
        status: OfflineStatus.loaded,
        downloadedDecks: decks,
        decksWithUpdates: updatedDecksWithUpdates,
        clearDownloading: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OfflineStatus.error,
        errorMessage: 'Failed to download deck: $e',
        clearDownloading: true,
      ));
    }
  }

  Future<void> _onDeleteDeck(
    DeleteDeck event,
    Emitter<OfflineState> emit,
  ) async {
    emit(state.copyWith(status: OfflineStatus.deleting));

    try {
      await OfflineStorageService.deleteDeck(event.deckId);

      final decks = OfflineStorageService.getAllDecks();
      
      // Remove from updates set
      final updatedDecksWithUpdates = Set<String>.from(state.decksWithUpdates)
        ..remove(event.deckId);

      emit(state.copyWith(
        status: OfflineStatus.loaded,
        downloadedDecks: decks,
        decksWithUpdates: updatedDecksWithUpdates,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OfflineStatus.error,
        errorMessage: 'Failed to delete deck: $e',
      ));
    }
  }

  Future<void> _onCheckForUpdates(
    CheckForUpdates event,
    Emitter<OfflineState> emit,
  ) async {
    final coursesWithUpdates = <String>{};
    final decksWithUpdates = <String>{};

    // Check courses for updates
    for (final entry in event.courseVersions.entries) {
      final localVersion = OfflineStorageService.getCourseVersion(entry.key);
      if (localVersion != null && localVersion != entry.value) {
        coursesWithUpdates.add(entry.key);
      }
    }

    // Check decks for updates
    for (final entry in event.deckVersions.entries) {
      final localVersion = OfflineStorageService.getDeckVersion(entry.key);
      if (localVersion != null && localVersion != entry.value) {
        decksWithUpdates.add(entry.key);
      }
    }

    emit(state.copyWith(
      coursesWithUpdates: coursesWithUpdates,
      decksWithUpdates: decksWithUpdates,
    ));
  }
}
