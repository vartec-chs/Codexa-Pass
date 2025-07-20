import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../error_system.dart';

/// Простая демо-страница для тестирования истории ошибок
class SimpleErrorTestPage extends ConsumerWidget {
  const SimpleErrorTestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorHistoryAsync = ref.watch(errorHistoryStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Тест истории ошибок'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Кнопки для генерации ошибок
            ElevatedButton(
              onPressed: () async {
                final error = BaseAppError(
                  code: 'TEST_ERROR_${DateTime.now().millisecondsSinceEpoch}',
                  message: 'Тестовая ошибка ${DateTime.now()}',
                  severity: ErrorSeverity.error,
                  timestamp: DateTime.now(),
                );

                await ref.read(errorControllerProvider).handleError(error);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Добавлена ошибка: ${error.code}')),
                );
              },
              child: const Text('Добавить тестовую ошибку'),
            ),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: () async {
                final error = BaseAppError(
                  code:
                      'SNACKBAR_ERROR_${DateTime.now().millisecondsSinceEpoch}',
                  message: 'Ошибка со SnackBar и кнопкой "Детали"',
                  severity: ErrorSeverity.warning,
                  timestamp: DateTime.now(),
                  metadata: {
                    'feature': 'SnackBar с деталями',
                    'description':
                        'Демонстрация глобального сервиса деталей ошибок',
                    'userId': 'demo_user_123',
                  },
                );

                // Сохраняем ошибку в истории
                await ref.read(errorControllerProvider).handleError(error);

                // Показываем SnackBar с кнопкой "Детали"
                ref
                    .read(errorControllerProvider)
                    .showErrorSnackBarWithDetails(
                      context,
                      error,
                      'Произошла ошибка с возможностью просмотра деталей',
                    );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Показать ошибку через SnackBar с деталями'),
            ),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: () async {
                final error = BaseAppError(
                  code:
                      'COMPLEX_ERROR_${DateTime.now().millisecondsSinceEpoch}',
                  message: 'Сложная ошибка с множеством метаданных',
                  severity: ErrorSeverity.critical,
                  timestamp: DateTime.now(),
                  module: 'TestModule',
                  stackTrace: StackTrace.current,
                  metadata: {
                    'userId': 'user_12345',
                    'action': 'complex_operation',
                    'attempt': 3,
                    'networkStatus': 'disconnected',
                    'memoryUsage': '85%',
                    'batteryLevel': '15%',
                  },
                );

                await ref.read(errorControllerProvider).handleError(error);

                ref
                    .read(errorControllerProvider)
                    .showErrorSnackBarWithDetails(
                      context,
                      error,
                      'Критическая ошибка с подробной информацией',
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              child: const Text('Показать сложную ошибку'),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                ref.read(errorControllerProvider).clearErrorHistory();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('История очищена')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Очистить историю'),
            ),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SecondTestPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Перейти на другую страницу'),
            ),

            const SizedBox(height: 24),

            // Показ истории ошибок
            Text(
              'История ошибок:',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 16),

            Expanded(
              child: errorHistoryAsync.when(
                data: (errorHistory) {
                  if (errorHistory.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'История пуста',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Нажмите кнопку выше, чтобы добавить ошибку',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: errorHistory.length,
                    itemBuilder: (context, index) {
                      final error =
                          errorHistory[errorHistory.length - 1 - index];
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.error,
                            color: _getSeverityColor(error.severity),
                          ),
                          title: Text(error.code),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(error.message),
                              const SizedBox(height: 4),
                              Text(
                                error.timestamp.toString(),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  ref
                                      .read(errorControllerProvider)
                                      .showErrorDetails(context, error);
                                },
                                icon: const Icon(Icons.info_outline),
                                tooltip: 'Детали ошибки',
                              ),
                              IconButton(
                                onPressed: () {
                                  ref
                                      .read(errorControllerProvider)
                                      .showErrorSnackBarWithDetails(
                                        context,
                                        error,
                                        'Ошибка из истории: ${error.code}',
                                      );
                                },
                                icon: const Icon(Icons.announcement),
                                tooltip: 'SnackBar с деталями',
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Ошибка: $error'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Colors.blue;
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.error:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red.shade800;
      case ErrorSeverity.fatal:
        return Colors.red.shade900;
    }
  }
}

/// Вторая тестовая страница для демонстрации работы деталей ошибок после навигации
class SecondTestPage extends ConsumerWidget {
  const SecondTestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorHistoryAsync = ref.watch(errorHistoryStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Вторая страница'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Демонстрация доступа к деталям ошибок с другой страницы',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            const Text(
              'Здесь вы можете просматривать детали ошибок, которые произошли на предыдущей странице. '
              'Это демонстрирует глобальную доступность системы обработки ошибок.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () async {
                final error = BaseAppError(
                  code:
                      'SECOND_PAGE_ERROR_${DateTime.now().millisecondsSinceEpoch}',
                  message: 'Ошибка, созданная на второй странице',
                  severity: ErrorSeverity.info,
                  timestamp: DateTime.now(),
                  module: 'SecondPage',
                );

                await ref.read(errorControllerProvider).handleError(error);

                ref
                    .read(errorControllerProvider)
                    .showErrorSnackBarWithDetails(
                      context,
                      error,
                      'Новая ошибка создана на второй странице',
                    );
              },
              child: const Text('Создать ошибку на этой странице'),
            ),

            const SizedBox(height: 24),

            Text(
              'История ошибок (доступна глобально):',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 16),

            Expanded(
              child: errorHistoryAsync.when(
                data: (errorHistory) {
                  if (errorHistory.isEmpty) {
                    return const Center(
                      child: Text(
                        'История ошибок пуста',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: errorHistory.length,
                    itemBuilder: (context, index) {
                      final error =
                          errorHistory[errorHistory.length - 1 - index];
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.error,
                            color: _getSeverityColor(error.severity),
                          ),
                          title: Text(error.code),
                          subtitle: Text(error.message),
                          trailing: ElevatedButton.icon(
                            onPressed: () {
                              ref
                                  .read(errorControllerProvider)
                                  .showErrorDetails(context, error);
                            },
                            icon: const Icon(Icons.info_outline, size: 16),
                            label: const Text('Детали'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Ошибка: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Colors.blue;
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.error:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red.shade800;
      case ErrorSeverity.fatal:
        return Colors.red.shade900;
    }
  }
}
