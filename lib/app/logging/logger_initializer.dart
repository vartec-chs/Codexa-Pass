import 'package:flutter/material.dart';
import 'app_logger.dart';
import 'logger_messages.dart';

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

  /// Получить экземпляр логгера
  static AppLogger get logger => AppLogger.instance;

  /// Получить безопасную версию логгера
  static AppLogger get safeLogger => AppLogger.createSafe();
}
