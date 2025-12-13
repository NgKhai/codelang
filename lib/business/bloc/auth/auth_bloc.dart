import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthUpdateNameRequested>(_onAuthUpdateNameRequested);
    on<AuthCompleteStreakRequested>(_onAuthCompleteStreakRequested);
    on<AuthCompleteCourseRequested>(_onAuthCompleteCourseRequested);
    on<AuthRefreshRequested>(_onAuthRefreshRequested);
  }
    
  Future<void> _onAuthRefreshRequested(
      AuthRefreshRequested event,
      Emitter<AuthState> emit,
      ) async {
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user));
        }
      }
    } catch (e) {
      print('❌ Auth refresh error: $e');
    }
  }

  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event,
      Emitter<AuthState> emit,
      ) async {
    print('🔄 AuthCheckRequested event received');
    emit(AuthLoading());
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          print('✅ Auth check complete: User authenticated - ${user.email}');
          emit(AuthAuthenticated(user));
        } else {
          print('⚠️ Auth check complete: No user data found');
          emit(AuthUnauthenticated());
        }
      } else {
        print('ℹ️ Auth check complete: User not logged in');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print('❌ Auth check error: $e');
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
      AuthLoginRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthRegisterRequested(
      AuthRegisterRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.register(
        email: event.email,
        password: event.password,
        name: event.name,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLogoutRequested(
      AuthLogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthUpdateNameRequested(
      AuthUpdateNameRequested event,
      Emitter<AuthState> emit,
      ) async {
    try {
      // Get current state
      final currentState = state;
      if (currentState is! AuthAuthenticated) {
        emit(AuthError('User not authenticated'));
        return;
      }

      final updatedUser = await _authRepository.updateUserName(event.newName);
      emit(AuthAuthenticated(updatedUser));
    } catch (e) {
      emit(AuthError(e.toString()));
      // Re-emit the current state if available
      final currentState = state;
      if (currentState is AuthAuthenticated) {
        emit(AuthAuthenticated(currentState.user));
      }
    }
  }

  Future<void> _onAuthCompleteStreakRequested(
      AuthCompleteStreakRequested event,
      Emitter<AuthState> emit,
      ) async {
    try {
      final currentState = state;
      if (currentState is! AuthAuthenticated) {
        print('⚠️ Cannot complete streak: User not authenticated');
        return;
      }

      final updatedUser = await _authRepository.completeStreak();
      emit(AuthAuthenticated(updatedUser));
    } catch (e) {
      print('❌ Complete streak error: $e');
      // Don't emit error state, just keep the current authenticated state
      final currentState = state;
      if (currentState is AuthAuthenticated) {
        emit(AuthAuthenticated(currentState.user));
      }
    }
  }

  Future<void> _onAuthCompleteCourseRequested(
      AuthCompleteCourseRequested event,
      Emitter<AuthState> emit,
      ) async {
    try {
      final currentState = state;
      if (currentState is! AuthAuthenticated) {
        print('⚠️ Cannot complete course: User not authenticated');
        return;
      }

      final updatedUser = await _authRepository.completeCourse(event.courseId);
      emit(AuthAuthenticated(updatedUser));
    } catch (e) {
      print('❌ Complete course error: $e');
      final currentState = state;
      if (currentState is AuthAuthenticated) {
        emit(AuthAuthenticated(currentState.user));
      }
    }
  }
}