import 'package:flutter/material.dart';
import '../credentials_store.dart';

class CredentialsDemoPage extends StatefulWidget {
  const CredentialsDemoPage({super.key});

  @override
  State<CredentialsDemoPage> createState() => _CredentialsDemoPageState();
}

class _CredentialsDemoPageState extends State<CredentialsDemoPage> {
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _credentialsService = CredentialsService.instance;

  bool _isLoading = false;
  List<DatabaseMetadata> _databases = [];
  String _status = 'База данных закрыта';

  @override
  void initState() {
    super.initState();
    _credentialsService.initialize();
  }

  Future<void> _openDatabase() async {
    if (_passwordController.text.isEmpty) {
      _showError('Введите пароль');
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Открытие базы данных...';
    });

    try {
      await _credentialsService.openDatabase(_passwordController.text);
      await _loadDatabases();
      setState(() {
        _status = 'База данных открыта';
      });
    } catch (e) {
      _showError('Ошибка открытия БД: ${e.toString()}');
      setState(() {
        _status = 'Ошибка открытия базы данных';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createDatabase() async {
    if (!_credentialsService.isDatabaseOpen) {
      _showError('Сначала откройте базу данных');
      return;
    }

    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty) {
      _showError('Заполните имя и описание');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _credentialsService.createDatabaseMetadata(
        name: _nameController.text,
        description: _descriptionController.text,
        password: _passwordController.text,
      );

      _nameController.clear();
      _descriptionController.clear();

      await _loadDatabases();
      _showSuccess('База данных создана');
    } catch (e) {
      _showError('Ошибка создания БД: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDatabases() async {
    if (!_credentialsService.isDatabaseOpen) return;

    try {
      final databases = await _credentialsService.getAllDatabaseMetadata();
      setState(() {
        _databases = databases;
      });
    } catch (e) {
      _showError('Ошибка загрузки БД: ${e.toString()}');
    }
  }

  Future<void> _closeDatabase() async {
    setState(() {
      _isLoading = true;
      _status = 'Закрытие базы данных...';
    });

    try {
      await _credentialsService.closeDatabase();
      setState(() {
        _databases = [];
        _status = 'База данных закрыта';
      });
    } catch (e) {
      _showError('Ошибка закрытия БД: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _lockDatabase() {
    _credentialsService.lockDatabase();
    setState(() {
      _databases = [];
      _status = 'База данных заблокирована';
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Демо работы с БД'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Статус: $_status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Пароль',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _openDatabase,
                            child: const Text('Открыть БД'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _closeDatabase,
                            child: const Text('Закрыть БД'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _lockDatabase,
                            child: const Text('Заблокировать'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_credentialsService.isDatabaseOpen) ...[
              Card(
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
                      ElevatedButton(
                        onPressed: _isLoading ? null : _createDatabase,
                        child: const Text('Создать запись'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Сохраненные базы данных (${_databases.length})',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _databases.isEmpty
                              ? const Center(
                                  child: Text('Нет сохраненных баз данных'),
                                )
                              : ListView.builder(
                                  itemCount: _databases.length,
                                  itemBuilder: (context, index) {
                                    final db = _databases[index];
                                    return ListTile(
                                      title: Text(db.name),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(db.description),
                                          Text(
                                            'Создана: ${db.createdAt.toString().substring(0, 19)}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                          Text(
                                            'Открыта: ${db.lastOpenedAt.toString().substring(0, 19)}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                      trailing: db.isLocked
                                          ? const Icon(
                                              Icons.lock,
                                              color: Colors.red,
                                            )
                                          : const Icon(
                                              Icons.lock_open,
                                              color: Colors.green,
                                            ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            if (_isLoading)
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

  @override
  void dispose() {
    _passwordController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _credentialsService.dispose();
    super.dispose();
  }
}
