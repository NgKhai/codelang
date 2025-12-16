import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthRefreshRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String? name;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthUpdateNameRequested extends AuthEvent {
  final String newName;

  const AuthUpdateNameRequested({required this.newName});

  @override
  List<Object?> get props => [newName];
}

class AuthCompleteStreakRequested extends AuthEvent {}

class AuthCompleteCourseRequested extends AuthEvent {
  final String courseId;

  const AuthCompleteCourseRequested({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

/// Event to continue as guest (no account)
class AuthGuestRequested extends AuthEvent {
  const AuthGuestRequested();
}

/// Event to enter offline mode (uses downloaded content only)
class AuthOfflineRequested extends AuthEvent {
  const AuthOfflineRequested();
}