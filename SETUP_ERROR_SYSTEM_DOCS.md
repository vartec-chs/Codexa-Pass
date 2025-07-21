# Интеграция системы ошибок в Setup экран

## Обзор

В setup экран была интегрирована комплексная система обработки ошибок, которая обеспечивает:

- Структурированную обработку ошибок
- Пользовательские уведомления
- Логирование и аналитику
- Возможность повтора операций
- Отображение статистики ошибок

## Компоненты системы ошибок

### 1. Модели ошибок (`setup_errors.dart`)

#### `SetupError` (базовый класс)
- Модуль: 'Setup'
- Поддержка повторных попыток
- Отображение через диалоги по умолчанию

#### Конкретные типы ошибок:

**`SetupPreferencesError`**
- Код: `SETUP_PREFERENCES_ERROR`
- Критичность: `ErrorSeverity.error`
- Повторы: до 3 попыток
- Причина: ошибки сохранения настроек

**`SetupNavigationError`**
- Код: `SETUP_NAVIGATION_ERROR`
- Критичность: `ErrorSeverity.warning`
- Повторы: не поддерживаются
- Причина: проблемы навигации после завершения

**`SetupThemeError`**
- Код: `SETUP_THEME_ERROR`
- Критичность: `ErrorSeverity.warning`
- Повторы: до 1 попытки
- Отображение: через snackbar
- Причина: ошибки смены темы

**`SetupInitializationError`**
- Код: `SETUP_INITIALIZATION_ERROR`
- Критичность: `ErrorSeverity.critical`
- Повторы: до 2 попыток
- Причина: проблемы инициализации экрана

### 2. Сервис ошибок (`setup_error_service.dart`)

#### `SetupErrorService`
Основной сервис для обработки ошибок setup экрана.

**Основные методы:**
- `handlePreferencesError()` - обработка ошибок сохранения
- `handleNavigationError()` - обработка ошибок навигации
- `handleThemeError()` - обработка ошибок смены темы
- `handleInitializationError()` - обработка ошибок инициализации

**Возможности:**
- Автоматическая категоризация ошибок
- Добавление метаданных
- Выбор способа отображения
- Обработка повторных попыток

#### Провайдеры Riverpod:
- `setupErrorServiceProvider` - основной сервис
- `setupErrorsProvider` - список ошибок setup экрана

### 3. UI компоненты (`setup_error_widget.dart`)

#### `SetupErrorWidget`
Виджет для отображения активных ошибок setup экрана.

**Функции:**
- Показ до 3 последних ошибок
- Индикация возможности повтора
- Кнопка очистки ошибок
- Адаптивный дизайн

#### `SetupErrorStatsWidget`
Виджет для отображения статистики ошибок.

**Функции:**
- Группировка по критичности
- Подсчет количества ошибок
- Цветовая индикация

## Интеграция в Setup экран

### Обработка ошибок в методах:

#### `_completeSetup()`
```dart
try {
  // Сохранение настроек
  await prefs.setBool('is_first_run', false);
  // Навигация
  context.go('/');
} catch (e, stackTrace) {
  // Обработка ошибки сохранения
  await errorService.handlePreferencesError(e, stackTrace, context: context);
  
  // Попытка навигации даже при ошибке
  try {
    context.go('/');
  } catch (navError, navStackTrace) {
    await errorService.handleNavigationError(navError, navStackTrace, context: context);
  }
}
```

#### `_safeChangeTheme()`
```dart
try {
  await themeChanger();
} catch (e, stackTrace) {
  await errorService.handleThemeError(themeName, e, stackTrace, context: context);
}
```

#### `_initializeSetup()`
```dart
try {
  // Логика инициализации
} catch (e, stackTrace) {
  await errorService.handleInitializationError(e, stackTrace, context: context);
}
```

### UI интеграция:
- `SetupErrorWidget` добавлен в верхнюю часть экрана
- Автоматическое отображение при возникновении ошибок
- Скрытие при отсутствии ошибок

## Примеры использования

### Тестирование системы ошибок:

```dart
// Симуляция ошибки сохранения настроек
final errorService = ref.read(setupErrorServiceProvider);
await errorService.handlePreferencesError(
  Exception('Test preferences error'),
  StackTrace.current,
  context: context,
);

// Симуляция ошибки смены темы
await errorService.handleThemeError(
  'dark',
  Exception('Theme change failed'),
  StackTrace.current,
  context: context,
);
```

### Мониторинг ошибок:

```dart
// Получение списка ошибок
final setupErrors = ref.watch(setupErrorsProvider);
print('Активных ошибок: ${setupErrors.length}');

// Очистка ошибок
final errorService = ref.read(setupErrorServiceProvider);
errorService.clearErrors();
```

## Логирование и аналитика

Все ошибки автоматически:
- Логируются через `AppLogger`
- Отправляются в аналитику (если включена)
- Сохраняются в историю ошибок
- Включают метаданные для отладки

### Метаданные ошибок:
```json
{
  "context": "setup_screen",
  "action": "save_preferences",
  "timestamp": "2025-01-22T...",
  "attempted_theme": "dark"
}
```

## Расширение системы

### Добавление нового типа ошибки:

1. Создать класс ошибки в `setup_errors.dart`
2. Добавить обработчик в `SetupErrorService`
3. Обновить UI для отображения
4. Добавить логику повтора (если нужно)

### Кастомизация отображения:

```dart
// Изменение типа отображения
displayType: ErrorDisplayType.snackbar,

// Настройка повторов
canRetry: true,
maxRetries: 3,

// Уровень критичности
severity: ErrorSeverity.error,
```

## Преимущества интеграции

1. **Унифицированная обработка** - все ошибки setup экрана обрабатываются единообразно
2. **Улучшенный UX** - пользователи получают понятные сообщения об ошибках
3. **Диагностика** - разработчики получают детальную информацию для отладки
4. **Восстановление** - автоматические попытки исправления ошибок
5. **Мониторинг** - возможность отслеживать проблемы в реальном времени
