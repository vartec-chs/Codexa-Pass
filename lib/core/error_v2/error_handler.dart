// pubspec.yaml
/*
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.0.0
  flutter_riverpod: ^2.4.0
  freezed_annotation: ^2.4.0
  uuid: ^4.0.0
  lottie: ^3.0.0

dev_dependencies:
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_annotation: ^4.8.1
  json_serializable: ^6.7.1
*/

// lib/errors/error_context.dart
import 'dart:async';
import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;

part 'error_handler.freezed.dart';

class ErrorContext {
  final String screenName;
  final String? userId;
  final Map<String, dynamic>? requestParams;
  final String correlationId;
  final DateTime timestamp;

  const ErrorContext({
    required this.screenName,
    this.userId,
    this.requestParams,
    required this.correlationId,
    required this.timestamp,
  });

  factory ErrorContext.create({
    required String screenName,
    String? userId,
    Map<String, dynamic>? requestParams,
  }) {
    return ErrorContext(
      screenName: screenName,
      userId: userId,
      requestParams: requestParams,
      correlationId: const Uuid().v4(),
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'screenName': screenName,
    'userId': userId,
    'requestParams': requestParams,
    'correlationId': correlationId,
    'timestamp': timestamp.toIso8601String(),
  };
}

@freezed
sealed class AppError with _$AppError {
  const AppError._();

  const factory AppError.network(
    String message,
    ErrorContext context, {
    @Default(false) bool isCritical,
  }) = NetworkError;

  const factory AppError.timeout(
    String message,
    ErrorContext context, {
    @Default(false) bool isCritical,
  }) = TimeoutError;

  const factory AppError.http(
    int statusCode,
    String message,
    ErrorContext context, {
    @Default(false) bool isCritical,
  }) = HttpError;

  const factory AppError.authentication(
    String message,
    ErrorContext context, {
    @Default(true) bool isCritical,
  }) = AuthError;

  const factory AppError.validation(
    String message,
    ErrorContext context, {
    @Default(false) bool isCritical,
  }) = ValidationError;

  const factory AppError.unknown(
    String message,
    ErrorContext context, {
    @Default(true) bool isCritical,
  }) = UnknownError;

  bool get shouldShowFullScreen => when(
    network: (_, __, isCritical) => isCritical,
    timeout: (_, __, isCritical) => isCritical,
    http: (statusCode, _, __, isCritical) => isCritical || statusCode >= 500,
    authentication: (_, __, isCritical) => isCritical,
    validation: (_, __, isCritical) => isCritical,
    unknown: (_, __, isCritical) => isCritical,
  );

  String get userFriendlyMessage => when(
    network: (message, _, __) => 'Проблемы с сетью: $message',
    timeout: (message, _, __) => 'Превышено время ожидания',
    http: (statusCode, message, _, __) => statusCode >= 500
        ? 'Ошибка сервера ($statusCode)'
        : 'Ошибка запроса: $message',
    authentication: (message, _, __) => 'Ошибка авторизации',
    validation: (message, _, __) => message,
    unknown: (message, _, __) => 'Неизвестная ошибка: $message',
  );
}

class ErrorHandler {
  static const int _maxErrorQueueSize = 50;
  final Queue<AppError> _errorQueue = Queue<AppError>();
  final UIErrorNotifier? _uiNotifier;

  ErrorHandler({UIErrorNotifier? uiNotifier}) : _uiNotifier = uiNotifier;

  void reportError(AppError error) {
    _addToQueue(error);
    _logError(error);
    _notifyUI(error);
  }

  void _addToQueue(AppError error) {
    if (_errorQueue.length >= _maxErrorQueueSize) {
      _errorQueue.removeFirst();
    }
    _errorQueue.addLast(error);
  }

  void _logError(AppError error) {
    final logMessage =
        '''
    ❌ [${error.runtimeType}] ${error.userFriendlyMessage}
    📍 Screen: ${error.context.screenName}
    🔗 Correlation ID: ${error.context.correlationId}
    ⏰ Timestamp: ${error.context.timestamp}
    👤 User ID: ${error.context.userId ?? 'Anonymous'}
    📋 Request Params: ${error.context.requestParams}
    ''';

    developer.log(
      logMessage,
      name: 'ErrorHandler',
      error: error,
      level: error.shouldShowFullScreen ? 1000 : 800,
    );
  }

  void _notifyUI(AppError error) {
    _uiNotifier?.showError(error);
  }

  List<AppError> get recentErrors => _errorQueue.toList();

  void clearErrors() {
    _errorQueue.clear();
  }
}

class UIErrorNotifier extends ChangeNotifier {
  final GlobalKey<NavigatorState> navigatorKey;
  AppError? _currentFullScreenError;
  StreamController<AppError>? _errorStream;

  UIErrorNotifier({required this.navigatorKey}) {
    _errorStream = StreamController<AppError>.broadcast();
  }

  Stream<AppError> get errorStream => _errorStream!.stream;

  AppError? get currentFullScreenError => _currentFullScreenError;

  void showError(AppError error) {
    if (error.shouldShowFullScreen) {
      _showFullScreenError(error);
    } else {
      _showSnackbarError(error);
    }

    _errorStream?.add(error);
    notifyListeners();
  }

  void _showFullScreenError(AppError error) {
    _currentFullScreenError = error;
    notifyListeners();
  }

  void _showSnackbarError(AppError error) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ErrorSnackbar.show(context, error);
    }
  }

  void dismissFullScreenError() {
    _currentFullScreenError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _errorStream?.close();
    super.dispose();
  }
}

class ErrorSnackbar {
  static void show(BuildContext context, AppError error) {
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: colorScheme.errorContainer,
        content: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error.userFriendlyMessage,
                style: TextStyle(
                  color: colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Подробнее',
          textColor: colorScheme.primary,
          onPressed: () => _showDetails(context, error),
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void _showDetails(BuildContext context, AppError error) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ErrorDetailsSheet(error: error),
    );
  }
}

class ErrorDetailsSheet extends StatelessWidget {
  final AppError error;

  const ErrorDetailsSheet({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildErrorInfo(context),
          const SizedBox(height: 24),
          _buildActions(context),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Детали ошибки',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildErrorInfo(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Тип ошибки:', error.runtimeType.toString(), textTheme),
        _buildInfoRow('Сообщение:', error.userFriendlyMessage, textTheme),
        _buildInfoRow('Экран:', error.context.screenName, textTheme),
        _buildInfoRow('ID корреляции:', error.context.correlationId, textTheme),
        _buildInfoRow('Время:', error.context.timestamp.toString(), textTheme),
        if (error.context.userId != null)
          _buildInfoRow('Пользователь:', error.context.userId!, textTheme),
        if (error.context.requestParams != null)
          _buildInfoRow(
            'Параметры:',
            error.context.requestParams.toString(),
            textTheme,
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        OutlinedButton.icon(
          onPressed: () => _copyToClipboard(context),
          icon: const Icon(Icons.copy),
          label: const Text('Скопировать'),
        ),
        FilledButton.icon(
          onPressed: () => _reportToSupport(context),
          icon: const Icon(Icons.support_agent),
          label: const Text('В поддержку'),
        ),
      ],
    );
  }

  void _copyToClipboard(BuildContext context) {
    final errorInfo =
        '''
Тип ошибки: ${error.runtimeType}
Сообщение: ${error.userFriendlyMessage}
Экран: ${error.context.screenName}
ID корреляции: ${error.context.correlationId}
Время: ${error.context.timestamp}
${error.context.userId != null ? 'Пользователь: ${error.context.userId}\n' : ''}
${error.context.requestParams != null ? 'Параметры: ${error.context.requestParams}\n' : ''}
    ''';

    Clipboard.setData(ClipboardData(text: errorInfo));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Информация скопирована в буфер обмена'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _reportToSupport(BuildContext context) {
    // Здесь можно интегрировать отправку в службу поддержки
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Отчет отправлен в службу поддержки'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop();
  }
}

class FullScreenErrorOverlay extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final VoidCallback? onReportError;
  final VoidCallback? onGoHome;
  final VoidCallback? onDismiss;

  const FullScreenErrorOverlay({
    super.key,
    required this.error,
    this.onRetry,
    this.onReportError,
    this.onGoHome,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surface.withOpacity(0.95),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Анимированная иконка ошибки
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Icon(
                      Icons.error_outline,
                      size: 80,
                      color: colorScheme.error,
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Заголовок
              Text(
                'Что-то пошло не так',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Описание ошибки
              Text(
                error.userFriendlyMessage,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // ID корреляции
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'ID: ${error.context.correlationId.substring(0, 8)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Кнопки действий
              Column(
                children: [
                  if (onRetry != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Повторить'),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          onReportError ?? () => _showErrorDetails(context),
                      icon: const Icon(Icons.bug_report),
                      label: const Text('Отправить отчет'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (onGoHome != null)
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: onGoHome,
                        icon: const Icon(Icons.home),
                        label: const Text('На главную'),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // Кнопка закрытия
              if (onDismiss != null)
                TextButton(
                  onPressed: onDismiss,
                  child: Text(
                    'Закрыть',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Детали ошибки',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Text(
                      error.context.toJson().toString(),
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ErrorPlaceholderWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final Color? iconColor;

  const ErrorPlaceholderWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.cloud_off,
    this.onRetry,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: iconColor ?? colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ApiService {
  late final Dio _dio;
  final ErrorHandler _errorHandler;

  ApiService({required ErrorHandler errorHandler})
    : _errorHandler = errorHandler {
    _dio = Dio();
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Добавляем correlation ID в заголовки
          options.headers['X-Correlation-ID'] = const Uuid().v4();
          handler.next(options);
        },
        onError: (error, handler) {
          final appError = _mapDioErrorToAppError(error);
          _errorHandler.reportError(appError);
          handler.next(error);
        },
      ),
    );
  }

  AppError _mapDioErrorToAppError(DioException error) {
    final context = _extractErrorContext(error);

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppError.timeout('Превышено время ожидания запроса', context);

      case DioExceptionType.connectionError:
        return AppError.network('Ошибка подключения к серверу', context);

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        return AppError.http(
          statusCode,
          _getHttpErrorMessage(statusCode),
          context,
          isCritical: statusCode >= 500,
        );

      case DioExceptionType.cancel:
        return AppError.network('Запрос был отменен', context);

      default:
        return AppError.unknown(
          error.message ?? 'Неизвестная ошибка сети',
          context,
        );
    }
  }

  ErrorContext _extractErrorContext(DioException error) {
    final correlationId =
        error.requestOptions.headers['X-Correlation-ID'] as String? ??
        const Uuid().v4();

    // Можно получить screenName из дополнительных параметров
    final screenName =
        error.requestOptions.extra['screenName'] as String? ?? 'Unknown';
    final userId = error.requestOptions.extra['userId'] as String?;

    return ErrorContext(
      screenName: screenName,
      userId: userId,
      requestParams: {
        'url': error.requestOptions.uri.toString(),
        'method': error.requestOptions.method,
        'data': error.requestOptions.data,
      },
      correlationId: correlationId,
      timestamp: DateTime.now(),
    );
  }

  String _getHttpErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Неверный запрос';
      case 401:
        return 'Необходима авторизация';
      case 403:
        return 'Доступ запрещен';
      case 404:
        return 'Ресурс не найден';
      case 429:
        return 'Слишком много запросов';
      case 500:
        return 'Внутренняя ошибка сервера';
      case 502:
        return 'Сервер недоступен';
      case 503:
        return 'Сервис временно недоступен';
      default:
        return 'HTTP ошибка $statusCode';
    }
  }

  // Пример метода API с контекстом
  Future<T> request<T>(
    String path, {
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? screenName,
    String? userId,
  }) async {
    final options = Options(
      method: method,
      extra: {'screenName': screenName ?? 'Unknown', 'userId': userId},
    );

    final response = await _dio.request<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );

    return response.data as T;
  }
}

final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});

final uiErrorNotifierProvider = ChangeNotifierProvider<UIErrorNotifier>((ref) {
  final navigatorKey = ref.read(navigatorKeyProvider);
  return UIErrorNotifier(navigatorKey: navigatorKey);
});

final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  final uiNotifier = ref.read(uiErrorNotifierProvider);
  return ErrorHandler(uiNotifier: uiNotifier);
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final errorHandler = ref.read(errorHandlerProvider);
  return ApiService(errorHandler: errorHandler);
});

// lib/widgets/error_boundary.dart

class ErrorBoundary extends ConsumerWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiErrorNotifier = ref.watch(uiErrorNotifierProvider);
    final currentError = uiErrorNotifier.currentFullScreenError;

    return Stack(
      children: [
        child,
        if (currentError != null)
          FullScreenErrorOverlay(
            error: currentError,
            onRetry: () {
              // Логика повторного выполнения
              uiErrorNotifier.dismissFullScreenError();
            },
            onReportError: () {
              // Логика отправки отчета
            },
            onGoHome: () {
              // Переход на главную
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (route) => false);
              uiErrorNotifier.dismissFullScreenError();
            },
            onDismiss: () {
              uiErrorNotifier.dismissFullScreenError();
            },
          ),
      ],
    );
  }
}

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();

      // Глобальная обработка ошибок Flutter
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        // Здесь можно добавить логику отправки в ErrorHandler
      };

      runApp(const ProviderScope(child: MyApp()));
    },
    (error, stackTrace) {
      // Глобальная обработка асинхронных ошибок
      debugPrint('Глобальная ошибка: $error');
      debugPrint('Stack trace: $stackTrace');
    },
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigatorKey = ref.read(navigatorKeyProvider);

    return MaterialApp(
      title: 'Error System Demo',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return ErrorBoundary(child: child ?? const SizedBox.shrink());
      },
      home: const HomeScreen(),
      routes: {
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

// Example screens to demonstrate error handling
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiService = ref.read(apiServiceProvider);
    final errorHandler = ref.read(errorHandlerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Error System Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Демонстрация системы ошибок',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Кнопки для тестирования различных типов ошибок
            ElevatedButton(
              onPressed: () => _simulateNetworkError(errorHandler),
              child: const Text('Сетевая ошибка'),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: () => _simulateTimeoutError(errorHandler),
              child: const Text('Ошибка таймаута'),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: () => _simulateHttpError(errorHandler),
              child: const Text('HTTP 500 ошибка'),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: () => _simulateAuthError(errorHandler),
              child: const Text('Ошибка авторизации (критическая)'),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: () => _simulateValidationError(errorHandler),
              child: const Text('Ошибка валидации'),
            ),
            const SizedBox(height: 24),

            // Пример API запроса
            ElevatedButton.icon(
              onPressed: () => _makeApiRequest(apiService),
              icon: const Icon(Icons.cloud_download),
              label: const Text('Тестовый API запрос'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),

            const SizedBox(height: 24),

            // Навигация к другим экранам
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/profile'),
                    child: const Text('Профиль'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                    child: const Text('Настройки'),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Информация о последних ошибках
            Consumer(
              builder: (context, ref, child) {
                final errorHandler = ref.read(errorHandlerProvider);
                final recentErrors = errorHandler.recentErrors;

                if (recentErrors.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Последние ошибки (${recentErrors.length})',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Последняя: ${recentErrors.last.userFriendlyMessage}',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => errorHandler.clearErrors(),
                          child: const Text('Очистить историю'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _simulateNetworkError(ErrorHandler errorHandler) {
    final context = ErrorContext.create(
      screenName: 'HomeScreen',
      userId: 'user123',
      requestParams: {'action': 'simulate_network_error'},
    );

    errorHandler.reportError(
      AppError.network('Не удается подключиться к серверу', context),
    );
  }

  void _simulateTimeoutError(ErrorHandler errorHandler) {
    final context = ErrorContext.create(
      screenName: 'HomeScreen',
      userId: 'user123',
    );

    errorHandler.reportError(
      AppError.timeout('Запрос занял слишком много времени', context),
    );
  }

  void _simulateHttpError(ErrorHandler errorHandler) {
    final context = ErrorContext.create(
      screenName: 'HomeScreen',
      userId: 'user123',
      requestParams: {'endpoint': '/api/data', 'method': 'GET'},
    );

    errorHandler.reportError(
      AppError.http(
        500,
        'Внутренняя ошибка сервера',
        context,
        isCritical: true,
      ),
    );
  }

  void _simulateAuthError(ErrorHandler errorHandler) {
    final context = ErrorContext.create(
      screenName: 'HomeScreen',
      userId: 'user123',
    );

    errorHandler.reportError(
      AppError.authentication('Токен авторизации истек', context),
    );
  }

  void _simulateValidationError(ErrorHandler errorHandler) {
    final context = ErrorContext.create(
      screenName: 'HomeScreen',
      userId: 'user123',
      requestParams: {'field': 'email', 'value': 'invalid-email'},
    );

    errorHandler.reportError(
      AppError.validation('Введите правильный email адрес', context),
    );
  }

  Future<void> _makeApiRequest(ApiService apiService) async {
    try {
      // Симуляция реального API запроса
      await apiService.request(
        'https://jsonplaceholder.typicode.com/posts/1',
        screenName: 'HomeScreen',
        userId: 'user123',
      );
    } catch (e) {
      // Ошибка будет автоматически обработана в ApiService
      debugPrint('API request failed: $e');
    }
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 64),
            SizedBox(height: 16),
            Text('Экран профиля'),
            SizedBox(height: 8),
            Text(
              'Здесь может произойти ошибка загрузки данных пользователя',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _simulateProfileError(ref),
        child: const Icon(Icons.error),
      ),
    );
  }

  void _simulateProfileError(WidgetRef ref) {
    final errorHandler = ref.read(errorHandlerProvider);
    final context = ErrorContext.create(
      screenName: 'ProfileScreen',
      userId: 'user123',
      requestParams: {'action': 'load_profile'},
    );

    errorHandler.reportError(
      AppError.network('Не удается загрузить данные профиля', context),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            leading: Icon(Icons.person),
            title: Text('Аккаунт'),
            subtitle: Text('Управление аккаунтом'),
          ),
          const ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Уведомления'),
            subtitle: Text('Настройка уведомлений'),
          ),
          const ListTile(
            leading: Icon(Icons.security),
            title: Text('Безопасность'),
            subtitle: Text('Пароль и двухфакторная аутентификация'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Тестировать ошибки'),
            subtitle: const Text('Различные типы ошибок для демонстрации'),
            onTap: () => _showErrorTestDialog(context, ref),
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('О приложении'),
            subtitle: Text('Версия 1.0.0'),
          ),
        ],
      ),
    );
  }

  void _showErrorTestDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Тестирование ошибок'),
        content: const Text(
          'Выберите тип ошибки для демонстрации системы обработки ошибок.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _simulateSettingsError(ref, critical: false);
            },
            child: const Text('Обычная ошибка'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _simulateSettingsError(ref, critical: true);
            },
            child: const Text('Критическая ошибка'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  void _simulateSettingsError(WidgetRef ref, {required bool critical}) {
    final errorHandler = ref.read(errorHandlerProvider);
    final context = ErrorContext.create(
      screenName: 'SettingsScreen',
      userId: 'user123',
      requestParams: {'action': 'save_settings', 'critical': critical},
    );

    if (critical) {
      errorHandler.reportError(
        AppError.unknown('Критическая ошибка в настройках', context),
      );
    } else {
      errorHandler.reportError(
        AppError.validation('Некорректное значение в настройках', context),
      );
    }
  }
}

class AsyncErrorWidget<T> extends StatelessWidget {
  final AsyncValue<T> asyncValue;
  final Widget Function(T data) dataBuilder;
  final VoidCallback? onRetry;
  final Widget? loadingWidget;
  final String? errorTitle;
  final String? errorMessage;

  const AsyncErrorWidget({
    super.key,
    required this.asyncValue,
    required this.dataBuilder,
    this.onRetry,
    this.loadingWidget,
    this.errorTitle,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      data: dataBuilder,
      loading: () =>
          loadingWidget ?? const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => ErrorPlaceholderWidget(
        title: errorTitle ?? 'Ошибка загрузки',
        message: errorMessage ?? 'Не удалось загрузить данные',
        onRetry: onRetry,
      ),
    );
  }
}

extension DioErrorExtensions on Exception {
  AppError toAppError({
    required String screenName,
    String? userId,
    Map<String, dynamic>? requestParams,
  }) {
    final context = ErrorContext.create(
      screenName: screenName,
      userId: userId,
      requestParams: requestParams,
    );

    // Базовая логика преобразования Exception в AppError
    if (toString().contains('timeout')) {
      return AppError.timeout(toString(), context);
    } else if (toString().contains('network') ||
        toString().contains('connection')) {
      return AppError.network(toString(), context);
    } else {
      return AppError.unknown(toString(), context);
    }
  }
}

extension AppErrorExtensions on AppError {
  /// Возвращает цвет для UI элементов в зависимости от типа ошибки
  Color getErrorColor(ColorScheme colorScheme) {
    return when(
      network: (_, __, ___) => colorScheme.error,
      timeout: (_, __, ___) => Colors.orange,
      http: (statusCode, _, __, ___) =>
          statusCode >= 500 ? colorScheme.error : Colors.amber,
      authentication: (_, __, ___) => Colors.red.shade700,
      validation: (_, __, ___) => Colors.orange.shade600,
      unknown: (_, __, ___) => colorScheme.error,
    );
  }

  /// Возвращает подходящую иконку для типа ошибки
  IconData getErrorIcon() {
    return when(
      network: (_, __, ___) => Icons.wifi_off,
      timeout: (_, __, ___) => Icons.timer_off,
      http: (_, __, ___, ____) => Icons.cloud_off,
      authentication: (_, __, ___) => Icons.lock,
      validation: (_, __, ___) => Icons.warning,
      unknown: (_, __, ___) => Icons.error,
    );
  }
}
