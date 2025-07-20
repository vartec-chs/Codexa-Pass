import 'dart:collection';
import 'dart:convert';

import '../models/app_error.dart';

/// Дедупликатор ошибок для предотвращения дублирования похожих ошибок
class ErrorDeduplicator {
  ErrorDeduplicator({
    this.timeWindow = const Duration(minutes: 5),
    this.maxCacheSize = 1000,
  });

  /// Временное окно для дедупликации
  final Duration timeWindow;

  /// Максимальный размер кеша
  final int maxCacheSize;

  /// Кеш ошибок с временными метками
  final Map<String, _ErrorCacheEntry> _errorCache = {};

  /// Счетчики повторяющихся ошибок
  final Map<String, int> _errorCounts = {};

  /// Очередь для удаления старых записей (FIFO)
  final Queue<String> _cacheQueue = Queue<String>();

  /// Проверить, является ли ошибка дубликатом
  bool isDuplicate(AppError error) {
    final key = _generateErrorKey(error);
    final now = DateTime.now();

    // Очищаем устаревшие записи
    _cleanExpiredEntries(now);

    // Проверяем наличие ошибки в кеше
    final cachedEntry = _errorCache[key];
    if (cachedEntry != null) {
      // Обновляем время последнего появления
      _errorCache[key] = cachedEntry.copyWith(
        lastSeen: now,
        count: cachedEntry.count + 1,
      );
      _errorCounts[key] = (_errorCounts[key] ?? 0) + 1;
      return true;
    }

    // Добавляем новую ошибку в кеш
    _addToCache(key, error, now);
    return false;
  }

  /// Получить количество повторений ошибки
  int getErrorCount(AppError error) {
    final key = _generateErrorKey(error);
    return _errorCounts[key] ?? 1;
  }

  /// Получить все уникальные ошибки за период
  List<AppError> getUniqueErrors({Duration? period}) {
    final now = DateTime.now();
    final cutoff = period != null ? now.subtract(period) : null;

    return _errorCache.entries
        .where(
          (entry) => cutoff == null || entry.value.firstSeen.isAfter(cutoff),
        )
        .map((entry) => entry.value.error)
        .toList();
  }

  /// Получить статистику ошибок
  Map<String, int> getErrorStatistics() {
    return Map.from(_errorCounts);
  }

  /// Очистить кеш
  void clear() {
    _errorCache.clear();
    _errorCounts.clear();
    _cacheQueue.clear();
  }

  /// Очистить устаревшие записи
  void _cleanExpiredEntries(DateTime now) {
    final cutoff = now.subtract(timeWindow);

    // Удаляем устаревшие записи
    _errorCache.removeWhere((key, entry) {
      if (entry.lastSeen.isBefore(cutoff)) {
        _errorCounts.remove(key);
        return true;
      }
      return false;
    });

    // Обновляем очередь
    while (_cacheQueue.isNotEmpty &&
        !_errorCache.containsKey(_cacheQueue.first)) {
      _cacheQueue.removeFirst();
    }
  }

  /// Добавить ошибку в кеш
  void _addToCache(String key, AppError error, DateTime now) {
    // Если кеш переполнен, удаляем самые старые записи
    while (_errorCache.length >= maxCacheSize && _cacheQueue.isNotEmpty) {
      final oldestKey = _cacheQueue.removeFirst();
      _errorCache.remove(oldestKey);
      _errorCounts.remove(oldestKey);
    }

    // Добавляем новую запись
    _errorCache[key] = _ErrorCacheEntry(
      error: error,
      firstSeen: now,
      lastSeen: now,
      count: 1,
    );
    _errorCounts[key] = 1;
    _cacheQueue.add(key);
  }

  /// Генерировать уникальный ключ для ошибки
  String _generateErrorKey(AppError error) {
    // Создаем строку для хеширования на основе критических полей
    final keyData = {
      'code': error.code,
      'module': error.module,
      'message': _normalizeMessage(error.message),
      'stackTrace': _normalizeStackTrace(error.stackTrace),
    };

    final keyString = json.encode(keyData);
    return keyString.hashCode.toString();
  }

  /// Нормализовать сообщение для сравнения
  String _normalizeMessage(String message) {
    // Удаляем динамические части (числа, UUID, временные метки)
    return message
        .replaceAll(RegExp(r'\d+'), '[NUMBER]')
        .replaceAll(
          RegExp(
            r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}',
          ),
          '[UUID]',
        )
        .replaceAll(
          RegExp(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}'),
          '[TIMESTAMP]',
        )
        .replaceAll(RegExp(r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'), '[IP]')
        .trim();
  }

  /// Нормализовать стек вызовов для сравнения
  String? _normalizeStackTrace(StackTrace? stackTrace) {
    if (stackTrace == null) return null;

    // Берем только первые несколько строк стека для сравнения
    final lines = stackTrace.toString().split('\n');
    final relevantLines = lines.take(5).toList();

    // Удаляем номера строк и адреса в памяти
    return relevantLines
        .map(
          (line) => line
              .replaceAll(RegExp(r':\d+:\d+'), ':LINE:COL')
              .replaceAll(RegExp(r'#\d+'), '#N')
              .replaceAll(RegExp(r'0x[0-9a-fA-F]+'), '0xADDRESS'),
        )
        .join('\n');
  }

  /// Получить подробную информацию об ошибке из кеша
  _ErrorCacheEntry? getCachedErrorInfo(AppError error) {
    final key = _generateErrorKey(error);
    return _errorCache[key];
  }

  /// Форсировать добавление ошибки в кеш (игнорируя дедупликацию)
  void forceAdd(AppError error) {
    final key = _generateErrorKey(error);
    final now = DateTime.now();
    _addToCache(key, error, now);
  }

  /// Проверить, не переполнен ли кеш
  bool get isCacheFull => _errorCache.length >= maxCacheSize;

  /// Получить размер кеша
  int get cacheSize => _errorCache.length;

  /// Получить информацию о состоянии дедупликатора
  Map<String, dynamic> getStatus() {
    return {
      'cacheSize': _errorCache.length,
      'maxCacheSize': maxCacheSize,
      'timeWindow': timeWindow.inMinutes,
      'totalUniqueErrors': _errorCache.length,
      'totalErrorOccurrences': _errorCounts.values.fold(
        0,
        (sum, count) => sum + count,
      ),
      'isCacheFull': isCacheFull,
    };
  }
}

/// Запись в кеше ошибок
class _ErrorCacheEntry {
  const _ErrorCacheEntry({
    required this.error,
    required this.firstSeen,
    required this.lastSeen,
    required this.count,
  });

  final AppError error;
  final DateTime firstSeen;
  final DateTime lastSeen;
  final int count;

  _ErrorCacheEntry copyWith({
    AppError? error,
    DateTime? firstSeen,
    DateTime? lastSeen,
    int? count,
  }) {
    return _ErrorCacheEntry(
      error: error ?? this.error,
      firstSeen: firstSeen ?? this.firstSeen,
      lastSeen: lastSeen ?? this.lastSeen,
      count: count ?? this.count,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error.toJson(),
      'firstSeen': firstSeen.toIso8601String(),
      'lastSeen': lastSeen.toIso8601String(),
      'count': count,
    };
  }
}
