import 'dart:convert';
import 'package:codexa_pass/core/logging/logging.dart';
import 'package:intl/intl.dart';

/// Красивый форматтер для консольного вывода
class PrettyConsoleFormatter implements LogFormatter {
  final bool enableColors;
  final bool enableEmoji;
  final bool showMetadata;
  final bool showStackTrace;

  const PrettyConsoleFormatter({
    this.enableColors = true,
    this.enableEmoji = true,
    this.showMetadata = true,
    this.showStackTrace = true,
  });

  static const String _reset = '\x1B[0m';
  static const String _bold = '\x1B[1m';
  static const String _dim = '\x1B[2m';

  @override
  String format(LogEntry entry) {
    final buffer = StringBuffer();

    // Временная метка
    final timeStr = DateFormat('HH:mm:ss.SSS').format(entry.timestamp);

    // Уровень с цветом и эмодзи
    final levelStr = _formatLevel(entry.level);

    // Логгер/модуль
    final loggerStr = _formatLogger(entry);

    // Основная строка
    buffer.write('$timeStr $levelStr $loggerStr ${entry.message}');

    // Метаданные
    if (showMetadata && entry.metadata != null && entry.metadata!.isNotEmpty) {
      buffer.write('\n${_formatMetadata(entry.metadata!)}');
    }

    // Ошибка
    if (entry.error != null) {
      buffer.write('\n${_formatError(entry.error!)}');
    }

    // Стек трейс
    if (showStackTrace && entry.stackTrace != null) {
      buffer.write('\n${_formatStackTrace(entry.stackTrace!)}');
    }

    return buffer.toString();
  }

  String _formatLevel(LogLevel level) {
    final emoji = enableEmoji ? '${level.emoji} ' : '';
    final color = enableColors ? level.ansiColor : '';
    final reset = enableColors ? _reset : '';
    final bold = enableColors ? _bold : '';

    return '$color$bold$emoji${level.name.padRight(7)}$reset';
  }

  String _formatLogger(LogEntry entry) {
    final parts = <String>[];

    if (entry.module != null) {
      parts.add(entry.module!);
    }

    if (entry.className != null) {
      parts.add(entry.className!);
    } else {
      parts.add(entry.logger);
    }

    if (entry.function != null) {
      parts.add(entry.function!);
    }

    final loggerStr = parts.join('.');

    final color = enableColors ? _dim : '';
    final reset = enableColors ? _reset : '';

    return '$color[$loggerStr]$reset';
  }

  String _formatMetadata(Map<String, dynamic> metadata) {
    final color = enableColors ? _dim : '';
    final reset = enableColors ? _reset : '';

    final json = const JsonEncoder.withIndent('  ').convert(metadata);
    return '$color🔍 Metadata:\n$json$reset';
  }

  String _formatError(Object error) {
    final color = enableColors ? '\x1B[31m' : ''; // Red
    final reset = enableColors ? _reset : '';

    return '$color💥 Error: $error$reset';
  }

  String _formatStackTrace(StackTrace stackTrace) {
    final color = enableColors ? _dim : '';
    final reset = enableColors ? _reset : '';

    final lines = stackTrace.toString().split('\n');
    final formattedLines = lines
        .take(10) // Показываем только первые 10 строк
        .map((line) => '   $line')
        .join('\n');

    return '$color📍 Stack trace:\n$formattedLines$reset';
  }
}

/// Форматтер для файлов (JSON)
class JsonFileFormatter implements LogFormatter {
  final bool prettyPrint;

  const JsonFileFormatter({this.prettyPrint = false});

  @override
  String format(LogEntry entry) {
    final data = {
      'id': entry.id,
      'timestamp': entry.timestamp.toIso8601String(),
      'level': entry.level.name,
      'message': entry.message,
      'sessionId': entry.sessionId,
      'logger': entry.logger,
      if (entry.module != null) 'module': entry.module,
      if (entry.context != null) 'context': entry.context,
      if (entry.className != null) 'className': entry.className,
      if (entry.line != null) 'line': entry.line,
      if (entry.function != null) 'function': entry.function,
      if (entry.metadata != null) 'metadata': entry.metadata,
      if (entry.error != null) 'error': entry.error.toString(),
      if (entry.stackTrace != null) 'stackTrace': entry.stackTrace.toString(),
      'deviceInfo': {
        'platform': entry.deviceInfo.platform,
        'version': entry.deviceInfo.version,
        'model': entry.deviceInfo.model,
        if (entry.deviceInfo.brand != null) 'brand': entry.deviceInfo.brand,
        if (entry.deviceInfo.manufacturer != null)
          'manufacturer': entry.deviceInfo.manufacturer,
        if (entry.deviceInfo.isPhysicalDevice != null)
          'isPhysicalDevice': entry.deviceInfo.isPhysicalDevice,
      },
      'appInfo': {
        'appName': entry.appInfo.appName,
        'version': entry.appInfo.version,
        'buildNumber': entry.appInfo.buildNumber,
        'packageName': entry.appInfo.packageName,
      },
    };

    if (prettyPrint) {
      return const JsonEncoder.withIndent('  ').convert(data);
    } else {
      return jsonEncode(data);
    }
  }
}

/// Простой форматтер для файлов (одна строка)
class SimpleFileFormatter implements LogFormatter {
  @override
  String format(LogEntry entry) {
    final timeStr = DateFormat(
      'yyyy-MM-dd HH:mm:ss.SSS',
    ).format(entry.timestamp);
    final levelStr = entry.level.name.padRight(7);

    final parts = <String>[
      timeStr,
      levelStr,
      '[${entry.logger}]',
      entry.message,
    ];

    if (entry.error != null) {
      parts.add('ERROR: ${entry.error}');
    }

    return parts.join(' ');
  }
}
