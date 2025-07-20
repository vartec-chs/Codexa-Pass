/// Модуль логгирования Codexa Pass
///
/// Предоставляет комплексное решение для логгирования с поддержкой:
/// - 5 уровней логгирования (DEBUG, INFO, WARNING, ERROR, FATAL)
/// - Метаданных (device info, session ID, app version)
/// - Асинхронной обработки
/// - Структурированных логов
/// - Красивого вывода в консоль и файлы
/// - Ротации файлов по датам
/// - Конфигурируемых уровней для разных сред
/// - Фильтрации по модулям
/// - Маскировки чувствительных данных
/// - Краш репортов
/// - Интеграции с Riverpod

library codexa_logging;

// Основные модели
export 'models/log_level.dart';
export 'models/log_entry.dart';

// Интерфейсы
export 'interfaces/logging_interfaces.dart';

// Основной логгер
export 'app_logger.dart';

// Провайдеры для Riverpod
export 'providers/logging_providers.dart';

// Форматтеры
export 'formatters/log_formatters.dart';

// Обработчики
export 'handlers/base_handlers.dart';
export 'handlers/file_handlers.dart';

// Сервисы
export 'services/system_info_provider.dart';
export 'services/sensitive_data_masker.dart';

// Утилиты
export 'utils/logging_utils.dart';
