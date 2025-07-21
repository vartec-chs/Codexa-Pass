# Система роутинга Codexa Pass

Система роутинга построена на основе `go_router` с интеграцией `riverpod` и включает продвинутые функции для управления навигацией, безопасности и переходов.

## Структура

```
lib/app/routing/
├── routing.dart              # Основной экспорт файл
├── app_router.dart          # Конфигурация GoRouter
├── route_config.dart        # Константы и конфигурация маршрутов
├── route_guards.dart        # Защита маршрутов и логирование
├── route_transitions.dart   # Анимации переходов
└── routes/                  # Определения маршрутов по модулям
    ├── auth_routes.dart     # Маршруты аутентификации
    ├── home_routes.dart     # Главная страница и поиск
    ├── vault_routes.dart    # Хранилище паролей
    └── settings_routes.dart # Настройки приложения
```

## Основные компоненты

### 1. AppRouter (`app_router.dart`)

Центральная конфигурация роутера с провайдером Riverpod:

```dart
final appRouterProvider = Provider<GoRouter>((ref) {
  // Конфигурация с защитой маршрутов и логированием
});
```

### 2. RouteConfig (`route_config.dart`)

Определяет все константы маршрутов и конфигурацию:

```dart
class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  // ...
}

class RouteNames {
  static const String home = 'home';
  static const String login = 'login';
  // ...
}
```

### 3. RouteGuards (`route_guards.dart`)

Система защиты маршрутов включает:

- **AuthGuard**: Проверка аутентификации
- **PermissionGuard**: Проверка разрешений (админ, премиум)
- **SecurityGuard**: Проверка биометрической аутентификации
- **RouteLogger**: Логирование всех переходов

### 4. RouteTransitions (`route_transitions.dart`)

Настраиваемые анимации переходов:

```dart
enum AppTransitions {
  none, fade, slide, slideUp, slideDown, 
  scale, rotation, custom
}
```

## Использование

### Основная интеграция

В `main.dart`:

```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      routerConfig: router,
      // ...
    );
  }
}
```

### Навигация

```dart
// Простой переход
context.push('/vault');

// Переход с параметрами
context.push('/password-details/123');

// Замена текущего маршрута
context.go('/home');

// Возврат назад
context.pop();
```

### Добавление новых маршрутов

1. Добавьте константы в `RouteConfig`:

```dart
class AppRoutes {
  static const String newFeature = '/new-feature';
}

class RouteNames {
  static const String newFeature = 'new-feature';
}
```

2. Создайте маршрут в соответствующем файле routes:

```dart
GoRoute(
  path: AppRoutes.newFeature,
  name: RouteNames.newFeature,
  pageBuilder: (context, state) => buildTransitionPage(
    context: context,
    state: state,
    child: const NewFeaturePage(),
    transitionType: AppTransitions.fade,
  ),
),
```

## Функции безопасности

### Защита маршрутов

Система автоматически проверяет:
- Аутентификацию пользователя
- Права доступа к функциям
- Требования биометрической аутентификации

### Автоматические перенаправления

- Неаутентифицированные пользователи → `/login`
- Аутентифицированные пользователи на `/login` → `/home`
- Сохранение URL для возврата после входа

## Логирование

Система автоматически логирует:
- Все переходы между страницами
- Попытки доступа к защищенным маршрутам
- Ошибки навигации
- Время выполнения переходов

## Переходы и анимации

### Предустановленные переходы

- **Fade**: Плавное затухание/появление
- **Slide**: Горизонтальное скольжение
- **SlideUp**: Вертикальное скольжение снизу
- **Scale**: Масштабирование с затуханием
- **Custom**: Комбинированные эффекты

### Автоматический выбор переходов

Система автоматически выбирает подходящие переходы:
- Настройки → Slide
- Модальные окна → SlideUp
- Детальные страницы → Scale
- Обычные переходы → Fade

## Конфигурация

### Настройка переходов

```dart
buildTransitionPage(
  context: context,
  state: state,
  child: widget,
  transitionType: AppTransitions.scale,
  config: AppTransitionConfigs.bounce,
);
```

### Настройка защиты

Маршруты автоматически классифицируются как:
- Публичные (доступны всем)
- Защищенные (требуют аутентификации)
- Премиум (требуют подписки)
- Админ (требуют админских прав)

## Обработка ошибок

Система включает:
- Автоматический перехват ошибок навигации
- Страницу ошибок с возможностью восстановления
- Логирование всех проблем

## Производительность

- Ленивая загрузка страниц
- Кэширование маршрутов
- Оптимизированные переходы
- Минимальное время инициализации

## Расширение

Для добавления новых функций:

1. Создайте новый файл в `routes/`
2. Добавьте константы в `RouteConfig`
3. При необходимости добавьте новые guards
4. Настройте переходы

Система спроектирована для легкого расширения и поддержания.
