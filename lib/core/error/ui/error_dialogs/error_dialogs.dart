import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/app_error.dart';

/// Диалог для критических ошибок
class CriticalErrorDialog extends StatelessWidget {
  const CriticalErrorDialog({
    Key? key,
    required this.error,
    this.onRetry,
    this.onRestart,
    this.onContact,
  }) : super(key: key);

  final AppError error;
  final VoidCallback? onRetry;
  final VoidCallback? onRestart;
  final VoidCallback? onContact;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(Icons.dangerous, color: Colors.red.shade700, size: 48),
      title: const Text(
        'Критическая ошибка',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(error.userFriendlyMessage, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          const Text(
            'Приложение не может продолжить работу в нормальном режиме.',
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildDetailedInfo(context),
        ],
      ),
      actions: [
        if (onContact != null)
          TextButton.icon(
            onPressed: onContact,
            icon: const Icon(Icons.support_agent),
            label: const Text('Связаться с поддержкой'),
          ),
        if (onRetry != null && error.canRetryOperation)
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Попробовать снова'),
          ),
        if (onRestart != null)
          ElevatedButton.icon(
            onPressed: onRestart,
            icon: const Icon(Icons.restart_alt),
            label: const Text('Перезапустить'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }

  Widget _buildDetailedInfo(BuildContext context) {
    return ExpansionTile(
      title: const Text('Техническая информация'),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Код ошибки: ${error.code}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'ID ошибки: ${error.errorId}',
                style: const TextStyle(fontFamily: 'monospace'),
              ),
              const SizedBox(height: 8),
              Text('Время: ${error.timestamp.toLocal()}'),
              if (error.module != null) ...[
                const SizedBox(height: 8),
                Text('Модуль: ${error.module}'),
              ],
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _copyErrorInfo(),
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Копировать информацию'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _copyErrorInfo() {
    Clipboard.setData(ClipboardData(text: error.detailedMessage));
  }
}

/// Диалог подтверждения отправки отчета об ошибке
class ErrorReportDialog extends StatefulWidget {
  const ErrorReportDialog({
    Key? key,
    required this.error,
    this.onSend,
    this.onCancel,
  }) : super(key: key);

  final AppError error;
  final Function(String? userComment)? onSend;
  final VoidCallback? onCancel;

  @override
  State<ErrorReportDialog> createState() => _ErrorReportDialogState();
}

class _ErrorReportDialogState extends State<ErrorReportDialog> {
  final _commentController = TextEditingController();
  bool _includeSystemInfo = true;
  bool _includeUserData = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.bug_report, color: Colors.orange),
          SizedBox(width: 8),
          Text('Отправить отчет об ошибке'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Отправка отчета поможет нам исправить эту ошибку в будущих версиях.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ваш комментарий (необязательно):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Опишите, что вы делали, когда произошла ошибка...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Включить в отчет:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            CheckboxListTile(
              title: const Text('Системная информация'),
              subtitle: const Text('Версия ОС, устройство, версия приложения'),
              value: _includeSystemInfo,
              onChanged: (value) {
                setState(() {
                  _includeSystemInfo = value ?? true;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Пользовательские данные'),
              subtitle: const Text('Настройки и конфигурация (без паролей)'),
              value: _includeUserData,
              onChanged: (value) {
                setState(() {
                  _includeUserData = value ?? false;
                });
              },
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.privacy_tip, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Мы серьезно относимся к вашей конфиденциальности. Пароли и другие конфиденциальные данные никогда не включаются в отчеты.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: widget.onCancel, child: const Text('Отмена')),
        ElevatedButton.icon(
          onPressed: () {
            widget.onSend?.call(
              _commentController.text.trim().isEmpty
                  ? null
                  : _commentController.text.trim(),
            );
          },
          icon: const Icon(Icons.send),
          label: const Text('Отправить'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}

/// Диалог выбора действия для восстановления
class ErrorRecoveryDialog extends StatelessWidget {
  const ErrorRecoveryDialog({
    Key? key,
    required this.error,
    this.onRetry,
    this.onIgnore,
    this.onRestart,
  }) : super(key: key);

  final AppError error;
  final VoidCallback? onRetry;
  final VoidCallback? onIgnore;
  final VoidCallback? onRestart;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.healing, color: Colors.orange),
          SizedBox(width: 8),
          Text('Восстановление после ошибки'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(error.userFriendlyMessage),
          const SizedBox(height: 16),
          const Text(
            'Выберите действие:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (onRetry != null && error.canRetryOperation)
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.blue),
              title: const Text('Повторить операцию'),
              subtitle: const Text('Попробовать выполнить операцию снова'),
              onTap: () {
                Navigator.of(context).pop();
                onRetry?.call();
              },
            ),
          if (onIgnore != null)
            ListTile(
              leading: const Icon(Icons.skip_next, color: Colors.orange),
              title: const Text('Пропустить и продолжить'),
              subtitle: const Text('Игнорировать ошибку и продолжить работу'),
              onTap: () {
                Navigator.of(context).pop();
                onIgnore?.call();
              },
            ),
          if (onRestart != null)
            ListTile(
              leading: const Icon(Icons.restart_alt, color: Colors.red),
              title: const Text('Перезапустить приложение'),
              subtitle: const Text('Полностью перезапустить приложение'),
              onTap: () {
                Navigator.of(context).pop();
                onRestart?.call();
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
      ],
    );
  }
}

/// Показать диалог критической ошибки
Future<void> showCriticalErrorDialog(
  BuildContext context,
  AppError error, {
  VoidCallback? onRetry,
  VoidCallback? onRestart,
  VoidCallback? onContact,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => CriticalErrorDialog(
      error: error,
      onRetry: onRetry,
      onRestart: onRestart,
      onContact: onContact,
    ),
  );
}

/// Показать диалог отправки отчета
Future<void> showErrorReportDialog(
  BuildContext context,
  AppError error, {
  Function(String? userComment)? onSend,
  VoidCallback? onCancel,
}) {
  return showDialog(
    context: context,
    builder: (context) => ErrorReportDialog(
      error: error,
      onSend: onSend,
      onCancel: onCancel ?? () => Navigator.of(context).pop(),
    ),
  );
}

/// Показать диалог восстановления
Future<void> showErrorRecoveryDialog(
  BuildContext context,
  AppError error, {
  VoidCallback? onRetry,
  VoidCallback? onIgnore,
  VoidCallback? onRestart,
}) {
  return showDialog(
    context: context,
    builder: (context) => ErrorRecoveryDialog(
      error: error,
      onRetry: onRetry,
      onIgnore: onIgnore,
      onRestart: onRestart,
    ),
  );
}
