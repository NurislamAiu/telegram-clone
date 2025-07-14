// lib/app/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/chat/chat_screen.dart';
import '../../screens/home/home_screen.dart';

final AppRouter = _AppRouter();

class _AppRouter {
  late final GoRouter router;

  _AppRouter() {
    router = GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final isLoggedIn = auth.isLoggedIn;
        final loggingIn = state.fullPath == '/login' || state.fullPath == '/register';

        if (!isLoggedIn && !loggingIn) return '/login';
        if (isLoggedIn && loggingIn) return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/chat/:userId/:username',
          name: 'chat',
          builder: (context, state) {
            final userId = state.pathParameters['userId']!;
            final username = state.pathParameters['username']!;
            return ChatScreen(
              otherUserId: userId,
              otherUsername: username,
            );
          },
        ),
      ],
    );
  }
}