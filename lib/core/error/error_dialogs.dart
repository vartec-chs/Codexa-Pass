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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = MediaQuery.of(context).size.height * 0.8;
          final maxWidth = MediaQuery.of(context).size.width < 600
              ? MediaQuery.of(context).size.width * 0.95
              : 450.0;
          final isSmallScreen = MediaQuery.of(context).size.width < 400;

          return Container(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
              minWidth: 280,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.errorContainer.withOpacity(0.1),
                  theme.colorScheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.error.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.error.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок с иконкой
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.error.withOpacity(0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                        size: 26,
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            localizations.getErrorTypeTitle(error),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Содержимое с прокруткой
                Flexible(
                  child: Scrollbar(
                    thumbVisibility: true,
                    radius: const Radius.circular(8),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(right: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Сообщение об ошибке
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.error.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
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
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(
                                0.08,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.2,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.lightbulb_outline,
                                    color: theme.colorScheme.primary,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Рекомендации',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.primary,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        localizations.getErrorResolution(error),
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Кнопки действий - адаптивные
                if (isSmallScreen)
                  // Вертикальное расположение для маленьких экранов
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Кнопка повтора (если доступна)
                      if (onRetry != null) ...[
                        FilledButton.icon(
                          onPressed: onRetry,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Повторить'),
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      Row(
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              onPressed: () => _copyErrorDetails(context),
                              icon: const Icon(Icons.copy, size: 16),
                              label: const Text('Копировать'),
                              style: TextButton.styleFrom(
                                foregroundColor: theme.colorScheme.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              onPressed: onClose,
                              child: const Text('Закрыть'),
                              style: FilledButton.styleFrom(
                                backgroundColor: theme.colorScheme.error,
                                foregroundColor: theme.colorScheme.onError,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  // Горизонтальное расположение для больших экранов
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Кнопка копирования деталей
                      TextButton.icon(
                        onPressed: () => _copyErrorDetails(context),
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Копировать'),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Кнопка повтора (если доступна)
                      if (onRetry != null) ...[
                        FilledButton.icon(
                          onPressed: onRetry,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Повторить'),
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Кнопка закрытия
                      FilledButton(
                        onPressed: onClose,
                        child: const Text('Закрыть'),
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = MediaQuery.of(context).size.height * 0.75;
          final maxWidth = MediaQuery.of(context).size.width < 600
              ? MediaQuery.of(context).size.width * 0.98
              : 500.0;
          return Container(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
              minWidth: 280,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceVariant.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Подробности ошибки',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: 'Закрыть',
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Содержимое с прокруткой
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    radius: const Radius.circular(8),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(right: 4),
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
                            _buildDetailSection(
                              'Подробности',
                              error.details!,
                              theme,
                            ),

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
                                color: theme.colorScheme.error,
                              ),
                            ),

                            const SizedBox(height: 8),

                            if ((error as UnknownError).originalError != null)
                              _buildDetailSection(
                                'Исходная ошибка',
                                (error as UnknownError).originalError
                                    .toString(),
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
                ),

                const SizedBox(height: 12),

                // Кнопки действий всегда видимы
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _copyAllDetails(context),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Копировать все'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        textStyle: theme.textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Закрыть'),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        textStyle: theme.textTheme.labelLarge,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
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
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getErrorColor(error).withOpacity(0.9),
            _getErrorColor(error),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _getErrorColor(error).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getErrorIcon(error),
              color: Colors.white,
              size: isSmallScreen ? 18 : 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.getErrorTypeTitle(error),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 11 : 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: isSmallScreen ? 13 : 14,
                  ),
                  maxLines: isSmallScreen ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Индикатор типа ошибки
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
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

  Color _getErrorColor(AppError error) {
    return switch (error.runtimeType.toString()) {
      'AuthenticationError' => const Color(0xFF8B5CF6), // Purple
      'EncryptionError' => const Color(0xFFEF4444), // Red
      'DatabaseError' => const Color(0xFF3B82F6), // Blue
      'NetworkError' => const Color(0xFF6B7280), // Gray
      'ValidationError' => const Color(0xFFF59E0B), // Amber
      'StorageError' => const Color(0xFF10B981), // Emerald
      'SecurityError' => const Color(0xFFDC2626), // Red-600
      'SystemError' => const Color(0xFF6366F1), // Indigo
      _ => const Color(0xFF9CA3AF), // Gray-400
    };
  }
}
