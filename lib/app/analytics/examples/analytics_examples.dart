import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../analytics.dart';
import '../integrations/analytics_integration.dart';

/// Пример использования системы аналитики в приложении
class AnalyticsExampleApp extends StatelessWidget {
  const AnalyticsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Analytics Example',
        // Добавляем навигационный наблюдатель для автоматического отслеживания
        navigatorObservers: [AnalyticsIntegration.createNavigationObserver()],
        home: const ExampleHomePage(),
      ),
    );
  }
}

/// Пример главной страницы с использованием аналитики
class ExampleHomePage extends ConsumerWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Автоматически отслеживаем просмотр экрана
    return AnalyticsScreenWrapper(
      screenName: 'home',
      screenParameters: {'section': 'main'},
      child: Scaffold(
        appBar: AppBar(title: const Text('Аналитика - Пример')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Пример использования кнопки с отслеживанием
              AnalyticsButton(
                buttonName: 'create_password',
                buttonType: 'primary',
                onPressed: () => _createPassword(context, ref),
                child: const Text('Создать пароль'),
              ),

              const SizedBox(height: 16),

              // Пример поиска с отслеживанием
              AnalyticsSearchField(
                searchContext: 'password_list',
                onSearch: (query) => _performSearch(query, ref),
                decoration: const InputDecoration(
                  labelText: 'Поиск паролей',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Пример отслеживания производительности
              AnalyticsPerformanceWrapper(
                operationName: 'password_list_render',
                child: const PasswordListExample(),
              ),

              const SizedBox(height: 16),

              // Кнопки для тестирования различных событий
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () => _testAuthentication(ref),
                    child: const Text('Тест аутентификации'),
                  ),
                  ElevatedButton(
                    onPressed: () => _testSecurity(ref),
                    child: const Text('Тест безопасности'),
                  ),
                  ElevatedButton(
                    onPressed: () => _testError(ref),
                    child: const Text('Тест ошибки'),
                  ),
                  ElevatedButton(
                    onPressed: () => _showMetrics(context, ref),
                    child: const Text('Показать метрики'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createPassword(BuildContext context, WidgetRef ref) async {
    final passwordTracker = AnalyticsIntegration.createPasswordTracker();

    // Отслеживаем создание пароля
    await passwordTracker.trackPasswordCreated(
      category: 'social',
      passwordStrength: 'strong',
      isGenerated: true,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пароль создан и отслежен!')),
      );
    }
  }

  Future<void> _performSearch(String query, WidgetRef ref) async {
    final performanceTracker = AnalyticsIntegration.createPerformanceTracker();

    // Измеряем время поиска
    await performanceTracker.measureExecutionTime(
      operationName: 'password_search',
      operation: () async {
        // Имитируем поиск
        await Future.delayed(const Duration(milliseconds: 200));
        return [];
      },
      additionalData: {
        'query_length': query.length,
        'search_type': 'full_text',
      },
    );
  }

  Future<void> _testAuthentication(WidgetRef ref) async {
    final authTracker = AnalyticsIntegration.createAuthTracker();

    // Отслеживаем попытку входа
    await authTracker.trackLoginAttempt(authMethod: 'biometric');

    // Имитируем успешный вход
    await Future.delayed(const Duration(milliseconds: 500));
    await authTracker.trackLoginSuccess(
      authMethod: 'biometric',
      attemptCount: 1,
    );
  }

  Future<void> _testSecurity(WidgetRef ref) async {
    final service = ref.read(analyticsServiceProvider);

    // Отслеживаем событие безопасности
    await service.trackSecurity(
      securityEventType: SecurityEvents.weakPasswordDetected,
      details: {
        'password_score': 25,
        'weaknesses': ['too_short', 'no_symbols'],
      },
    );
  }

  Future<void> _testError(WidgetRef ref) async {
    final errorHandler = AnalyticsIntegration.errorHandler;

    // Отслеживаем пользовательскую ошибку
    errorHandler.handleCustomError(
      errorType: 'validation_error',
      errorMessage: 'Неверный формат пароля',
      context: {'screen': 'password_creation', 'field': 'password_input'},
    );
  }

  Future<void> _showMetrics(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;

    // Показываем диалог с метриками
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Метрики аналитики'),
        content: Consumer(
          builder: (context, ref, child) {
            final dateRange = AnalyticsUtils.last30Days;
            final metricsAsync = ref.watch(allMetricsProvider(dateRange));

            return metricsAsync.when(
              data: (metrics) => SingleChildScrollView(
                child: Text(
                  'Производительность: ${metrics['performance'] != null ? 'Доступно' : 'Нет данных'}\n'
                  'Безопасность: ${metrics['security'] != null ? 'Доступно' : 'Нет данных'}\n'
                  'Поведение: ${metrics['behavior'] != null ? 'Доступно' : 'Нет данных'}\n'
                  'Ошибки: ${metrics['errors'] != null ? 'Доступно' : 'Нет данных'}\n'
                  '\nГенерировано: ${metrics['generated_at']}',
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Ошибка загрузки: $error'),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}

/// Пример списка паролей для демонстрации отслеживания производительности
class PasswordListExample extends ConsumerWidget {
  const PasswordListExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Список паролей',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.password),
                    title: Text('Пароль ${index + 1}'),
                    subtitle: Text('example${index + 1}@email.com'),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copyPassword(index, ref),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyPassword(int index, WidgetRef ref) async {
    final passwordTracker = AnalyticsIntegration.createPasswordTracker();

    // Отслеживаем копирование пароля
    await passwordTracker.trackPasswordCopied(
      category: 'social',
      copyType: 'password',
    );
  }
}

/// Пример инициализации аналитики в main.dart
class AnalyticsInitializationExample {
  static Future<void> initializeAnalytics() async {
    // Инициализируем сервис аналитики
    final storage = InMemoryAnalyticsStorage();
    final analyticsService = AnalyticsService.instance;

    await analyticsService.initialize(
      storage: storage,
      enablePerformanceTracking: true,
      enableSecurityTracking: true,
      enableUserBehaviorTracking: true,
    );

    // Инициализируем интеграцию
    await AnalyticsIntegration.initialize(analyticsService);

    print('Аналитика инициализирована');
  }
}

/// Пример использования в основном приложении
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем аналитику
  await AnalyticsInitializationExample.initializeAnalytics();

  runApp(const AnalyticsExampleApp());
}

/// Пример экрана с детальной аналитикой
class AnalyticsDetailsScreen extends ConsumerWidget {
  const AnalyticsDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnalyticsScreenWrapper(
      screenName: 'analytics_details',
      child: Scaffold(
        appBar: AppBar(title: const Text('Детали аналитики')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetricsSection(ref),
              const SizedBox(height: 24),
              _buildEventsSection(ref),
              const SizedBox(height: 24),
              _buildExportSection(ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsSection(WidgetRef ref) {
    final dateRange = AnalyticsUtils.thisWeek;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Метрики за эту неделю',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Метрики производительности
            Consumer(
              builder: (context, ref, child) {
                final metricsAsync = ref.watch(
                  performanceMetricsProvider(dateRange),
                );
                return metricsAsync.when(
                  data: (metrics) => _buildPerformanceMetrics(metrics),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, _) => Text('Ошибка: $error'),
                );
              },
            ),

            const SizedBox(height: 16),

            // Метрики безопасности
            Consumer(
              builder: (context, ref, child) {
                final metricsAsync = ref.watch(
                  securityMetricsProvider(dateRange),
                );
                return metricsAsync.when(
                  data: (metrics) => _buildSecurityMetrics(metrics),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, _) => Text('Ошибка: $error'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics(PerformanceMetrics? metrics) {
    if (metrics == null) {
      return const Text('Нет данных о производительности');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Производительность:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text('Время запуска: ${metrics.appStartupTime}мс'),
        Text('Время загрузки экрана: ${metrics.screenLoadTime}мс'),
        Text('Время БД запроса: ${metrics.databaseQueryTime}мс'),
        Text(
          'Использование памяти: ${(metrics.memoryUsage / (1024 * 1024)).toStringAsFixed(1)}МБ',
        ),
      ],
    );
  }

  Widget _buildSecurityMetrics(SecurityMetrics? metrics) {
    if (metrics == null) {
      return const Text('Нет данных о безопасности');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Безопасность:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text('Общий балл: ${metrics.securityScore}/100'),
        Text('Слабые пароли: ${metrics.weakPasswordCount}'),
        Text('Попытки входа: ${metrics.loginAttempts}'),
        Text('Неудачные попытки: ${metrics.failedLoginAttempts}'),
      ],
    );
  }

  Widget _buildEventsSection(WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Последние события',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final eventsAsync = ref.watch(recentEventsProvider(20));
                return eventsAsync.when(
                  data: (events) => Column(
                    children: events
                        .take(5)
                        .map(
                          (event) => ListTile(
                            dense: true,
                            title: Text(event.eventName),
                            subtitle: Text(event.eventType),
                            trailing: Text(
                              '${event.timestamp.hour}:${event.timestamp.minute.toString().padLeft(2, '0')}',
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, _) => Text('Ошибка: $error'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportSection(WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Экспорт данных',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _exportData(ref),
              child: const Text('Экспортировать данные аналитики'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData(WidgetRef ref) async {
    final dateRange = AnalyticsUtils.last30Days;
    final service = ref.read(analyticsServiceProvider);

    try {
      final exportData = await service.exportAnalyticsData(
        startDate: dateRange.startDate,
        endDate: dateRange.endDate,
      );
      print('Данные экспортированы: ${exportData.keys}');
      // Здесь можно сохранить данные в файл или отправить
    } catch (e) {
      print('Ошибка экспорта: $e');
    }
  }
}
