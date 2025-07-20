/// Система локализации ошибок v2 с поддержкой множественных языков
/// и контекстно-зависимых сообщений

import 'error_base.dart';
import 'error_types.dart';

/// Интерфейс для локализации ошибок
abstract class ErrorLocalizerV2 {
  /// Получение локализованного сообщения для ошибки
  String getLocalizedMessage(AppErrorV2 error);

  /// Получение локализованного технического описания
  String? getLocalizedTechnicalDetails(AppErrorV2 error);

  /// Получение локализованных рекомендаций по устранению
  String? getLocalizedSolution(AppErrorV2 error);

  /// Получение локализованного заголовка для уведомления
  String getLocalizedTitle(AppErrorV2 error);

  /// Текущий язык локализации
  String get currentLocale;

  /// Установка языка локализации
  void setLocale(String locale);

  /// Доступные языки
  List<String> get supportedLocales;
}

/// Базовая реализация локализатора ошибок
class DefaultErrorLocalizerV2 implements ErrorLocalizerV2 {
  String _currentLocale = 'ru';

  @override
  String get currentLocale => _currentLocale;

  @override
  void setLocale(String locale) {
    if (supportedLocales.contains(locale)) {
      _currentLocale = locale;
    }
  }

  @override
  List<String> get supportedLocales => ['ru', 'en'];

  @override
  String getLocalizedMessage(AppErrorV2 error) {
    return _getMessageByCategory(error);
  }

  @override
  String? getLocalizedTechnicalDetails(AppErrorV2 error) {
    if (error.technicalDetails?.isNotEmpty == true) {
      return _getTechnicalDetailsTemplate(error);
    }
    return null;
  }

  @override
  String? getLocalizedSolution(AppErrorV2 error) {
    return _getSolutionByError(error);
  }

  @override
  String getLocalizedTitle(AppErrorV2 error) {
    return _getTitleBySeverity(error.severity);
  }

  /// Получение сообщения по категории и типу ошибки
  String _getMessageByCategory(AppErrorV2 error) {
    switch (error.category) {
      case ErrorCategoryV2.authentication:
        return _getAuthMessage(error as AuthenticationErrorV2);
      case ErrorCategoryV2.encryption:
        return _getEncryptionMessage(error as EncryptionErrorV2);
      case ErrorCategoryV2.database:
        return _getDatabaseMessage(error as DatabaseErrorV2);
      case ErrorCategoryV2.network:
        return _getNetworkMessage(error as NetworkErrorV2);
      case ErrorCategoryV2.validation:
        return _getValidationMessage(error as ValidationErrorV2);
      default:
        return _getGenericMessage(error);
    }
  }

  /// Сообщения для ошибок аутентификации
  String _getAuthMessage(AuthenticationErrorV2 error) {
    final messages = _currentLocale == 'ru' ? _authMessagesRu : _authMessagesEn;
    return messages[error.errorType] ?? error.message;
  }

  /// Сообщения для ошибок шифрования
  String _getEncryptionMessage(EncryptionErrorV2 error) {
    final messages = _currentLocale == 'ru'
        ? _encryptionMessagesRu
        : _encryptionMessagesEn;
    return messages[error.errorType] ?? error.message;
  }

  /// Сообщения для ошибок базы данных
  String _getDatabaseMessage(DatabaseErrorV2 error) {
    final messages = _currentLocale == 'ru'
        ? _databaseMessagesRu
        : _databaseMessagesEn;
    return messages[error.errorType] ?? error.message;
  }

  /// Сообщения для сетевых ошибок
  String _getNetworkMessage(NetworkErrorV2 error) {
    final messages = _currentLocale == 'ru'
        ? _networkMessagesRu
        : _networkMessagesEn;
    return messages[error.errorType] ?? error.message;
  }

  /// Сообщения для ошибок валидации
  String _getValidationMessage(ValidationErrorV2 error) {
    final messages = _currentLocale == 'ru'
        ? _validationMessagesRu
        : _validationMessagesEn;
    var message = messages[error.errorType] ?? error.message;

    // Подстановка имени поля
    if (error.field != null) {
      message = message.replaceAll('{field}', error.field!);
    }

    return message;
  }

  /// Общие сообщения для других типов ошибок
  String _getGenericMessage(AppErrorV2 error) {
    return error.message;
  }

  /// Шаблон для технических деталей
  String _getTechnicalDetailsTemplate(AppErrorV2 error) {
    final templates = _currentLocale == 'ru'
        ? _technicalDetailsTemplatesRu
        : _technicalDetailsTemplatesEn;

    final template = templates[error.category.name] ?? templates['generic']!;
    return template.replaceAll('{details}', error.technicalDetails ?? '');
  }

  /// Получение заголовка по уровню критичности
  String _getTitleBySeverity(ErrorSeverityV2 severity) {
    final titles = _currentLocale == 'ru'
        ? _severityTitlesRu
        : _severityTitlesEn;
    return titles[severity] ?? titles[ErrorSeverityV2.error]!;
  }

  /// Получение рекомендаций по устранению
  String? _getSolutionByError(AppErrorV2 error) {
    final solutions = _currentLocale == 'ru' ? _solutionsRu : _solutionsEn;

    // Специфичные решения по типу ошибки
    var solution = solutions[error.category]?[error.type];

    if (solution == null) {
      // Общие решения по категории
      solution = solutions['generic']?[error.category.name];
    }

    return solution;
  }

  // Русские сообщения для ошибок аутентификации
  static const Map<AuthenticationErrorType, String> _authMessagesRu = {
    AuthenticationErrorType.invalidCredentials: 'Неверные учетные данные',
    AuthenticationErrorType.userNotFound: 'Пользователь не найден',
    AuthenticationErrorType.userAlreadyExists: 'Пользователь уже существует',
    AuthenticationErrorType.sessionExpired:
        'Сессия истекла, необходимо войти заново',
    AuthenticationErrorType.accountLocked: 'Аккаунт заблокирован',
    AuthenticationErrorType.biometricNotAvailable:
        'Биометрическая аутентификация недоступна',
    AuthenticationErrorType.biometricNotEnrolled:
        'Биометрические данные не настроены',
    AuthenticationErrorType.biometricFailed:
        'Биометрическая аутентификация не удалась',
    AuthenticationErrorType.pinIncorrect: 'Неверный PIN-код',
    AuthenticationErrorType.masterPasswordIncorrect: 'Неверный мастер-пароль',
    AuthenticationErrorType.twoFactorRequired:
        'Требуется двухфакторная аутентификация',
    AuthenticationErrorType.twoFactorInvalid:
        'Неверный код двухфакторной аутентификации',
    AuthenticationErrorType.tokenExpired: 'Токен истек',
    AuthenticationErrorType.tokenInvalid: 'Недействительный токен',
    AuthenticationErrorType.permissionDenied: 'Доступ запрещен',
  };

  // Английские сообщения для ошибок аутентификации
  static const Map<AuthenticationErrorType, String> _authMessagesEn = {
    AuthenticationErrorType.invalidCredentials: 'Invalid credentials',
    AuthenticationErrorType.userNotFound: 'User not found',
    AuthenticationErrorType.userAlreadyExists: 'User already exists',
    AuthenticationErrorType.sessionExpired:
        'Session expired, please log in again',
    AuthenticationErrorType.accountLocked: 'Account is locked',
    AuthenticationErrorType.biometricNotAvailable:
        'Biometric authentication not available',
    AuthenticationErrorType.biometricNotEnrolled: 'Biometric data not set up',
    AuthenticationErrorType.biometricFailed: 'Biometric authentication failed',
    AuthenticationErrorType.pinIncorrect: 'Incorrect PIN',
    AuthenticationErrorType.masterPasswordIncorrect:
        'Incorrect master password',
    AuthenticationErrorType.twoFactorRequired:
        'Two-factor authentication required',
    AuthenticationErrorType.twoFactorInvalid:
        'Invalid two-factor authentication code',
    AuthenticationErrorType.tokenExpired: 'Token expired',
    AuthenticationErrorType.tokenInvalid: 'Invalid token',
    AuthenticationErrorType.permissionDenied: 'Permission denied',
  };

  // Русские сообщения для ошибок шифрования
  static const Map<EncryptionErrorType, String> _encryptionMessagesRu = {
    EncryptionErrorType.keyGenerationFailed:
        'Не удалось создать ключ шифрования',
    EncryptionErrorType.encryptionFailed: 'Ошибка шифрования данных',
    EncryptionErrorType.decryptionFailed: 'Ошибка расшифровки данных',
    EncryptionErrorType.keyDerivationFailed: 'Ошибка генерации ключа',
    EncryptionErrorType.invalidKey: 'Недействительный ключ шифрования',
    EncryptionErrorType.corruptedData: 'Данные повреждены',
    EncryptionErrorType.unsupportedAlgorithm:
        'Неподдерживаемый алгоритм шифрования',
    EncryptionErrorType.hardwareSecurityModuleError:
        'Ошибка модуля безопасности',
    EncryptionErrorType.keyStorageError: 'Ошибка хранения ключей',
    EncryptionErrorType.certificateError: 'Ошибка сертификата',
  };

  // Английские сообщения для ошибок шифрования
  static const Map<EncryptionErrorType, String> _encryptionMessagesEn = {
    EncryptionErrorType.keyGenerationFailed:
        'Failed to generate encryption key',
    EncryptionErrorType.encryptionFailed: 'Data encryption failed',
    EncryptionErrorType.decryptionFailed: 'Data decryption failed',
    EncryptionErrorType.keyDerivationFailed: 'Key derivation failed',
    EncryptionErrorType.invalidKey: 'Invalid encryption key',
    EncryptionErrorType.corruptedData: 'Data is corrupted',
    EncryptionErrorType.unsupportedAlgorithm:
        'Unsupported encryption algorithm',
    EncryptionErrorType.hardwareSecurityModuleError:
        'Hardware security module error',
    EncryptionErrorType.keyStorageError: 'Key storage error',
    EncryptionErrorType.certificateError: 'Certificate error',
  };

  // Русские сообщения для ошибок базы данных
  static const Map<DatabaseErrorType, String> _databaseMessagesRu = {
    DatabaseErrorType.connectionFailed: 'Не удалось подключиться к базе данных',
    DatabaseErrorType.queryFailed: 'Ошибка выполнения запроса',
    DatabaseErrorType.transactionFailed: 'Ошибка транзакции',
    DatabaseErrorType.migrationFailed: 'Ошибка миграции базы данных',
    DatabaseErrorType.corruptedDatabase: 'База данных повреждена',
    DatabaseErrorType.databaseLocked: 'База данных заблокирована',
    DatabaseErrorType.insufficientSpace: 'Недостаточно места для базы данных',
    DatabaseErrorType.permissionDenied: 'Нет доступа к базе данных',
    DatabaseErrorType.recordNotFound: 'Запись не найдена',
    DatabaseErrorType.duplicateEntry: 'Дублирующаяся запись',
    DatabaseErrorType.constraintViolation: 'Нарушение ограничений базы данных',
    DatabaseErrorType.foreignKeyViolation: 'Нарушение внешнего ключа',
    DatabaseErrorType.indexError: 'Ошибка индекса',
    DatabaseErrorType.backupFailed: 'Ошибка резервного копирования',
    DatabaseErrorType.restoreFailed: 'Ошибка восстановления',
  };

  // Английские сообщения для ошибок базы данных
  static const Map<DatabaseErrorType, String> _databaseMessagesEn = {
    DatabaseErrorType.connectionFailed: 'Failed to connect to database',
    DatabaseErrorType.queryFailed: 'Query execution failed',
    DatabaseErrorType.transactionFailed: 'Transaction failed',
    DatabaseErrorType.migrationFailed: 'Database migration failed',
    DatabaseErrorType.corruptedDatabase: 'Database is corrupted',
    DatabaseErrorType.databaseLocked: 'Database is locked',
    DatabaseErrorType.insufficientSpace: 'Insufficient space for database',
    DatabaseErrorType.permissionDenied: 'Database access denied',
    DatabaseErrorType.recordNotFound: 'Record not found',
    DatabaseErrorType.duplicateEntry: 'Duplicate entry',
    DatabaseErrorType.constraintViolation: 'Database constraint violation',
    DatabaseErrorType.foreignKeyViolation: 'Foreign key violation',
    DatabaseErrorType.indexError: 'Index error',
    DatabaseErrorType.backupFailed: 'Backup failed',
    DatabaseErrorType.restoreFailed: 'Restore failed',
  };

  // Русские сообщения для сетевых ошибок
  static const Map<NetworkErrorType, String> _networkMessagesRu = {
    NetworkErrorType.noConnection: 'Нет подключения к интернету',
    NetworkErrorType.timeout: 'Время ожидания истекло',
    NetworkErrorType.serverError: 'Ошибка сервера',
    NetworkErrorType.clientError: 'Ошибка клиента',
    NetworkErrorType.certificateError: 'Ошибка сертификата',
    NetworkErrorType.rateLimitExceeded: 'Превышен лимит запросов',
    NetworkErrorType.serviceMaintenance: 'Сервис на техническом обслуживании',
    NetworkErrorType.invalidResponse: 'Неверный ответ сервера',
    NetworkErrorType.syncFailed: 'Ошибка синхронизации',
    NetworkErrorType.backupFailed: 'Ошибка резервного копирования',
    NetworkErrorType.downloadFailed: 'Ошибка загрузки',
    NetworkErrorType.uploadFailed: 'Ошибка отправки',
    NetworkErrorType.connectionLost: 'Соединение потеряно',
    NetworkErrorType.proxyError: 'Ошибка прокси-сервера',
    NetworkErrorType.dnsError: 'Ошибка DNS',
  };

  // Английские сообщения для сетевых ошибок
  static const Map<NetworkErrorType, String> _networkMessagesEn = {
    NetworkErrorType.noConnection: 'No internet connection',
    NetworkErrorType.timeout: 'Request timeout',
    NetworkErrorType.serverError: 'Server error',
    NetworkErrorType.clientError: 'Client error',
    NetworkErrorType.certificateError: 'Certificate error',
    NetworkErrorType.rateLimitExceeded: 'Rate limit exceeded',
    NetworkErrorType.serviceMaintenance: 'Service under maintenance',
    NetworkErrorType.invalidResponse: 'Invalid server response',
    NetworkErrorType.syncFailed: 'Synchronization failed',
    NetworkErrorType.backupFailed: 'Backup failed',
    NetworkErrorType.downloadFailed: 'Download failed',
    NetworkErrorType.uploadFailed: 'Upload failed',
    NetworkErrorType.connectionLost: 'Connection lost',
    NetworkErrorType.proxyError: 'Proxy server error',
    NetworkErrorType.dnsError: 'DNS error',
  };

  // Русские сообщения для ошибок валидации
  static const Map<ValidationErrorType, String> _validationMessagesRu = {
    ValidationErrorType.required: 'Поле {field} обязательно для заполнения',
    ValidationErrorType.invalidFormat: 'Неверный формат поля {field}',
    ValidationErrorType.tooShort: 'Поле {field} слишком короткое',
    ValidationErrorType.tooLong: 'Поле {field} слишком длинное',
    ValidationErrorType.weakPassword: 'Пароль слишком слабый',
    ValidationErrorType.passwordMismatch: 'Пароли не совпадают',
    ValidationErrorType.invalidEmail: 'Неверный формат email',
    ValidationErrorType.invalidUrl: 'Неверный формат URL',
    ValidationErrorType.duplicateValue: 'Значение уже существует',
    ValidationErrorType.outOfRange: 'Значение вне допустимого диапазона',
    ValidationErrorType.invalidCharacters: 'Недопустимые символы',
    ValidationErrorType.patternMismatch: 'Значение не соответствует шаблону',
    ValidationErrorType.numericExpected: 'Ожидается числовое значение',
    ValidationErrorType.booleanExpected: 'Ожидается булево значение',
    ValidationErrorType.dateExpected: 'Ожидается дата',
    ValidationErrorType.futureDate: 'Дата должна быть в будущем',
    ValidationErrorType.pastDate: 'Дата должна быть в прошлом',
  };

  // Английские сообщения для ошибок валидации
  static const Map<ValidationErrorType, String> _validationMessagesEn = {
    ValidationErrorType.required: 'Field {field} is required',
    ValidationErrorType.invalidFormat: 'Invalid format for field {field}',
    ValidationErrorType.tooShort: 'Field {field} is too short',
    ValidationErrorType.tooLong: 'Field {field} is too long',
    ValidationErrorType.weakPassword: 'Password is too weak',
    ValidationErrorType.passwordMismatch: 'Passwords do not match',
    ValidationErrorType.invalidEmail: 'Invalid email format',
    ValidationErrorType.invalidUrl: 'Invalid URL format',
    ValidationErrorType.duplicateValue: 'Value already exists',
    ValidationErrorType.outOfRange: 'Value is out of range',
    ValidationErrorType.invalidCharacters: 'Invalid characters',
    ValidationErrorType.patternMismatch: 'Value does not match pattern',
    ValidationErrorType.numericExpected: 'Numeric value expected',
    ValidationErrorType.booleanExpected: 'Boolean value expected',
    ValidationErrorType.dateExpected: 'Date expected',
    ValidationErrorType.futureDate: 'Date must be in the future',
    ValidationErrorType.pastDate: 'Date must be in the past',
  };

  // Заголовки по уровню критичности (русский)
  static const Map<ErrorSeverityV2, String> _severityTitlesRu = {
    ErrorSeverityV2.info: 'Информация',
    ErrorSeverityV2.warning: 'Предупреждение',
    ErrorSeverityV2.error: 'Ошибка',
    ErrorSeverityV2.critical: 'Критическая ошибка',
    ErrorSeverityV2.fatal: 'Фатальная ошибка',
  };

  // Заголовки по уровню критичности (английский)
  static const Map<ErrorSeverityV2, String> _severityTitlesEn = {
    ErrorSeverityV2.info: 'Information',
    ErrorSeverityV2.warning: 'Warning',
    ErrorSeverityV2.error: 'Error',
    ErrorSeverityV2.critical: 'Critical Error',
    ErrorSeverityV2.fatal: 'Fatal Error',
  };

  // Шаблоны технических деталей (русский)
  static const Map<String, String> _technicalDetailsTemplatesRu = {
    'authentication': 'Техническая информация: {details}',
    'encryption': 'Ошибка криптографии: {details}',
    'database': 'Ошибка базы данных: {details}',
    'network': 'Сетевая ошибка: {details}',
    'validation': 'Ошибка валидации: {details}',
    'generic': 'Дополнительная информация: {details}',
  };

  // Шаблоны технических деталей (английский)
  static const Map<String, String> _technicalDetailsTemplatesEn = {
    'authentication': 'Technical info: {details}',
    'encryption': 'Cryptography error: {details}',
    'database': 'Database error: {details}',
    'network': 'Network error: {details}',
    'validation': 'Validation error: {details}',
    'generic': 'Additional info: {details}',
  };

  // Рекомендации по устранению (русский)
  static const Map<String, Map<String, String>> _solutionsRu = {
    'authentication': {
      'invalidCredentials': 'Проверьте правильность ввода логина и пароля',
      'sessionExpired': 'Войдите в приложение заново',
      'biometricFailed': 'Попробуйте использовать PIN-код или пароль',
    },
    'network': {
      'noConnection': 'Проверьте подключение к интернету',
      'timeout': 'Повторите попытку через несколько секунд',
    },
    'generic': {
      'authentication': 'Обратитесь к разделу "Помощь" в настройках',
      'network': 'Проверьте настройки сети',
      'database': 'Перезапустите приложение',
    },
  };

  // Рекомендации по устранению (английский)
  static const Map<String, Map<String, String>> _solutionsEn = {
    'authentication': {
      'invalidCredentials': 'Check your username and password',
      'sessionExpired': 'Please log in again',
      'biometricFailed': 'Try using PIN or password instead',
    },
    'network': {
      'noConnection': 'Check your internet connection',
      'timeout': 'Try again in a few seconds',
    },
    'generic': {
      'authentication': 'Check the Help section in settings',
      'network': 'Check your network settings',
      'database': 'Restart the application',
    },
  };
}

/// Глобальный экземпляр локализатора
ErrorLocalizerV2? _globalLocalizer;

/// Получение глобального локализатора
ErrorLocalizerV2 getGlobalLocalizer() {
  return _globalLocalizer ??= DefaultErrorLocalizerV2();
}

/// Установка глобального локализатора
void setGlobalLocalizer(ErrorLocalizerV2 localizer) {
  _globalLocalizer = localizer;
}

/// Расширение для добавления локализации к ошибкам
extension ErrorLocalizationV2 on AppErrorV2 {
  /// Получение локализованного сообщения
  String get localizedMessage => getGlobalLocalizer().getLocalizedMessage(this);

  /// Получение локализованных технических деталей
  String? get localizedTechnicalDetails =>
      getGlobalLocalizer().getLocalizedTechnicalDetails(this);

  /// Получение локализованного решения
  String? get localizedSolution =>
      getGlobalLocalizer().getLocalizedSolution(this);

  /// Получение локализованного заголовка
  String get localizedTitle => getGlobalLocalizer().getLocalizedTitle(this);
}
