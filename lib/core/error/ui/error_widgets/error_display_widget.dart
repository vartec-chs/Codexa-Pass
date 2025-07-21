import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/app_error.dart';
import '../../models/error_severity.dart';
import '../../models/error_display_type.dart';

/// Виджет для отображения ошибок пользователю
class ErrorDisplayWidget extends StatelessWidget {
  const ErrorDisplayWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
    this.showDetails = true,
  });

  final AppError error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    switch (error.displayType) {
      case ErrorDisplayType.dialog:
        return _buildDialog(context);
      case ErrorDisplayType.fullscreen:
        return _buildFullscreen(context);
      case ErrorDisplayType.banner:
        return _buildBanner(context);
      case ErrorDisplayType.inline:
        return _buildInline(context);
      case ErrorDisplayType.snackbar:
      case ErrorDisplayType.toast:
      case ErrorDisplayType.none:
        return _buildInline(context);
    }
  }

  /// Диалоговое окно
  Widget _buildDialog(BuildContext context) {
    return AlertDialog(
      icon: _getErrorIcon(),
      title: Text(_getTitle()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(error.userFriendlyMessage),
          if (showDetails && error.shouldShowDetails) ...[
            const SizedBox(height: 16),
            _buildDetailsSection(context),
          ],
        ],
      ),
      actions: _buildActions(context),
    );
  }

  /// Полноэкранное отображение
  Widget _buildFullscreen(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: _getBackgroundColor(),
        foregroundColor: _getTextColor(),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _getErrorIcon(size: 80),
              const SizedBox(height: 24),
              Text(
                _getTitle(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: _getTextColor(),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                error.userFriendlyMessage,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: _getTextColor()),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _buildActions(context)
                    .map(
                      (action) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: action,
                        ),
                      ),
                    )
                    .toList(),
              ),
              if (showDetails && error.shouldShowDetails) ...[
                const SizedBox(height: 24),
                _buildDetailsSection(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Баннер
  Widget _buildBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        border: Border(bottom: BorderSide(color: _getAccentColor(), width: 2)),
      ),
      child: Row(
        children: [
          _getErrorIcon(size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getTitle(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  error.userFriendlyMessage,
                  style: TextStyle(color: _getTextColor()),
                ),
              ],
            ),
          ),
          ..._buildCompactActions(context),
        ],
      ),
    );
  }

  /// Встроенное отображение
  Widget _buildInline(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: _getBackgroundColor(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _getErrorIcon(size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTitle(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getTextColor(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        error.userFriendlyMessage,
                        style: TextStyle(color: _getTextColor()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (showDetails && error.shouldShowDetails) ...[
              const SizedBox(height: 12),
              _buildDetailsSection(context),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildCompactActions(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Секция с деталями ошибки
  Widget _buildDetailsSection(BuildContext context) {
    return ExpansionTile(
      title: const Text('Техническая информация'),
      iconColor: _getAccentColor(),
      textColor: _getTextColor(),
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
              SelectableText(
                error.detailedMessage,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _copyToClipboard(context),
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Копировать'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getAccentColor(),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Действия для диалогов и полноэкранного режима
  List<Widget> _buildActions(BuildContext context) {
    final actions = <Widget>[];

    if (onDismiss != null) {
      actions.add(
        TextButton(onPressed: onDismiss, child: const Text('Закрыть')),
      );
    }

    if (onRetry != null && error.canRetryOperation) {
      actions.add(
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Повторить'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _getAccentColor(),
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    return actions;
  }

  /// Компактные действия для баннеров и inline
  List<Widget> _buildCompactActions(BuildContext context) {
    final actions = <Widget>[];

    if (onRetry != null && error.canRetryOperation) {
      actions.add(
        IconButton(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          color: _getAccentColor(),
          tooltip: 'Повторить',
        ),
      );
    }

    if (onDismiss != null) {
      actions.add(
        IconButton(
          onPressed: onDismiss,
          icon: const Icon(Icons.close),
          color: _getTextColor(),
          tooltip: 'Закрыть',
        ),
      );
    }

    return actions;
  }

  /// Получить иконку ошибки
  Widget _getErrorIcon({double size = 24}) {
    IconData iconData;
    Color color;

    switch (error.severity) {
      case ErrorSeverity.info:
        iconData = Icons.info_outline;
        color = Colors.blue;
        break;
      case ErrorSeverity.warning:
        iconData = Icons.warning_amber_outlined;
        color = Colors.orange;
        break;
      case ErrorSeverity.error:
        iconData = Icons.error_outline;
        color = Colors.red;
        break;
      case ErrorSeverity.critical:
        iconData = Icons.dangerous_outlined;
        color = Colors.red.shade700;
        break;
      case ErrorSeverity.fatal:
        iconData = Icons.cancel_outlined;
        color = Colors.red.shade900;
        break;
    }

    return Icon(iconData, size: size, color: color);
  }

  /// Получить заголовок
  String _getTitle() {
    switch (error.severity) {
      case ErrorSeverity.info:
        return 'Информация';
      case ErrorSeverity.warning:
        return 'Предупреждение';
      case ErrorSeverity.error:
        return 'Ошибка';
      case ErrorSeverity.critical:
        return 'Критическая ошибка';
      case ErrorSeverity.fatal:
        return 'Фатальная ошибка';
    }
  }

  /// Получить цвет фона
  Color _getBackgroundColor() {
    switch (error.severity) {
      case ErrorSeverity.info:
        return Colors.blue.shade50;
      case ErrorSeverity.warning:
        return Colors.orange.shade50;
      case ErrorSeverity.error:
        return Colors.red.shade50;
      case ErrorSeverity.critical:
        return Colors.red.shade100;
      case ErrorSeverity.fatal:
        return Colors.red.shade200;
    }
  }

  /// Получить цвет текста
  Color _getTextColor() {
    switch (error.severity) {
      case ErrorSeverity.info:
        return Colors.blue.shade800;
      case ErrorSeverity.warning:
        return Colors.orange.shade800;
      case ErrorSeverity.error:
        return Colors.red.shade800;
      case ErrorSeverity.critical:
        return Colors.red.shade900;
      case ErrorSeverity.fatal:
        return Colors.red.shade900;
    }
  }

  /// Получить акцентный цвет
  Color _getAccentColor() {
    switch (error.severity) {
      case ErrorSeverity.info:
        return Colors.blue.shade600;
      case ErrorSeverity.warning:
        return Colors.orange.shade600;
      case ErrorSeverity.error:
        return Colors.red.shade600;
      case ErrorSeverity.critical:
        return Colors.red.shade700;
      case ErrorSeverity.fatal:
        return Colors.red.shade800;
    }
  }

  /// Копировать детали в буфер обмена
  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: error.detailedMessage));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Информация об ошибке скопирована'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Показать ошибку в виде snackbar
void showErrorSnackbar(
  BuildContext context,
  AppError error, {
  VoidCallback? onRetry,
  VoidCallback? onDismiss,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(_getSnackbarIcon(error.severity), color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error.userFriendlyMessage,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: _getSnackbarColor(error.severity),
      duration: error.displayType.duration ?? const Duration(seconds: 4),
      action: onRetry != null && error.canRetryOperation
          ? SnackBarAction(
              label: 'Повторить',
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
    ),
  );
}

/// Показать ошибку в виде toast
void showErrorToast(BuildContext context, AppError error) {
  // Здесь должна быть интеграция с библиотекой для toast
  // Например, fluttertoast или подобной
  showErrorSnackbar(context, error);
}

/// Показать диалог с ошибкой
Future<void> showErrorDialog(
  BuildContext context,
  AppError error, {
  VoidCallback? onRetry,
  VoidCallback? onDismiss,
}) {
  return showDialog(
    context: context,
    barrierDismissible: !error.severity.isCritical,
    builder: (context) => ErrorDisplayWidget(
      error: error,
      onRetry: onRetry,
      onDismiss: onDismiss ?? () => Navigator.of(context).pop(),
    ),
  );
}

IconData _getSnackbarIcon(ErrorSeverity severity) {
  switch (severity) {
    case ErrorSeverity.info:
      return Icons.info_outline;
    case ErrorSeverity.warning:
      return Icons.warning_amber_outlined;
    case ErrorSeverity.error:
    case ErrorSeverity.critical:
    case ErrorSeverity.fatal:
      return Icons.error_outline;
  }
}

Color _getSnackbarColor(ErrorSeverity severity) {
  switch (severity) {
    case ErrorSeverity.info:
      return Colors.blue.shade600;
    case ErrorSeverity.warning:
      return Colors.orange.shade600;
    case ErrorSeverity.error:
      return Colors.red.shade600;
    case ErrorSeverity.critical:
      return Colors.red.shade700;
    case ErrorSeverity.fatal:
      return Colors.red.shade800;
  }
}
