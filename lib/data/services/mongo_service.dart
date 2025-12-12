// lib/data/services/mongo_service.dart

import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class MongoService {
  static MongoService? _instance;
  static Db? _db;
  static DbCollection? _usersCollection;
  static DbCollection? _reorderExercisesCollection;
  static DbCollection? _multipleChoiceExercisesCollection;
  static DbCollection? _fillBlankExercisesCollection;
  static DbCollection? _flashCardsCollection;
  static DbCollection? _exerciseSetsCollection;
  static DbCollection? _flashCardDecksCollection;

  MongoService._();

  static MongoService get instance {
    _instance ??= MongoService._();
    return _instance!;
  }

  Future<void> connect() async {
    if (_db != null && _db!.state == State.OPEN) {
      return;
    }

    try {
      final mongoUrl = dotenv.env['MONGO_URL'];
      if (mongoUrl == null || mongoUrl.isEmpty) {
        throw Exception('MONGO_URL not found in .env file');
      }

      _db = await Db.create(mongoUrl);
      await _db!.open();
      _usersCollection = _db!.collection('users');
      _reorderExercisesCollection = _db!.collection('reorder_exercises');
      _multipleChoiceExercisesCollection = _db!.collection('multiple_choice_exercises');
      _fillBlankExercisesCollection = _db!.collection('fill_blank_exercises');
      _flashCardsCollection = _db!.collection('flash_cards');
      _exerciseSetsCollection = _db!.collection('exercise_sets');
      _flashCardDecksCollection = _db!.collection('flash_card_decks');
      print('MongoDB connected successfully');
    } catch (e) {
      print('MongoDB connection error: $e');
      rethrow;
    }
  }

  Future<void> disconnect() async {
    if (_db != null && _db!.state == State.OPEN) {
      await _db!.close();
    }
  }

  // Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Register user with email/password
  Future<Map<String, dynamic>?> registerUser({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      await connect();

      // Check if user already exists
      final existingUser = await _usersCollection!.findOne(
        where.eq('email', email.toLowerCase()),
      );

      if (existingUser != null) {
        throw Exception('User already exists');
      }

      // Create manual ObjectId
      final objectId = ObjectId();

      final user = {
        '_id': objectId,
        'email': email.toLowerCase(),
        'password': _hashPassword(password),
        'name': name ?? email.split('@')[0],
        'authProvider': 'email',
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Insert
      await _usersCollection!.insertOne(user);

      // Convert _id to String when returning
      user['_id'] = objectId.toHexString();
      user.remove('password');

      return user;

    } catch (e) {
      print('Register error: $e');
      rethrow;
    }
  }


  // Login user with email/password
  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await connect();

      final user = await _usersCollection!.findOne(
        where.eq('email', email.toLowerCase()).eq('password', _hashPassword(password)),
      );

      if (user == null) {
        throw Exception('Invalid email or password');
      }

      user.remove('password'); // Don't return password
      user['_id'] = (user['_id'] as ObjectId).toHexString();

      return user;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }


  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(String id) async {
    try {
      await connect();
      final user = await _usersCollection!.findOne(
        where.eq('_id', ObjectId.fromHexString(id)),
      );

      if (user != null) {
        user.remove('password');
        user['_id'] = (user['_id'] as ObjectId).toHexString();
      }

      return user;
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }

  // Update user's name
  Future<Map<String, dynamic>?> updateUserName({
    required String userId,
    required String newName,
  }) async {
    try {
      await connect();
      
      // Update the user's name
      await _usersCollection!.update(
        where.eq('_id', ObjectId.fromHexString(userId)),
        modify.set('name', newName),
      );

      // Get and return the updated user
      return await getUserById(userId);
    } catch (e) {
      print('Update user name error: $e');
      rethrow;
    }
  }

  // Update user's streak
  Future<Map<String, dynamic>?> updateUserStreak({
    required String userId,
  }) async {
    try {
      await connect();
      
      // Get current user data
      final user = await _usersCollection!.findOne(
        where.eq('_id', ObjectId.fromHexString(userId)),
      );
      
      if (user == null) {
        throw Exception('User not found');
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Parse last completion date
      DateTime? lastCompletionDate;
      if (user['lastCompletionDate'] != null) {
        lastCompletionDate = DateTime.parse(user['lastCompletionDate']);
      }
      
      // Normalize to date only (no time)
      final lastCompletionDay = lastCompletionDate != null
          ? DateTime(lastCompletionDate.year, lastCompletionDate.month, lastCompletionDate.day)
          : null;
      
      // Check if already completed today
      if (lastCompletionDay != null && lastCompletionDay.isAtSameMomentAs(today)) {
        print('🔥 Streak already completed today');
        return await getUserById(userId);
      }
      
      // Calculate new streak
      int currentStreak = user['currentStreak'] ?? 0;
      int newStreak;
      
      if (lastCompletionDay != null) {
        final yesterday = today.subtract(const Duration(days: 1));
        if (lastCompletionDay.isAtSameMomentAs(yesterday)) {
          // Completed yesterday, increment streak
          newStreak = currentStreak + 1;
          print('🔥 Streak incremented: $currentStreak -> $newStreak');
        } else {
          // Missed days, reset streak
          newStreak = 1;
          print('🔥 Streak reset to 1 (was $currentStreak)');
        }
      } else {
        // First time completing streak
        newStreak = 1;
        print('🔥 First streak!');
      }
      
      // Update the database
      await _usersCollection!.update(
        where.eq('_id', ObjectId.fromHexString(userId)),
        modify
          .set('currentStreak', newStreak)
          .set('lastCompletionDate', now.toIso8601String()),
      );

      return await getUserById(userId);
    } catch (e) {
      print('Update user streak error: $e');
      rethrow;
    }
  }

  // Complete a course (add to completedCourseIds if not already there)
  Future<Map<String, dynamic>?> completeCourse({
    required String userId,
    required String courseId,
  }) async {
    try {
      await connect();
      
      // Get current user data
      final user = await _usersCollection!.findOne(
        where.eq('_id', ObjectId.fromHexString(userId)),
      );
      
      if (user == null) {
        throw Exception('User not found');
      }

      // Get current completed courses
      final List<dynamic> currentCompleted = user['completedCourseIds'] ?? [];
      
      // Check if already completed
      if (currentCompleted.contains(courseId)) {
        print('📚 Course $courseId already completed');
        return await getUserById(userId);
      }
      
      // Add to completed list
      await _usersCollection!.update(
        where.eq('_id', ObjectId.fromHexString(userId)),
        modify.push('completedCourseIds', courseId),
      );

      print('📚 Course $courseId marked as completed');
      return await getUserById(userId);
    } catch (e) {
      print('Complete course error: $e');
      rethrow;
    }
  }

  // ============================================================
  // EXERCISE FETCH METHODS
  // ============================================================

  // Fetch all reorder exercises
  Future<List<Map<String, dynamic>>> fetchReorderExercises() async {
    try {
      await connect();
      final exercises = await _reorderExercisesCollection!.find().toList();
      return exercises;
    } catch (e) {
      print('Fetch reorder exercises error: $e');
      rethrow;
    }
  }

  // Fetch all multiple choice exercises
  Future<List<Map<String, dynamic>>> fetchMultipleChoiceExercises() async {
    try {
      await connect();
      final exercises = await _multipleChoiceExercisesCollection!.find().toList();
      return exercises;
    } catch (e) {
      print('Fetch multiple choice exercises error: $e');
      rethrow;
    }
  }

  // Fetch multiple choice exercises by practice type
  Future<List<Map<String, dynamic>>> fetchMultipleChoiceByType(String practiceType) async {
    try {
      await connect();
      final exercises = await _multipleChoiceExercisesCollection!
          .find(where.eq('practiceType', practiceType))
          .toList();
      return exercises;
    } catch (e) {
      print('Fetch multiple choice by type error: $e');
      rethrow;
    }
  }

  // Fetch all fill blank exercises
  Future<List<Map<String, dynamic>>> fetchFillBlankExercises() async {
    try {
      await connect();
      final exercises = await _fillBlankExercisesCollection!.find().toList();
      return exercises;
    } catch (e) {
      print('Fetch fill blank exercises error: $e');
      rethrow;
    }
  }

  // Fetch all flash cards with pagination
  Future<List<Map<String, dynamic>>> fetchFlashCards({
    int page = 0,
    int limit = 5,
  }) async {
    try {
      await connect();
      final flashCards = await _flashCardsCollection!
          .find()
          .skip(page * limit)
          .take(limit)
          .toList();
      return flashCards;
    } catch (e) {
      print('Fetch flash cards error: $e');
      rethrow;
    }
  }

  // Fetch flash card by ID
  Future<Map<String, dynamic>?> fetchFlashCardById(String id) async {
    try {
      await connect();
      final flashCard = await _flashCardsCollection!.findOne(
        where.eq('flashCardId', id),
      );
      return flashCard;
    } catch (e) {
      print('Fetch flash card by ID error: $e');
      rethrow;
    }
  }

  // Get total flash cards count
  Future<int> getFlashCardsCount() async {
    try {
      await connect();
      return await _flashCardsCollection!.count();
    } catch (e) {
      print('Get flash cards count error: $e');
      rethrow;
    }
  }

  // Fetch all exercise sets
  Future<List<Map<String, dynamic>>> fetchExerciseSets() async {
    try {
      await connect();
      final sets = await _exerciseSetsCollection!.find().toList();
      return sets;
    } catch (e) {
      print('Fetch exercise sets error: $e');
      rethrow;
    }
  }

  // Fetch exercise set by ID
  Future<Map<String, dynamic>?> fetchExerciseSetById(String setId) async {
    try {
      await connect();
      final set = await _exerciseSetsCollection!.findOne(
        where.eq('setId', setId),
      );
      return set;
    } catch (e) {
      print('Fetch exercise set by ID error: $e');
      rethrow;
    }
  }

  // ============================================================
  // FLASH CARD DECK METHODS
  // ============================================================

  // Fetch all flash card decks
  Future<List<Map<String, dynamic>>> fetchFlashCardDecks() async {
    try {
      await connect();
      final decks = await _flashCardDecksCollection!.find().toList();
      return decks;
    } catch (e) {
      print('Fetch flash card decks error: $e');
      rethrow;
    }
  }

  // Fetch flash card deck by ID
  Future<Map<String, dynamic>?> fetchFlashCardDeckById(String deckId) async {
    try {
      await connect();
      final deck = await _flashCardDecksCollection!.findOne(
        where.eq('deckId', deckId),
      );
      return deck;
    } catch (e) {
      print('Fetch flash card deck by ID error: $e');
      rethrow;
    }
  }

  // Fetch flash cards by list of IDs
  Future<List<Map<String, dynamic>>> fetchFlashCardsByIds(List<String> ids) async {
    try {
      await connect();
      final flashCards = await _flashCardsCollection!
          .find(where.oneFrom('flashCardId', ids))
          .toList();
      return flashCards;
    } catch (e) {
      print('Fetch flash cards by IDs error: $e');
      rethrow;
    }
  }
}