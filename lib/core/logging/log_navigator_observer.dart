import 'package:flutter/material.dart';
import 'app_logger.dart';

/// Наблюдатель навигации для логирования переходов между экранами
class LogNavigatorObserver extends NavigatorObserver {
  final AppLogger _logger = AppLogger.instance;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logNavigation('PUSH', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logNavigation('POP', route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logNavigation('REPLACE', newRoute, oldRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _logNavigation('REMOVE', route, previousRoute);
  }

  void _logNavigation(String action, Route<dynamic>? route, Route<dynamic>? previousRoute) {
    final String routeName = _getRouteName(route);
    final String previousRouteName = _getRouteName(previousRoute);
    
    String message = 'Navigation $action: $routeName';
    if (previousRoute != null) {
      message += ' (from: $previousRouteName)';
    }
    
    _logger.info(message);
  }

  String _getRouteName(Route<dynamic>? route) {
    if (route == null) return 'null';
    if (route.settings.name != null) return route.settings.name!;
    return route.runtimeType.toString();
  }
}