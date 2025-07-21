# Система аналитики для Flutter-приложения

## Обзор

Комплексная система аналитики для отслеживания действий пользователя в приложении-менеджере паролей. Система построена на модульной архитектуре с использованием Riverpod для управления состоянием.

## Структура проекта

```
lib/app/analytics/
├── models/                     # Модели данных
│   ├── analytics_event.dart    # Базовая модель события
│   ├── analytics_events.dart   # Типы событий и константы
│   ├── analytics_metrics.dart  # Модели метрик
│   └── user_models.dart        # Модели пользователя и сессии
├── services/                   # Основные сервисы
│   └── analytics_service.dart  # Главный сервис аналитики
├── storage/                    # Хранение данных
│   └── analytics_storage.dart  # Абстракция и реализации хранилища
├── collectors/                 # Сборщики метрик
│   ├── event_collector.dart    # Сбор событий
│   ├── performance_collector.dart # Метрики производительности
│   ├── security_collector.dart # Метрики безопасности
│   └── user_behavior_collector.dart # Поведение пользователя
├── providers/                  # Riverpod провайдеры
│   └── analytics_providers.dart # Все провайдеры для аналитики
├── trackers/                   # Специализированные трекеры
│   ├── authentication_tracker.dart # Отслеживание аутентификации
│   ├── password_tracker.dart   # Отслеживание операций с паролями
│   ├── ui_tracker.dart         # Отслеживание UI взаимодействий
│   ├── performance_tracker.dart # Отслеживание производительности
│   └── trackers.dart          # Экспорт всех трекеров
├── integrations/              # Интеграция с Flutter
│   └── analytics_integration.dart # Виджеты и утилиты интеграции
├── examples/                  # Примеры использования
│   └── analytics_examples.dart # Полные примеры интеграции
└── analytics.dart            # Главный экспорт модуля
```

## Основные компоненты

### 1. Модели данных

#### AnalyticsEvent
Базовая модель для всех аналитических событий:
```dart
class AnalyticsEvent {
  final String eventId;
  final String eventName;
  final String eventType;
  final DateTime timestamp;
  final Map<String, dynamic> properties;
  final Map<String, dynamic> metadata;
}
```

#### Типы событий
- **Аутентификация**: Вход, выход, смена пароля
- **Пароли**: Создание, изменение, копирование, удаление
- **UI**: Навигация, поиск, взаимодействия с элементами
- **Производительность**: Время загрузки, использование памяти
- **Безопасность**: Обнаружение слабых паролей, попытки взлома

#### Метрики
- **PerformanceMetrics**: Время запуска, загрузки экранов, запросов к БД
- **SecurityMetrics**: Общий балл безопасности, количество слабых паролей
- **UserBehaviorMetrics**: Активность пользователя, предпочтения
- **ErrorMetrics**: Частота ошибок, типы сбоев

### 2. Основной сервис

**AnalyticsService** - централизованный сервис для:
- Инициализации системы аналитики
- Отслеживания событий и метрик
- Управления сессиями пользователя
- Экспорта данных
- Очистки старых данных

### 3. Хранилище данных

Абстракция **AnalyticsStorage** с реализациями:
- **InMemoryAnalyticsStorage**: Хранение в памяти (для разработки)
- **FileAnalyticsStorage**: Хранение в файлах (для продакшена)

### 4. Сборщики метрик

Специализированные классы для агрегации данных:
- **EventCollector**: Базовый сбор событий
- **PerformanceCollector**: Метрики производительности
- **SecurityCollector**: Метрики безопасности
- **UserBehaviorCollector**: Анализ поведения пользователя

### 5. Riverpod провайдеры

Комплексная система провайдеров для:
- Доступа к сервису аналитики
- Получения метрик по датам
- Управления состоянием сессии
- Экспорта данных

### 6. Специализированные трекеры

- **AuthenticationTracker**: Отслеживание входа/выхода
- **PasswordTracker**: Операции с паролями
- **UITracker**: Взаимодействие с интерфейсом
- **PerformanceTracker**: Измерение производительности

### 7. Интеграция с Flutter

**AnalyticsIntegration** предоставляет:
- Виджеты-обертки для автоматического трекинга
- Навигационный наблюдатель
- Обработчик ошибок
- Миксины для добавления аналитики в виджеты

## Быстрый старт

### 1. Инициализация

```dart
import 'package:your_app/app/analytics/analytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация аналитики
  final storage = FileAnalyticsStorage();
  final analyticsService = AnalyticsService.instance;
  
  await analyticsService.initialize(
    storage: storage,
    enablePerformanceTracking: true,
    enableSecurityTracking: true,
    enableUserBehaviorTracking: true,
  );
  
  await AnalyticsIntegration.initialize(analyticsService);
  
  runApp(MyApp());
}
```

### 2. Добавление провайдеров

```dart
void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 3. Отслеживание экранов

```dart
class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnalyticsScreenWrapper(
      screenName: 'home',
      screenParameters: {'section': 'main'},
      child: Scaffold(
        appBar: AppBar(title: Text('Главная')),
        body: YourContent(),
      ),
    );
  }
}
```

### 4. Отслеживание действий

```dart
// Кнопка с автоматическим трекингом
AnalyticsButton(
  buttonName: 'create_password',
  buttonType: 'primary',
  onPressed: () => _createPassword(),
  child: Text('Создать пароль'),
)

// Поиск с трекингом
AnalyticsSearchField(
  searchContext: 'password_list',
  onSearch: (query) => _performSearch(query),
)

// Производительность
AnalyticsPerformanceWrapper(
  operationName: 'password_list_render',
  child: PasswordList(),
)
```

### 5. Ручное отслеживание

```dart
class PasswordManager extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          return Column(
            children: [
              ElevatedButton(
                onPressed: () => _createPassword(ref),
                child: Text('Создать пароль'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _createPassword(WidgetRef ref) async {
    final passwordTracker = AnalyticsIntegration.createPasswordTracker();
    
    await passwordTracker.trackPasswordCreated(
      category: 'social',
      passwordStrength: 'strong',
      isGenerated: true,
    );
  }
}
```

### 6. Получение метрик

```dart
class AnalyticsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateRange = AnalyticsUtils.thisWeek;
    final metricsAsync = ref.watch(allMetricsProvider(dateRange));
    
    return metricsAsync.when(
      data: (metrics) => MetricsDisplay(metrics: metrics),
      loading: () => CircularProgressIndicator(),
      error: (error, _) => Text('Ошибка: $error'),
    );
  }
}
```

## Доступные события

### Аутентификация
- `login_attempt` - Попытка входа
- `login_success` - Успешный вход
- `login_failure` - Неудачный вход
- `logout` - Выход из системы
- `password_change` - Смена мастер-пароля

### Пароли
- `password_created` - Создание пароля
- `password_updated` - Обновление пароля
- `password_deleted` - Удаление пароля
- `password_copied` - Копирование пароля
- `password_viewed` - Просмотр пароля

### UI взаимодействия
- `screen_view` - Просмотр экрана
- `button_click` - Нажатие кнопки
- `search_performed` - Выполнение поиска
- `menu_opened` - Открытие меню

### Безопасность
- `weak_password_detected` - Обнаружен слабый пароль
- `security_check_failed` - Провал проверки безопасности
- `suspicious_activity` - Подозрительная активность

## Метрики производительности

- **Время запуска приложения**
- **Время загрузки экранов**
- **Время выполнения запросов к БД**
- **Использование памяти**
- **Частота кадров (FPS)**

## Конфигурация

```dart
await analyticsService.initialize(
  storage: storage,
  enablePerformanceTracking: true,  // Отслеживание производительности
  enableSecurityTracking: true,     // Отслеживание безопасности
  enableUserBehaviorTracking: true, // Отслеживание поведения
  sessionTimeout: Duration(minutes: 30), // Таймаут сессии
  maxEventsInMemory: 1000,          // Максимум событий в памяти
  autoCleanupEnabled: true,         // Автоочистка старых данных
  cleanupThresholdDays: 90,         // Хранить данные 90 дней
);
```

## Экспорт данных

```dart
final service = ref.read(analyticsServiceProvider);
final exportData = await service.exportAnalyticsData(
  startDate: DateTime.now().subtract(Duration(days: 30)),
  endDate: DateTime.now(),
);

// Данные включают:
// - events: Список всех событий
// - metrics: Агрегированные метрики
// - sessions: Данные сессий
// - summary: Сводная информация
```

## Утилиты

```dart
// Предопределенные периоды
final today = AnalyticsUtils.today;
final thisWeek = AnalyticsUtils.thisWeek;
final thisMonth = AnalyticsUtils.thisMonth;
final last30Days = AnalyticsUtils.last30Days;

// Создание кастомного периода
final customRange = DateRange(
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime(2024, 12, 31),
);
```

## Лучшие практики

1. **Инициализируйте аналитику** в main() перед запуском приложения
2. **Используйте AnalyticsScreenWrapper** для всех основных экранов
3. **Добавляйте контекст** к событиям через параметры
4. **Группируйте связанные действия** в одну аналитическую сессию
5. **Регулярно экспортируйте данные** для анализа
6. **Настройте автоочистку** для управления размером данных
7. **Используйте специализированные трекеры** для типизированных событий

## Примеры интеграции

Полные примеры использования системы аналитики доступны в файле:
`lib/app/analytics/examples/analytics_examples.dart`

Примеры включают:
- Полное приложение с аналитикой
- Различные типы виджетов с трекингом
- Обработку ошибок и производительности
- Отображение метрик в UI
- Экспорт данных

## Поддержка и расширение

Система построена модульно и легко расширяется:

1. **Новые типы событий**: Добавьте в `analytics_events.dart`
2. **Новые метрики**: Создайте модель в `analytics_metrics.dart`
3. **Новые трекеры**: Реализуйте в папке `trackers/`
4. **Новые хранилища**: Наследуйте от `AnalyticsStorage`
5. **Новые сборщики**: Создайте в папке `collectors/`

Система готова к использованию и предоставляет полный набор инструментов для мониторинга действий пользователя в приложении-менеджере паролей.
