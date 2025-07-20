import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'enhanced_app_error.dart';
import 'app_error.dart' as old;

/// Универсальная локализация сообщений об ошибках для обеих систем
class UniversalErrorLocalizations {
  const UniversalErrorLocalizations();

  /// Получает локализованное сообщение для ошибки (новая система)
  String getLocalizedMessage(BaseAppError error) {
    if (error is AppError) {
      return _getEnhancedErrorMessage(error);
    }
    return error.message;
  }

  /// Получает краткое описание типа ошибки (новая система)
  String getErrorTypeTitle(BaseAppError error) {
    if (error is AppError) {
      return _getEnhancedErrorTitle(error);
    }
    return 'Ошибка';
  }

  /// Получает рекомендации по устранению ошибки (новая система)
  String getErrorResolution(BaseAppError error) {
    if (error is AppError) {
      return _getEnhancedErrorResolution(error);
    }
    return 'Обратитесь в техническую поддержку';
  }

  /// Методы для работы со старой системой ошибок
  String getLegacyLocalizedMessage(old.AppError error) {
    return _getLegacyErrorMessage(error);
  }

  String getLegacyErrorTypeTitle(old.AppError error) {
    return _getLegacyErrorTitle(error);
  }

  String getLegacyErrorResolution(old.AppError error) {
    return _getLegacyErrorResolution(error);
  }

  // === НОВАЯ СИСТЕМА (enhanced_app_error.dart) ===

  String _getEnhancedErrorMessage(AppError error) {
    return switch (error) {
      AuthenticationError() => _getAuthenticationMessage(error.message),
      EncryptionError() => _getEncryptionMessage(error.message),
      DatabaseError() => _getDatabaseMessage(error.message),
      NetworkError() => _getNetworkMessage(error.message),
      ValidationError() => _getValidationMessage(error.message),
      StorageError() => _getStorageMessage(error.message),
      SecurityError() => _getSecurityMessage(error.message),
      SystemError() => _getSystemMessage(error.message),
      UIError() => _getUIMessage(error.message),
      BusinessError() => _getBusinessMessage(error.message),
      UnknownAppError() =>
        error.message.isNotEmpty
            ? error.message
            : 'Произошла неизвестная ошибка',
      _ => error.message.isNotEmpty ? error.message : 'Произошла ошибка',
    };
  }

  String _getEnhancedErrorTitle(AppError error) {
    return switch (error) {
      AuthenticationError() => 'Ошибка аутентификации',
      EncryptionError() => 'Ошибка шифрования',
      DatabaseError() => 'Ошибка базы данных',
      NetworkError() => 'Сетевая ошибка',
      ValidationError() => 'Ошибка валидации',
      StorageError() => 'Ошибка хранилища',
      SecurityError() => 'Ошибка безопасности',
      SystemError() => 'Системная ошибка',
      UIError() => 'Ошибка интерфейса',
      BusinessError() => 'Бизнес-ошибка',
      UnknownAppError() => 'Неизвестная ошибка',
      _ => 'Ошибка',
    };
  }

  String _getEnhancedErrorResolution(AppError error) {
    return switch (error) {
      AuthenticationError() =>
        'Проверьте правильность введенных данных и повторите попытку',
      EncryptionError() =>
        'Обратитесь в техническую поддержку для восстановления данных',
      DatabaseError() => 'Перезапустите приложение или обратитесь в поддержку',
      NetworkError() => 'Проверьте подключение к интернету и повторите попытку',
      ValidationError() => 'Исправьте введенные данные согласно требованиям',
      StorageError() => 'Проверьте доступное место на устройстве',
      SecurityError() => 'Немедленно обратитесь в службу безопасности',
      SystemError() => 'Перезапустите приложение или обратитесь в поддержку',
      UIError() => 'Обновите приложение или обратитесь в поддержку',
      BusinessError() => 'Проверьте правильность выполняемых действий',
      UnknownAppError() =>
        'Попробуйте перезапустить приложение или обратитесь в поддержку',
      _ => 'Обратитесь в техническую поддержку',
    };
  }

  // === СТАРАЯ СИСТЕМА (app_error.dart) ===

  String _getLegacyErrorMessage(old.AppError error) {
    return switch (error) {
      old.AuthenticationError(:final type, :final message) =>
        _getLegacyAuthenticationMessage(type, message),
      old.EncryptionError(:final type, :final message) =>
        _getLegacyEncryptionMessage(type, message),
      old.DatabaseError(:final type, :final message) =>
        _getLegacyDatabaseMessage(type, message),
      old.NetworkError(:final type, :final message) => _getLegacyNetworkMessage(
        type,
        message,
      ),
      old.ValidationError(:final type, :final message) =>
        _getLegacyValidationMessage(type, message),
      old.StorageError(:final type, :final message) => _getLegacyStorageMessage(
        type,
        message,
      ),
      old.SecurityError(:final type, :final message) =>
        _getLegacySecurityMessage(type, message),
      old.SystemError(:final type, :final message) => _getLegacySystemMessage(
        type,
        message,
      ),
      old.UnknownError(:final message) =>
        message.isNotEmpty ? message : 'Произошла неизвестная ошибка',
    };
  }

  String _getLegacyErrorTitle(old.AppError error) {
    return switch (error) {
      old.AuthenticationError() => 'Ошибка аутентификации',
      old.EncryptionError() => 'Ошибка шифрования',
      old.DatabaseError() => 'Ошибка базы данных',
      old.NetworkError() => 'Сетевая ошибка',
      old.ValidationError() => 'Ошибка валидации',
      old.StorageError() => 'Ошибка хранилища',
      old.SecurityError() => 'Ошибка безопасности',
      old.SystemError() => 'Системная ошибка',
      old.UnknownError() => 'Неизвестная ошибка',
    };
  }

  String _getLegacyErrorResolution(old.AppError error) {
    return switch (error) {
      old.AuthenticationError() => 'Проверьте правильность введенных данных',
      old.EncryptionError() => 'Обратитесь в техническую поддержку',
      old.DatabaseError() => 'Перезапустите приложение',
      old.NetworkError() => 'Проверьте подключение к интернету',
      old.ValidationError() => 'Исправьте введенные данные',
      old.StorageError() => 'Проверьте доступное место на устройстве',
      old.SecurityError() => 'Обратитесь в службу безопасности',
      old.SystemError() => 'Перезапустите приложение',
      old.UnknownError() => 'Попробуйте перезапустить приложение',
    };
  }

  // === ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ===

  String _getAuthenticationMessage(String fallback) =>
      fallback.isNotEmpty ? fallback : 'Ошибка аутентификации';
  String _getEncryptionMessage(String fallback) =>
      fallback.isNotEmpty ? fallback : 'Ошибка шифрования';
  String _getDatabaseMessage(String fallback) =>
      fallback.isNotEmpty ? fallback : 'Ошибка базы данных';
  String _getNetworkMessage(String fallback) =>
      fallback.isNotEmpty ? fallback : 'Сетевая ошибка';
  String _getValidationMessage(String fallback) =>
      fallback.isNotEmpty ? fallback : 'Ошибка валидации';
  String _getStorageMessage(String fallback) =>
      fallback.isNotEmpty ? fallback : 'Ошибка хранилища';
  String _getSecurityMessage(String fallback) =>
      fallback.isNotEmpty ? fallback : 'Ошибка безопасности';
  String _getSystemMessage(String fallback) =>
      fallback.isNotEmpty ? fallback : 'Системная ошибка';
  String _getUIMessage(String fallback) =>
      fallback.isNotEmpty ? fallback : 'Ошибка интерфейса';
  String _getBusinessMessage(String fallback) =>
      fallback.isNotEmpty ? fallback : 'Бизнес-ошибка';

  // Методы для старой системы с типами
  String _getLegacyAuthenticationMessage(
    old.AuthenticationErrorType type,
    String fallback,
  ) {
    return switch (type) {
      old.AuthenticationErrorType.invalidCredentials =>
        'Неверные учетные данные',
      old.AuthenticationErrorType.userNotFound => 'Пользователь не найден',
      old.AuthenticationErrorType.sessionExpired => 'Сессия истекла',
      old.AuthenticationErrorType.biometricFailed =>
        'Ошибка биометрической аутентификации',
      _ => fallback.isNotEmpty ? fallback : 'Ошибка аутентификации',
    };
  }

  String _getLegacyEncryptionMessage(
    old.EncryptionErrorType type,
    String fallback,
  ) {
    return switch (type) {
      old.EncryptionErrorType.decryptionFailed =>
        'Не удалось расшифровать данные',
      old.EncryptionErrorType.encryptionFailed =>
        'Ошибка при шифровании данных',
      old.EncryptionErrorType.corruptedData => 'Данные повреждены или изменены',
      _ => fallback.isNotEmpty ? fallback : 'Ошибка шифрования',
    };
  }

  String _getLegacyDatabaseMessage(
    old.DatabaseErrorType type,
    String fallback,
  ) {
    return switch (type) {
      old.DatabaseErrorType.connectionFailed =>
        'Не удалось подключиться к базе данных',
      old.DatabaseErrorType.queryFailed => 'Ошибка выполнения запроса',
      old.DatabaseErrorType.recordNotFound => 'Запись не найдена',
      _ => fallback.isNotEmpty ? fallback : 'Ошибка базы данных',
    };
  }

  String _getLegacyNetworkMessage(old.NetworkErrorType type, String fallback) {
    return switch (type) {
      old.NetworkErrorType.noConnection => 'Нет подключения к интернету',
      old.NetworkErrorType.timeout => 'Превышено время ожидания',
      old.NetworkErrorType.serverError => 'Ошибка сервера',
      _ => fallback.isNotEmpty ? fallback : 'Сетевая ошибка',
    };
  }

  String _getLegacyValidationMessage(
    old.ValidationErrorType type,
    String fallback,
  ) {
    return switch (type) {
      old.ValidationErrorType.required => 'Поле обязательно для заполнения',
      old.ValidationErrorType.invalidFormat => 'Неверный формат данных',
      old.ValidationErrorType.weakPassword => 'Пароль слишком слабый',
      _ => fallback.isNotEmpty ? fallback : 'Ошибка валидации',
    };
  }

  String _getLegacyStorageMessage(old.StorageErrorType type, String fallback) {
    return switch (type) {
      old.StorageErrorType.fileNotFound => 'Файл не найден',
      old.StorageErrorType.accessDenied => 'Нет прав доступа',
      old.StorageErrorType.insufficientSpace => 'Недостаточно места на диске',
      _ => fallback.isNotEmpty ? fallback : 'Ошибка хранилища',
    };
  }

  String _getLegacySecurityMessage(
    old.SecurityErrorType type,
    String fallback,
  ) {
    return switch (type) {
      old.SecurityErrorType.unauthorizedAccess => 'Несанкционированный доступ',
      old.SecurityErrorType.dataBreachDetected => 'Обнаружена утечка данных',
      old.SecurityErrorType.suspiciousLogin => 'Подозрительная попытка входа',
      _ => fallback.isNotEmpty ? fallback : 'Ошибка безопасности',
    };
  }

  String _getLegacySystemMessage(old.SystemErrorType type, String fallback) {
    return switch (type) {
      old.SystemErrorType.outOfMemory => 'Недостаточно памяти',
      old.SystemErrorType.diskFull => 'Диск заполнен',
      old.SystemErrorType.permissionDenied => 'Нет необходимых разрешений',
      _ => fallback.isNotEmpty ? fallback : 'Системная ошибка',
    };
  }
}

/// Провайдер универсальной локализации ошибок
final universalErrorLocalizationsProvider =
    Provider<UniversalErrorLocalizations>((ref) {
      return const UniversalErrorLocalizations();
    });
