import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/credentials_store_provider.dart';
import '../providers/credentials_store_state.dart';

class CredentialsProviderDemoPage extends ConsumerStatefulWidget {
  const CredentialsProviderDemoPage({super.key});

  @override
  ConsumerState<CredentialsProviderDemoPage> createState() =>
      _CredentialsProviderDemoPageState();
}

class _CredentialsProviderDemoPageState
    extends ConsumerState<CredentialsProviderDemoPage> {
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Отслеживаем состояние через провайдеры
    final state = ref.watch(credentialsStoreProvider);
    final notifier = ref.watch(credentialsStoreProvider.notifier);
    final connectionStatus = ref.watch(credentialsConnectionStatusProvider);
    final databases = ref.watch(credentialsDatabasesProvider);
    final isLoading = ref.watch(credentialsIsLoadingProvider);
    final errorMessage = ref.watch(credentialsErrorMessageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Демо Riverpod Провайдеров'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.refreshDatabases(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Карточка состояния подключения
            _buildConnectionStatusCard(state, connectionStatus),
            const SizedBox(height: 16),

            // Карточка управления БД
            _buildDatabaseControlCard(notifier, isLoading),
            const SizedBox(height: 16),

            // Отображение ошибок
            if (errorMessage != null) _buildErrorCard(errorMessage, notifier),

            // Карточка создания записи (если БД открыта)
            if (state.isDatabaseOpen) ...[
              _buildCreateRecordCard(notifier, isLoading),
              const SizedBox(height: 16),
            ],

            // Список баз данных
            if (state.isDatabaseOpen)
              Expanded(
                child: _buildDatabasesList(databases, notifier, isLoading),
              ),

            // Индикатор загрузки
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatusCard(
    CredentialsStoreState state,
    DatabaseConnectionStatus status,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Состояние подключения',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(_getStatusIcon(status), color: _getStatusColor(status)),
                const SizedBox(width: 8),
                Text(
                  status.displayName,
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (state.lastActivity != null) ...[
                  Text(
                    'Активность: ${_formatTime(state.lastActivity!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
            if (state.databases.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Записей в БД: ${state.databases.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDatabaseControlCard(
    CredentialsStoreNotifier notifier,
    bool isLoading,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Управление базой данных',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : () => _openDatabase(notifier),
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Открыть'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => notifier.closeDatabase(),
                    icon: const Icon(Icons.folder),
                    label: const Text('Закрыть'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : () => notifier.lockDatabase(),
                    icon: const Icon(Icons.lock),
                    label: const Text('Заблокировать'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(
    String errorMessage,
    CredentialsStoreNotifier notifier,
  ) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
            IconButton(
              onPressed: () => notifier.clearError(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateRecordCard(
    CredentialsStoreNotifier notifier,
    bool isLoading,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Создание новой записи',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Имя базы данных',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : () => _createDatabase(notifier),
                icon: const Icon(Icons.add),
                label: const Text('Создать запись'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatabasesList(
    List databases,
    CredentialsStoreNotifier notifier,
    bool isLoading,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Сохраненные базы данных (${databases.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: databases.isEmpty
                  ? const Center(child: Text('Нет сохраненных баз данных'))
                  : ListView.builder(
                      itemCount: databases.length,
                      itemBuilder: (context, index) {
                        final db = databases[index];
                        return ListTile(
                          title: Text(db.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(db.description),
                              Text(
                                'Создана: ${_formatTime(db.createdAt)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'Открыта: ${_formatTime(db.lastOpenedAt)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: isLoading
                                    ? null
                                    : () => notifier.setDatabaseLocked(
                                        db.id,
                                        !db.isLocked,
                                      ),
                                icon: Icon(
                                  db.isLocked ? Icons.lock : Icons.lock_open,
                                  color: db.isLocked
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                              IconButton(
                                onPressed: isLoading
                                    ? null
                                    : () => _deleteDatabase(notifier, db.id),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDatabase(CredentialsStoreNotifier notifier) async {
    if (_passwordController.text.isEmpty) {
      _showSnackBar('Введите пароль', isError: true);
      return;
    }

    try {
      await notifier.openDatabase(_passwordController.text);
      _showSnackBar('База данных открыта успешно');
    } catch (e) {
      _showSnackBar('Ошибка открытия БД: ${e.toString()}', isError: true);
    }
  }

  Future<void> _createDatabase(CredentialsStoreNotifier notifier) async {
    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty) {
      _showSnackBar('Заполните имя и описание', isError: true);
      return;
    }

    try {
      await notifier.createDatabaseMetadata(
        name: _nameController.text,
        description: _descriptionController.text,
        password: _passwordController.text,
      );

      _nameController.clear();
      _descriptionController.clear();
      _showSnackBar('Запись создана успешно');
    } catch (e) {
      _showSnackBar('Ошибка создания записи: ${e.toString()}', isError: true);
    }
  }

  Future<void> _deleteDatabase(
    CredentialsStoreNotifier notifier,
    int id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтверждение'),
        content: const Text('Удалить эту запись?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await notifier.deleteDatabaseMetadata(id);
        _showSnackBar('Запись удалена');
      } catch (e) {
        _showSnackBar('Ошибка удаления: ${e.toString()}', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  IconData _getStatusIcon(DatabaseConnectionStatus status) {
    switch (status) {
      case DatabaseConnectionStatus.disconnected:
        return Icons.cloud_off;
      case DatabaseConnectionStatus.connecting:
        return Icons.cloud_sync;
      case DatabaseConnectionStatus.connected:
        return Icons.cloud_done;
      case DatabaseConnectionStatus.locked:
        return Icons.lock;
      case DatabaseConnectionStatus.error:
        return Icons.error;
    }
  }

  Color _getStatusColor(DatabaseConnectionStatus status) {
    switch (status) {
      case DatabaseConnectionStatus.disconnected:
        return Colors.grey;
      case DatabaseConnectionStatus.connecting:
        return Colors.orange;
      case DatabaseConnectionStatus.connected:
        return Colors.green;
      case DatabaseConnectionStatus.locked:
        return Colors.blue;
      case DatabaseConnectionStatus.error:
        return Colors.red;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
