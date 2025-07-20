import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

import '../models/app_error.dart';
import '../models/error_severity.dart';
import '../utils/error_config.dart';
import '../utils/error_deduplicator.dart';

/// Контроллер очереди ошибок с асинхронной обработкой
class ErrorQueueController {
  ErrorQueueController({
    required this.config,
    this.enableBackgroundProcessing = true,
  }) : _deduplicator = ErrorDeduplicator(
         timeWindow: config.deduplicationTimeWindow,
         maxCacheSize: config.maxErrorQueueSize,
       );

  final ErrorConfig config;
  final bool enableBackgroundProcessing;
  final ErrorDeduplicator _deduplicator;

  /// Очередь ошибок для обработки
  final Queue<_ErrorQueueItem> _errorQueue = Queue<_ErrorQueueItem>();

  /// Контроллер для стрима ошибок
  final StreamController<AppError> _errorStreamController =
      StreamController<AppError>.broadcast();

  /// Обработчики ошибок
  final List<Future<void> Function(AppError)> _errorHandlers = [];

  /// Изолят для фоновой обработки
  Isolate? _backgroundIsolate;
  SendPort? _backgroundSendPort;

  /// Флаг активности
  bool _isActive = true;

  /// Таймер для обработки очереди
  Timer? _processingTimer;

  /// Статистика
  int _processedErrorsCount = 0;
  int _droppedErrorsCount = 0;
  DateTime? _lastProcessedTime;

  /// Стрим ошибок
  Stream<AppError> get errorStream => _errorStreamController.stream;

  /// Размер очереди
  int get queueSize => _errorQueue.length;

  /// Статистика обработки
  Map<String, dynamic> get statistics => {
    'queueSize': queueSize,
    'processedCount': _processedErrorsCount,
    'droppedCount': _droppedErrorsCount,
    'lastProcessedTime': _lastProcessedTime?.toIso8601String(),
    'isActive': _isActive,
    'deduplicatorStatus': _deduplicator.getStatus(),
  };

  /// Инициализация контроллера
  Future<void> initialize() async {
    if (enableBackgroundProcessing) {
      await _initializeBackgroundProcessing();
    }

    // Запускаем периодическую обработку очереди
    _processingTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _processQueue(),
    );
  }

  /// Добавить ошибку в очередь
  Future<void> enqueueError(AppError error) async {
    if (!_isActive) return;

    // Проверяем дедупликацию если включена
    if (config.enableDeduplication) {
      if (_deduplicator.isDuplicate(error)) {
        // Обновляем счетчик, но не добавляем в очередь
        return;
      }
    }

    // Проверяем размер очереди
    if (_errorQueue.length >= config.maxErrorQueueSize) {
      // Удаляем самую старую ошибку
      final dropped = _errorQueue.removeFirst();
      _droppedErrorsCount++;

      // Логируем превышение размера очереди
      await enqueueError(_createQueueOverflowError(dropped.error));
    }

    // Добавляем ошибку в очередь
    final queueItem = _ErrorQueueItem(
      error: error,
      timestamp: DateTime.now(),
      retryCount: 0,
    );

    _errorQueue.add(queueItem);

    // Уведомляем подписчиков
    _errorStreamController.add(error);
  }

  /// Обработать очередь ошибок
  Future<void> _processQueue() async {
    if (_errorQueue.isEmpty || !_isActive) return;

    final batch = <_ErrorQueueItem>[];
    final maxBatchSize = 10;

    // Собираем батч для обработки
    while (batch.length < maxBatchSize && _errorQueue.isNotEmpty) {
      batch.add(_errorQueue.removeFirst());
    }

    // Обрабатываем ошибки
    for (final item in batch) {
      try {
        await _processErrorItem(item);
        _processedErrorsCount++;
        _lastProcessedTime = DateTime.now();
      } catch (e) {
        // Если обработка не удалась, возвращаем в очередь с увеличенным счетчиком
        if (item.retryCount < 3) {
          _errorQueue.add(item.copyWith(retryCount: item.retryCount + 1));
        } else {
          _droppedErrorsCount++;
        }
      }
    }
  }

  /// Обработать отдельную ошибку
  Future<void> _processErrorItem(_ErrorQueueItem item) async {
    final error = item.error;

    // Отправляем в фоновый изолят если доступен
    if (_backgroundSendPort != null) {
      _backgroundSendPort!.send({
        'action': 'processError',
        'error': error.toJson(),
      });
    }

    // Вызываем зарегистрированные обработчики
    for (final handler in _errorHandlers) {
      try {
        await handler(error);
      } catch (e) {
        // Игнорируем ошибки в обработчиках
      }
    }
  }

  /// Добавить обработчик ошибок
  void addErrorHandler(Future<void> Function(AppError) handler) {
    _errorHandlers.add(handler);
  }

  /// Удалить обработчик ошибок
  void removeErrorHandler(Future<void> Function(AppError) handler) {
    _errorHandlers.remove(handler);
  }

  /// Очистить очередь
  void clearQueue() {
    _errorQueue.clear();
    _deduplicator.clear();
  }

  /// Получить ошибки из очереди
  List<AppError> getQueuedErrors() {
    return _errorQueue.map((item) => item.error).toList();
  }

  /// Получить уникальные ошибки за период
  List<AppError> getUniqueErrors({Duration? period}) {
    return _deduplicator.getUniqueErrors(period: period);
  }

  /// Получить статистику ошибок
  Map<String, int> getErrorStatistics() {
    return _deduplicator.getErrorStatistics();
  }

  /// Приостановить обработку
  void pause() {
    _isActive = false;
  }

  /// Возобновить обработку
  void resume() {
    _isActive = true;
  }

  /// Закрыть контроллер
  Future<void> dispose() async {
    _isActive = false;

    _processingTimer?.cancel();

    // Завершаем обработку оставшихся ошибок
    await _processQueue();

    // Закрываем фоновый изолят
    if (_backgroundIsolate != null) {
      _backgroundIsolate!.kill(priority: Isolate.immediate);
    }

    await _errorStreamController.close();
    _errorHandlers.clear();
    _errorQueue.clear();
  }

  /// Инициализация фоновой обработки
  Future<void> _initializeBackgroundProcessing() async {
    try {
      final receivePort = ReceivePort();

      _backgroundIsolate = await Isolate.spawn(
        _backgroundIsolateEntry,
        receivePort.sendPort,
      );

      // Получаем SendPort от изолята
      final completer = Completer<SendPort>();
      receivePort.listen((message) {
        if (message is SendPort && !completer.isCompleted) {
          completer.complete(message);
        }
      });

      _backgroundSendPort = await completer.future.timeout(
        const Duration(seconds: 5),
      );
    } catch (e) {
      // Если не удалось создать изолят, работаем в основном потоке
      print('Failed to create background isolate: $e');
    }
  }

  /// Точка входа для фонового изолята
  static void _backgroundIsolateEntry(SendPort mainSendPort) {
    final receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      if (message is Map<String, dynamic>) {
        final action = message['action'] as String?;

        switch (action) {
          case 'processError':
            // Здесь можно добавить тяжелую обработку ошибок
            // Например, сериализацию, валидацию, форматирование
            _processErrorInBackground(message['error'] as Map<String, dynamic>);
            break;
        }
      }
    });
  }

  /// Обработка ошибки в фоновом изоляте
  static void _processErrorInBackground(Map<String, dynamic> errorData) {
    // Здесь выполняется тяжелая обработка ошибки
    // Например, подготовка данных для отправки, валидация, сжатие
  }

  /// Создать ошибку переполнения очереди
  AppError _createQueueOverflowError(AppError droppedError) {
    return BaseAppError(
      code: 'ERROR_QUEUE_OVERFLOW',
      message: 'Error queue overflow, dropped error: ${droppedError.code}',
      severity: ErrorSeverity.warning,
      timestamp: DateTime.now(),
      module: 'ErrorQueue',
      metadata: {
        'droppedErrorCode': droppedError.code,
        'droppedErrorMessage': droppedError.message,
        'queueSize': _errorQueue.length,
        'maxQueueSize': config.maxErrorQueueSize,
      },
      shouldReport: false,
    );
  }
}

/// Элемент очереди ошибок
class _ErrorQueueItem {
  const _ErrorQueueItem({
    required this.error,
    required this.timestamp,
    required this.retryCount,
  });

  final AppError error;
  final DateTime timestamp;
  final int retryCount;

  _ErrorQueueItem copyWith({
    AppError? error,
    DateTime? timestamp,
    int? retryCount,
  }) {
    return _ErrorQueueItem(
      error: error ?? this.error,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}
