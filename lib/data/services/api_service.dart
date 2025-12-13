// lib/data/services/api_service.dart
// HTTP API service for Node.js backend communication

import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static ApiService? _instance;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  // Change this to your server URL
  // For Android emulator use: http://10.0.2.2:3000
  // For iOS simulator use: http://localhost:3000
  // For physical device use: http://YOUR_IP:3000
  // For production use: https://your-server.com
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  ApiService._();
  
  static ApiService get instance {
    _instance ??= ApiService._();
    return _instance!;
  }
  
  // ============================================================
  // TOKEN MANAGEMENT
  // ============================================================
  
  Future<String?> _getAccessToken() async {
    return await _secureStorage.read(key: 'accessToken');
  }
  
  Future<String?> _getRefreshToken() async {
    return await _secureStorage.read(key: 'refreshToken');
  }
  
  Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: 'accessToken', value: accessToken);
    await _secureStorage.write(key: 'refreshToken', value: refreshToken);
  }
  
  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: 'accessToken');
    await _secureStorage.delete(key: 'refreshToken');
    await _secureStorage.delete(key: 'userId');
  }
  
  Future<void> _saveUserId(String userId) async {
    await _secureStorage.write(key: 'userId', value: userId);
  }
  
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: 'userId');
  }
  
  // ============================================================
  // HTTP HELPERS
  // ============================================================
  
  Map<String, String> _getHeaders({bool requiresAuth = false, String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (requiresAuth && token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
  
  /// Make authenticated request with auto token refresh
  Future<http.Response> _authenticatedRequest(
    Future<http.Response> Function(String token) requestFn,
  ) async {
    String? token = await _getAccessToken();
    
    if (token == null) {
      throw Exception('Not authenticated');
    }
    
    var response = await requestFn(token);
    
    // If token expired, try to refresh
    if (response.statusCode == 401) {
      final refreshed = await _refreshAccessToken();
      if (refreshed) {
        token = await _getAccessToken();
        response = await requestFn(token!);
      } else {
        await _clearTokens();
        throw Exception('Session expired. Please login again.');
      }
    }
    
    return response;
  }
  
  Future<bool> _refreshAccessToken() async {
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null) return false;
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: _getHeaders(),
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Token refresh error: $e');
      return false;
    }
  }
  
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Request failed');
    }
  }
  
  // ============================================================
  // AUTHENTICATION
  // ============================================================
  
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );
      
      final data = _handleResponse(response);
      
      await _saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );
      await _saveUserId(data['user']['_id']);
      
      return data['user'];
    } catch (e) {
      print('❌ Register error: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      final data = _handleResponse(response);
      
      await _saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );
      await _saveUserId(data['user']['_id']);
      
      return data['user'];
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }
  
  Future<void> logout() async {
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken != null) {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: _getHeaders(),
          body: jsonEncode({'refreshToken': refreshToken}),
        );
      }
    } catch (e) {
      print('❌ Logout error: $e');
    } finally {
      await _clearTokens();
    }
  }
  
  Future<bool> isLoggedIn() async {
    final token = await _getAccessToken();
    return token != null && token.isNotEmpty;
  }
  
  // ============================================================
  // USER
  // ============================================================
  
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await _authenticatedRequest((token) => 
        http.get(
          Uri.parse('$baseUrl/users/me'),
          headers: _getHeaders(requiresAuth: true, token: token),
        ),
      );
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ Get current user error: $e');
      return null;
    }
  }
  
  Future<Map<String, dynamic>> updateUserName(String newName) async {
    final response = await _authenticatedRequest((token) =>
      http.put(
        Uri.parse('$baseUrl/users/name'),
        headers: _getHeaders(requiresAuth: true, token: token),
        body: jsonEncode({'name': newName}),
      ),
    );
    
    return _handleResponse(response);
  }
  
  Future<Map<String, dynamic>> completeStreak() async {
    final response = await _authenticatedRequest((token) =>
      http.post(
        Uri.parse('$baseUrl/users/streak'),
        headers: _getHeaders(requiresAuth: true, token: token),
      ),
    );
    
    return _handleResponse(response);
  }
  
  Future<Map<String, dynamic>> completeCourse(String courseId) async {
    final response = await _authenticatedRequest((token) =>
      http.post(
        Uri.parse('$baseUrl/users/complete-course'),
        headers: _getHeaders(requiresAuth: true, token: token),
        body: jsonEncode({'courseId': courseId}),
      ),
    );
    
    return _handleResponse(response);
  }
  
  // ============================================================
  // EXERCISES
  // ============================================================
  
  Future<List<Map<String, dynamic>>> fetchReorderExercises() async {
    final response = await http.get(
      Uri.parse('$baseUrl/exercises/reorder'),
      headers: _getHeaders(),
    );
    
    final data = _handleResponse(response);
    return List<Map<String, dynamic>>.from(data);
  }
  
  Future<List<Map<String, dynamic>>> fetchMultipleChoiceExercises() async {
    final response = await http.get(
      Uri.parse('$baseUrl/exercises/multiple-choice'),
      headers: _getHeaders(),
    );
    
    final data = _handleResponse(response);
    return List<Map<String, dynamic>>.from(data);
  }
  
  Future<List<Map<String, dynamic>>> fetchMultipleChoiceByType(String practiceType) async {
    final response = await http.get(
      Uri.parse('$baseUrl/exercises/multiple-choice/$practiceType'),
      headers: _getHeaders(),
    );
    
    final data = _handleResponse(response);
    return List<Map<String, dynamic>>.from(data);
  }
  
  Future<List<Map<String, dynamic>>> fetchFillBlankExercises() async {
    final response = await http.get(
      Uri.parse('$baseUrl/exercises/fill-blank'),
      headers: _getHeaders(),
    );
    
    final data = _handleResponse(response);
    return List<Map<String, dynamic>>.from(data);
  }
  
  Future<List<Map<String, dynamic>>> fetchExerciseSets() async {
    final response = await http.get(
      Uri.parse('$baseUrl/exercises/sets'),
      headers: _getHeaders(),
    );
    
    final data = _handleResponse(response);
    return List<Map<String, dynamic>>.from(data);
  }
  
  Future<Map<String, dynamic>?> fetchExerciseSetById(String setId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/exercises/sets/$setId'),
      headers: _getHeaders(),
    );
    
    if (response.statusCode == 404) return null;
    return _handleResponse(response);
  }
  
  Future<List<Map<String, dynamic>>> fetchAllCourses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/exercises/courses'),
      headers: _getHeaders(),
    );
    
    final data = _handleResponse(response);
    return List<Map<String, dynamic>>.from(data);
  }
  
  Future<List<Map<String, dynamic>>> fetchRandomExercises({int count = 10}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/exercises/random?count=$count'),
      headers: _getHeaders(),
    );
    
    final data = _handleResponse(response);
    return List<Map<String, dynamic>>.from(data);
  }
  
  // ============================================================
  // FLASH CARDS
  // ============================================================
  
  Future<List<Map<String, dynamic>>> fetchFlashCards({
    int page = 0,
    int limit = 5,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/flashcards?page=$page&limit=$limit'),
      headers: _getHeaders(),
    );
    
    final data = _handleResponse(response);
    return List<Map<String, dynamic>>.from(data);
  }
  
  Future<int> getFlashCardsCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/flashcards/count'),
      headers: _getHeaders(),
    );
    
    final data = _handleResponse(response);
    return data['count'];
  }
  
  Future<Map<String, dynamic>?> fetchFlashCardById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/flashcards/$id'),
      headers: _getHeaders(),
    );
    
    if (response.statusCode == 404) return null;
    return _handleResponse(response);
  }
  
  Future<List<Map<String, dynamic>>> fetchFlashCardDecks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/flashcards/decks'),
      headers: _getHeaders(),
    );
    
    final data = _handleResponse(response);
    return List<Map<String, dynamic>>.from(data);
  }
  
  Future<Map<String, dynamic>?> fetchFlashCardDeckById(String deckId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/flashcards/decks/$deckId'),
      headers: _getHeaders(),
    );
    
    if (response.statusCode == 404) return null;
    return _handleResponse(response);
  }
  
  Future<List<Map<String, dynamic>>> fetchFlashCardsByIds(List<String> ids) async {
    final response = await http.post(
      Uri.parse('$baseUrl/flashcards/by-ids'),
      headers: _getHeaders(),
      body: jsonEncode({'ids': ids}),
    );
    
    final data = _handleResponse(response);
    return List<Map<String, dynamic>>.from(data);
  }
  
  // ============================================================
  // USER FLASHCARD PROGRESS
  // ============================================================
  
  Future<List<Map<String, dynamic>>> getUserCardProgress({
    required String deckId,
  }) async {
    final response = await _authenticatedRequest((token) =>
      http.get(
        Uri.parse('$baseUrl/progress/$deckId'),
        headers: _getHeaders(requiresAuth: true, token: token),
      ),
    );
    
    final data = _handleResponse(response);
    return List<Map<String, dynamic>>.from(data);
  }
  
  Future<Map<String, dynamic>> getCardProgress({
    required String flashCardId,
  }) async {
    final response = await _authenticatedRequest((token) =>
      http.get(
        Uri.parse('$baseUrl/progress/card/$flashCardId'),
        headers: _getHeaders(requiresAuth: true, token: token),
      ),
    );
    
    return _handleResponse(response);
  }
  
  Future<Map<String, dynamic>> upsertCardProgress({
    required String deckId,
    required String flashCardId,
    required Map<String, dynamic> progressData,
  }) async {
    final response = await _authenticatedRequest((token) =>
      http.put(
        Uri.parse('$baseUrl/progress/card/$flashCardId'),
        headers: _getHeaders(requiresAuth: true, token: token),
        body: jsonEncode({
          'deckId': deckId,
          ...progressData,
        }),
      ),
    );
    
    return _handleResponse(response);
  }
  
  Future<Map<String, int>> getDeckProgressStats({
    required String deckId,
    required int totalCards,
  }) async {
    final response = await _authenticatedRequest((token) =>
      http.get(
        Uri.parse('$baseUrl/progress/stats/$deckId?totalCards=$totalCards'),
        headers: _getHeaders(requiresAuth: true, token: token),
      ),
    );
    
    final data = _handleResponse(response);
    return Map<String, int>.from(data);
  }
  
  Future<void> batchUpdateProgress(List<Map<String, dynamic>> progressUpdates) async {
    await _authenticatedRequest((token) =>
      http.post(
        Uri.parse('$baseUrl/progress/batch'),
        headers: _getHeaders(requiresAuth: true, token: token),
        body: jsonEncode({'progressUpdates': progressUpdates}),
      ),
    );
  }
}
