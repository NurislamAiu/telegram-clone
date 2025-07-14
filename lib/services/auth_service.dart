import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  final _firestore = FirebaseFirestore.instance;

  /// Хэширование пароля
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Проверка существования username
  Future<bool> _checkUsernameExists(String username) async {
    final result = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    return result.docs.isNotEmpty;
  }

  /// Регистрация
  Future<dynamic> registerUser({
    required String username,
    required String password,
  }) async {
    final exists = await _checkUsernameExists(username);
    if (exists) return "Username already exists";

    final id = const Uuid().v4();
    final hashedPassword = _hashPassword(password);

    final newUser = UserModel(
      id: id,
      username: username,
      passwordHash: hashedPassword,
    );

    try {
      await _firestore.collection('users').doc(id).set(newUser.toJson());
      return newUser;
    } catch (e) {
      return "Registration failed: $e";
    }
  }

  /// Логин
  Future<dynamic> loginUser({
    required String username,
    required String password,
  }) async {
    final hashedPassword = _hashPassword(password);

    try {
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: hashedPassword)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return "Invalid credentials";
      }

      final userData = query.docs.first.data();
      return UserModel.fromJson(userData);
    } catch (e) {
      return "Login failed: $e";
    }
  }

  /// Получить пользователя по ID (для загрузки сессии)
  Future<UserModel?> getUserById(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}