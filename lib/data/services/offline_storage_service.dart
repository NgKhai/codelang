import 'package:hive_flutter/hive_flutter.dart';
import '../models/offline/offline_course.dart';
import '../models/offline/offline_flash_card_deck.dart';

/// Service for managing offline storage using Hive
class OfflineStorageService {
  static const String _coursesBoxName = 'offline_courses';
  static const String _decksBoxName = 'offline_decks';

  static Box<OfflineCourse>? _coursesBox;
  static Box<OfflineFlashCardDeck>? _decksBox;

  /// Initialize Hive and open boxes
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(OfflineCourseAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(OfflineFlashCardDeckAdapter());
    }

    // Open boxes
    _coursesBox = await Hive.openBox<OfflineCourse>(_coursesBoxName);
    _decksBox = await Hive.openBox<OfflineFlashCardDeck>(_decksBoxName);
  }

  // ================ COURSES ================

  /// Save a course for offline use
  static Future<void> saveCourse(OfflineCourse course) async {
    await _coursesBox?.put(course.id, course);
  }

  /// Delete a downloaded course
  static Future<void> deleteCourse(String courseId) async {
    await _coursesBox?.delete(courseId);
  }

  /// Get a specific downloaded course
  static OfflineCourse? getCourse(String courseId) {
    return _coursesBox?.get(courseId);
  }

  /// Get all downloaded courses
  static List<OfflineCourse> getAllCourses() {
    return _coursesBox?.values.toList() ?? [];
  }

  /// Check if a course is downloaded
  static bool isCourseDownloaded(String courseId) {
    return _coursesBox?.containsKey(courseId) ?? false;
  }

  /// Get course version for update check
  static String? getCourseVersion(String courseId) {
    return _coursesBox?.get(courseId)?.version;
  }

  // ================ FLASH CARD DECKS ================

  /// Save a flash card deck for offline use
  static Future<void> saveDeck(OfflineFlashCardDeck deck) async {
    await _decksBox?.put(deck.deckId, deck);
  }

  /// Delete a downloaded deck
  static Future<void> deleteDeck(String deckId) async {
    await _decksBox?.delete(deckId);
  }

  /// Get a specific downloaded deck
  static OfflineFlashCardDeck? getDeck(String deckId) {
    return _decksBox?.get(deckId);
  }

  /// Get all downloaded decks
  static List<OfflineFlashCardDeck> getAllDecks() {
    return _decksBox?.values.toList() ?? [];
  }

  /// Check if a deck is downloaded
  static bool isDeckDownloaded(String deckId) {
    return _decksBox?.containsKey(deckId) ?? false;
  }

  /// Get deck version for update check
  static String? getDeckVersion(String deckId) {
    return _decksBox?.get(deckId)?.version;
  }

  // ================ UTILITIES ================

  /// Get total downloaded content count
  static int get totalDownloadedCount {
    return (_coursesBox?.length ?? 0) + (_decksBox?.length ?? 0);
  }

  /// Get total storage size in bytes
  static int get totalStorageSizeBytes {
    int totalBytes = 0;
    
    // Calculate course storage
    for (final course in getAllCourses()) {
      totalBytes += course.exercisesJson.length * 2; // Approximate UTF-16 size
      totalBytes += course.name.length * 2;
      totalBytes += course.id.length * 2;
    }
    
    // Calculate deck storage
    for (final deck in getAllDecks()) {
      totalBytes += deck.cardsJson.length * 2; // Approximate UTF-16 size
      totalBytes += deck.name.length * 2;
      totalBytes += deck.deckId.length * 2;
    }
    
    return totalBytes;
  }

  /// Get formatted storage size string (KB, MB, GB)
  static String get formattedStorageSize {
    final bytes = totalStorageSizeBytes;
    
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// Clear all offline data
  static Future<void> clearAll() async {
    await _coursesBox?.clear();
    await _decksBox?.clear();
  }
}
