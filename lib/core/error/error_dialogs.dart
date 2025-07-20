import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'enhanced_app_error.dart';
import 'error_localizations_universal.dart';

/// Диалог для отображения критических ошибок
class CriticalErrorDialog extends ConsumerStatefulWidget {
  final BaseAppError error;
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
  ConsumerState<CriticalErrorDialog> createState() =>
      _CriticalErrorDialogState();
}

class _CriticalErrorDialogState extends ConsumerState<CriticalErrorDialog> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = ref.read(universalErrorLocalizationsProvider);

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
                            localizations.getErrorTypeTitle(widget.error),
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
                    controller: _scrollController,
                    thumbVisibility: true,
                    radius: const Radius.circular(8),
                    child: SingleChildScrollView(
                      controller: _scrollController,
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
                                  widget.message,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (widget.error.message.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Подробности: ${widget.error.message}',
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
                                        localizations.getErrorResolution(
                                          widget.error,
                                        ),
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
                      if (widget.onRetry != null) ...[
                        FilledButton.icon(
                          onPressed: widget.onRetry,
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
                              onPressed: widget.onClose,
                              style: FilledButton.styleFrom(
                                backgroundColor: theme.colorScheme.error,
                                foregroundColor: theme.colorScheme.onError,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Закрыть'),
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
                      if (widget.onRetry != null) ...[
                        FilledButton.icon(
                          onPressed: widget.onRetry,
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
                        onPressed: widget.onClose,
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Закрыть'),
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
    final localizations = ref.read(universalErrorLocalizationsProvider);
    final details =
        '''
Тип ошибки: ${localizations.getErrorTypeTitle(widget.error)}
Сообщение: ${widget.message}
${widget.error.message.isNotEmpty ? 'Подробности: ${widget.error.message}' : ''}
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
class ErrorDetailsDialog extends ConsumerStatefulWidget {
  final AppError error;

  const ErrorDetailsDialog({super.key, required this.error});

  @override
  ConsumerState<ErrorDetailsDialog> createState() => _ErrorDetailsDialogState();
}

class _ErrorDetailsDialogState extends ConsumerState<ErrorDetailsDialog> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = ref.read(universalErrorLocalizationsProvider);

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
                  theme.colorScheme.surfaceContainerHighest.withOpacity(0.7),
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
                    controller: _scrollController,
                    thumbVisibility: true,
                    radius: const Radius.circular(8),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(right: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailSection(
                            'Тип ошибки',
                            localizations.getErrorTypeTitle(widget.error),
                            theme,
                          ),

                          _buildDetailSection(
                            'Сообщение',
                            localizations.getLocalizedMessage(widget.error),
                            theme,
                          ),

                          if (widget.error.message.isNotEmpty)
                            _buildDetailSection(
                              'Подробности',
                              widget.error.message,
                              theme,
                            ),

                          _buildDetailSection(
                            'Критичность',
                            widget.error.isCritical
                                ? 'Критическая'
                                : 'Некритическая',
                            theme,
                          ),

                          _buildDetailSection(
                            'Время',
                            DateTime.now().toString(),
                            theme,
                          ),

                          _buildDetailSection(
                            'Рекомендации',
                            localizations.getErrorResolution(widget.error),
                            theme,
                          ),

                          // Техническая информация (если есть)
                          if (widget.error is UnknownAppError) ...[
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

                            _buildDetailSection(
                              'Тип ошибки',
                              'UnknownAppError',
                              theme,
                            ),

                            _buildDetailSection(
                              'Детали',
                              widget.error.message,
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
                      child: const Text('Закрыть'),
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
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(content, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  void _copyAllDetails(BuildContext context) {
    final localizations = ref.read(universalErrorLocalizationsProvider);
    final buffer = StringBuffer();

    buffer.writeln('=== ДЕТАЛИ ОШИБКИ ===');
    buffer.writeln('Тип: ${localizations.getErrorTypeTitle(widget.error)}');
    buffer.writeln(
      'Сообщение: ${localizations.getLocalizedMessage(widget.error)}',
    );

    buffer.writeln('Подробности: ${widget.error.message}');

    buffer.writeln(
      'Критичность: ${widget.error.isCritical ? 'Критическая' : 'Некритическая'}',
    );
    buffer.writeln('Время: ${DateTime.now().toIso8601String()}');
    buffer.writeln(
      'Рекомендации: ${localizations.getErrorResolution(widget.error)}',
    );

    if (widget.error is UnknownAppError) {
      buffer.writeln('\n=== ТЕХНИЧЕСКАЯ ИНФОРМАЦИЯ ===');
      buffer.writeln('Тип ошибки: UnknownAppError');
      buffer.writeln('Дополнительная информация: ${widget.error.message}');
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
class ErrorSnackBarContent extends ConsumerWidget {
  final BaseAppError error;
  final String message;
  final bool showTapHint;

  const ErrorSnackBarContent({
    super.key,
    required this.error,
    required this.message,
    this.showTapHint = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ref.read(universalErrorLocalizationsProvider);
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
          // Дополнительная тень для нажимаемых элементов
          if (showTapHint && isSmallScreen)
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
        ],
        // Добавляем тонкую белую границу для нажимаемых элементов
        border: showTapHint && isSmallScreen
            ? Border.all(color: Colors.white.withOpacity(0.3), width: 0.5)
            : null,
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
                // Показываем подсказку о нажатии на маленьких экранах
                if (showTapHint && isSmallScreen) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.touch_app,
                        color: Colors.white.withOpacity(0.7),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Нажмите для подробностей',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
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

  IconData _getErrorIcon(BaseAppError error) {
    return switch (error.runtimeType.toString()) {
      'AuthenticationError' => Icons.lock_outline,
      'EncryptionError' => Icons.security,
      'DatabaseError' => Icons.storage,
      'NetworkError' => Icons.wifi_off,
      'ValidationError' => Icons.warning_outlined,
      'StorageError' => Icons.folder_off,
      'SecurityError' => Icons.shield_outlined,
      'SystemError' => Icons.computer,
      'UIError' => Icons.smartphone,
      'BusinessError' => Icons.business,
      'UnknownAppError' => Icons.help_outline,
      _ => Icons.error_outline,
    };
  }

  Color _getErrorColor(BaseAppError error) {
    return switch (error.runtimeType.toString()) {
      'AuthenticationError' => const Color(0xFF8B5CF6), // Purple
      'EncryptionError' => const Color(0xFFEF4444), // Red
      'DatabaseError' => const Color(0xFF3B82F6), // Blue
      'NetworkError' => const Color(0xFF6B7280), // Gray
      'ValidationError' => const Color(0xFFF59E0B), // Amber
      'StorageError' => const Color(0xFF10B981), // Emerald
      'SecurityError' => const Color(0xFFDC2626), // Red-600
      'SystemError' => const Color(0xFF6366F1), // Indigo
      'UIError' => const Color(0xFF8B5CF6), // Purple
      'BusinessError' => const Color(0xFF059669), // Emerald-600
      'UnknownAppError' => const Color(0xFF6B7280), // Gray
      _ => const Color(0xFF9CA3AF), // Gray-400
    };
  }
}
