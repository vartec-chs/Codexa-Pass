import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_error.dart';
import 'error_localizations.dart';

/// Диалог для отображения критических ошибок
class CriticalErrorDialog extends StatelessWidget {
  final AppError error;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback onClose;

  const CriticalErrorDialog({
    super.key,
    required this.error,
    required this.message,
    this.onRetry,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const localizations = ErrorLocalizations();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с иконкой
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Критическая ошибка',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        localizations.getErrorTypeTitle(error),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Сообщение об ошибке
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.error.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message, style: theme.textTheme.bodyMedium),
                  if (error.details?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Подробности: ${error.details}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Рекомендации
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      localizations.getErrorResolution(error),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Кнопки действий
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Кнопка копирования деталей
                TextButton.icon(
                  onPressed: () => _copyErrorDetails(context),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Копировать'),
                ),

                const SizedBox(width: 8),

                // Кнопка повтора (если доступна)
                if (onRetry != null) ...[
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Повторить'),
                  ),
                  const SizedBox(width: 8),
                ],

                // Кнопка закрытия
                FilledButton(onPressed: onClose, child: const Text('Закрыть')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copyErrorDetails(BuildContext context) {
    const localizations = ErrorLocalizations();
    final details =
        '''
Тип ошибки: ${localizations.getErrorTypeTitle(error)}
Сообщение: $message
${error.details != null ? 'Подробности: ${error.details}' : ''}
Время: ${DateTime.now().toIso8601String()}
''';

    Clipboard.setData(ClipboardData(text: details));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Детали ошибки скопированы в буфер обмена'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Диалог для отображения подробностей ошибки
class ErrorDetailsDialog extends StatelessWidget {
  final AppError error;

  const ErrorDetailsDialog({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const localizations = ErrorLocalizations();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Подробности ошибки',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Содержимое
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection(
                      'Тип ошибки',
                      localizations.getErrorTypeTitle(error),
                      theme,
                    ),

                    _buildDetailSection(
                      'Сообщение',
                      localizations.getLocalizedMessage(error),
                      theme,
                    ),

                    if (error.details?.isNotEmpty == true)
                      _buildDetailSection('Подробности', error.details!, theme),

                    _buildDetailSection(
                      'Критичность',
                      error.isCritical ? 'Критическая' : 'Некритическая',
                      theme,
                    ),

                    _buildDetailSection(
                      'Время',
                      DateTime.now().toString(),
                      theme,
                    ),

                    _buildDetailSection(
                      'Рекомендации',
                      localizations.getErrorResolution(error),
                      theme,
                    ),

                    // Техническая информация (если есть)
                    if (error is UnknownError) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      Text(
                        'Техническая информация',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      if ((error as UnknownError).originalError != null)
                        _buildDetailSection(
                          'Исходная ошибка',
                          (error as UnknownError).originalError.toString(),
                          theme,
                        ),

                      if ((error as UnknownError).stackTrace != null)
                        _buildDetailSection(
                          'Стек вызовов',
                          (error as UnknownError).stackTrace.toString(),
                          theme,
                        ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Кнопки действий
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _copyAllDetails(context),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Копировать все'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Закрыть'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(content, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  void _copyAllDetails(BuildContext context) {
    const localizations = ErrorLocalizations();
    final buffer = StringBuffer();

    buffer.writeln('=== ДЕТАЛИ ОШИБКИ ===');
    buffer.writeln('Тип: ${localizations.getErrorTypeTitle(error)}');
    buffer.writeln('Сообщение: ${localizations.getLocalizedMessage(error)}');

    if (error.details?.isNotEmpty == true) {
      buffer.writeln('Подробности: ${error.details}');
    }

    buffer.writeln(
      'Критичность: ${error.isCritical ? 'Критическая' : 'Некритическая'}',
    );
    buffer.writeln('Время: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Рекомендации: ${localizations.getErrorResolution(error)}');

    if (error is UnknownError) {
      final unknownError = error as UnknownError;
      if (unknownError.originalError != null) {
        buffer.writeln('\n=== ТЕХНИЧЕСКАЯ ИНФОРМАЦИЯ ===');
        buffer.writeln('Исходная ошибка: ${unknownError.originalError}');
      }
      if (unknownError.stackTrace != null) {
        buffer.writeln('Стек вызовов:\n${unknownError.stackTrace}');
      }
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Все детали ошибки скопированы в буфер обмена'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Содержимое для SnackBar с ошибкой
class ErrorSnackBarContent extends StatelessWidget {
  final AppError error;
  final String message;

  const ErrorSnackBarContent({
    super.key,
    required this.error,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    const localizations = ErrorLocalizations();

    return Row(
      children: [
        Icon(_getErrorIcon(error), color: Colors.white, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.getErrorTypeTitle(error),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getErrorIcon(AppError error) {
    return switch (error.runtimeType.toString()) {
      'AuthenticationError' => Icons.lock_outline,
      'EncryptionError' => Icons.security,
      'DatabaseError' => Icons.storage,
      'NetworkError' => Icons.wifi_off,
      'ValidationError' => Icons.warning_outlined,
      'StorageError' => Icons.folder_off,
      'SecurityError' => Icons.shield_outlined,
      'SystemError' => Icons.computer,
      _ => Icons.error_outline,
    };
  }
}
