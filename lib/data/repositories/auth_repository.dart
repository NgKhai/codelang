// lib/data/repositories/auth_repository.dart
// Updated to use REST API instead of direct MongoDB

import '../models/user_account.dart';
import '../services/api_service.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository({
    ApiService? apiService,
  }) : _apiService = apiService ?? ApiService.instance;

  // Register with email and password
  Future<UserModel> register({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      print('📝 Attempting registration for: $email');
      final userData = await _apiService.register(
        email: email,
        password: password,
        name: name,
      );

      final user = UserModel.fromJson(userData);
      print('✅ Registration successful for user: ${user.id}');
      return user;
    } catch (e) {
      print('❌ Registration error: $e');
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Login with email and password
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Attempting login for: $email');
      final userData = await _apiService.login(
        email: email,
        password: password,
      );

      final user = UserModel.fromJson(userData);
      print('✅ Login successful for user: ${user.id}');
      return user;
    } catch (e) {
      print('❌ Login error: $e');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    await _apiService.logout();
    print('👋 Logged out, cleared session');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final isLoggedIn = await _apiService.isLoggedIn();
    print('🔍 Auth check: isLoggedIn=$isLoggedIn');
    return isLoggedIn;
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final userData = await _apiService.getCurrentUser();
      if (userData == null) {
        print('⚠️ getCurrentUser: No user found');
        return null;
      }

      print('✅ getCurrentUser: User found - ${userData['email']}');
      return UserModel.fromJson(userData);
    } catch (e) {
      print('❌ getCurrentUser error: $e');
      return null;
    }
  }

  // Update user's name
  Future<UserModel> updateUserName(String newName) async {
    try {
      print('📝 Updating name to: $newName');
      final userData = await _apiService.updateUserName(newName);

      print('✅ Name updated successfully');
      return UserModel.fromJson(userData);
    } catch (e) {
      print('❌ Update name error: $e');
      throw Exception('Failed to update name: ${e.toString()}');
    }
  }

  // Complete daily streak
  Future<UserModel> completeStreak() async {
    try {
      print('🔥 Completing streak');
      final userData = await _apiService.completeStreak();

      print('✅ Streak completed successfully');
      return UserModel.fromJson(userData);
    } catch (e) {
      print('❌ Complete streak error: $e');
      throw Exception('Failed to complete streak: ${e.toString()}');
    }
  }

  // Complete a course
  Future<UserModel> completeCourse(String courseId) async {
    try {
      print('📚 Completing course $courseId');
      final userData = await _apiService.completeCourse(courseId);

      print('✅ Course completed successfully');
      return UserModel.fromJson(userData);
    } catch (e) {
      print('❌ Complete course error: $e');
      throw Exception('Failed to complete course: ${e.toString()}');
    }
  }
}