import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_account.dart';
import '../services/mongo_service.dart';


class AuthRepository {
  final MongoService _mongoService;
  final FlutterSecureStorage _secureStorage;

  AuthRepository({
    MongoService? mongoService,
    FlutterSecureStorage? secureStorage,
  })  : _mongoService = mongoService ?? MongoService.instance,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // Register with email and password
  Future<UserModel> register({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      print('📝 Attempting registration for: $email');
      final userData = await _mongoService.registerUser(
        email: email,
        password: password,
        name: name,
      );

      if (userData == null) {
        throw Exception('Registration failed');
      }

      final user = UserModel.fromJson(userData);
      await _saveUserSession(user.id);
      print('✅ Registration successful, saved session for user: ${user.id}');
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
      final userData = await _mongoService.loginUser(
        email: email,
        password: password,
      );

      if (userData == null) {
        throw Exception('Login failed');
      }

      final user = UserModel.fromJson(userData);
      await _saveUserSession(user.id);
      print('✅ Login successful, saved session for user: ${user.id}');
      return user;
    } catch (e) {
      print('❌ Login error: $e');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    await _secureStorage.delete(key: 'userId');
    print('👋 Logged out, cleared session');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final userId = await _secureStorage.read(key: 'userId');
    final isLoggedIn = userId != null && userId.isNotEmpty;
    print('🔍 Auth check: userId=${userId ?? "null"}, isLoggedIn=$isLoggedIn');
    return isLoggedIn;
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final userId = await _secureStorage.read(key: 'userId');
      if (userId == null || userId.isEmpty) {
        print('⚠️ getCurrentUser: No userId found in storage');
        return null;
      }

      print('🔍 Fetching user data for userId: $userId');
      final userData = await _mongoService.getUserById(userId);
      if (userData == null) {
        print('⚠️ getCurrentUser: No user found in DB for userId: $userId');
        return null;
      }

      print('✅ getCurrentUser: User found - ${userData['email']}');
      return UserModel.fromJson(userData);
    } catch (e) {
      print('❌ getCurrentUser error: $e');
      return null;
    }
  }

  // Save user session
  Future<void> _saveUserSession(String userId) async {
    await _secureStorage.write(key: 'userId', value: userId);
    print('💾 Saved session for userId: $userId');
  }

  // Update user's name
  Future<UserModel> updateUserName(String newName) async {
    try {
      final userId = await _secureStorage.read(key: 'userId');
      if (userId == null || userId.isEmpty) {
        throw Exception('No user session found');
      }

      print('📝 Updating name for user: $userId to: $newName');
      final userData = await _mongoService.updateUserName(
        userId: userId,
        newName: newName,
      );

      if (userData == null) {
        throw Exception('Failed to update user name');
      }

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
      final userId = await _secureStorage.read(key: 'userId');
      if (userId == null || userId.isEmpty) {
        throw Exception('No user session found');
      }

      print('🔥 Completing streak for user: $userId');
      final userData = await _mongoService.updateUserStreak(userId: userId);

      if (userData == null) {
        throw Exception('Failed to complete streak');
      }

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
      final userId = await _secureStorage.read(key: 'userId');
      if (userId == null || userId.isEmpty) {
        throw Exception('No user session found');
      }

      print('📚 Completing course $courseId for user: $userId');
      final userData = await _mongoService.completeCourse(
        userId: userId,
        courseId: courseId,
      );

      if (userData == null) {
        throw Exception('Failed to complete course');
      }

      print('✅ Course completed successfully');
      return UserModel.fromJson(userData);
    } catch (e) {
      print('❌ Complete course error: $e');
      throw Exception('Failed to complete course: ${e.toString()}');
    }
  }
}