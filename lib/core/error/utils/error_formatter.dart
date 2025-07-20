import '../models/app_error.dart';
import '../models/error_severity.dart';

/// Форматтер для ошибок различных типов
class ErrorFormatter {
  const ErrorFormatter({
    this.maxMessageLength = 1000,
    this.maxStackTraceLines = 50,
    this.enableSensitiveDataMasking = true,
  });

  final int maxMessageLength;
  final int maxStackTraceLines;
  final bool enableSensitiveDataMasking;

  /// Форматировать ошибку для пользователя (краткое сообщение)
  String formatUserMessage(AppError error) {
    String message = error.userFriendlyMessage;

    if (enableSensitiveDataMasking) {
      message = _maskSensitiveData(message);
    }

    return _truncateMessage(message, 200);
  }

  /// Форматировать ошибку для логирования (полная информация)
  String formatLogMessage(AppError error) {
    final buffer = StringBuffer();

    // Заголовок
    buffer.writeln('=== ERROR REPORT ===');
    buffer.writeln('ID: ${error.errorId}');
    buffer.writeln('Code: ${error.code}');
    buffer.writeln('Severity: ${error.severity.name}');
    buffer.writeln('Timestamp: ${error.timestamp.toIso8601String()}');

    if (error.module != null) {
      buffer.writeln('Module: ${error.module}');
    }

    // Сообщение
    buffer.writeln('\n--- MESSAGE ---');
    String message = error.message;
    if (enableSensitiveDataMasking) {
      message = _maskSensitiveData(message);
    }
    buffer.writeln(_truncateMessage(message, maxMessageLength));

    // Метаданные
    if (error.metadata != null && error.metadata!.isNotEmpty) {
      buffer.writeln('\n--- METADATA ---');
      final metadata = enableSensitiveDataMasking
          ? _maskMetadata(error.metadata!)
          : error.metadata!;
      metadata.forEach((key, value) {
        buffer.writeln('$key: $value');
      });
    }

    // Пользовательский контекст
    if (error.userContext != null && error.userContext!.isNotEmpty) {
      buffer.writeln('\n--- USER CONTEXT ---');
      final context = enableSensitiveDataMasking
          ? _maskMetadata(error.userContext!)
          : error.userContext!;
      context.forEach((key, value) {
        buffer.writeln('$key: $value');
      });
    }

    // Информация о повторах
    if (error.canRetry) {
      buffer.writeln('\n--- RETRY INFO ---');
      buffer.writeln('Can Retry: ${error.canRetry}');
      buffer.writeln('Max Retries: ${error.maxRetries}');
      buffer.writeln('Retry Count: ${error.retryCount}');
    }

    // Оригинальная ошибка
    if (error.originalError != null) {
      buffer.writeln('\n--- ORIGINAL ERROR ---');
      buffer.writeln(error.originalError.toString());
    }

    // Стек вызовов
    if (error.stackTrace != null) {
      buffer.writeln('\n--- STACK TRACE ---');
      buffer.writeln(_formatStackTrace(error.stackTrace!));
    }

    buffer.writeln('\n=== END ERROR REPORT ===');

    return buffer.toString();
  }

  /// Форматировать ошибку для консоли (с цветами и иконками)
  String formatConsoleMessage(AppError error) {
    final severityIcon = _getSeverityIcon(error.severity);
    final timestamp = _formatTimestamp(error.timestamp);

    String message = error.message;
    if (enableSensitiveDataMasking) {
      message = _maskSensitiveData(message);
    }

    final truncatedMessage = _truncateMessage(message, 150);

    final buffer = StringBuffer();
    buffer.write('$severityIcon [$timestamp] ');

    if (error.module != null) {
      buffer.write('[${error.module}] ');
    }

    buffer.write('[${error.code}] ');
    buffer.writeln(truncatedMessage);

    return buffer.toString();
  }

  /// Форматировать ошибку для JSON
  Map<String, dynamic> formatJsonMessage(AppError error) {
    final json = error.toJson();

    if (enableSensitiveDataMasking) {
      json['message'] = _maskSensitiveData(json['message'] as String);
      if (json['metadata'] != null) {
        json['metadata'] = _maskMetadata(
          json['metadata'] as Map<String, dynamic>,
        );
      }
      if (json['userContext'] != null) {
        json['userContext'] = _maskMetadata(
          json['userContext'] as Map<String, dynamic>,
        );
      }
    }

    // Обрезаем длинные поля
    json['message'] = _truncateMessage(
      json['message'] as String,
      maxMessageLength,
    );
    if (json['stackTrace'] != null) {
      json['stackTrace'] = _truncateStackTrace(json['stackTrace'] as String);
    }

    return json;
  }

  /// Форматировать краткую сводку ошибки
  String formatSummary(AppError error) {
    final severity = error.severity.name.toUpperCase();
    final module = error.module != null ? '[${error.module}]' : '';
    final code = error.code;

    String message = error.userFriendlyMessage;
    if (enableSensitiveDataMasking) {
      message = _maskSensitiveData(message);
    }

    return '$severity $module $code: ${_truncateMessage(message, 100)}';
  }

  /// Получить иконку для уровня критичности
  String _getSeverityIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return 'ℹ️';
      case ErrorSeverity.warning:
        return '⚠️';
      case ErrorSeverity.error:
        return '❌';
      case ErrorSeverity.critical:
        return '🔥';
      case ErrorSeverity.fatal:
        return '💀';
    }
  }

  /// Форматировать timestamp
  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }

  /// Обрезать сообщение до указанной длины
  String _truncateMessage(String message, int maxLength) {
    if (message.length <= maxLength) return message;
    return '${message.substring(0, maxLength - 3)}...';
  }

  /// Форматировать стек вызовов
  String _formatStackTrace(StackTrace stackTrace) {
    final lines = stackTrace.toString().split('\n');
    final relevantLines = lines.take(maxStackTraceLines).toList();

    return relevantLines
        .asMap()
        .entries
        .map((entry) => '${entry.key + 1}: ${entry.value}')
        .join('\n');
  }

  /// Обрезать стек вызовов
  String _truncateStackTrace(String stackTrace) {
    final lines = stackTrace.split('\n');
    if (lines.length <= maxStackTraceLines) return stackTrace;

    final truncatedLines = lines.take(maxStackTraceLines).toList();
    truncatedLines.add(
      '... (truncated ${lines.length - maxStackTraceLines} more lines)',
    );

    return truncatedLines.join('\n');
  }

  /// Маскировать чувствительные данные в сообщении
  String _maskSensitiveData(String message) {
    // Паттерны для чувствительных данных
    final patterns = [
      // Пароли
      RegExp(r'password["\s]*[:=]["\s]*[^"\s,}]+', caseSensitive: false),
      RegExp(r'pwd["\s]*[:=]["\s]*[^"\s,}]+', caseSensitive: false),
      RegExp(r'pass["\s]*[:=]["\s]*[^"\s,}]+', caseSensitive: false),

      // Токены
      RegExp(r'token["\s]*[:=]["\s]*[^"\s,}]+', caseSensitive: false),
      RegExp(r'bearer [a-zA-Z0-9._-]+', caseSensitive: false),
      RegExp(r'jwt [a-zA-Z0-9._-]+', caseSensitive: false),

      // API ключи
      RegExp(r'api[_-]?key["\s]*[:=]["\s]*[^"\s,}]+', caseSensitive: false),
      RegExp(r'secret["\s]*[:=]["\s]*[^"\s,}]+', caseSensitive: false),

      // Email адреса (частично)
      RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'),

      // Номера телефонов
      RegExp(r'\+?\d{1,4}[-.\s]?\(?\d{1,3}\)?[-.\s]?\d{1,4}[-.\s]?\d{1,4}'),

      // Кредитные карты
      RegExp(r'\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}'),
    ];

    String maskedMessage = message;

    for (final pattern in patterns) {
      maskedMessage = maskedMessage.replaceAllMapped(pattern, (match) {
        final matched = match.group(0)!;
        if (matched.contains('@')) {
          // Для email показываем только первую букву и домен
          final parts = matched.split('@');
          return '${parts[0][0]}***@${parts[1]}';
        } else if (matched.contains(
          RegExp(r'\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}'),
        )) {
          // Для карт показываем только последние 4 цифры
          final digits = matched.replaceAll(RegExp(r'[-\s]'), '');
          return '**** **** **** ${digits.substring(digits.length - 4)}';
        } else {
          // Для остальных показываем только тип данных
          return '***[MASKED]***';
        }
      });
    }

    return maskedMessage;
  }

  /// Маскировать чувствительные данные в метаданных
  Map<String, dynamic> _maskMetadata(Map<String, dynamic> metadata) {
    final sensitiveKeys = [
      'password',
      'pwd',
      'pass',
      'token',
      'secret',
      'api_key',
      'apikey',
      'authorization',
      'auth',
      'credentials',
      'key',
      'private_key',
      'client_secret',
      'session_id',
      'cookie',
    ];

    final maskedMetadata = <String, dynamic>{};

    metadata.forEach((key, value) {
      final lowerKey = key.toLowerCase();
      if (sensitiveKeys.any(
        (sensitiveKey) => lowerKey.contains(sensitiveKey),
      )) {
        maskedMetadata[key] = '***[MASKED]***';
      } else if (value is String) {
        maskedMetadata[key] = _maskSensitiveData(value);
      } else if (value is Map<String, dynamic>) {
        maskedMetadata[key] = _maskMetadata(value);
      } else {
        maskedMetadata[key] = value;
      }
    });

    return maskedMetadata;
  }
}
