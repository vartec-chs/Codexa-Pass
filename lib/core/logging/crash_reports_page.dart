import 'package:flutter/material.dart';
import 'package:codexa_pass/core/logging/logging.dart';

/// Демонстрационная страница для краш-репортов
class CrashReportsPage extends StatefulWidget {
  const CrashReportsPage({super.key});

  @override
  State<CrashReportsPage> createState() => _CrashReportsPageState();
}

class _CrashReportsPageState extends State<CrashReportsPage> {
  final AppLogger _logger = AppLogger.instance;
  final CrashReporter _crashReporter = CrashReporter.instance;

  List<CrashReport> _crashReports = [];
  Map<CrashType, int> _statistics = {};
  bool _isLoading = true;
  String? _crashReportsPath;

  @override
  void initState() {
    super.initState();
    _loadCrashReports();
  }

  Future<void> _loadCrashReports() async {
    setState(() => _isLoading = true);

    try {
      final reports = await _crashReporter.getAllCrashReports();
      final stats = await LogUtils.getCrashReportsStatistics();
      final path = LogUtils.getCrashReportsPath();

      setState(() {
        _crashReports = reports;
        _statistics = stats;
        _crashReportsPath = path;
        _isLoading = false;
      });
    } catch (e) {
      _logger.error('Ошибка загрузки краш-репортов', e);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Краш-репорты'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCrashReports,
            tooltip: 'Обновить',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Очистить все'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'show_path',
                child: Row(
                  children: [
                    Icon(Icons.folder),
                    SizedBox(width: 8),
                    Text('Показать путь'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'test_crash',
                child: Row(
                  children: [
                    Icon(Icons.bug_report, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Тестовый краш'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatisticsCard(),
                Expanded(child: _buildCrashReportsList()),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTestCrash,
        tooltip: 'Создать тестовый краш-репорт',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    int totalCrashes = _statistics.values.fold(0, (sum, count) => sum + count);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Статистика краш-репортов',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Всего краш-репортов: $totalCrashes',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: CrashType.values.map((type) {
                final count = _statistics[type] ?? 0;
                final color = _getCrashTypeColor(type);
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getCrashTypeIcon(type), size: 16, color: color),
                      const SizedBox(width: 4),
                      Text(
                        '${type.folderName}: $count',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrashReportsList() {
    if (_crashReports.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Краш-репорты отсутствуют',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'Это хорошо! Ваше приложение работает стабильно.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _crashReports.length,
      itemBuilder: (context, index) {
        final report = _crashReports[index];
        return _buildCrashReportCard(report);
      },
    );
  }

  Widget _buildCrashReportCard(CrashReport report) {
    final color = _getCrashTypeColor(report.type);
    final timeAgo = _getTimeAgo(report.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showCrashReportDetails(report),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_getCrashTypeIcon(report.type), color: color, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      report.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    timeAgo,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                report.message,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report.type.folderName,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'ID: ${report.id.split('_').last.substring(0, 8)}...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                      fontFamily: 'monospace',
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

  void _showCrashReportDetails(CrashReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getCrashTypeIcon(report.type),
              color: _getCrashTypeColor(report.type),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(report.title)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('ID', report.id),
                _buildDetailRow('Время', report.timestamp.toLocal().toString()),
                _buildDetailRow('Тип', report.type.folderName),
                const SizedBox(height: 16),
                const Text(
                  'Сообщение об ошибке:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    report.message,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                if (report.stackTrace != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Стек вызовов:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      report.stackTrace!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
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
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showFullReport(report);
            },
            child: const Text('Полный отчет'),
          ),
        ],
      ),
    );
  }

  void _showFullReport(CrashReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Полный краш-репорт'),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: SingleChildScrollView(
            child: Text(
              report.toReadableText(),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
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
            width: 60,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCrashTypeColor(CrashType type) {
    switch (type) {
      case CrashType.flutter:
        return Colors.blue;
      case CrashType.dart:
        return Colors.green;
      case CrashType.native:
        return Colors.orange;
      case CrashType.custom:
        return Colors.purple;
      case CrashType.fatal:
        return Colors.red;
    }
  }

  IconData _getCrashTypeIcon(CrashType type) {
    switch (type) {
      case CrashType.flutter:
        return Icons.widgets;
      case CrashType.dart:
        return Icons.code;
      case CrashType.native:
        return Icons.computer;
      case CrashType.custom:
        return Icons.bug_report;
      case CrashType.fatal:
        return Icons.dangerous;
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}д назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}ч назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}м назад';
    } else {
      return 'только что';
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'clear_all':
        _confirmClearAll();
        break;
      case 'show_path':
        _showPath();
        break;
      case 'test_crash':
        _createTestCrash();
        break;
    }
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистка краш-репортов'),
        content: const Text('Вы уверены, что хотите удалить все краш-репорты?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearAllCrashReports();
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _clearAllCrashReports() async {
    try {
      await LogUtils.clearAllCrashReports();
      _showSnackBar('Все краш-репорты удалены');
      _loadCrashReports();
    } catch (e) {
      _showSnackBar('Ошибка очистки: $e', isError: true);
    }
  }

  void _showPath() {
    final path = _crashReportsPath ?? 'Не найден';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Путь к краш-репортам'),
        content: Text(path),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _createTestCrash() async {
    try {
      final testError = Exception(
        'Это тестовая ошибка для демонстрации краш-репорта',
      );
      await LogUtils.reportCustomCrash(
        'Тестовый краш-репорт',
        testError,
        stackTrace: StackTrace.current,
        additionalInfo: {
          'source': 'CrashReportsPage',
          'action': 'manual_test',
          'timestamp': DateTime.now().toIso8601String(),
          'user_initiated': true,
        },
      );

      _showSnackBar('Тестовый краш-репорт создан');
      _loadCrashReports();
    } catch (e) {
      _showSnackBar('Ошибка создания краш-репорта: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
