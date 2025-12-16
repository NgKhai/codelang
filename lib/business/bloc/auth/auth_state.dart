import 'package:equatable/equatable.dart';

import '../../../data/models/user_account.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
  
  /// Helper to check if user can save progress
  bool get canSaveProgress => this is AuthAuthenticated;
  
  /// Helper to check if user can use ALC
  bool get canUseAlc => this is AuthAuthenticated;
  
  /// Helper to check if user is in any authenticated state (including guest)
  bool get isLoggedIn => this is AuthAuthenticated || this is AuthGuest || this is AuthOffline;
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Guest mode - can use app but no progress saved
class AuthGuest extends AuthState {
  const AuthGuest();
}

/// Offline mode - can only access downloaded content
class AuthOffline extends AuthState {
  const AuthOffline();
}