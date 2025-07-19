import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_error.dart';

/// Локализация сообщений об ошибках
class ErrorLocalizations {
  const ErrorLocalizations();

  /// Получает локализованное сообщение для ошибки
  String getLocalizedMessage(AppError error) {
    return switch (error) {
      AuthenticationError(:final type, :final message) =>
        _getAuthenticationMessage(type, message),
      EncryptionError(:final type, :final message) => _getEncryptionMessage(
        type,
        message,
      ),
      DatabaseError(:final type, :final message) => _getDatabaseMessage(
        type,
        message,
      ),
      NetworkError(:final type, :final message) => _getNetworkMessage(
        type,
        message,
      ),
      ValidationError(:final type, :final message) => _getValidationMessage(
        type,
        message,
      ),
      StorageError(:final type, :final message) => _getStorageMessage(
        type,
        message,
      ),
      SecurityError(:final type, :final message) => _getSecurityMessage(
        type,
        message,
      ),
      SystemError(:final type, :final message) => _getSystemMessage(
        type,
        message,
      ),
      UnknownError(:final message) =>
        message.isNotEmpty ? message : 'Произошла неизвестная ошибка',
    };
  }

  /// Получает краткое описание типа ошибки
  String getErrorTypeTitle(AppError error) {
    return switch (error) {
      AuthenticationError() => 'Ошибка аутентификации',
      EncryptionError() => 'Ошибка шифрования',
      DatabaseError() => 'Ошибка базы данных',
      NetworkError() => 'Сетевая ошибка',
      ValidationError() => 'Ошибка валидации',
      StorageError() => 'Ошибка хранилища',
      SecurityError() => 'Ошибка безопасности',
      SystemError() => 'Системная ошибка',
      UnknownError() => 'Неизвестная ошибка',
    };
  }

  String _getAuthenticationMessage(
    AuthenticationErrorType type,
    String fallback,
  ) {
    return switch (type) {
      AuthenticationErrorType.invalidCredentials => 'Неверные учетные данные',
      AuthenticationErrorType.userNotFound => 'Пользователь не найден',
      AuthenticationErrorType.userAlreadyExists =>
        'Пользователь уже существует',
      AuthenticationErrorType.sessionExpired =>
        'Сессия истекла. Войдите в систему заново',
      AuthenticationErrorType.accountLocked => 'Аккаунт заблокирован',
      AuthenticationErrorType.biometricNotAvailable =>
        'Биометрическая аутентификация недоступна',
      AuthenticationErrorType.biometricNotEnrolled =>
        'Биометрические данные не настроены',
      AuthenticationErrorType.biometricFailed =>
        'Ошибка биометрической аутентификации',
      AuthenticationErrorType.pinIncorrect => 'Неверный PIN-код',
      AuthenticationErrorType.masterPasswordIncorrect =>
        'Неверный мастер-пароль',
      AuthenticationErrorType.twoFactorRequired =>
        'Требуется двухфакторная аутентификация',
      AuthenticationErrorType.twoFactorInvalid =>
        'Неверный код двухфакторной аутентификации',
    };
  }

  String _getEncryptionMessage(EncryptionErrorType type, String fallback) {
    return switch (type) {
      EncryptionErrorType.keyGenerationFailed =>
        'Не удалось сгенерировать ключ шифрования',
      EncryptionErrorType.encryptionFailed => 'Ошибка при шифровании данных',
      EncryptionErrorType.decryptionFailed => 'Ошибка при расшифровке данных',
      EncryptionErrorType.keyDerivationFailed => 'Ошибка при выводе ключа',
      EncryptionErrorType.invalidKey => 'Недействительный ключ шифрования',
      EncryptionErrorType.corruptedData => 'Данные повреждены или изменены',
      EncryptionErrorType.unsupportedAlgorithm =>
        'Неподдерживаемый алгоритм шифрования',
      EncryptionErrorType.hardwareSecurityModuleError =>
        'Ошибка модуля аппаратной безопасности',
    };
  }

  String _getDatabaseMessage(DatabaseErrorType type, String fallback) {
    return switch (type) {
      DatabaseErrorType.connectionFailed =>
        'Не удалось подключиться к базе данных',
      DatabaseErrorType.queryFailed =>
        'Ошибка выполнения запроса к базе данных',
      DatabaseErrorType.transactionFailed => 'Ошибка транзакции базы данных',
      DatabaseErrorType.migrationFailed => 'Ошибка миграции базы данных',
      DatabaseErrorType.corruptedDatabase => 'База данных повреждена',
      DatabaseErrorType.databaseLocked => 'База данных заблокирована',
      DatabaseErrorType.insufficientSpace =>
        'Недостаточно места для базы данных',
      DatabaseErrorType.permissionDenied => 'Нет прав доступа к базе данных',
      DatabaseErrorType.recordNotFound => 'Запись не найдена',
      DatabaseErrorType.duplicateEntry => 'Запись уже существует',
    };
  }

  String _getNetworkMessage(NetworkErrorType type, String fallback) {
    return switch (type) {
      NetworkErrorType.noConnection => 'Нет подключения к интернету',
      NetworkErrorType.timeout => 'Превышено время ожидания',
      NetworkErrorType.serverError => 'Ошибка сервера',
      NetworkErrorType.clientError => 'Ошибка клиента',
      NetworkErrorType.certificateError => 'Ошибка SSL-сертификата',
      NetworkErrorType.rateLimitExceeded => 'Превышен лимит запросов',
      NetworkErrorType.serviceMaintenance => 'Техническое обслуживание сервиса',
      NetworkErrorType.invalidResponse => 'Неверный ответ сервера',
      NetworkErrorType.syncFailed => 'Ошибка синхронизации',
      NetworkErrorType.backupFailed => 'Ошибка создания резервной копии',
    };
  }

  String _getValidationMessage(ValidationErrorType type, String fallback) {
    return switch (type) {
      ValidationErrorType.required => 'Поле обязательно для заполнения',
      ValidationErrorType.invalidFormat => 'Неверный формат данных',
      ValidationErrorType.tooShort => 'Значение слишком короткое',
      ValidationErrorType.tooLong => 'Значение слишком длинное',
      ValidationErrorType.weakPassword => 'Пароль слишком слабый',
      ValidationErrorType.passwordMismatch => 'Пароли не совпадают',
      ValidationErrorType.invalidEmail => 'Неверный формат email',
      ValidationErrorType.invalidUrl => 'Неверный формат URL',
      ValidationErrorType.duplicateValue => 'Значение уже существует',
      ValidationErrorType.outOfRange => 'Значение вне допустимого диапазона',
    };
  }

  String _getStorageMessage(StorageErrorType type, String fallback) {
    return switch (type) {
      StorageErrorType.fileNotFound => 'Файл не найден',
      StorageErrorType.accessDenied => 'Доступ запрещен',
      StorageErrorType.insufficientSpace => 'Недостаточно места на диске',
      StorageErrorType.corruptedFile => 'Файл поврежден',
      StorageErrorType.backupFailed => 'Ошибка создания резервной копии',
      StorageErrorType.restoreFailed =>
        'Ошибка восстановления из резервной копии',
      StorageErrorType.exportFailed => 'Ошибка экспорта данных',
      StorageErrorType.importFailed => 'Ошибка импорта данных',
      StorageErrorType.syncFailed => 'Ошибка синхронизации файлов',
    };
  }

  String _getSecurityMessage(SecurityErrorType type, String fallback) {
    return switch (type) {
      SecurityErrorType.dataBreachDetected => 'Обнаружена утечка данных',
      SecurityErrorType.unauthorizedAccess => 'Несанкционированный доступ',
      SecurityErrorType.maliciousActivity =>
        'Обнаружена подозрительная активность',
      SecurityErrorType.certificateExpired => 'Сертификат истек',
      SecurityErrorType.integrityCheckFailed =>
        'Проверка целостности не пройдена',
      SecurityErrorType.suspiciousLogin => 'Подозрительная попытка входа',
      SecurityErrorType.deviceCompromised =>
        'Устройство может быть скомпрометировано',
      SecurityErrorType.dataLeakage => 'Возможная утечка данных',
    };
  }

  String _getSystemMessage(SystemErrorType type, String fallback) {
    return switch (type) {
      SystemErrorType.outOfMemory => 'Недостаточно памяти',
      SystemErrorType.diskFull => 'Диск заполнен',
      SystemErrorType.permissionDenied => 'Нет необходимых разрешений',
      SystemErrorType.platformNotSupported => 'Платформа не поддерживается',
      SystemErrorType.serviceUnavailable => 'Сервис недоступен',
      SystemErrorType.configurationError => 'Ошибка конфигурации',
      SystemErrorType.initializationFailed => 'Ошибка инициализации',
      SystemErrorType.unexpectedShutdown => 'Неожиданное завершение работы',
    };
  }

  /// Получает рекомендации по устранению ошибки
  String getErrorResolution(AppError error) {
    return switch (error) {
      AuthenticationError(:final type) => _getAuthenticationResolution(type),
      EncryptionError(:final type) => _getEncryptionResolution(type),
      DatabaseError(:final type) => _getDatabaseResolution(type),
      NetworkError(:final type) => _getNetworkResolution(type),
      ValidationError(:final type) => _getValidationResolution(type),
      StorageError(:final type) => _getStorageResolution(type),
      SecurityError(:final type) => _getSecurityResolution(type),
      SystemError(:final type) => _getSystemResolution(type),
      UnknownError() =>
        'Попробуйте перезапустить приложение или обратитесь в поддержку',
    };
  }

  String _getAuthenticationResolution(AuthenticationErrorType type) {
    return switch (type) {
      AuthenticationErrorType.invalidCredentials =>
        'Проверьте правильность введенных данных',
      AuthenticationErrorType.userNotFound =>
        'Зарегистрируйтесь или проверьте имя пользователя',
      AuthenticationErrorType.sessionExpired => 'Войдите в систему заново',
      AuthenticationErrorType.biometricNotAvailable =>
        'Используйте альтернативный способ входа',
      AuthenticationErrorType.biometricNotEnrolled =>
        'Настройте биометрическую аутентификацию в настройках',
      _ => 'Обратитесь к администратору системы',
    };
  }

  String _getEncryptionResolution(EncryptionErrorType type) {
    return switch (type) {
      EncryptionErrorType.corruptedData =>
        'Восстановите данные из резервной копии',
      EncryptionErrorType.invalidKey => 'Проверьте правильность мастер-пароля',
      _ => 'Обратитесь в техническую поддержку',
    };
  }

  String _getDatabaseResolution(DatabaseErrorType type) {
    return switch (type) {
      DatabaseErrorType.insufficientSpace => 'Освободите место на устройстве',
      DatabaseErrorType.corruptedDatabase =>
        'Восстановите базу данных из резервной копии',
      _ => 'Перезапустите приложение',
    };
  }

  String _getNetworkResolution(NetworkErrorType type) {
    return switch (type) {
      NetworkErrorType.noConnection => 'Проверьте подключение к интернету',
      NetworkErrorType.timeout => 'Попробуйте позже или проверьте соединение',
      _ => 'Проверьте настройки сети',
    };
  }

  String _getValidationResolution(ValidationErrorType type) {
    return switch (type) {
      ValidationErrorType.weakPassword => 'Используйте более сложный пароль',
      ValidationErrorType.invalidFormat => 'Проверьте формат введенных данных',
      _ => 'Исправьте ошибки в форме',
    };
  }

  String _getStorageResolution(StorageErrorType type) {
    return switch (type) {
      StorageErrorType.insufficientSpace => 'Освободите место на устройстве',
      StorageErrorType.accessDenied => 'Предоставьте необходимые разрешения',
      _ => 'Попробуйте позже',
    };
  }

  String _getSecurityResolution(SecurityErrorType type) {
    return switch (type) {
      SecurityErrorType.dataBreachDetected => 'Немедленно смените все пароли',
      SecurityErrorType.deviceCompromised =>
        'Проверьте устройство на наличие вредоносного ПО',
      _ => 'Обратитесь в службу безопасности',
    };
  }

  String _getSystemResolution(SystemErrorType type) {
    return switch (type) {
      SystemErrorType.outOfMemory => 'Закройте другие приложения',
      SystemErrorType.diskFull => 'Освободите место на диске',
      _ => 'Перезапустите приложение или устройство',
    };
  }
}

/// Провайдер локализации ошибок
final errorLocalizationsProvider = Provider<ErrorLocalizations>((ref) {
  return const ErrorLocalizations();
});
