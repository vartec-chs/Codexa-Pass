import 'package:flutter/material.dart';
import 'package:codexa_pass/core/error/enhanced_error_system.dart';

/// Примеры использования новой системы ошибок
class ErrorExamples {
  /// Пример 1: Безопасное выполнение операции
  static Future<void> exampleSafeOperation() async {
    // Синхронная операция
    final parseResult = ErrorHandler.safe(
      () => int.parse('123'),
      errorCode: 'parsing_error',
      category: ErrorCategory.validation,
    );

    if (parseResult.isSuccess) {
      print('Результат: ${parseResult.value}');
    } else {
      print('Ошибка: ${parseResult.error!.message}');
    }

    // Асинхронная операция
    final httpResult = await ErrorHandler.safeAsync(
      () => _mockHttpRequest(),
      category: ErrorCategory.network,
    );

    httpResult.fold(
      (data) => print('Получены данные: $data'),
      (error) => print('Ошибка сети: ${error.message}'),
    );
  }

  /// Пример 2: Создание и обработка кастомных ошибок
  static void exampleCustomErrors() {
    try {
      // Валидация email
      _validateEmail('invalid-email');
    } catch (e) {
      if (e is ValidationError) {
        print('Ошибка валидации: ${e.message}');
        print('Поле: ${e.field}');
        print('Код: ${e.code}');
      }
    }

    try {
      // Работа с базой данных
      _simulateDatabaseError();
    } catch (e) {
      if (e is DatabaseError) {
        print('Ошибка БД: ${e.message}');
        print('Критическая: ${e.isCritical}');
        if (e.context != null) {
          print('Контекст: ${e.context}');
        }
      }
    }
  }

  /// Пример 3: Цепочка операций с обработкой ошибок
  static Future<void> exampleChainOperations() async {
    final initialData = Success<String>('user123');

    final result = ErrorHandler.chain(
      initialData,
    ).then((userId) => Success('Processed: $userId')).build();

    result.fold(
      (data) => print('Операция успешна: $data'),
      (error) => print('Ошибка в цепочке: ${error.message}'),
    );
  }

  /// Пример 4: Retry логика
  static Future<void> exampleRetryLogic() async {
    // Простой retry
    await ErrorHandler.retry(
      () => _unstableOperation(),
      maxAttempts: 3,
      delay: Duration(seconds: 1),
      retryIf: (error) => error.category == ErrorCategory.network,
    );

    // Retry через расширение
    final extResult = await _unstableHttpOperation()
        .toResult(category: ErrorCategory.network)
        .retry(maxAttempts: 5);

    extResult.onSuccess((data) => print('Успех после retry: $data'));
  }

  /// Пример 5: Обработка в UI виджете
  static Widget exampleWidget() {
    return ErrorHandlerWidget();
  }

  // Вспомогательные методы для примеров
  static Future<String> _mockHttpRequest() async {
    await Future.delayed(Duration(milliseconds: 100));
    return 'mock data';
  }

  static void _validateEmail(String email) {
    if (!email.contains('@')) {
      throw ValidationError.invalidFormat('email', 'Должен содержать @');
    }
  }

  static void _simulateDatabaseError() {
    throw DatabaseError.connectionFailed('Connection timeout');
  }

  static Future<Result<String>> _unstableOperation() async {
    return ErrorHandler.safeAsync(() async {
      if (DateTime.now().millisecond % 2 == 0) {
        throw NetworkError.timeout('Random timeout');
      }
      return 'success';
    });
  }

  static Future<String> _unstableHttpOperation() async {
    if (DateTime.now().millisecond % 3 == 0) {
      throw NetworkError.noConnection();
    }
    return 'http data';
  }
}

/// Пример виджета с обработкой ошибок
class ErrorHandlerWidget extends StatefulWidget {
  @override
  _ErrorHandlerWidgetState createState() => _ErrorHandlerWidgetState();
}

class _ErrorHandlerWidgetState extends State<ErrorHandlerWidget> {
  String? data;
  BaseAppError? error;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final result = await ErrorHandler.safeAsyncWithTimeout(
      () => _simulateDataLoading(),
      Duration(seconds: 5),
      category: ErrorCategory.network,
    );

    setState(() {
      isLoading = false;
      result.fold(
        (loadedData) {
          data = loadedData;
          error = null;
        },
        (loadError) {
          data = null;
          error = loadError;
        },
      );
    });
  }

  Future<String> _simulateDataLoading() async {
    await Future.delayed(Duration(seconds: 2));

    // Случайно генерируем разные типы ошибок
    final random = DateTime.now().millisecond % 4;
    switch (random) {
      case 0:
        throw NetworkError.noConnection();
      case 1:
        throw ValidationError.required('data');
      case 2:
        throw DatabaseError.queryFailed('SELECT * FROM table');
      default:
        return 'Загруженные данные';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Пример обработки ошибок')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Загрузка данных...'),
                ],
              )
            else if (error != null)
              _buildErrorWidget(error!)
            else if (data != null)
              _buildSuccessWidget(data!)
            else
              Text('Нет данных'),

            SizedBox(height: 32),
            ElevatedButton(
              onPressed: isLoading ? null : _loadData,
              child: Text('Загрузить данные'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BaseAppError error) {
    return Column(
      children: [
        Icon(
          _getErrorIcon(error.category),
          size: 64,
          color: error.isCritical ? Colors.red : Colors.orange,
        ),
        SizedBox(height: 16),
        Text(
          error.message,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        if (error.technicalDetails != null) ...[
          SizedBox(height: 8),
          Text(
            error.technicalDetails!,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
        SizedBox(height: 16),
        Card(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Код ошибки: ${error.code}'),
                Text('Категория: ${error.category.name}'),
                Text('Критическая: ${error.isCritical ? "Да" : "Нет"}'),
                Text('Время: ${error.timestamp}'),
                if (error.context != null) Text('Контекст: ${error.context}'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessWidget(String data) {
    return Column(
      children: [
        Icon(Icons.check_circle, size: 64, color: Colors.green),
        SizedBox(height: 16),
        Text(
          'Данные загружены успешно',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 8),
        Text(data),
      ],
    );
  }

  IconData _getErrorIcon(ErrorCategory category) {
    switch (category) {
      case ErrorCategory.network:
        return Icons.wifi_off;
      case ErrorCategory.authentication:
        return Icons.lock;
      case ErrorCategory.validation:
        return Icons.warning;
      case ErrorCategory.database:
        return Icons.storage;
      case ErrorCategory.security:
        return Icons.security;
      case ErrorCategory.system:
        return Icons.computer;
      case ErrorCategory.ui:
        return Icons.widgets;
      default:
        return Icons.error;
    }
  }
}

/// Пример использования в сервисе
class ExampleUserService {
  Future<Result<User>> getUser(String userId) async {
    return ErrorHandler.safeAsync(() async {
      // Валидация входных данных
      if (userId.isEmpty) {
        throw ValidationError.required('userId');
      }

      // Симуляция HTTP запроса
      await Future.delayed(Duration(milliseconds: 500));

      // Случайная ошибка для демонстрации
      if (userId == 'error') {
        throw NetworkError.serverError(500, 'Internal server error');
      }

      return User(id: userId, name: 'Test User');
    }, category: ErrorCategory.network);
  }

  Future<Result<List<User>>> getAllUsers() async {
    // Пример с retry логикой
    return ErrorHandler.retry(
      () => ErrorHandler.safeAsyncWithTimeout(
        () async {
          await Future.delayed(Duration(seconds: 1));
          return [User(id: '1', name: 'User 1'), User(id: '2', name: 'User 2')];
        },
        Duration(seconds: 5),
        category: ErrorCategory.network,
      ),
      maxAttempts: 3,
      delay: Duration(seconds: 1),
      retryIf: (error) => error.category == ErrorCategory.network,
    );
  }
}

class User {
  final String id;
  final String name;

  User({required this.id, required this.name});

  @override
  String toString() => 'User(id: $id, name: $name)';
}
