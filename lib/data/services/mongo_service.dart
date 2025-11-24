// lib/data/services/mongo_service.dart

import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class MongoService {
  static MongoService? _instance;
  static Db? _db;
  static DbCollection? _usersCollection;

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

  // Login or register with Google
  Future<Map<String, dynamic>?> loginWithGoogle({
    required String email,
    required String name,
    required String photoUrl,
    required String googleId,
  }) async {
    try {
      await connect();

      // Check if user exists
      var user = await _usersCollection!.findOne(
        where.eq('email', email.toLowerCase()),
      );

      if (user == null) {
        // Create new user
        final objectId = ObjectId();
        user = {
          '_id': objectId,
          'email': email.toLowerCase(),
          'name': name,
          'photoUrl': photoUrl,
          'googleId': googleId,
          'authProvider': 'google',
          'createdAt': DateTime.now().toIso8601String(),
        };

        await _usersCollection!.insertOne(user);
        user['_id'] = objectId.toHexString();
      } else {
        // Store the ObjectId before converting
        final userId = (user['_id'] as ObjectId).toHexString();
        user['_id'] = userId;
        
        // Update existing user info
        await _usersCollection!.update(
          where.eq('_id', ObjectId.fromHexString(userId)),
          modify.set('photoUrl', photoUrl).set('name', name),
        );
      }

      user.remove('password');
      return user;
    } catch (e) {
      print('Google login error: $e');
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
}