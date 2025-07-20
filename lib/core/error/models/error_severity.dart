/// Уровни критичности ошибок
enum ErrorSeverity {
  /// Информационная ошибка - не критична, может игнорироваться
  info(level: 0, name: 'Info'),

  /// Предупреждение - следует обратить внимание
  warning(level: 1, name: 'Warning'),

  /// Ошибка - требует обработки, но приложение может продолжать работу
  error(level: 2, name: 'Error'),

  /// Критическая ошибка - серьезно влияет на функциональность
  critical(level: 3, name: 'Critical'),

  /// Фатальная ошибка - приложение не может продолжать работу
  fatal(level: 4, name: 'Fatal');

  const ErrorSeverity({required this.level, required this.name});

  final int level;
  final String name;

  /// Проверка, является ли ошибка критической
  bool get isCritical => level >= ErrorSeverity.critical.level;

  /// Проверка, требует ли ошибка немедленного внимания
  bool get requiresImmediateAttention => level >= ErrorSeverity.error.level;

  /// Сравнение критичности ошибок
  bool isMoreCriticalThan(ErrorSeverity other) => level > other.level;

  bool isLessCriticalThan(ErrorSeverity other) => level < other.level;

  @override
  String toString() => name;
}
