import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_logger.dart';

/// Interceptor для Riverpod провайдеров для логирования
class LogInterceptor extends ProviderObserver {
  final AppLogger _logger = AppLogger.instance;

  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    _logger.debug(
      'Provider добавлен: ${provider.name ?? provider.runtimeType}',
    );
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    _logger.debug('Provider удален: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    _logger.debug(
      'Provider обновлен: ${provider.name ?? provider.runtimeType}\n'
      'Предыдущее значение: $previousValue\n'
      'Новое значение: $newValue',
    );
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    _logger.error(
      'Ошибка в Provider: ${provider.name ?? provider.runtimeType}',
      error,
      stackTrace,
    );
  }
}

/// Interceptor для HTTP запросов (если нужен)
class HttpLogInterceptor {
  final AppLogger _logger = AppLogger.instance;

  void logRequest(String method, String url, Map<String, dynamic>? data) {
    _logger.info('HTTP Запрос: $method $url', data);
  }

  void logResponse(String method, String url, int statusCode, dynamic data) {
    _logger.info('HTTP Ответ: $method $url - Status: $statusCode', data);
  }

  void logError(
    String method,
    String url,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    _logger.error('HTTP Ошибка: $method $url', error, stackTrace);
  }
}
