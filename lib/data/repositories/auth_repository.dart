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
      return user;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Login with email and password
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final userData = await _mongoService.loginUser(
        email: email,
        password: password,
      );

      if (userData == null) {
        throw Exception('Login failed');
      }

      final user = UserModel.fromJson(userData);
      await _saveUserSession(user.id);
      return user;
    } catch (e) {
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
      return user;
    } catch (e) {
      throw Exception('Google login failed: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    await _secureStorage.delete(key: 'userId');
    await _googleSignIn.signOut();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final userId = await _secureStorage.read(key: 'userId');
    return userId != null && userId.isNotEmpty;
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final userId = await _secureStorage.read(key: 'userId');
      if (userId == null || userId.isEmpty) {
        return null;
      }

      final userData = await _mongoService.getUserById(userId);
      if (userData == null) {
        return null;
      }

      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  // Save user session
  Future<void> _saveUserSession(String userId) async {
    await _secureStorage.write(key: 'userId', value: userId);
  }
}