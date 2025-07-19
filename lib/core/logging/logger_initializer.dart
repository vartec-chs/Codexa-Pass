import 'package:flutter/material.dart';
import 'app_logger.dart';
import 'logger_messages.dart';
import 'log_utils.dart';
import 'system_info.dart';

/// Утилитный класс для инициализации логгера с локализацией
class LoggerInitializer {
  /// Инициализирует логгер с контекстом локализации
  static void initializeWithContext(BuildContext context) {
    LoggerMessages.instance.setContext(context);
  }

  /// Инициализирует логгер без контекста (использует локализацию по умолчанию)
  static void initialize() {
    // Логгер будет использовать английские сообщения по умолчанию
    // если локализация недоступна
  }

  /// Инициализирует безопасную версию логгера
  static void initializeSafe() {
    // Создает безопасную версию, которая не будет падать при ошибках инициализации
  }

  /// Полная инициализация логгера с системной информацией
  static Future<void> initializeComplete({BuildContext? context}) async {
    // Инициализируем локализацию если есть контекст
    if (context != null) {
      LoggerMessages.instance.setContext(context);
    }

    // Инициализируем системную информацию
    await LogUtils.initializeSystemInfo();

    // Дожидаемся инициализации логгера
    await AppLogger.instance.waitForInitialization();

    // Логируем начало сессии с полной информацией
    await LogUtils.logSessionStart();
  }

  /// Быстрая инициализация с системной информацией (без ожидания)
  static void initializeQuick({BuildContext? context}) {
    // Инициализируем локализацию если есть контекст
    if (context != null) {
      LoggerMessages.instance.setContext(context);
    }

    // Запускаем асинхронную инициализацию в фоне
    _initializeInBackground();
  }

  /// Фоновая инициализация системной информации
  static void _initializeInBackground() async {
    try {
      await LogUtils.initializeSystemInfo();
      await LogUtils.logSessionStart();
    } catch (e) {
      // В случае ошибки просто логируем без системной информации
      AppLogger.instance.error('Ошибка фоновой инициализации логгера', e);
    }
  }

  /// Получить экземпляр логгера
  static AppLogger get logger => AppLogger.instance;

  /// Получить безопасную версию логгера
  static AppLogger get safeLogger => AppLogger.createSafe();

  /// Получить системную информацию
  static SystemInfo get systemInfo => SystemInfo.instance;
}
