import 'package:flutter/material.dart';
import 'package:codexa_pass/core/logging/logging.dart';

/// Демонстрационная страница для показа возможностей расширенной системы логирования
class LoggingDemoPage extends StatefulWidget {
  const LoggingDemoPage({super.key});

  @override
  State<LoggingDemoPage> createState() => _LoggingDemoPageState();
}

class _LoggingDemoPageState extends State<LoggingDemoPage> {
  final AppLogger _logger = AppLogger.instance;
  final SystemInfo _systemInfo = SystemInfo.instance;

  String _systemInfoText = 'Загрузка...';
  String _shortInfoText = 'Загрузка...';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadInfo();
  }

  Future<void> _initializeAndLoadInfo() async {
    try {
      // Инициализируем системную информацию, если ещё не сделали
      if (_systemInfo.appName == 'Unknown') {
        await LogUtils.initializeSystemInfo();
      }

      setState(() {
        _systemInfoText = _systemInfo.getSystemInfoString();
        _shortInfoText = _systemInfo.getShortSystemInfo();
        _isInitialized = true;
      });

      _logger.info('📱 Демонстрационная страница логирования загружена');
    } catch (e, stackTrace) {
      _logger.error('Ошибка инициализации демо-страницы', e, stackTrace);
      setState(() {
        _systemInfoText = 'Ошибка загрузки: $e';
        _shortInfoText = 'Ошибка загрузки';
        _isInitialized = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Демо системы логирования'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                'Краткая информация о системе',
                _shortInfoText,
                icon: Icons.info_outline,
              ),
              const SizedBox(height: 20),
              _buildSection(
                'Полная информация о системе',
                _systemInfoText,
                icon: Icons.computer,
                monospace: true,
              ),
              const SizedBox(height: 20),
              _buildButtonsSection(),
              const SizedBox(height: 20),
              _buildLogsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    String content, {
    IconData? icon,
    bool monospace = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                content,
                style: TextStyle(
                  fontFamily: monospace ? 'monospace' : null,
                  fontSize: monospace ? 12 : 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Демонстрация логирования',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _logDebugInfo,
                  icon: const Icon(Icons.bug_report),
                  label: const Text('Debug'),
                ),
                ElevatedButton.icon(
                  onPressed: _logInfo,
                  icon: const Icon(Icons.info),
                  label: const Text('Info'),
                ),
                ElevatedButton.icon(
                  onPressed: _logWarning,
                  icon: const Icon(Icons.warning),
                  label: const Text('Warning'),
                ),
                ElevatedButton.icon(
                  onPressed: _logError,
                  icon: const Icon(Icons.error),
                  label: const Text('Error'),
                ),
                ElevatedButton.icon(
                  onPressed: _logPerformance,
                  icon: const Icon(Icons.speed),
                  label: const Text('Performance'),
                ),
                ElevatedButton.icon(
                  onPressed: _logUserAction,
                  icon: const Icon(Icons.person),
                  label: const Text('User Action'),
                ),
                ElevatedButton.icon(
                  onPressed: _logSystemDetails,
                  icon: const Icon(Icons.computer),
                  label: const Text('System Details'),
                ),
                ElevatedButton.icon(
                  onPressed: _logSessionInfo,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Session'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Управление логами',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _refreshSystemInfo,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Обновить информацию'),
                ),
                ElevatedButton.icon(
                  onPressed: _showLogDirectory,
                  icon: const Icon(Icons.folder),
                  label: const Text('Папка логов'),
                ),
                ElevatedButton.icon(
                  onPressed: _showCrashReports,
                  icon: const Icon(Icons.bug_report),
                  label: const Text('Краш-репорты'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[100],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _clearLogs,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Очистить логи'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[100],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Методы для демонстрации различных типов логирования
  void _logDebugInfo() {
    _logger.debug('🐛 Это отладочное сообщение из демо-страницы');
    LogUtils.logUserAction('Нажата кнопка Debug');
    _showSnackBar('Debug лог записан');
  }

  void _logInfo() {
    _logger.info('ℹ️ Информационное сообщение из демо-страницы');
    LogUtils.logUserAction('Нажата кнопка Info');
    _showSnackBar('Info лог записан');
  }

  void _logWarning() {
    _logger.warning('⚠️ Предупреждение из демо-страницы');
    LogUtils.logUserAction('Нажата кнопка Warning');
    _showSnackBar('Warning лог записан');
  }

  void _logError() {
    final testError = Exception('Тестовая ошибка для демонстрации');
    _logger.error('❌ Ошибка из демо-страницы', testError, StackTrace.current);
    LogUtils.logCriticalErrorWithContext(
      'Демо-страница логирования',
      testError,
      StackTrace.current,
      additionalInfo: {
        'button': 'Error',
        'timestamp': DateTime.now().toIso8601String(),
        'user_action': 'test_error_logging',
      },
    );
    _showSnackBar('Error лог записан');
  }

  void _logPerformance() async {
    await LogUtils.measurePerformance('Демо операция', () async {
      // Имитируем некоторую работу
      await Future.delayed(const Duration(milliseconds: 100));
      return 'result';
    });
    LogUtils.logUserAction('Нажата кнопка Performance');
    _showSnackBar('Performance лог записан');
  }

  void _logUserAction() {
    LogUtils.logUserAction(
      'Демонстрация пользовательского действия',
      details: {
        'page': 'LoggingDemoPage',
        'button': 'User Action',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    _showSnackBar('User Action лог записан');
  }

  void _logSystemDetails() {
    if (_isInitialized) {
      LogUtils.logDeviceDetails();
      LogUtils.logEnvironmentInfo();
      LogUtils.logBuildInfo();
      _showSnackBar('System Details логи записаны');
    } else {
      _showSnackBar('Системная информация ещё не загружена', isError: true);
    }
  }

  void _logSessionInfo() async {
    await LogUtils.logSessionStart();
    _showSnackBar('Session лог записан');
  }

  // Методы для управления логами
  void _refreshSystemInfo() async {
    setState(() {
      _systemInfoText = 'Загрузка...';
      _shortInfoText = 'Загрузка...';
    });

    await _initializeAndLoadInfo();
    _showSnackBar('Информация обновлена');
  }

  void _showLogDirectory() async {
    try {
      final logDir = await AppLogger.instance.getLogDirectory();
      if (logDir != null) {
        _showDialog('Папка логов', 'Логи сохраняются в:\n$logDir');
      } else {
        _showDialog('Ошибка', 'Не удалось получить путь к папке логов');
      }
    } catch (e) {
      _showDialog('Ошибка', 'Ошибка получения папки логов: $e');
    }
  }

  void _clearLogs() async {
    final confirmed = await _showConfirmDialog(
      'Очистка логов',
      'Вы уверены, что хотите удалить все лог-файлы?',
    );

    if (confirmed) {
      try {
        await AppLogger.instance.clearAllLogs();
        _showSnackBar('Логи очищены');
      } catch (e) {
        _showSnackBar('Ошибка очистки логов: $e', isError: true);
      }
    }
  }

  // Утилитарные методы для UI
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Да'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showCrashReports() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CrashReportsPage()));
    LogUtils.logUserAction('Переход к краш-репортам');
  }

  @override
  void dispose() {
    LogUtils.logUserAction('Закрытие демо-страницы логирования');
    super.dispose();
  }
}
