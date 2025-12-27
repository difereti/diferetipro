import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/dashboard_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) => NoTransitionPage(
          child: RegisterPage(
            initialCountryCode: state.uri.queryParameters['iso'],
            initialCountryName: state.uri.queryParameters['country'],
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        pageBuilder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'client';
          return NoTransitionPage(
            child: DashboardPage(role: role),
          );
        },
      ),
    ],
  );
}

class AppRoutes {
  static const String login = '/';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
}
