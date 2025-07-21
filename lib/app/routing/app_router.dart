import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'route_config.dart';
import 'route_guards.dart';
import 'route_transitions.dart';
import 'routes/auth_routes.dart';
import 'routes/home_routes.dart';
import 'routes/settings_routes.dart';
import 'routes/vault_routes.dart';

/// Провайдер для GoRouter с интеграцией Riverpod
final appRouterProvider = Provider<GoRouter>((ref) {
  final authGuard = AuthGuard(ref);
  final routeLogger = RouteLogger(ref);

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.splash,

    // Глобальный обработчик навигации
    navigatorKey: GlobalKey<NavigatorState>(),

    // Перехватчик для логирования
    observers: [routeLogger],

    // Обработчик ошибок
    errorBuilder: (context, state) => ErrorPage(
      error: state.error.toString(),
      onRetry: () => context.go(AppRoutes.home),
    ),

    // Перенаправления для аутентификации
    redirect: (context, state) {
      return authGuard.redirect(context, state);
    },

    routes: [
      // Группа маршрутов без аутентификации
      ...getPublicRoutes(),

      // Группа маршрутов с аутентификацией
      ...getProtectedRoutes(),
    ],
  );
});

/// Публичные маршруты (без аутентификации)
List<RouteBase> getPublicRoutes() {
  return [
    // Splash экран
    GoRoute(
      path: AppRoutes.splash,
      name: RouteNames.splash,
      pageBuilder: (context, state) => buildTransitionPage(
        context: context,
        state: state,
        child: const SplashPage(),
        transitionType: AppTransitions.fade,
      ),
    ),

    // Аутентификация
    ...AuthRoutes.routes,
  ];
}

/// Защищенные маршруты (требуют аутентификации)
List<RouteBase> getProtectedRoutes() {
  return [
    // Главная страница с нижней навигацией
    ShellRoute(
      navigatorKey: GlobalKey<NavigatorState>(),
      pageBuilder: (context, state, child) => buildTransitionPage(
        context: context,
        state: state,
        child: MainShell(child: child),
        transitionType: AppTransitions.slide,
      ),
      routes: [
        ...HomeRoutes.routes,
        ...VaultRoutes.routes,
        ...SettingsRoutes.routes,
      ],
    ),
  ];
}

/// Базовая страница ошибки
class ErrorPage extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const ErrorPage({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ошибка')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Произошла ошибка',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (onRetry != null)
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Повторить'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Главная оболочка с нижней навигацией
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}

/// Нижняя навигационная панель
class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _getCurrentIndex(currentRoute),
      onTap: (index) => _onTap(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
        BottomNavigationBarItem(icon: Icon(Icons.security), label: 'Хранилище'),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Добавить'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'История'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Настройки'),
      ],
    );
  }

  int _getCurrentIndex(String route) {
    if (route.startsWith(AppRoutes.home)) return 0;
    if (route.startsWith(AppRoutes.vault)) return 1;
    if (route.startsWith(AppRoutes.addPassword)) return 2;
    if (route.startsWith(AppRoutes.history)) return 3;
    if (route.startsWith(AppRoutes.settings)) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.vault);
        break;
      case 2:
        context.go(AppRoutes.addPassword);
        break;
      case 3:
        context.go(AppRoutes.history);
        break;
      case 4:
        context.go(AppRoutes.settings);
        break;
    }
  }
}

/// Splash экран
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Загрузка...'),
          ],
        ),
      ),
    );
  }
}
