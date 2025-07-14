import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/auth/register_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final isAuth = auth.isAuthenticated;

      final loggingIn = state.uri.toString() == '/login' || state.uri.toString() == '/register';

      if (!isAuth && !loggingIn) return '/login';
      if (isAuth && loggingIn) return '/home';

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    ],
  );
}