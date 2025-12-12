import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;

  // final String authProvider; // 'email' or 'google'
  final int currentStreak;
  final List<String> completedCourseIds;
  final DateTime lastCompletionDate;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    // required this.authProvider,
    required this.currentStreak,
    required this.completedCourseIds,
    required this.lastCompletionDate,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      photoUrl: json['photoUrl'],
      // authProvider: json['authProvider'] ?? 'email',
      currentStreak: json['currentStreak'] ?? 0,
      completedCourseIds: (json['completedCourseIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      lastCompletionDate: json['lastCompletionDate'] != null
          ? DateTime.parse(json['lastCompletionDate'])
          : DateTime.now().subtract(const Duration(days: 1)),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      // 'authProvider': authProvider,
      'currentStreak': currentStreak,
      'completedCourseIds': completedCourseIds,
      'lastCompletionDate': lastCompletionDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Check if the user has completed their streak today
  bool get hasCompletedStreakToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final completionDay = DateTime(
      lastCompletionDate.year,
      lastCompletionDate.month,
      lastCompletionDate.day,
    );
    return completionDay.isAtSameMomentAs(today);
  }

  // Check if a specific course is completed
  bool hasCourseCompleted(String courseId) {
    return completedCourseIds.contains(courseId);
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    photoUrl,
    // authProvider,
    currentStreak,
    completedCourseIds,
    lastCompletionDate,
    createdAt,
  ];
}

