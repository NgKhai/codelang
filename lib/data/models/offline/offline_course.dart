import 'dart:convert';
import 'package:hive/hive.dart';

part 'offline_course.g.dart';

/// Hive adapter for storing courses offline
/// Uses JSON serialization for complex nested exercises
@HiveType(typeId: 0)
class OfflineCourse extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String exercisesJson; // Serialized exercises as JSON

  @HiveField(3)
  final String version; // For update detection (hash of content)

  @HiveField(4)
  final DateTime downloadedAt;

  OfflineCourse({
    required this.id,
    required this.name,
    required this.exercisesJson,
    required this.version,
    required this.downloadedAt,
  });

  /// Create from server data with version hash
  factory OfflineCourse.fromServerData({
    required String id,
    required String name,
    required List<Map<String, dynamic>> exercisesData,
  }) {
    final jsonStr = jsonEncode(exercisesData);
    // Create a simple version hash from content
    final version = jsonStr.hashCode.toString();
    
    return OfflineCourse(
      id: id,
      name: name,
      exercisesJson: jsonStr,
      version: version,
      downloadedAt: DateTime.now(),
    );
  }

  /// Get exercises as parsed JSON list
  List<Map<String, dynamic>> get exercisesData {
    try {
      final List<dynamic> decoded = jsonDecode(exercisesJson);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  /// Check if local version differs from server version
  bool hasUpdate(String serverVersion) {
    return version != serverVersion;
  }
}
