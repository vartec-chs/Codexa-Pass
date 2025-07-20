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
