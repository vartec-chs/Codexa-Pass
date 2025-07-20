# История ошибок - Решение проблемы доступа к деталям

## 🎯 Проблема
При уходе с экрана, на котором произошла ошибка, пользователь не мог просмотреть детали ошибки, так как ErrorBoundary сбрасывал свое состояние при навигации.

## ✅ Решение

### 1. Глобальное хранение ошибок в ErrorController

```dart
class ErrorController {
  /// История ошибок для просмотра деталей
  final List<AppError> _errorHistory = [];
  final Map<String, AppError> _persistedErrors = {};

  /// Сохранить ошибку для последующего просмотра
  void persistError(AppError error) {
    _persistedErrors[error.errorId] = error;
    _errorHistory.add(error);
    
    // Ограничиваем размер истории (настраивается в config)
    if (_errorHistory.length > config.maxErrorHistorySize) {
      final removedError = _errorHistory.removeAt(0);
      _persistedErrors.remove(removedError.errorId);
    }
  }

  /// Получить ошибку по ID
  AppError? getPersistedError(String errorId) {
    return _persistedErrors[errorId];
  }

  /// Получить историю ошибок
  List<AppError> get errorHistory => List.unmodifiable(_errorHistory);
}
```

### 2. Автоматическое сохранение в ErrorBoundary

```dart
class _ErrorBoundaryState extends ConsumerState<ErrorBoundary> {
  @override
  void dispose() {
    // Сохраняем ошибку в глобальное хранилище перед уничтожением
    if (_hasError && _currentError != null && widget.enableLogging) {
      final errorController = ref.read(errorControllerProvider);
      errorController.persistError(_currentError!);
    }
    super.dispose();
  }

  void _handleError(AppError error) {
    // При обработке сразу сохраняем в историю
    if (widget.enableLogging) {
      final errorController = ref.read(errorControllerProvider);
      errorController.handleError(error);
      errorController.persistError(error); // ⭐ Немедленное сохранение
    }
  }
}
```

### 3. Страница истории ошибок (ErrorHistoryPage)

#### Возможности:
- **Просмотр всех ошибок** с группировкой по дням
- **Детальная информация** по каждой ошибке
- **Поиск и фильтрация** по модулям и типам
- **Копирование деталей** в буфер обмена
- **Удаление** отдельных ошибок
- **Очистка** всей истории

#### UI компоненты:
```dart
class ErrorHistoryPage extends ConsumerWidget {
  // Группировка ошибок по дням
  Widget _buildErrorList(context, errors, controller) {
    final groupedErrors = <String, List<AppError>>{};
    // "Сегодня", "Вчера", "15.07.2025"
  }

  // Карточка ошибки с иконкой уровня критичности
  Widget _buildErrorCard(context, error, controller) {
    return Card(
      child: InkWell(
        onTap: () => _showErrorDetails(context, error),
        child: // Детали ошибки с цветовым кодированием
      ),
    );
  }

  // Полный диалог с деталями
  void _showErrorDetails(BuildContext context, AppError error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // Все метаданные, стек вызовов, возможность копирования
      ),
    );
  }
}
```

### 4. Конфигурация

Добавлен параметр в `ErrorConfig`:
```dart
class ErrorConfig {
  const ErrorConfig({
    this.maxErrorHistorySize = 50, // ⭐ Максимум ошибок в истории
    // ... другие параметры
  });

  final int maxErrorHistorySize;
}
```

### 5. Интеграция с демо виджетом

```dart
// В AppBar ErrorDemoPage добавлена кнопка
IconButton(
  icon: const Icon(Icons.history),
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ErrorHistoryPage(),
      ),
    );
  },
  tooltip: 'История ошибок',
),
```

## 🚀 Преимущества решения

### ✅ Полное решение проблемы:
- **Доступ к деталям** ошибок в любой момент
- **Сохранение контекста** при навигации
- **История** всех произошедших ошибок
- **Удобный UI** для просмотра и управления

### ✅ Производительность:
- **Ограниченный размер** истории (конфигурируется)
- **Эффективное хранение** по ID
- **Ленивая загрузка** UI элементов
- **Автоматическая очистка** старых ошибок

### ✅ Пользовательский опыт:
- **Интуитивный интерфейс** с группировкой по дням
- **Цветовое кодирование** по уровню критичности
- **Контекстное меню** для действий с ошибками
- **Поиск и фильтрация** для больших объемов данных

### ✅ Отладка и мониторинг:
- **Полная информация** о каждой ошибке
- **Временные метки** для анализа
- **Метаданные** и стек вызовов
- **Возможность экспорта** данных

## 🎯 Использование

### Автоматическое сохранение:
Все ошибки, обработанные через ErrorBoundary или ErrorController, автоматически сохраняются в истории.

### Просмотр истории:
1. Откройте демо виджет
2. Нажмите иконку "История" в AppBar
3. Просмотрите все ошибки, сгруппированные по дням
4. Нажмите на ошибку для просмотра деталей

### Управление историей:
- **Копирование**: Меню → Копировать
- **Удаление**: Меню → Удалить
- **Очистка всего**: Кнопка в AppBar

## 🔮 Возможные улучшения

1. **Фильтрация по критичности** и модулям
2. **Экспорт в файл** (JSON, CSV)
3. **Синхронизация** с облачными сервисами
4. **Push-уведомления** о критических ошибках
5. **Аналитика** и графики
6. **Автоматические отчеты** по email

Теперь пользователи могут легко отслеживать и анализировать все ошибки в приложении! 🎉
