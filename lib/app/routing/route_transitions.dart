import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Типы переходов для маршрутов
enum AppTransitions {
  none,
  fade,
  slide,
  slideUp,
  slideDown,
  scale,
  rotation,
  custom,
}

/// Конфигурация переходов
class TransitionConfig {
  final Duration duration;
  final Duration reverseDuration;
  final Curve curve;
  final Curve reverseCurve;

  const TransitionConfig({
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.reverseCurve = Curves.easeInOut,
  });
}

/// Предустановленные конфигурации переходов
class AppTransitionConfigs {
  static const fast = TransitionConfig(
    duration: Duration(milliseconds: 200),
    reverseDuration: Duration(milliseconds: 200),
    curve: Curves.easeOut,
  );

  static const normal = TransitionConfig(
    duration: Duration(milliseconds: 300),
    reverseDuration: Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );

  static const slow = TransitionConfig(
    duration: Duration(milliseconds: 500),
    reverseDuration: Duration(milliseconds: 500),
    curve: Curves.easeInOutCubic,
  );

  static const bounce = TransitionConfig(
    duration: Duration(milliseconds: 400),
    reverseDuration: Duration(milliseconds: 400),
    curve: Curves.bounceOut,
    reverseCurve: Curves.bounceIn,
  );
}

/// Построитель страниц с переходами
Page<T> buildTransitionPage<T extends Object?>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  AppTransitions transitionType = AppTransitions.fade,
  TransitionConfig config = AppTransitionConfigs.normal,
  String? name,
  Object? arguments,
  String? restorationId,
}) {
  name ??= state.name;

  switch (transitionType) {
    case AppTransitions.none:
      return NoTransitionPage<T>(
        key: state.pageKey,
        name: name,
        arguments: arguments,
        restorationId: restorationId,
        child: child,
      );

    case AppTransitions.fade:
      return CustomTransitionPage<T>(
        key: state.pageKey,
        name: name,
        arguments: arguments,
        restorationId: restorationId,
        child: child,
        transitionDuration: config.duration,
        reverseTransitionDuration: config.reverseDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(curve: config.curve).animate(animation),
            child: child,
          );
        },
      );

    case AppTransitions.slide:
      return CustomTransitionPage<T>(
        key: state.pageKey,
        name: name,
        arguments: arguments,
        restorationId: restorationId,
        child: child,
        transitionDuration: config.duration,
        reverseTransitionDuration: config.reverseDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final offsetAnimation = animation.drive(
            tween.chain(CurveTween(curve: config.curve)),
          );

          return SlideTransition(position: offsetAnimation, child: child);
        },
      );

    case AppTransitions.slideUp:
      return CustomTransitionPage<T>(
        key: state.pageKey,
        name: name,
        arguments: arguments,
        restorationId: restorationId,
        child: child,
        transitionDuration: config.duration,
        reverseTransitionDuration: config.reverseDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final offsetAnimation = animation.drive(
            tween.chain(CurveTween(curve: config.curve)),
          );

          return SlideTransition(position: offsetAnimation, child: child);
        },
      );

    case AppTransitions.slideDown:
      return CustomTransitionPage<T>(
        key: state.pageKey,
        name: name,
        arguments: arguments,
        restorationId: restorationId,
        child: child,
        transitionDuration: config.duration,
        reverseTransitionDuration: config.reverseDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, -1.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final offsetAnimation = animation.drive(
            tween.chain(CurveTween(curve: config.curve)),
          );

          return SlideTransition(position: offsetAnimation, child: child);
        },
      );

    case AppTransitions.scale:
      return CustomTransitionPage<T>(
        key: state.pageKey,
        name: name,
        arguments: arguments,
        restorationId: restorationId,
        child: child,
        transitionDuration: config.duration,
        reverseTransitionDuration: config.reverseDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: CurveTween(curve: config.curve).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      );

    case AppTransitions.rotation:
      return CustomTransitionPage<T>(
        key: state.pageKey,
        name: name,
        arguments: arguments,
        restorationId: restorationId,
        child: child,
        transitionDuration: config.duration,
        reverseTransitionDuration: config.reverseDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RotationTransition(
            turns: CurveTween(curve: config.curve).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      );

    case AppTransitions.custom:
      return _buildCustomTransitionPage<T>(
        state: state,
        child: child,
        config: config,
        name: name,
        arguments: arguments,
        restorationId: restorationId,
      );
  }
}

/// Построитель кастомного перехода
Page<T> _buildCustomTransitionPage<T extends Object?>({
  required GoRouterState state,
  required Widget child,
  required TransitionConfig config,
  String? name,
  Object? arguments,
  String? restorationId,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    name: name,
    arguments: arguments,
    restorationId: restorationId,
    child: child,
    transitionDuration: config.duration,
    reverseTransitionDuration: config.reverseDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Комбинированный переход: масштаб + поворот + затухание
      return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final curvedAnimation = CurveTween(
            curve: config.curve,
          ).animate(animation);

          return Transform.scale(
            scale: 0.8 + (0.2 * curvedAnimation.value),
            child: Transform.rotate(
              angle: (1.0 - curvedAnimation.value) * 0.1,
              child: Opacity(opacity: curvedAnimation.value, child: child),
            ),
          );
        },
        child: child,
      );
    },
  );
}

/// Специализированные переходы для разных типов экранов
class SpecializedTransitions {
  /// Переход для модальных окон
  static Page<T> buildModalTransition<T extends Object?>({
    required GoRouterState state,
    required Widget child,
    String? name,
    Object? arguments,
    String? restorationId,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final slideTween = Tween(begin: begin, end: end);
        final slideAnimation = animation.drive(
          slideTween.chain(CurveTween(curve: Curves.easeOutCubic)),
        );

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: CurveTween(curve: Curves.easeOut).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  /// Переход для всплывающих окон
  static Page<T> buildPopupTransition<T extends Object?>({
    required GoRouterState state,
    required Widget child,
    String? name,
    Object? arguments,
    String? restorationId,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
      child: child,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurveTween(curve: Curves.elasticOut).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  /// Переход для экранов настроек
  static Page<T> buildSettingsTransition<T extends Object?>({
    required GoRouterState state,
    required Widget child,
    String? name,
    Object? arguments,
    String? restorationId,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
      child: child,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final slideTween = Tween(begin: begin, end: end);
        final slideAnimation = animation.drive(
          slideTween.chain(CurveTween(curve: Curves.easeInOutCubic)),
        );

        return SlideTransition(position: slideAnimation, child: child);
      },
    );
  }
}

/// Утилиты для переходов
class TransitionUtils {
  /// Получение подходящего перехода для маршрута
  static AppTransitions getTransitionForRoute(String route) {
    // Настройки и административные страницы
    if (route.startsWith('/settings') || route.startsWith('/admin')) {
      return AppTransitions.slide;
    }

    // Модальные окна
    if (route.contains('/add-') || route.contains('/edit-')) {
      return AppTransitions.slideUp;
    }

    // Детальные страницы
    if (route.contains('/details') || route.contains('/view/')) {
      return AppTransitions.scale;
    }

    // По умолчанию
    return AppTransitions.fade;
  }

  /// Получение конфигурации для типа перехода
  static TransitionConfig getConfigForTransition(AppTransitions transition) {
    switch (transition) {
      case AppTransitions.none:
        return const TransitionConfig(duration: Duration.zero);
      case AppTransitions.fade:
        return AppTransitionConfigs.fast;
      case AppTransitions.slide:
      case AppTransitions.slideUp:
      case AppTransitions.slideDown:
        return AppTransitionConfigs.normal;
      case AppTransitions.scale:
        return AppTransitionConfigs.bounce;
      case AppTransitions.rotation:
        return AppTransitionConfigs.slow;
      case AppTransitions.custom:
        return AppTransitionConfigs.normal;
    }
  }
}
