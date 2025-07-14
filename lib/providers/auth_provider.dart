// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<void> login(UserModel user) async {
    _user = user;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userId', user.userId);
  }

  Future<void> logout() async {
    _user = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userId');
  }

  Future<void> tryAutoLogin(Future<UserModel?> Function(String userId) loadUser) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    final user = await loadUser(userId);
    if (user != null) {
      _user = user;
      notifyListeners();
    }
  }
}