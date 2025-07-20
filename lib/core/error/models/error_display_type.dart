/// Типы отображения ошибок в UI
enum ErrorDisplayType {
  /// Снэкбар в нижней части экрана
  snackbar(
    name: 'Snackbar',
    description: 'Brief message at bottom of screen',
    duration: Duration(seconds: 4),
  ),

  /// Диалоговое окно
  dialog(
    name: 'Dialog',
    description: 'Modal dialog requiring user interaction',
    duration: null,
  ),

  /// Баннер в верхней части экрана
  banner(
    name: 'Banner',
    description: 'Persistent banner at top of screen',
    duration: Duration(seconds: 6),
  ),

  /// Встроенное уведомление в контент
  inline(
    name: 'Inline',
    description: 'Embedded notification within content',
    duration: Duration(seconds: 5),
  ),

  /// Полноэкранная страница ошибки
  fullscreen(
    name: 'Fullscreen',
    description: 'Full screen error page',
    duration: null,
  ),

  /// Тост-уведомление
  toast(
    name: 'Toast',
    description: 'Brief floating message',
    duration: Duration(seconds: 3),
  ),

  /// Не показывать UI (только логирование)
  none(
    name: 'None',
    description: 'No UI display, logging only',
    duration: null,
  );

  const ErrorDisplayType({
    required this.name,
    required this.description,
    required this.duration,
  });

  final String name;
  final String description;
  final Duration? duration;

  /// Проверка, требует ли тип взаимодействия с пользователем
  bool get requiresUserInteraction => this == dialog || this == fullscreen;

  /// Проверка, является ли уведомление временным
  bool get isTemporary => duration != null;

  /// Проверка, является ли отображение навязчивым
  bool get isIntrusive =>
      this == dialog || this == fullscreen || this == banner;

  @override
  String toString() => name;
}
