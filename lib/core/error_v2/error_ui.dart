/// UI компоненты для отображения ошибок в улучшенной системе v2

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'error_base.dart';
import 'error_localization.dart';

/// Типы отображения ошибок
enum ErrorDisplayType {
  /// Снэкбар внизу экрана
  snackbar,

  /// Диалоговое окно
  dialog,

  /// Баннер вверху экрана
  banner,

  /// Встроенное уведомление в контент
  inline,

  /// Полноэкранная страница ошибки
  fullscreen,

  /// Тост уведомление
  toast,
}

/// Конфигурация отображения ошибки
class ErrorDisplayConfigV2 {
  final ErrorDisplayType type;
  final Duration duration;
  final bool isDismissible;
  final bool showTechnicalDetails;
  final bool showSolution;
  final bool showRetryButton;
  final bool showReportButton;
  final String? customTitle;
  final String? customMessage;
  final Widget? customIcon;
  final Color? backgroundColor;
  final Color? textColor;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;
  final List<Widget>? customActions;

  const ErrorDisplayConfigV2({
    this.type = ErrorDisplayType.snackbar,
    this.duration = const Duration(seconds: 4),
    this.isDismissible = true,
    this.showTechnicalDetails = false,
    this.showSolution = true,
    this.showRetryButton = false,
    this.showReportButton = false,
    this.customTitle,
    this.customMessage,
    this.customIcon,
    this.backgroundColor,
    this.textColor,
    this.titleStyle,
    this.messageStyle,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.customActions,
  });

  /// Создание конфигурации для критических ошибок
  factory ErrorDisplayConfigV2.critical() {
    return const ErrorDisplayConfigV2(
      type: ErrorDisplayType.dialog,
      showTechnicalDetails: true,
      showSolution: true,
      showRetryButton: true,
      showReportButton: true,
      isDismissible: false,
    );
  }

  /// Создание конфигурации для предупреждений
  factory ErrorDisplayConfigV2.warning() {
    return const ErrorDisplayConfigV2(
      type: ErrorDisplayType.banner,
      duration: Duration(seconds: 6),
      showSolution: true,
    );
  }

  /// Создание конфигурации для информационных сообщений
  factory ErrorDisplayConfigV2.info() {
    return const ErrorDisplayConfigV2(
      type: ErrorDisplayType.snackbar,
      duration: Duration(seconds: 3),
      showSolution: false,
    );
  }
}

/// Основной виджет для отображения ошибок
class ErrorDisplayV2 {
  static final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Ключ для ScaffoldMessenger
  static GlobalKey<ScaffoldMessengerState> get scaffoldKey => _scaffoldKey;

  /// Отображение ошибки с автоматическим выбором типа
  static Future<void> show(
    BuildContext context,
    AppErrorV2 error, {
    ErrorDisplayConfigV2? config,
    VoidCallback? onRetry,
    VoidCallback? onReport,
    VoidCallback? onDismiss,
  }) async {
    final displayConfig = config ?? _getDefaultConfig(error);

    switch (displayConfig.type) {
      case ErrorDisplayType.snackbar:
        _showSnackbar(
          context,
          error,
          displayConfig,
          onRetry,
          onReport,
          onDismiss,
        );
        break;

      case ErrorDisplayType.dialog:
        await _showDialog(
          context,
          error,
          displayConfig,
          onRetry,
          onReport,
          onDismiss,
        );
        break;

      case ErrorDisplayType.banner:
        _showBanner(
          context,
          error,
          displayConfig,
          onRetry,
          onReport,
          onDismiss,
        );
        break;

      case ErrorDisplayType.inline:
        // Inline отображение требует отдельной реализации в месте использования
        break;

      case ErrorDisplayType.fullscreen:
        await _showFullscreen(
          context,
          error,
          displayConfig,
          onRetry,
          onReport,
          onDismiss,
        );
        break;

      case ErrorDisplayType.toast:
        _showToast(context, error, displayConfig);
        break;
    }
  }

  /// Получение конфигурации по умолчанию для ошибки
  static ErrorDisplayConfigV2 _getDefaultConfig(AppErrorV2 error) {
    switch (error.severity) {
      case ErrorSeverityV2.info:
        return ErrorDisplayConfigV2.info();
      case ErrorSeverityV2.warning:
        return ErrorDisplayConfigV2.warning();
      case ErrorSeverityV2.error:
        return const ErrorDisplayConfigV2(
          type: ErrorDisplayType.snackbar,
          showSolution: true,
          showRetryButton: true,
        );
      case ErrorSeverityV2.critical:
      case ErrorSeverityV2.fatal:
        return ErrorDisplayConfigV2.critical();
    }
  }

  /// Отображение снэкбара
  static void _showSnackbar(
    BuildContext context,
    AppErrorV2 error,
    ErrorDisplayConfigV2 config,
    VoidCallback? onRetry,
    VoidCallback? onReport,
    VoidCallback? onDismiss,
  ) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: _ErrorSnackbarContent(
          error: error,
          config: config,
          onRetry: onRetry,
          onReport: onReport,
        ),
        duration: config.duration,
        backgroundColor:
            config.backgroundColor ?? _getErrorColor(error.severity),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: config.borderRadius ?? BorderRadius.circular(8),
        ),
        action: config.isDismissible
            ? SnackBarAction(
                label: 'Закрыть',
                textColor: Colors.white,
                onPressed: () {
                  scaffoldMessenger.hideCurrentSnackBar();
                  onDismiss?.call();
                },
              )
            : null,
      ),
    );
  }

  /// Отображение диалога
  static Future<void> _showDialog(
    BuildContext context,
    AppErrorV2 error,
    ErrorDisplayConfigV2 config,
    VoidCallback? onRetry,
    VoidCallback? onReport,
    VoidCallback? onDismiss,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: config.isDismissible,
      builder: (context) => _ErrorDialog(
        error: error,
        config: config,
        onRetry: onRetry,
        onReport: onReport,
        onDismiss: onDismiss,
      ),
    );
  }

  /// Отображение баннера
  static void _showBanner(
    BuildContext context,
    AppErrorV2 error,
    ErrorDisplayConfigV2 config,
    VoidCallback? onRetry,
    VoidCallback? onReport,
    VoidCallback? onDismiss,
  ) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.showMaterialBanner(
      MaterialBanner(
        content: _ErrorBannerContent(error: error, config: config),
        backgroundColor:
            config.backgroundColor ??
            _getErrorColor(error.severity).withOpacity(0.1),
        leading: config.customIcon ?? _getErrorIcon(error.severity),
        actions: [
          if (config.showRetryButton && onRetry != null)
            TextButton(
              onPressed: () {
                scaffoldMessenger.hideCurrentMaterialBanner();
                onRetry();
              },
              child: const Text('Повторить'),
            ),
          if (config.isDismissible)
            TextButton(
              onPressed: () {
                scaffoldMessenger.hideCurrentMaterialBanner();
                onDismiss?.call();
              },
              child: const Text('Закрыть'),
            ),
        ],
      ),
    );

    // Автоматическое скрытие
    Future.delayed(config.duration, () {
      scaffoldMessenger.hideCurrentMaterialBanner();
    });
  }

  /// Отображение полноэкранной страницы ошибки
  static Future<void> _showFullscreen(
    BuildContext context,
    AppErrorV2 error,
    ErrorDisplayConfigV2 config,
    VoidCallback? onRetry,
    VoidCallback? onReport,
    VoidCallback? onDismiss,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ErrorFullscreenPage(
          error: error,
          config: config,
          onRetry: onRetry,
          onReport: onReport,
          onDismiss: onDismiss,
        ),
      ),
    );
  }

  /// Отображение тоста (простая реализация)
  static void _showToast(
    BuildContext context,
    AppErrorV2 error,
    ErrorDisplayConfigV2 config,
  ) {
    // Простая реализация тоста через Overlay
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(error: error, config: config),
    );

    overlay.insert(overlayEntry);

    Future.delayed(config.duration, () {
      overlayEntry.remove();
    });
  }

  /// Получение цвета для уровня ошибки
  static Color _getErrorColor(ErrorSeverityV2 severity) {
    switch (severity) {
      case ErrorSeverityV2.info:
        return Colors.blue;
      case ErrorSeverityV2.warning:
        return Colors.orange;
      case ErrorSeverityV2.error:
        return Colors.red;
      case ErrorSeverityV2.critical:
        return Colors.deepOrange;
      case ErrorSeverityV2.fatal:
        return Colors.red.shade900;
    }
  }

  /// Получение иконки для уровня ошибки
  static Widget _getErrorIcon(ErrorSeverityV2 severity) {
    IconData iconData;
    Color color;

    switch (severity) {
      case ErrorSeverityV2.info:
        iconData = Icons.info_outline;
        color = Colors.blue;
        break;
      case ErrorSeverityV2.warning:
        iconData = Icons.warning_amber_outlined;
        color = Colors.orange;
        break;
      case ErrorSeverityV2.error:
        iconData = Icons.error_outline;
        color = Colors.red;
        break;
      case ErrorSeverityV2.critical:
        iconData = Icons.dangerous_outlined;
        color = Colors.deepOrange;
        break;
      case ErrorSeverityV2.fatal:
        iconData = Icons.report_problem_outlined;
        color = Colors.red.shade900;
        break;
    }

    return Icon(iconData, color: color, size: 24);
  }
}

/// Содержимое снэкбара для ошибки
class _ErrorSnackbarContent extends StatelessWidget {
  final AppErrorV2 error;
  final ErrorDisplayConfigV2 config;
  final VoidCallback? onRetry;
  final VoidCallback? onReport;

  const _ErrorSnackbarContent({
    required this.error,
    required this.config,
    this.onRetry,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        config.customIcon ?? _getErrorIcon(error.severity),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                config.customTitle ?? error.localizedTitle,
                style:
                    config.titleStyle ??
                    const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              Text(
                config.customMessage ?? error.localizedMessage,
                style:
                    config.messageStyle ?? const TextStyle(color: Colors.white),
              ),
              if (config.showSolution && error.localizedSolution != null)
                Text(
                  error.localizedSolution!,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
            ],
          ),
        ),
        if (config.showRetryButton && onRetry != null)
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: onRetry,
          ),
      ],
    );
  }

  Widget _getErrorIcon(ErrorSeverityV2 severity) {
    return ErrorDisplayV2._getErrorIcon(severity);
  }
}

/// Содержимое баннера для ошибки
class _ErrorBannerContent extends StatelessWidget {
  final AppErrorV2 error;
  final ErrorDisplayConfigV2 config;

  const _ErrorBannerContent({required this.error, required this.config});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          config.customTitle ?? error.localizedTitle,
          style:
              config.titleStyle ??
              Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          config.customMessage ?? error.localizedMessage,
          style: config.messageStyle ?? Theme.of(context).textTheme.bodyMedium,
        ),
        if (config.showSolution && error.localizedSolution != null) ...[
          const SizedBox(height: 8),
          Text(
            'Решение: ${error.localizedSolution}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ],
    );
  }
}

/// Диалог для отображения ошибки
class _ErrorDialog extends StatefulWidget {
  final AppErrorV2 error;
  final ErrorDisplayConfigV2 config;
  final VoidCallback? onRetry;
  final VoidCallback? onReport;
  final VoidCallback? onDismiss;

  const _ErrorDialog({
    required this.error,
    required this.config,
    this.onRetry,
    this.onReport,
    this.onDismiss,
  });

  @override
  State<_ErrorDialog> createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<_ErrorDialog> {
  bool _showTechnicalDetails = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon:
          widget.config.customIcon ??
          ErrorDisplayV2._getErrorIcon(widget.error.severity),
      title: Text(widget.config.customTitle ?? widget.error.localizedTitle),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.config.customMessage ?? widget.error.localizedMessage),

            if (widget.config.showSolution &&
                widget.error.localizedSolution != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Рекомендация',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(widget.error.localizedSolution!),
                    ],
                  ),
                ),
              ),
            ],

            if (widget.config.showTechnicalDetails &&
                widget.error.technicalDetails != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showTechnicalDetails = !_showTechnicalDetails;
                  });
                },
                icon: Icon(
                  _showTechnicalDetails ? Icons.expand_less : Icons.expand_more,
                ),
                label: Text(
                  _showTechnicalDetails
                      ? 'Скрыть детали'
                      : 'Показать технические детали',
                ),
              ),

              if (_showTechnicalDetails) ...[
                Card(
                  color: Colors.grey.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Технические детали',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(
                                    text: widget.error.technicalDetails!,
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Скопировано в буфер обмена'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.error.technicalDetails!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ID ошибки: ${widget.error.id}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        if (widget.config.showReportButton && widget.onReport != null)
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onReport!();
            },
            icon: const Icon(Icons.bug_report),
            label: const Text('Сообщить об ошибке'),
          ),

        if (widget.config.showRetryButton && widget.onRetry != null)
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onRetry!();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Повторить'),
          ),

        if (widget.config.isDismissible)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDismiss?.call();
            },
            child: const Text('Закрыть'),
          ),
      ],
    );
  }
}

/// Полноэкранная страница ошибки
class _ErrorFullscreenPage extends StatelessWidget {
  final AppErrorV2 error;
  final ErrorDisplayConfigV2 config;
  final VoidCallback? onRetry;
  final VoidCallback? onReport;
  final VoidCallback? onDismiss;

  const _ErrorFullscreenPage({
    required this.error,
    required this.config,
    this.onRetry,
    this.onReport,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(config.customTitle ?? error.localizedTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
            onDismiss?.call();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ErrorDisplayV2._getErrorIcon(error.severity),
            const SizedBox(height: 24),
            Text(
              config.customTitle ?? error.localizedTitle,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              config.customMessage ?? error.localizedMessage,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (config.showSolution && error.localizedSolution != null) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.lightbulb_outline, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Рекомендация',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.localizedSolution!,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (config.showRetryButton && onRetry != null) ...[
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onRetry!();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Повторить'),
                  ),
                  const SizedBox(width: 16),
                ],
                if (config.showReportButton && onReport != null)
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onReport!();
                    },
                    icon: const Icon(Icons.bug_report),
                    label: const Text('Сообщить об ошибке'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Виджет тоста
class _ToastWidget extends StatelessWidget {
  final AppErrorV2 error;
  final ErrorDisplayConfigV2 config;

  const _ToastWidget({required this.error, required this.config});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 20,
      right: 20,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                config.backgroundColor ??
                ErrorDisplayV2._getErrorColor(error.severity),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              ErrorDisplayV2._getErrorIcon(error.severity),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      config.customTitle ?? error.localizedTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      config.customMessage ?? error.localizedMessage,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Встроенный виджет для отображения ошибки
class InlineErrorWidgetV2 extends StatelessWidget {
  final AppErrorV2 error;
  final ErrorDisplayConfigV2? config;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const InlineErrorWidgetV2({
    super.key,
    required this.error,
    this.config,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final displayConfig = config ?? const ErrorDisplayConfigV2();

    return Card(
      color: ErrorDisplayV2._getErrorColor(error.severity).withOpacity(0.1),
      child: Padding(
        padding: displayConfig.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                displayConfig.customIcon ??
                    ErrorDisplayV2._getErrorIcon(error.severity),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    displayConfig.customTitle ?? error.localizedTitle,
                    style:
                        displayConfig.titleStyle ??
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (displayConfig.isDismissible && onDismiss != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onDismiss,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              displayConfig.customMessage ?? error.localizedMessage,
              style:
                  displayConfig.messageStyle ??
                  Theme.of(context).textTheme.bodyMedium,
            ),
            if (displayConfig.showSolution &&
                error.localizedSolution != null) ...[
              const SizedBox(height: 8),
              Text(
                'Решение: ${error.localizedSolution}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
            if (displayConfig.showRetryButton && onRetry != null) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
