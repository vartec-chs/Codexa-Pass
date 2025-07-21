import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/analytics_service.dart';
import '../trackers/trackers.dart';
import '../providers/analytics_providers.dart';

/// Миксин для автоматического отслеживания навигации
mixin AnalyticsNavigationMixin on RouteAware {
  String get screenName;
  Map<String, dynamic>? get screenParameters => null;

  @override
  void didPush() {
    super.didPush();
    _trackScreenView();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _trackScreenView();
  }

  void _trackScreenView() {
    final analytics = AnalyticsService.instance;
    analytics.trackScreenView(
      screenName: screenName,
      parameters: screenParameters,
    );
  }
}

/// Виджет для автоматического отслеживания экранов
class AnalyticsScreenWrapper extends ConsumerWidget {
  final String screenName;
  final Widget child;
  final Map<String, dynamic>? screenParameters;

  const AnalyticsScreenWrapper({
    super.key,
    required this.screenName,
    required this.child,
    this.screenParameters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Отслеживаем просмотр экрана при построении виджета
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(analyticsStateProvider.notifier)
          .trackScreenView(
            screenName: screenName,
            parameters: screenParameters,
          );
    });

    return child;
  }
}

/// Виджет для отслеживания производительности
class AnalyticsPerformanceWrapper extends ConsumerWidget {
  final String operationName;
  final Widget child;
  final Map<String, dynamic>? additionalData;

  const AnalyticsPerformanceWrapper({
    super.key,
    required this.operationName,
    required this.child,
    this.additionalData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Отслеживаем время рендеринга виджета
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Здесь можно добавить логику отслеживания производительности
    });

    return child;
  }
}

/// Кнопка с автоматическим отслеживанием нажатий
class AnalyticsButton extends ConsumerWidget {
  final String buttonName;
  final VoidCallback? onPressed;
  final Widget child;
  final String? buttonType;
  final Map<String, dynamic>? additionalData;

  const AnalyticsButton({
    super.key,
    required this.buttonName,
    required this.onPressed,
    required this.child,
    this.buttonType,
    this.additionalData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: onPressed == null
          ? null
          : () {
              // Отслеживаем нажатие кнопки
              final currentRoute =
                  ModalRoute.of(context)?.settings.name ?? 'unknown';

              final uiTracker = UITracker(AnalyticsService.instance);
              uiTracker.trackButtonClicked(
                buttonName: buttonName,
                screenName: currentRoute,
                buttonType: buttonType,
                context: additionalData,
              );

              // Выполняем оригинальный callback
              onPressed!();
            },
      child: child,
    );
  }
}

/// Поле поиска с автоматическим отслеживанием
class AnalyticsSearchField extends ConsumerStatefulWidget {
  final String searchContext;
  final Function(String)? onSearch;
  final Function(String, int)? onResults;
  final InputDecoration? decoration;
  final Map<String, dynamic>? additionalData;

  const AnalyticsSearchField({
    super.key,
    required this.searchContext,
    this.onSearch,
    this.onResults,
    this.decoration,
    this.additionalData,
  });

  @override
  ConsumerState<AnalyticsSearchField> createState() =>
      _AnalyticsSearchFieldState();
}

class _AnalyticsSearchFieldState extends ConsumerState<AnalyticsSearchField> {
  final TextEditingController _controller = TextEditingController();
  DateTime? _searchStartTime;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration:
          widget.decoration ??
          const InputDecoration(
            hintText: 'Поиск...',
            prefixIcon: Icon(Icons.search),
          ),
      onSubmitted: _handleSearch,
      onChanged: (value) {
        if (value.isNotEmpty && _searchStartTime == null) {
          _searchStartTime = DateTime.now();
        }
      },
    );
  }

  void _handleSearch(String query) {
    if (query.isEmpty) return;

    final searchTimeMs = _searchStartTime != null
        ? DateTime.now().difference(_searchStartTime!).inMilliseconds
        : null;

    // Сбрасываем время начала поиска
    _searchStartTime = null;

    // Отслеживаем поиск
    final uiTracker = UITracker(AnalyticsService.instance);
    uiTracker.trackSearchPerformed(
      searchQuery: query,
      searchContext: widget.searchContext,
      searchTimeMs: searchTimeMs,
      context: widget.additionalData,
    );

    // Выполняем оригинальный callback
    widget.onSearch?.call(query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Менеджер интеграции аналитики с навигацией
class AnalyticsNavigationObserver extends NavigatorObserver {
  final UITracker _uiTracker;

  AnalyticsNavigationObserver(this._uiTracker);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackRouteChange(route, previousRoute, 'push');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _trackRouteChange(previousRoute, route, 'pop');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _trackRouteChange(newRoute, oldRoute, 'replace');
    }
  }

  void _trackRouteChange(
    Route<dynamic>? route,
    Route<dynamic>? previousRoute,
    String action,
  ) {
    if (route?.settings.name != null) {
      _uiTracker.trackScreenViewed(
        screenName: route!.settings.name!,
        previousScreen: previousRoute?.settings.name,
        screenParameters: route.settings.arguments as Map<String, String>?,
        context: {'navigation_action': action},
      );
    }
  }
}

/// Обработчик ошибок для аналитики
class AnalyticsErrorHandler {
  final AnalyticsService _analyticsService;

  AnalyticsErrorHandler(this._analyticsService);

  /// Обработка Flutter ошибок
  void handleFlutterError(FlutterErrorDetails details) {
    _analyticsService.trackError(
      errorType: 'flutter_error',
      errorMessage: details.exception.toString(),
      stackTrace: details.stack?.toString(),
      additionalData: {
        'library': details.library,
        'context': details.context?.toString(),
        'silent': details.silent,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Обработка асинхронных ошибок
  void handleAsyncError(Object error, StackTrace stackTrace) {
    _analyticsService.trackError(
      errorType: 'async_error',
      errorMessage: error.toString(),
      stackTrace: stackTrace.toString(),
      additionalData: {'timestamp': DateTime.now().toIso8601String()},
    );
  }

  /// Обработка пользовательских ошибок
  void handleCustomError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
    Map<String, dynamic>? context,
  }) {
    _analyticsService.trackError(
      errorType: errorType,
      errorMessage: errorMessage,
      stackTrace: stackTrace,
      additionalData: {
        'custom_error': true,
        'timestamp': DateTime.now().toIso8601String(),
        ...?context,
      },
    );
  }
}

/// Утилиты для интеграции аналитики
class AnalyticsIntegration {
  static AnalyticsService? _analyticsService;
  static late AnalyticsErrorHandler _errorHandler;

  /// Инициализация интеграции аналитики
  static Future<void> initialize(AnalyticsService analyticsService) async {
    _analyticsService = analyticsService;
    _errorHandler = AnalyticsErrorHandler(analyticsService);

    // Настраиваем обработку ошибок Flutter
    FlutterError.onError = _errorHandler.handleFlutterError;

    // Настраиваем обработку асинхронных ошибок
    PlatformDispatcher.instance.onError = (error, stack) {
      _errorHandler.handleAsyncError(error, stack);
      return true;
    };
  }

  /// Создание навигационного наблюдателя
  static NavigatorObserver createNavigationObserver() {
    if (_analyticsService == null) {
      throw StateError('AnalyticsIntegration not initialized');
    }
    return AnalyticsNavigationObserver(UITracker(_analyticsService!));
  }

  /// Получение обработчика ошибок
  static AnalyticsErrorHandler get errorHandler {
    if (_analyticsService == null) {
      throw StateError('AnalyticsIntegration not initialized');
    }
    return _errorHandler;
  }

  /// Создание трекеров
  static AuthenticationTracker createAuthTracker() {
    if (_analyticsService == null) {
      throw StateError('AnalyticsIntegration not initialized');
    }
    return AuthenticationTracker(_analyticsService!);
  }

  static PasswordTracker createPasswordTracker() {
    if (_analyticsService == null) {
      throw StateError('AnalyticsIntegration not initialized');
    }
    return PasswordTracker(_analyticsService!);
  }

  static UITracker createUITracker() {
    if (_analyticsService == null) {
      throw StateError('AnalyticsIntegration not initialized');
    }
    return UITracker(_analyticsService!);
  }

  static PerformanceTracker createPerformanceTracker() {
    if (_analyticsService == null) {
      throw StateError('AnalyticsIntegration not initialized');
    }
    return PerformanceTracker(_analyticsService!);
  }
}
