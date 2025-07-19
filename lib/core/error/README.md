# Система обработки ошибок CodexaPass

## Обзор

Улучшенная система обработки ошибок предоставляет типизированные ошибки, безопасное выполнение операций, автоматическое логирование и интеграцию с краш-репортами.

## Компоненты системы

### 1. Типизированные ошибки (`enhanced_app_error.dart`)

#### Базовые классы

```dart
// Базовый интерфейс для всех ошибок
abstract class BaseAppError implements Exception {
  String get code;
  String get message;
  String? get technicalDetails;
  Map<String, dynamic>? get context;
  bool get isCritical;
  ErrorCategory get category;
  DateTime get timestamp;
  Object? get originalError;
  StackTrace? get stackTrace;
  bool get shouldCreateCrashReport;
  CrashType get crashReportType;
}

// Абстрактный класс для реализации ошибок
abstract class AppError extends BaseAppError {
  // Реализация базового функционала
}
```

#### Категории ошибок

```dart
enum ErrorCategory {
  authentication('auth'),
  encryption('crypto'),
  database('db'),
  network('net'),
  validation('validation'),
  storage('storage'),
  security('security'),
  system('system'),
  ui('ui'),
  business('business'),
  unknown('unknown');
}
```

#### Предопределенные типы ошибок

1. **AuthenticationError** - ошибки аутентификации
2. **EncryptionError** - ошибки шифрования (критические)
3. **DatabaseError** - ошибки базы данных
4. **NetworkError** - сетевые ошибки
5. **ValidationError** - ошибки валидации
6. **StorageError** - ошибки хранилища
7. **SecurityError** - ошибки безопасности (критические)
8. **SystemError** - системные ошибки (критические)
9. **UIError** - ошибки пользовательского интерфейса
10. **BusinessError** - бизнес-логические ошибки

### 2. Обработчик ошибок (`enhanced_error_handler.dart`)

#### Result<T> - Типизированный результат операции

```dart
// Использование Result
Result<String> result = someOperation();

// Проверка результата
if (result.isSuccess) {
  String value = result.value!;
} else {
  BaseAppError error = result.error!;
}

// Функциональный стиль
result.fold(
  onSuccess: (value) => print('Успех: $value'),
  onFailure: (error) => print('Ошибка: $error'),
);
```

#### ErrorHandler - Глобальный обработчик ошибок

```dart
// Инициализация
await ErrorHandler.instance.initialize();

// Обработка ошибки
ErrorHandler.instance.handleError(error);

// Безопасное выполнение
Result<int> result = ErrorHandler.safe(
  () => int.parse('123'),
  errorCode: 'parsing_error',
  category: ErrorCategory.validation,
);

// Асинхронное выполнение
Result<String> asyncResult = await ErrorHandler.safeAsync(
  () => httpClient.get('https://api.example.com'),
  category: ErrorCategory.network,
);
```

## Интеграция с приложением

### 1. Инициализация в main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация системы ошибок
  await ErrorHandler.instance.initialize();
  
  runApp(MyApp());
}
```

### 2. Использование в коде

#### Создание и выбрасывание ошибок

```dart
// Создание простой ошибки
throw ValidationError.required('email');

// Создание ошибки с контекстом
throw DatabaseError.queryFailed(
  'SELECT * FROM users WHERE id = ?',
  'Connection timeout',
);

// Создание кастомной ошибки
throw AppError.create(
  message: 'Произошла неожиданная ошибка',
  category: ErrorCategory.unknown,
  technicalDetails: 'Additional debug info',
  context: {'userId': 123, 'action': 'login'},
);
```

#### Безопасное выполнение операций

```dart
// Синхронные операции
Result<User> getUserResult = ErrorHandler.safe(
  () => userService.getUser(id),
  errorCode: 'user_fetch_error',
  category: ErrorCategory.database,
);

// Асинхронные операции
Result<List<Post>> getPostsResult = await ErrorHandler.safeAsync(
  () => apiService.getPosts(),
  category: ErrorCategory.network,
);

// С таймаутом
Result<String> timeoutResult = await ErrorHandler.safeAsyncWithTimeout(
  () => slowApiCall(),
  Duration(seconds: 30),
  category: ErrorCategory.network,
);
```

#### Обработка результатов

```dart
// Базовая обработка
final result = await fetchUserData();
if (result.isSuccess) {
  updateUI(result.value!);
} else {
  showErrorDialog(result.error!.message);
}

// Функциональная обработка
result
  .onSuccess((data) => updateUI(data))
  .onFailure((error) => showErrorDialog(error.message));

// Преобразование данных
final processedResult = result
  .map((user) => user.toDisplayModel())
  .recover((error) => UserDisplayModel.empty());

// Цепочка операций
final chainResult = await ErrorHandler.chain(initialResult)
  .then((data) => validateData(data))
  .thenAsync((validData) => saveToDatabase(validData))
  .build();
```

#### Retry логика

```dart
// Автоматический повтор
Result<String> retryResult = await ErrorHandler.retry(
  () => unstableApiCall(),
  maxAttempts: 3,
  delay: Duration(seconds: 2),
  retryIf: (error) => error.category == ErrorCategory.network,
);

// Через расширение
Result<Data> dataResult = await fetchData()
  .toResult(category: ErrorCategory.network)
  .retry(maxAttempts: 5);
```

### 3. Обработка в UI

#### Обработка ошибок в виджетах

```dart
class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  User? user;
  BaseAppError? error;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => isLoading = true);
    
    final result = await ErrorHandler.safeAsync(
      () => userService.getCurrentUser(),
      category: ErrorCategory.database,
    );
    
    setState(() {
      isLoading = false;
      result.fold(
        onSuccess: (userData) {
          user = userData;
          error = null;
        },
        onFailure: (userError) {
          user = null;
          error = userError;
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (error != null) {
      return ErrorWidget(
        error: error!,
        onRetry: _loadUser,
      );
    }
    
    return UserProfileWidget(user: user!);
  }
}
```

#### Универсальный виджет для отображения ошибок

```dart
class ErrorWidget extends StatelessWidget {
  final BaseAppError error;
  final VoidCallback? onRetry;

  const ErrorWidget({
    Key? key,
    required this.error,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _getErrorIcon(),
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
        if (onRetry != null) ...[
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            child: Text('Повторить'),
          ),
        ],
      ],
    );
  }

  IconData _getErrorIcon() {
    switch (error.category) {
      case ErrorCategory.network:
        return Icons.wifi_off;
      case ErrorCategory.authentication:
        return Icons.lock;
      case ErrorCategory.validation:
        return Icons.warning;
      case ErrorCategory.database:
        return Icons.storage;
      default:
        return Icons.error;
    }
  }
}
```

### 4. Работа с формами

```dart
class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  Map<String, String> fieldErrors = {};

  Future<void> _login() async {
    setState(() => fieldErrors.clear());
    
    if (!_formKey.currentState!.validate()) return;
    
    final result = await ErrorHandler.safeAsync(
      () => authService.login(
        _emailController.text,
        _passwordController.text,
      ),
      category: ErrorCategory.authentication,
    );
    
    result.fold(
      onSuccess: (user) => Navigator.pushReplacementNamed(context, '/home'),
      onFailure: (error) => _handleLoginError(error),
    );
  }

  void _handleLoginError(BaseAppError error) {
    if (error is ValidationError && error.field != null) {
      setState(() {
        fieldErrors[error.field!] = error.message;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              errorText: fieldErrors['email'],
            ),
            validator: _validateEmail,
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Пароль',
              errorText: fieldErrors['password'],
            ),
            obscureText: true,
            validator: _validatePassword,
          ),
          ElevatedButton(
            onPressed: _login,
            child: Text('Войти'),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationError.required('email').message;
    }
    if (!value.contains('@')) {
      return ValidationError.invalidFormat('email').message;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationError.required('password').message;
    }
    if (value.length < 8) {
      return ValidationError.tooShort('password', 8).message;
    }
    return null;
  }
}
```

## Лучшие практики

### 1. Создание кастомных ошибок

```dart
// Создавайте специфичные ошибки для вашего домена
class UserNotFoundError extends BusinessError {
  UserNotFoundError(String userId) : super(
    code: 'user_not_found',
    message: 'Пользователь не найден',
    context: {'userId': userId},
  );
}

// Используйте фабричные методы для частых случаев
class PaymentError extends BusinessError {
  PaymentError({
    required String code,
    required String message,
    String? technicalDetails,
    Map<String, dynamic>? context,
  }) : super(
    code: code,
    message: message,
    category: ErrorCategory.business,
    technicalDetails: technicalDetails,
    context: context,
  );

  factory PaymentError.insufficientFunds(double amount) =>
      PaymentError(
        code: 'payment_insufficient_funds',
        message: 'Недостаточно средств для проведения операции',
        context: {'amount': amount},
      );

  factory PaymentError.cardExpired() =>
      PaymentError(
        code: 'payment_card_expired',
        message: 'Срок действия карты истек',
      );
}
```

### 2. Использование в сервисах

```dart
class UserService {
  final ApiClient _apiClient;
  final DatabaseService _database;

  UserService(this._apiClient, this._database);

  Future<Result<User>> getUser(String id) async {
    return ErrorHandler.safeAsync(
      () async {
        // Проверяем валидность ID
        if (id.isEmpty) {
          throw ValidationError.required('userId');
        }

        // Пытаемся получить из локальной БД
        final localUser = await _database.getUser(id);
        if (localUser != null) {
          return localUser;
        }

        // Загружаем с сервера
        final response = await _apiClient.get('/users/$id');
        if (response.statusCode == 404) {
          throw UserNotFoundError(id);
        }

        final user = User.fromJson(response.data);
        await _database.saveUser(user);
        return user;
      },
      category: ErrorCategory.database,
    );
  }

  Future<Result<List<User>>> getAllUsers() async {
    return ErrorHandler.retry(
      () => ErrorHandler.safeAsyncWithTimeout(
        () => _apiClient.get('/users').then(
          (response) => (response.data as List)
              .map((json) => User.fromJson(json))
              .toList(),
        ),
        Duration(seconds: 30),
        category: ErrorCategory.network,
      ),
      maxAttempts: 3,
      retryIf: (error) => error.category == ErrorCategory.network,
    );
  }
}
```

### 3. Тестирование

```dart
void main() {
  group('UserService', () {
    late UserService userService;
    late MockApiClient mockApiClient;
    late MockDatabaseService mockDatabase;

    setUp(() {
      mockApiClient = MockApiClient();
      mockDatabase = MockDatabaseService();
      userService = UserService(mockApiClient, mockDatabase);
    });

    test('should return user from database if available', () async {
      // Arrange
      const userId = 'test-id';
      final expectedUser = User(id: userId, name: 'Test User');
      when(mockDatabase.getUser(userId))
          .thenAnswer((_) async => expectedUser);

      // Act
      final result = await userService.getUser(userId);

      // Assert
      expect(result.isSuccess, true);
      expect(result.value, expectedUser);
      verifyNever(mockApiClient.get(any));
    });

    test('should return ValidationError for empty userId', () async {
      // Act
      final result = await userService.getUser('');

      // Assert
      expect(result.isFailure, true);
      expect(result.error, isA<ValidationError>());
      expect(result.error!.code, 'validation_required');
    });

    test('should return UserNotFoundError when API returns 404', () async {
      // Arrange
      const userId = 'non-existent';
      when(mockDatabase.getUser(userId))
          .thenAnswer((_) async => null);
      when(mockApiClient.get('/users/$userId'))
          .thenAnswer((_) async => ApiResponse(statusCode: 404));

      // Act
      final result = await userService.getUser(userId);

      // Assert
      expect(result.isFailure, true);
      expect(result.error, isA<UserNotFoundError>());
    });
  });
}
```

## Интеграция с логированием и краш-репортами

Система автоматически интегрируется с существующими системами логирования и краш-репортов:

1. **Автоматическое логирование**: Все ошибки автоматически логируются с соответствующим уровнем
2. **Краш-репорты**: Критические ошибки автоматически создают краш-репорты
3. **Контекстная информация**: Ошибки включают системную информацию и контекст

## Миграция с существующей системы

Для миграции с существующей системы ошибок:

1. Замените использование старых классов ошибок на новые типизированные
2. Оберните существующие операции в `ErrorHandler.safe()` или `ErrorHandler.safeAsync()`
3. Обновите обработку ошибок в UI для использования `Result<T>`
4. Добавьте инициализацию `ErrorHandler` в `main.dart`

Система полностью совместима с существующим кодом и может быть внедрена постепенно.
