import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/error_controller.dart';
import '../models/app_error.dart';
import '../models/error_severity.dart';

/// Страница с историей ошибок для просмотра деталей
class ErrorHistoryPage extends ConsumerWidget {
  const ErrorHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorController = ref.watch(errorControllerProvider);
    final errorHistory = errorController.errorHistory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('История ошибок'),
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: errorHistory.isNotEmpty
                ? () => _showClearConfirmation(context, errorController)
                : null,
          ),
        ],
      ),
      body: errorHistory.isEmpty
          ? _buildEmptyState(context)
          : _buildErrorList(context, errorHistory, errorController),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'История пуста',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Ошибки будут отображаться здесь по мере их возникновения',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorList(
    BuildContext context,
    List<AppError> errors,
    ErrorController controller,
  ) {
    // Группируем ошибки по дате
    final groupedErrors = <String, List<AppError>>{};
    for (final error in errors.reversed) {
      final dateKey = _formatDate(error.timestamp);
      groupedErrors.putIfAbsent(dateKey, () => []).add(error);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedErrors.length,
      itemBuilder: (context, index) {
        final dateKey = groupedErrors.keys.elementAt(index);
        final dayErrors = groupedErrors[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
              child: Text(
                dateKey,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            ...dayErrors.map(
              (error) => _buildErrorCard(context, error, controller),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildErrorCard(
    BuildContext context,
    AppError error,
    ErrorController controller,
  ) {
    final severityColor = _getSeverityColor(error.severity);
    final severityIcon = _getSeverityIcon(error.severity);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showErrorDetails(context, error),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(severityIcon, color: severityColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      error.code,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      error.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _formatTime(error.timestamp),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                        if (error.module != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              error.module!,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(fontSize: 10),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'details':
                      _showErrorDetails(context, error);
                      break;
                    case 'copy':
                      _copyErrorDetails(context, error);
                      break;
                    case 'remove':
                      controller.removeErrorFromHistory(error.errorId);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'details',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline),
                        SizedBox(width: 8),
                        Text('Детали'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'copy',
                    child: Row(
                      children: [
                        Icon(Icons.copy),
                        SizedBox(width: 8),
                        Text('Копировать'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline),
                        SizedBox(width: 8),
                        Text('Удалить'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDetails(BuildContext context, AppError error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getSeverityIcon(error.severity),
              color: _getSeverityColor(error.severity),
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Детали ошибки',
                style: TextStyle(
                  color: _getSeverityColor(error.severity),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Код', error.code),
              _buildDetailRow('Сообщение', error.message),
              _buildDetailRow('Уровень', error.severity.name.toUpperCase()),
              _buildDetailRow(
                'Время',
                error.timestamp.toString().split('.')[0],
              ),
              if (error.module != null)
                _buildDetailRow('Модуль', error.module!),
              if (error.metadata?.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                const Text(
                  'Метаданные:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...error.metadata!.entries.map(
                  (entry) => _buildDetailRow(entry.key, entry.value.toString()),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _copyErrorDetails(context, error);
            },
            icon: const Icon(Icons.copy),
            label: const Text('Копировать'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  void _copyErrorDetails(BuildContext context, AppError error) {
    // В реальном приложении здесь был бы Clipboard.setData с деталями ошибки
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Детали ошибки скопированы в буфер обмена'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showClearConfirmation(
    BuildContext context,
    ErrorController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить историю?'),
        content: const Text(
          'Это действие удалит всю историю ошибок. Отменить его будет невозможно.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.clearErrorHistory();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('История ошибок очищена')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final errorDate = DateTime(date.year, date.month, date.day);

    if (errorDate == today) {
      return 'Сегодня';
    } else if (errorDate == yesterday) {
      return 'Вчера';
    } else {
      return '${date.day}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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

  IconData _getSeverityIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Icons.info;
      case ErrorSeverity.warning:
        return Icons.warning;
      case ErrorSeverity.error:
        return Icons.error;
      case ErrorSeverity.critical:
        return Icons.dangerous;
      case ErrorSeverity.fatal:
        return Icons.block;
    }
  }
}
