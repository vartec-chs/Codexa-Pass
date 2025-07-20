import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_error.dart';
import '../models/error_severity.dart';

/// Глобальный сервис для показа деталей ошибок
class GlobalErrorDetailsService {
  static final GlobalErrorDetailsService _instance = GlobalErrorDetailsService._internal();
  factory GlobalErrorDetailsService() => _instance;
  GlobalErrorDetailsService._internal();

  static GlobalErrorDetailsService get instance => _instance;

  /// Показать детали ошибки в диалоге
  static void showErrorDetails(BuildContext context, AppError error) {
    showDialog(
      context: context,
      builder: (context) => ErrorDetailsDialog(error: error),
    );
  }

  /// Показать SnackBar с кнопкой "Детали"
  static void showErrorSnackBarWithDetails(
    BuildContext context,
    AppError error,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getSeverityIcon(error.severity),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: _getSeverityColor(error.severity),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Детали',
          textColor: Colors.white,
          onPressed: () {
            showErrorDetails(context, error);
          },
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static Color _getSeverityColor(ErrorSeverity severity) {
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

  static IconData _getSeverityIcon(ErrorSeverity severity) {
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

/// Диалог с деталями ошибки
class ErrorDetailsDialog extends StatelessWidget {
  const ErrorDetailsDialog({
    super.key,
    required this.error,
  });

  final AppError error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Код', error.code),
              _buildDetailRow('Сообщение', error.message),
              _buildDetailRow('Уровень', error.severity.name.toUpperCase()),
              _buildDetailRow(
                'Время',
                _formatDateTime(error.timestamp),
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
              if (error.stackTrace != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Stack Trace:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SelectableText(
                    error.stackTrace.toString(),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            _copyErrorDetails();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Детали ошибки скопированы в буфер обмена'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          icon: const Icon(Icons.copy),
          label: const Text('Копировать'),
        ),
      ],
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  void _copyErrorDetails() {
    final details = StringBuffer();
    details.writeln('=== ДЕТАЛИ ОШИБКИ ===');
    details.writeln('Код: ${error.code}');
    details.writeln('Сообщение: ${error.message}');
    details.writeln('Уровень: ${error.severity.name.toUpperCase()}');
    details.writeln('Время: ${_formatDateTime(error.timestamp)}');
    
    if (error.module != null) {
      details.writeln('Модуль: ${error.module}');
    }
    
    if (error.metadata?.isNotEmpty == true) {
      details.writeln('\nМетаданные:');
      error.metadata!.forEach((key, value) {
        details.writeln('  $key: $value');
      });
    }
    
    if (error.stackTrace != null) {
      details.writeln('\nStack Trace:');
      details.writeln(error.stackTrace.toString());
    }

    Clipboard.setData(ClipboardData(text: details.toString()));
  }

  Color _getSeverityColor(ErrorSeverity severity) {
    return GlobalErrorDetailsService._getSeverityColor(severity);
  }

  IconData _getSeverityIcon(ErrorSeverity severity) {
    return GlobalErrorDetailsService._getSeverityIcon(severity);
  }
}
