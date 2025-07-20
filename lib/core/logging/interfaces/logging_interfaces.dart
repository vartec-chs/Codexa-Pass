import '../models/log_entry.dart';
import '../models/log_level.dart';

/// Абстрактный интерфейс для обработчика логов
abstract class LogHandler {
  /// Обработать запись лога
  Future<void> handle(LogEntry entry);

  /// Закрыть обработчик и освободить ресурсы
  Future<void> close();

  /// Проверить, может ли обработчик обработать данный уровень лога
  bool canHandle(LogLevel level);
}

/// Абстрактный интерфейс для форматирования логов
abstract class LogFormatter {
  /// Форматировать запись лога в строку
  String format(LogEntry entry);
}

/// Абстрактный интерфейс для фильтрации логов
abstract class LogFilterInterface {
  /// Проверить, проходит ли запись лога через фильтр
  bool shouldLog(LogEntry entry);
}

/// Абстрактный интерфейс для хранения логов
abstract class LogStorage {
  /// Сохранить запись лога
  Future<void> store(LogEntry entry);

  /// Получить записи логов по фильтру
  Future<List<LogEntry>> getLogs(LogFilter filter);

  /// Очистить старые логи
  Future<void> cleanup();

  /// Получить размер хранилища в байтах
  Future<int> getStorageSize();

  /// Закрыть хранилище
  Future<void> close();
}

/// Абстрактный интерфейс для получения информации о системе
abstract class SystemInfoProvider {
  /// Получить информацию об устройстве
  Future<DeviceInfo> getDeviceInfo();

  /// Получить информацию о приложении
  Future<AppInfo> getAppInfo();
}

/// Абстрактный интерфейс для маскировки чувствительных данных
abstract class SensitiveDataMasker {
  /// Замаскировать чувствительные данные в сообщении
  String mask(String message);

  /// Замаскировать чувствительные данные в метаданных
  Map<String, dynamic>? maskMetadata(Map<String, dynamic>? metadata);
}
