import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/welcome/presentation/pages/welcome_page.dart';
import '../../features/info/presentation/pages/info_page.dart';
import '../../features/camera/presentation/pages/camera_page.dart';
import '../../features/result/presentation/pages/result_page.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const WelcomePage()),
      GoRoute(path: '/info', builder: (context, state) => const InfoPage()),
      GoRoute(path: '/camera', builder: (context, state) => const CameraPage()),
      GoRoute(
        path: '/result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ResultPage(
            imagePath: extra['imagePath'] as String,
            userPrompt: extra['userPrompt'] as String?,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Page not found',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    ),
  );
}
