import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../error_system.dart';
import '../error_history_page.dart';

/// Демонстрационная страница для показа возможностей системы обработки ошибок
class ErrorDemoPage extends ConsumerStatefulWidget {
  const ErrorDemoPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ErrorDemoPage> createState() => _ErrorDemoPageState();
}

class _ErrorDemoPageState extends ConsumerState<ErrorDemoPage> {
  final Random _random = Random();
  final List<Timer> _activeTimers = [];
  final List<OverlayEntry> _activeOverlays = [];

  // Выбор типа уведомления
  String _selectedNotificationType = 'snackbar';
  final List<String> _notificationTypes = [
    'snackbar',
    'toast',
    'modal',
    'topbar',
    'inline',
  ];

  // Inline error display
  AppError? _inlineError;
  Color? _inlineErrorColor;

  @override
  void dispose() {
    // Отменяем все активные таймеры
    for (final timer in _activeTimers) {
      if (timer.isActive) {
        timer.cancel();
      }
    }
    _activeTimers.clear();

    // Убираем все активные overlay
    for (final overlay in _activeOverlays) {
      if (overlay.mounted) {
        overlay.remove();
      }
    }
    _activeOverlays.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final errorController = ref.watch(errorControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Error System Demo'),
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ErrorHistoryPage(),
                ),
              );
            },
            tooltip: 'История ошибок',
          ),
        ],
      ),
      body: ErrorBoundary(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildNotificationTypeSelector(),
              const SizedBox(height: 20),
              _buildInlineErrorDisplay(),
              const SizedBox(height: 20),
              _buildErrorMetrics(errorController),
              const SizedBox(height: 20),
              _buildBasicErrorsSection(),
              const SizedBox(height: 20),
              _buildAdvancedErrorsSection(),
              const SizedBox(height: 20),
              _buildUIErrorsSection(),
              const SizedBox(height: 20),
              _buildRecoverySection(),
              const SizedBox(height: 20),
              _buildAnalyticsSection(errorController),
            ],
          ),
        ),
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ErrorBoundary caught: ${error.message}'),
              backgroundColor: Colors.orange,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 8),
            const Text(
              'Error System Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Демонстрация комплексной системы обработки ошибок',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTypeSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Choose how error notifications are displayed:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _notificationTypes.map((type) {
                final isSelected = type == _selectedNotificationType;
                return ChoiceChip(
                  label: Text(_getNotificationTypeName(type)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedNotificationType = type;
                      });
                    }
                  },
                  selectedColor: Colors.blue.shade200,
                  avatar: Icon(
                    _getNotificationTypeIcon(type),
                    size: 18,
                    color: isSelected ? Colors.blue.shade700 : Colors.grey,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _getNotificationTypeName(String type) {
    switch (type) {
      case 'snackbar':
        return 'SnackBar';
      case 'toast':
        return 'Toast';
      case 'modal':
        return 'Modal Dialog';
      case 'topbar':
        return 'Top Banner';
      case 'inline':
        return 'Inline Message';
      default:
        return type;
    }
  }

  IconData _getNotificationTypeIcon(String type) {
    switch (type) {
      case 'snackbar':
        return Icons.horizontal_rule;
      case 'toast':
        return Icons.bubble_chart;
      case 'modal':
        return Icons.open_in_new;
      case 'topbar':
        return Icons.keyboard_arrow_down;
      case 'inline':
        return Icons.insert_comment;
      default:
        return Icons.notification_important;
    }
  }

  Widget _buildErrorMetrics(ErrorController errorController) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Error Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem(
                  'Queue Size',
                  '${errorController.statistics['queueController']?['queueSize'] ?? 0}',
                  Icons.queue,
                  Colors.blue,
                ),
                _buildMetricItem(
                  'Total Errors',
                  '${errorController.statistics['queueController']?['totalProcessed'] ?? 0}',
                  Icons.error,
                  Colors.red,
                ),
                _buildMetricItem(
                  'Status',
                  errorController.statistics['isInitialized'] == true
                      ? 'Ready'
                      : 'Init',
                  Icons.healing,
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildBasicErrorsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Error Types',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildErrorButton(
                  'Database Error',
                  Icons.storage,
                  Colors.purple,
                  () => _simulateDatabaseError(),
                ),
                _buildErrorButton(
                  'Network Error',
                  Icons.wifi_off,
                  Colors.orange,
                  () => _simulateNetworkError(),
                ),
                _buildErrorButton(
                  'Auth Error',
                  Icons.lock,
                  Colors.red,
                  () => _simulateAuthError(),
                ),
                _buildErrorButton(
                  'Validation Error',
                  Icons.warning,
                  Colors.amber,
                  () => _simulateValidationError(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedErrorsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Advanced Error Types',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildErrorButton(
                  'Crypto Error',
                  Icons.security,
                  Colors.indigo,
                  () => _simulateCryptoError(),
                ),
                _buildErrorButton(
                  'Serialization Error',
                  Icons.code,
                  Colors.teal,
                  () => _simulateSerializationError(),
                ),
                _buildErrorButton(
                  'Security Error',
                  Icons.shield,
                  Colors.red.shade800,
                  () => _simulateSecurityError(),
                ),
                _buildErrorButton(
                  'System Error',
                  Icons.computer,
                  Colors.grey,
                  () => _simulateSystemError(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUIErrorsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'UI Error Demonstrations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildErrorButton(
                  'Critical Dialog',
                  Icons.dangerous,
                  Colors.red,
                  () => _showCriticalErrorDialog(),
                ),
                _buildErrorButton(
                  'Error Report',
                  Icons.bug_report,
                  Colors.blue,
                  () => _showErrorReportDialog(),
                ),
                _buildErrorButton(
                  'Recovery Dialog',
                  Icons.refresh,
                  Colors.green,
                  () => _showRecoveryDialog(),
                ),
                _buildErrorButton(
                  'Throw Widget Error',
                  Icons.widgets,
                  Colors.purple,
                  () => _throwWidgetError(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoverySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recovery & Circuit Breaker',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildErrorButton(
                  'Auto Recovery',
                  Icons.autorenew,
                  Colors.green,
                  () => _demonstrateAutoRecovery(),
                ),
                _buildErrorButton(
                  'Retry Mechanism',
                  Icons.replay,
                  Colors.blue,
                  () => _demonstrateRetry(),
                ),
                _buildErrorButton(
                  'Circuit Breaker',
                  Icons.electrical_services,
                  Colors.orange,
                  () => _demonstrateCircuitBreaker(),
                ),
                _buildErrorButton(
                  'Cascade Failure',
                  Icons.warning_amber,
                  Colors.red,
                  () => _demonstrateCascadeFailure(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection(ErrorController errorController) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analytics & Monitoring',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _clearAllErrors(),
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _exportErrorReport(),
                    icon: const Icon(Icons.download),
                    label: const Text('Export Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  // Симуляция различных типов ошибок
  void _simulateDatabaseError() {
    final error = DatabaseError(
      code: 'DB_CONNECTION_FAILED',
      message: 'Failed to connect to database',
      severity: ErrorSeverity.error,
      timestamp: DateTime.now(),
      metadata: {
        'operation': 'SELECT',
        'table': 'users',
        'connectionId': _random.nextInt(1000).toString(),
        'database': 'codexa_pass_db',
        'driver': 'sqlite3',
        'timeout': '30s',
      },
    );

    ref.read(errorControllerProvider).handleError(error);

    // Показываем уведомление выбранного типа
    _showErrorNotification(error, Colors.purple);
  }

  void _simulateNetworkError() {
    final error = NetworkError(
      code: 'NETWORK_TIMEOUT',
      message: 'Connection timeout',
      severity: ErrorSeverity.warning,
      timestamp: DateTime.now(),
      metadata: {
        'url': 'https://api.example.com/auth',
        'method': 'POST',
        'timeout': '10s',
        'statusCode': 408,
        'userAgent': 'Codexa Pass/1.0',
        'retryCount': _random.nextInt(3),
      },
    );

    ref.read(errorControllerProvider).handleError(error);
    _showErrorNotification(error, Colors.orange);
  }

  void _simulateAuthError() {
    final error = AuthenticationError(
      code: 'AUTH_INVALID_CREDENTIALS',
      message: 'Invalid credentials',
      severity: ErrorSeverity.error,
      timestamp: DateTime.now(),
      metadata: {
        'username': 'user@example.com',
        'loginAttempt': _random.nextInt(5) + 1,
        'ipAddress': '192.168.1.${_random.nextInt(255)}',
        'authMethod': 'password',
        'sessionId': 'sess_${_random.nextInt(10000)}',
      },
    );

    ref.read(errorControllerProvider).handleError(error);
    _showErrorNotification(error, Colors.red);
  }

  void _simulateValidationError() {
    final error = ValidationError(
      code: 'VALIDATION_WEAK_PASSWORD',
      message: 'Password does not meet requirements',
      severity: ErrorSeverity.warning,
      timestamp: DateTime.now(),
      field: 'password',
      metadata: {
        'requirements': 'min 8 chars, uppercase, number, symbol',
        'provided': '*' * (_random.nextInt(10) + 1),
        'formId': 'registration_form',
        'validationEngine': 'custom',
      },
    );

    ref.read(errorControllerProvider).handleError(error);
    _showErrorNotification(error, Colors.amber);
  }

  void _simulateCryptoError() {
    final error = BaseAppError(
      code: 'CRYPTO_KEY_DERIVATION_FAILED',
      message: 'Encryption key derivation failed',
      severity: ErrorSeverity.critical,
      timestamp: DateTime.now(),
      module: 'Cryptography',
      metadata: {
        'algorithm': 'PBKDF2',
        'iterations': 100000,
        'saltLength': 32,
        'keySize': 256,
        'provider': 'OpenSSL',
        'mode': 'encrypt',
      },
    );

    ref.read(errorControllerProvider).handleError(error);
    _showErrorNotification(error, Colors.indigo);
  }

  void _simulateSerializationError() {
    final error = SerializationError(
      code: 'JSON_PARSE_FAILED',
      message: 'JSON parsing failed',
      severity: ErrorSeverity.error,
      timestamp: DateTime.now(),
      metadata: {
        'format': 'JSON',
        'fieldPath': 'user.credentials.encrypted_data',
        'expectedType': 'String',
        'actualType': 'null',
        'parser': 'dart:convert',
        'dataSize': '${_random.nextInt(1000)}KB',
      },
    );

    ref.read(errorControllerProvider).handleError(error);
    _showErrorNotification(error, Colors.teal);
  }

  void _simulateSecurityError() {
    final error = BaseAppError(
      code: 'SECURITY_SUSPICIOUS_ACTIVITY',
      message: 'Suspicious activity detected',
      severity: ErrorSeverity.critical,
      timestamp: DateTime.now(),
      module: 'Security',
      metadata: {
        'activity': 'multiple_failed_logins',
        'count': _random.nextInt(10) + 5,
        'timeWindow': '5 minutes',
        'sourceIP': '192.168.1.${_random.nextInt(255)}',
        'threatLevel': 'medium',
        'action': 'account_locked',
        'alertId': 'alert_${_random.nextInt(10000)}',
      },
    );

    ref.read(errorControllerProvider).handleError(error);
    _showErrorNotification(error, Colors.red.shade800);
  }

  void _simulateSystemError() {
    final error = BaseAppError(
      code: 'SYSTEM_INSUFFICIENT_STORAGE',
      message: 'Insufficient storage space',
      severity: ErrorSeverity.error,
      timestamp: DateTime.now(),
      module: 'System',
      metadata: {
        'operation': 'backup_creation',
        'requiredSpace': '${_random.nextInt(500) + 100}MB',
        'availableSpace': '${_random.nextInt(50)}MB',
        'filesystem': 'NTFS',
        'drive': 'C:',
        'totalSpace': '500GB',
      },
    );

    ref.read(errorControllerProvider).handleError(error);
    _showErrorNotification(error, Colors.grey);
  }

  // Универсальный метод для показа уведомлений
  void _showErrorNotification(AppError error, Color color) {
    switch (_selectedNotificationType) {
      case 'snackbar':
        _showErrorSnackBar(error, color);
        break;
      case 'toast':
        _showErrorToast(error, color);
        break;
      case 'modal':
        _showErrorModal(error, color);
        break;
      case 'topbar':
        _showErrorTopBar(error, color);
        break;
      case 'inline':
        _showErrorInline(error, color);
        break;
      default:
        _showErrorSnackBar(error, color);
    }
  } // Вспомогательный метод для показа SnackBar

  void _showErrorSnackBar(AppError error, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_getErrorIcon(error.severity), color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    error.userFriendlyMessage,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Code: ${error.code}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Details',
          textColor: Colors.white,
          onPressed: () => _showErrorDetails(error),
        ),
      ),
    );
  }

  void _showErrorToast(AppError error, Color color) {
    if (!mounted) return;

    // Имитация toast уведомления через overlay
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  _getErrorIcon(error.severity),
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        error.code,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        error.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: () {
                    overlayEntry.remove();
                    _activeOverlays.remove(overlayEntry);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    _activeOverlays.add(overlayEntry);

    // Автоматически убираем через 4 секунды
    final timer = Timer(const Duration(seconds: 4), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
        _activeOverlays.remove(overlayEntry);
      }
    });
    _activeTimers.add(timer);
  }

  void _showErrorModal(AppError error, Color color) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(_getErrorIcon(error.severity), color: color, size: 32),
        title: Text(error.code, style: TextStyle(color: color)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error.message),
            const SizedBox(height: 16),
            Text(
              'Тип: ${error.severity.name}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Время: ${error.timestamp.toString().split('.')[0]}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showErrorDetails(error);
            },
            child: const Text('Детали'),
          ),
        ],
      ),
    );
  }

  void _showErrorTopBar(AppError error, Color color) {
    if (!mounted) return;

    // Имитация топ-бара через overlay
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Material(
          color: color,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    _getErrorIcon(error.severity),
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          error.code,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          error.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () {
                      overlayEntry.remove();
                      _activeOverlays.remove(overlayEntry);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    _activeOverlays.add(overlayEntry);

    // Автоматически убираем через 5 секунд
    final timer = Timer(const Duration(seconds: 5), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
        _activeOverlays.remove(overlayEntry);
      }
    });
    _activeTimers.add(timer);
  }

  void _showErrorInline(AppError error, Color color) {
    if (!mounted) return;

    setState(() {
      _inlineError = error;
      _inlineErrorColor = color;
    });

    // Убираем inline ошибку через 6 секунд
    final timer = Timer(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _inlineError = null;
          _inlineErrorColor = null;
        });
      }
    });
    _activeTimers.add(timer);
  }

  IconData _getErrorIcon(ErrorSeverity severity) {
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

  Widget _buildInlineErrorDisplay() {
    if (_inlineError == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _inlineErrorColor?.withOpacity(0.1),
        border: Border.all(color: _inlineErrorColor ?? Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getErrorIcon(_inlineError!.severity),
            color: _inlineErrorColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _inlineError!.code,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _inlineErrorColor,
                  ),
                ),
                Text(
                  _inlineError!.message,
                  style: TextStyle(color: _inlineErrorColor?.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: _inlineErrorColor),
            onPressed: () {
              if (mounted) {
                setState(() {
                  _inlineError = null;
                  _inlineErrorColor = null;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  void _showErrorDetails(AppError error) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getErrorIcon(error.severity),
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
              // Копировать в буфер обмена
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Детали ошибки скопированы в буфер обмена'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
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

  // UI демонстрации
  void _showCriticalErrorDialog() {
    final error = BaseAppError(
      code: 'SYSTEM_CRITICAL_FAILURE',
      message: 'Critical system failure detected',
      severity: ErrorSeverity.critical,
      timestamp: DateTime.now(),
      module: 'security_module',
      metadata: {'component': 'security_module', 'errorCode': 'SEC_FATAL_001'},
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CriticalErrorDialog(
        error: error,
        onExit: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'App exit simulated (would close app in production)',
              ),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pop();
        },
        onRestart: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('App restart simulated'),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showErrorReportDialog() {
    final error = NetworkError(
      code: 'API_COMMUNICATION_FAILED',
      message: 'API communication failed',
      severity: ErrorSeverity.error,
      timestamp: DateTime.now(),
      metadata: {'endpoint': '/api/v1/sync', 'method': 'POST'},
    );

    showDialog(
      context: context,
      builder: (context) => ErrorReportDialog(
        error: error,
        onSend: (comment) {
          // Симулируем отправку
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error report sent${comment != null ? ' with comment' : ''}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showRecoveryDialog() {
    final error = DatabaseError(
      code: 'DB_CONNECTION_LOST',
      message: 'Database connection lost',
      severity: ErrorSeverity.error,
      timestamp: DateTime.now(),
      metadata: {'operation': 'save_credentials', 'connectionId': 'conn_12345'},
    );

    showDialog(
      context: context,
      builder: (context) => ErrorRecoveryDialog(
        error: error,
        onRetry: () async {
          await Future.delayed(const Duration(seconds: 2));
          // Симулируем успешное восстановление
        },
      ),
    );
  }

  void _throwWidgetError() {
    // Создаем ошибку и передаем в ErrorController вместо throw
    final error = BaseAppError(
      code: 'UI_WIDGET_RENDERING_FAILED',
      message: 'Widget rendering failed',
      severity: ErrorSeverity.error,
      timestamp: DateTime.now(),
      module: 'UI',
      metadata: {'widget': 'ErrorDemoButton', 'renderPhase': 'build'},
    );

    // Обрабатываем ошибку через систему
    ref.read(errorControllerProvider).handleError(error);

    // Показываем уведомление
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Widget error simulated: ${error.message}'),
        backgroundColor: Colors.purple,
        action: SnackBarAction(
          label: 'Details',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Widget Error Details'),
                content: Text(error.detailedMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Демонстрация recovery механизмов
  Future<void> _demonstrateAutoRecovery() async {
    final error = NetworkError(
      code: 'NETWORK_TEMPORARY_FAILURE',
      message: 'Temporary network failure',
      severity: ErrorSeverity.warning,
      timestamp: DateTime.now(),
      canRetry: true,
      metadata: {'operation': 'data_sync', 'retryable': true},
    );

    // Симулируем автоматическое восстановление
    ref.read(errorControllerProvider).handleError(error);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Auto recovery initiated. Check error metrics.'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _demonstrateRetry() async {
    final controller = ref.read(errorControllerProvider);

    for (int i = 1; i <= 3; i++) {
      final error = ValidationError(
        code: 'VALIDATION_RETRY_TEST',
        message: 'Retry attempt $i',
        severity: ErrorSeverity.info,
        timestamp: DateTime.now(),
        metadata: {'attempt': i, 'maxAttempts': 3},
      );

      controller.handleError(error);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Retry sequence completed'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _demonstrateCircuitBreaker() async {
    final controller = ref.read(errorControllerProvider);

    // Создаем много ошибок подряд для активации circuit breaker
    for (int i = 1; i <= 6; i++) {
      final error = NetworkError(
        code: 'NETWORK_CIRCUIT_BREAKER_TEST',
        message: 'Circuit breaker test $i',
        severity: ErrorSeverity.error,
        timestamp: DateTime.now(),
        metadata: {'service': 'api_gateway', 'attempt': i},
      );

      controller.handleError(error);
      await Future.delayed(const Duration(milliseconds: 200));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Circuit breaker should be activated'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _demonstrateCascadeFailure() async {
    final controller = ref.read(errorControllerProvider);

    // Симулируем каскадные сбои
    final errors = [
      DatabaseError(
        code: 'DB_PRIMARY_FAILED',
        message: 'Primary DB connection failed',
        severity: ErrorSeverity.critical,
        timestamp: DateTime.now(),
      ),
      DatabaseError(
        code: 'DB_BACKUP_FAILED',
        message: 'Backup DB connection failed',
        severity: ErrorSeverity.critical,
        timestamp: DateTime.now(),
      ),
      BaseAppError(
        code: 'CACHE_UNAVAILABLE',
        message: 'Cache system unavailable',
        severity: ErrorSeverity.error,
        timestamp: DateTime.now(),
        module: 'Cache',
      ),
      NetworkError(
        code: 'API_UNREACHABLE',
        message: 'External API unreachable',
        severity: ErrorSeverity.error,
        timestamp: DateTime.now(),
      ),
      BaseAppError(
        code: 'SECURITY_COMPROMISED',
        message: 'Security subsystem compromised',
        severity: ErrorSeverity.fatal,
        timestamp: DateTime.now(),
        module: 'Security',
      ),
    ];

    for (final error in errors) {
      controller.handleError(error);
      await Future.delayed(const Duration(milliseconds: 300));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cascade failure simulation completed'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Управление системой
  void _clearAllErrors() {
    // Симулируем очистку
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All errors cleared'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _exportErrorReport() {
    final controller = ref.read(errorControllerProvider);

    // Симулируем экспорт отчета
    final report = {
      'timestamp': DateTime.now().toIso8601String(),
      'statistics': controller.statistics,
      'systemStatus': 'operational',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report exported: ${report.length} fields'),
        backgroundColor: Colors.blue,
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Error Report'),
                content: SingleChildScrollView(child: Text(report.toString())),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
