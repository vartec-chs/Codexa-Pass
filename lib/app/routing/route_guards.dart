import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codexa_pass/core/logging/logging.dart';

import 'route_config.dart';

/// Базовый интерфейс для защиты маршрутов
abstract class RouteGuard {
  /// Проверка доступа к маршруту
  Future<bool> canAccess(BuildContext context, GoRouterState state);

  /// Перенаправление при отсутствии доступа
  String? redirect(BuildContext context, GoRouterState state);
}

/// Защита для аутентификации
class AuthGuard implements RouteGuard {
  AuthGuard(Ref ref);

  @override
  Future<bool> canAccess(BuildContext context, GoRouterState state) async {
    // Здесь будет проверка состояния аутентификации
    // Пока что возвращаем true для демонстрации
    return true;
  }

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    final currentPath = state.matchedLocation;

    // Логируем попытку навигации
    AppLogger.instance.debug(
      'Route guard check',
      logger: 'AuthGuard',
      metadata: {
        'path': currentPath,
        'fullPath': state.fullPath,
        'params': state.pathParameters,
        'query': state.uri.queryParameters,
      },
    );

    // Проверяем, нужна ли аутентификация для данного маршрута
    if (RouteConfig.isPublicRoute(currentPath)) {
      // Публичные маршруты доступны всем
      return null;
    }

    // Для защищенных маршрутов проверяем аутентификацию
    if (RouteConfig.isProtectedRoute(currentPath)) {
      final isAuthenticated = _checkAuthenticationState();

      if (!isAuthenticated) {
        AppLogger.instance.warning(
          'Access denied to protected route',
          logger: 'AuthGuard',
          metadata: {
            'attemptedPath': currentPath,
            'redirectTo': AppRoutes.login,
          },
        );

        // Сохраняем путь для возврата после аутентификации
        final returnUrl = Uri.encodeComponent(currentPath);
        return '${AppRoutes.login}?${QueryParams.returnUrl}=$returnUrl';
      }
    }

    // Если пользователь аутентифицирован и пытается попасть на splash/login
    if (_checkAuthenticationState() &&
        (currentPath == AppRoutes.splash || currentPath == AppRoutes.login)) {
      AppLogger.instance.info(
        'Redirecting authenticated user to home',
        logger: 'AuthGuard',
        metadata: {'from': currentPath, 'to': AppRoutes.home},
      );
      return AppRoutes.home;
    }

    return null;
  }

  /// Проверка состояния аутентификации
  bool _checkAuthenticationState() {
    // Здесь будет реальная проверка состояния аутентификации через провайдеры
    // Пока что возвращаем true для демонстрации
    return true;
  }
}

/// Защита для проверки разрешений
class PermissionGuard implements RouteGuard {
  PermissionGuard(Ref ref);

  @override
  Future<bool> canAccess(BuildContext context, GoRouterState state) async {
    // Проверка разрешений для конкретного маршрута
    final currentPath = state.matchedLocation;

    // Административные маршруты
    if (_isAdminRoute(currentPath)) {
      return _checkAdminPermissions();
    }

    // Премиум функции
    if (_isPremiumRoute(currentPath)) {
      return _checkPremiumAccess();
    }

    return true;
  }

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    // Здесь можно добавить логику перенаправления при отсутствии разрешений
    return null;
  }

  bool _isAdminRoute(String path) {
    const adminRoutes = ['/admin', '/analytics'];
    return adminRoutes.any((route) => path.startsWith(route));
  }

  bool _isPremiumRoute(String path) {
    const premiumRoutes = ['/backup', '/analytics'];
    return premiumRoutes.any((route) => path.startsWith(route));
  }

  bool _checkAdminPermissions() {
    // Проверка административных разрешений
    return true; // Заглушка
  }

  bool _checkPremiumAccess() {
    // Проверка премиум доступа
    return true; // Заглушка
  }
}

/// Защита для проверки безопасности
class SecurityGuard implements RouteGuard {
  SecurityGuard(Ref ref);

  @override
  Future<bool> canAccess(BuildContext context, GoRouterState state) async {
    // Проверка безопасности (например, биометрии для чувствительных данных)
    final currentPath = state.matchedLocation;

    if (_requiresBiometricAuth(currentPath)) {
      return await _checkBiometricAuth();
    }

    return true;
  }

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    // Перенаправление на экран безопасности если необходимо
    return null;
  }

  bool _requiresBiometricAuth(String path) {
    const secureRoutes = ['/vault', '/password-details', '/backup'];
    return secureRoutes.any((route) => path.startsWith(route));
  }

  Future<bool> _checkBiometricAuth() async {
    // Проверка биометрической аутентификации
    return true; // Заглушка
  }
}

/// Логгер маршрутов для отслеживания навигации
class RouteLogger extends NavigatorObserver {
  RouteLogger(Ref ref);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logNavigation('push', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logNavigation('pop', route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null && oldRoute != null) {
      _logNavigation('replace', newRoute, oldRoute);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _logNavigation('remove', route, previousRoute);
  }

  void _logNavigation(
    String action,
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    final routeName = route.settings.name ?? 'Unknown';
    final previousRouteName = previousRoute?.settings.name ?? 'None';

    AppLogger.instance.info(
      'Navigation: $action',
      logger: 'RouteLogger',
      metadata: {
        'action': action,
        'route': routeName,
        'previousRoute': previousRouteName,
        'arguments': route.settings.arguments?.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}

/// Композитный охранник маршрутов
class CompositeRouteGuard implements RouteGuard {
  final List<RouteGuard> _guards;

  CompositeRouteGuard(this._guards);

  @override
  Future<bool> canAccess(BuildContext context, GoRouterState state) async {
    for (final guard in _guards) {
      final canAccess = await guard.canAccess(context, state);
      if (!canAccess) {
        return false;
      }
    }
    return true;
  }

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    for (final guard in _guards) {
      final redirect = guard.redirect(context, state);
      if (redirect != null) {
        return redirect;
      }
    }
    return null;
  }
}
