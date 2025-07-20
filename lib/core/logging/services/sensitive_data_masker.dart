import '../interfaces/logging_interfaces.dart';

/// Реализация маскировщика чувствительных данных
class SensitiveDataMaskerImpl implements SensitiveDataMasker {
  // Паттерны для поиска чувствительных данных
  static final List<RegExp> _sensitivePatterns = [
    // Пароли
    RegExp(r'password["\s]*[:=]["\s]*[^"\s,}]*', caseSensitive: false),
    RegExp(r'pwd["\s]*[:=]["\s]*[^"\s,}]*', caseSensitive: false),
    RegExp(r'passwd["\s]*[:=]["\s]*[^"\s,}]*', caseSensitive: false),

    // Токены и ключи
    RegExp(r'token["\s]*[:=]["\s]*[^"\s,}]*', caseSensitive: false),
    RegExp(r'key["\s]*[:=]["\s]*[^"\s,}]*', caseSensitive: false),
    RegExp(r'secret["\s]*[:=]["\s]*[^"\s,}]*', caseSensitive: false),
    RegExp(r'api[_-]?key["\s]*[:=]["\s]*[^"\s,}]*', caseSensitive: false),
    RegExp(r'access[_-]?token["\s]*[:=]["\s]*[^"\s,}]*', caseSensitive: false),

    // PIN коды и коды доступа
    RegExp(r'pin["\s]*[:=]["\s]*\d{4,8}', caseSensitive: false),
    RegExp(r'code["\s]*[:=]["\s]*\d{4,8}', caseSensitive: false),

    // Кредитные карты
    RegExp(r'\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b'),

    // Email адреса (частично маскируем)
    RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),

    // Телефонные номера
    RegExp(r'\+?[\d\s\-\(\)]{10,}'),

    // JWT токены
    RegExp(r'eyJ[A-Za-z0-9_-]*\.eyJ[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*'),
  ];

  // Ключи в метаданных, которые нужно маскировать
  static final Set<String> _sensitiveKeys = {
    'password',
    'pwd',
    'passwd',
    'token',
    'key',
    'secret',
    'api_key',
    'apikey',
    'access_token',
    'refresh_token',
    'authorization',
    'auth',
    'pin',
    'code',
    'credit_card',
    'card_number',
    'cvv',
    'ccv',
    'social_security',
    'ssn',
    'passport',
    'driver_license',
  };

  @override
  String mask(String message) {
    String maskedMessage = message;

    for (final pattern in _sensitivePatterns) {
      maskedMessage = maskedMessage.replaceAllMapped(pattern, (match) {
        final matched = match.group(0) ?? '';

        // Для JWT токенов показываем только начало
        if (matched.startsWith('eyJ')) {
          return '${matched.substring(0, 10)}...***';
        }

        // Для email показываем первую букву и домен
        if (matched.contains('@')) {
          final parts = matched.split('@');
          if (parts.length == 2) {
            final username = parts[0];
            final domain = parts[1];
            final maskedUsername = username.isNotEmpty
                ? '${username[0]}***'
                : '***';
            return '$maskedUsername@$domain';
          }
        }

        // Для остальных паттернов заменяем на звездочки
        if (matched.contains(':') || matched.contains('=')) {
          final parts = matched.split(RegExp(r'[:=]'));
          if (parts.length >= 2) {
            return '${parts[0]}${matched.contains(':') ? ':' : '='}"***"';
          }
        }

        return '***';
      });
    }

    return maskedMessage;
  }

  @override
  Map<String, dynamic>? maskMetadata(Map<String, dynamic>? metadata) {
    if (metadata == null) return null;

    final masked = <String, dynamic>{};

    metadata.forEach((key, value) {
      final lowerKey = key.toLowerCase();

      if (_sensitiveKeys.any((sensitive) => lowerKey.contains(sensitive))) {
        // Маскируем чувствительные ключи
        masked[key] = _maskValue(value);
      } else if (value is Map<String, dynamic>) {
        // Рекурсивно обрабатываем вложенные объекты
        masked[key] = maskMetadata(value);
      } else if (value is List) {
        // Обрабатываем списки
        masked[key] = _maskList(value);
      } else if (value is String) {
        // Проверяем строковые значения на чувствительные данные
        masked[key] = mask(value);
      } else {
        // Остальные значения оставляем как есть
        masked[key] = value;
      }
    });

    return masked;
  }

  /// Маскировка значения
  dynamic _maskValue(dynamic value) {
    if (value == null) return null;

    if (value is String) {
      if (value.length <= 4) {
        return '***';
      } else {
        return '${value.substring(0, 2)}***';
      }
    } else if (value is num) {
      return '***';
    } else if (value is bool) {
      return value; // Булевы значения не маскируем
    } else if (value is Map<String, dynamic>) {
      return maskMetadata(value);
    } else if (value is List) {
      return _maskList(value);
    }

    return '***';
  }

  /// Маскировка списка
  List<dynamic> _maskList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map<String, dynamic>) {
        return maskMetadata(item);
      } else if (item is String) {
        return mask(item);
      } else if (item is List) {
        return _maskList(item);
      }
      return item;
    }).toList();
  }
}
