import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isInitialized = false;

  UserModel? get user => _user;
  bool get isInitialized => _isInitialized;

  /// Проверка на вход
  bool get isLoggedIn => _user != null;

  /// Загружает пользователя из сессии (при старте приложения)
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      final user = await AuthService().getUserById(userId);
      if (user != null) {
        _user = user;
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Вход
  Future<String?> login({
    required String username,
    required String password,
  }) async {
    final result = await AuthService().loginUser(username: username, password: password);

    if (result is UserModel) {
      _user = result;
      await _saveSession(result.id);
      notifyListeners();
      return null;
    } else if (result is String) {
      return result;
    }

    return 'Unknown error';
  }

  /// Регистрация
  Future<String?> register({
    required String username,
    required String password,
  }) async {
    final result = await AuthService().registerUser(username: username, password: password);

    if (result is UserModel) {
      _user = result;
      await _saveSession(result.id);
      notifyListeners();
      return null;
    } else if (result is String) {
      return result;
    }

    return 'Unknown error';
  }

  /// Выход
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    _user = null;
    notifyListeners();
  }

  /// Сохраняет userId в SharedPreferences
  Future<void> _saveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }
}