# Быстрый старт - Система ошибок v2

## 🚀 Интеграция завершена!

Новая система ошибок v2 полностью интегрирована в приложение. Старая система удалена.

## 📱 Тестирование

1. **Запустите приложение**:
   ```bash
   flutter run
   ```

2. **Найдите кнопку "Расширенный тест ошибок v2"** на главной странице

3. **Протестируйте различные типы ошибок**:
   - Аутентификация (SnackBar)
   - Шифрование (Dialog) 
   - Сеть (Banner)
   - Валидация (Inline)
   - База данных (Fullscreen)

4. **Протестируйте Result<T> операции**:
   - Успешная операция
   - Операция с ошибкой
   - Автоматический retry

## 🔧 Основное использование

### 1. Создание ошибки
```dart
final error = NetworkErrorV2(
  errorType: NetworkErrorType.noConnection,
  message: 'Нет подключения к интернету',
  url: 'https://api.example.com',
);
```

### 2. Отображение ошибки
```dart
await ErrorDisplayV2.show(
  context,
  error,
  config: const ErrorDisplayConfigV2(
    type: ErrorDisplayType.snackbar,
    showRetryButton: true,
  ),
  onRetry: () => _retryOperation(),
);
```

### 3. Использование Result<T>
```dart
Future<ResultV2<String>> fetchData() async {
  try {
    final data = await api.getData();
    return SuccessV2(data);
  } catch (e) {
    final error = NetworkErrorV2(
      errorType: NetworkErrorType.serverError,
      message: 'Ошибка сервера',
    );
    return FailureV2(error);
  }
}

// Использование
final result = await fetchData();
result.fold(
  (data) => print('Данные: $data'),
  (error) => _handleError(error),
);
```

### 4. Глобальный обработчик ошибок
```dart
final handler = getGlobalErrorHandler();

// Выполнение с retry
final result = await handler.executeWithRetry(
  () => dangerousOperation(),
  maxRetries: 3,
);

// Обработка необработанных ошибок
await handler.handleError(error, context);
```

## 🎨 Типы UI отображения

1. **SnackBar** - быстрые уведомления
2. **Dialog** - критические ошибки  
3. **Banner** - временные предупреждения
4. **Inline** - встроенные в формы
5. **Fullscreen** - фатальные ошибки

## 📊 Аналитика и логирование

Все ошибки автоматически:
- Логируются в AppLogger
- Отправляются в аналитику
- Отслеживаются для статистики

## 🌍 Локализация

Система поддерживает автоматическую локализацию сообщений об ошибках на основе контекста и типа ошибки.

## 📈 Мониторинг

Используйте тестовую страницу для просмотра статистики системы ошибок в реальном времени.

---

**Готово к использованию!** 🎉

Система ошибок v2 обеспечивает:
- ✅ Типобезопасность
- ✅ Автоматическое восстановление  
- ✅ Богатый UI
- ✅ Локализацию
- ✅ Аналитику
- ✅ Простоту использования
