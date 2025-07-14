// lib/services/auth_service.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> registerUser({
    required String username,
    required String password,
  }) async {
    final usernameTaken = await _checkUsernameExists(username);
    if (usernameTaken) return 'Username already taken';

    final userId = const Uuid().v4();
    final passwordHash = _hashPassword(password);

    final user = UserModel(
      userId: userId,
      username: username,
      passwordHash: passwordHash,
      createdAt: DateTime.now(),
    );

    try {
      await _db.collection('users').doc(userId).set(user.toMap());
      return null; // success
    } catch (e) {
      return 'Failed to register: $e';
    }
  }

  Future<String?> loginUser({
    required String username,
    required String password,
  }) async {
    final passwordHash = _hashPassword(password);

    final query = await _db
        .collection('users')
        .where('username', isEqualTo: username)
        .where('passwordHash', isEqualTo: passwordHash)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return 'Invalid username or password';

    // You may store session info here using Provider or SharedPreferences
    return null;
  }

  Future<bool> _checkUsernameExists(String username) async {
    final query = await _db
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }
}
