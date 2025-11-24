import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_account.dart';
import '../services/mongo_service.dart';

class AuthRepository {
  final MongoService _mongoService;
  final FlutterSecureStorage _secureStorage;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    MongoService? mongoService,
    FlutterSecureStorage? secureStorage,
    GoogleSignIn? googleSignIn,
  })  : _mongoService = mongoService ?? MongoService.instance,
        _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

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

  // Login with Google
  Future<UserModel> loginWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final userData = await _mongoService.loginWithGoogle(
        email: googleUser.email,
        name: googleUser.displayName ?? googleUser.email.split('@')[0],
        photoUrl: googleUser.photoUrl ?? '',
        googleId: googleUser.id,
      );

      if (userData == null) {
        throw Exception('Google login failed');
      }

      final user = UserModel.fromJson(userData);
      await _saveUserSession(user.id);
      print('✅ Google login successful, saved session for user: ${user.id}');
      return user;
    } catch (e) {
      print('❌ Google login error: $e');
      throw Exception('Google login failed: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    await _secureStorage.delete(key: 'userId');
    await _googleSignIn.signOut();
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
}