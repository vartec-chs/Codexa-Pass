import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../route_config.dart';
import '../route_transitions.dart';

/// Маршруты хранилища паролей
class VaultRoutes {
  static List<RouteBase> get routes => [
    // Хранилище
    GoRoute(
      path: AppRoutes.vault,
      name: RouteNames.vault,
      pageBuilder: (context, state) => buildTransitionPage(
        context: context,
        state: state,
        child: const VaultPage(),
        transitionType: AppTransitions.fade,
      ),
    ),

    // Добавление пароля
    GoRoute(
      path: AppRoutes.addPassword,
      name: RouteNames.addPassword,
      pageBuilder: (context, state) => buildTransitionPage(
        context: context,
        state: state,
        child: const AddPasswordPage(),
        transitionType: AppTransitions.slideUp,
      ),
    ),

    // Редактирование пароля
    GoRoute(
      path: '${AppRoutes.editPassword}/:${RouteParams.passwordId}',
      name: RouteNames.editPassword,
      pageBuilder: (context, state) {
        final passwordId = state.pathParameters[RouteParams.passwordId] ?? '';
        return buildTransitionPage(
          context: context,
          state: state,
          child: EditPasswordPage(passwordId: passwordId),
          transitionType: AppTransitions.slideUp,
        );
      },
    ),

    // Детали пароля
    GoRoute(
      path: '${AppRoutes.passwordDetails}/:${RouteParams.passwordId}',
      name: RouteNames.passwordDetails,
      pageBuilder: (context, state) {
        final passwordId = state.pathParameters[RouteParams.passwordId] ?? '';
        return buildTransitionPage(
          context: context,
          state: state,
          child: PasswordDetailsPage(passwordId: passwordId),
          transitionType: AppTransitions.scale,
        );
      },
    ),

    // Категории
    GoRoute(
      path: AppRoutes.categories,
      name: RouteNames.categories,
      pageBuilder: (context, state) => buildTransitionPage(
        context: context,
        state: state,
        child: const CategoriesPage(),
        transitionType: AppTransitions.slide,
      ),
    ),

    // Генератор паролей
    GoRoute(
      path: AppRoutes.generator,
      name: RouteNames.generator,
      pageBuilder: (context, state) => buildTransitionPage(
        context: context,
        state: state,
        child: const PasswordGeneratorPage(),
        transitionType: AppTransitions.scale,
      ),
    ),

    // История
    GoRoute(
      path: AppRoutes.history,
      name: RouteNames.history,
      pageBuilder: (context, state) => buildTransitionPage(
        context: context,
        state: state,
        child: const HistoryPage(),
        transitionType: AppTransitions.fade,
      ),
    ),
  ];
}

/// Страница хранилища паролей
class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  String _selectedCategory = 'Все';
  String _sortBy = 'Название';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'Все',
    'Социальные сети',
    'Банки',
    'Электронная почта',
    'Работа',
    'Разработка',
    'Развлечения',
  ];

  final List<String> _sortOptions = [
    'Название',
    'Дата создания',
    'Последнее использование',
    'Категория',
  ];

  final List<VaultItem> _passwords = [
    VaultItem(
      id: '1',
      title: 'Google',
      username: 'user@example.com',
      category: 'Социальные сети',
      isFavorite: true,
      strength: PasswordStrength.strong,
      lastUsed: DateTime.now().subtract(const Duration(hours: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    VaultItem(
      id: '2',
      title: 'GitHub',
      username: 'developer',
      category: 'Разработка',
      isFavorite: false,
      strength: PasswordStrength.medium,
      lastUsed: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    VaultItem(
      id: '3',
      title: 'Сбербанк',
      username: 'client123',
      category: 'Банки',
      isFavorite: true,
      strength: PasswordStrength.weak,
      lastUsed: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Хранилище'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
              _sortPasswords();
            },
            itemBuilder: (context) => _sortOptions
                .map(
                  (option) => PopupMenuItem(value: option, child: Text(option)),
                )
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Фильтр по категориям
          _buildCategoryFilter(),

          // Список паролей
          Expanded(child: _buildPasswordsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addPassword),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPasswordsList() {
    final filteredPasswords = _getFilteredPasswords();

    if (filteredPasswords.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Нет паролей',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Добавьте первый пароль',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPasswords.length,
      itemBuilder: (context, index) {
        final password = filteredPasswords[index];
        return _buildPasswordCard(password);
      },
    );
  }

  Widget _buildPasswordCard(VaultItem password) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: _getStrengthColor(
                password.strength,
              ).withOpacity(0.2),
              child: Text(
                password.title.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: _getStrengthColor(password.strength),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (password.isFavorite)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
        title: Text(
          password.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(password.username),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    password.category,
                    style: TextStyle(fontSize: 10, color: Colors.blue.shade800),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStrengthColor(
                      password.strength,
                    ).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStrengthText(password.strength),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStrengthColor(password.strength),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'copy',
              child: ListTile(
                leading: Icon(Icons.copy),
                title: Text('Копировать пароль'),
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Редактировать'),
              ),
            ),
            const PopupMenuItem(
              value: 'favorite',
              child: ListTile(
                leading: Icon(Icons.star),
                title: Text('В избранное'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete),
                title: Text('Удалить'),
              ),
            ),
          ],
          onSelected: (value) =>
              _handlePasswordAction(value as String, password),
        ),
        onTap: () =>
            context.push('${AppRoutes.passwordDetails}/${password.id}'),
      ),
    );
  }

  List<VaultItem> _getFilteredPasswords() {
    var filtered = _passwords.where((password) {
      if (_selectedCategory != 'Все' &&
          password.category != _selectedCategory) {
        return false;
      }
      return true;
    }).toList();

    _sortPasswordsByOption(filtered);
    return filtered;
  }

  void _sortPasswords() {
    setState(() {
      // Сортировка будет применена в _getFilteredPasswords
    });
  }

  void _sortPasswordsByOption(List<VaultItem> passwords) {
    switch (_sortBy) {
      case 'Название':
        passwords.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Дата создания':
        passwords.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Последнее использование':
        passwords.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
        break;
      case 'Категория':
        passwords.sort((a, b) => a.category.compareTo(b.category));
        break;
    }
  }

  Color _getStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }

  String _getStrengthText(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Слабый';
      case PasswordStrength.medium:
        return 'Средний';
      case PasswordStrength.strong:
        return 'Сильный';
    }
  }

  void _handlePasswordAction(String action, VaultItem password) {
    switch (action) {
      case 'copy':
        // Копирование пароля
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Пароль скопирован')));
        break;
      case 'edit':
        context.push('${AppRoutes.editPassword}/${password.id}');
        break;
      case 'favorite':
        setState(() {
          password.isFavorite = !password.isFavorite;
        });
        break;
      case 'delete':
        _showDeleteDialog(password);
        break;
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Поиск'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Введите название или имя пользователя',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Выполнить поиск
            },
            child: const Text('Поиск'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(VaultItem password) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить пароль'),
        content: Text(
          'Вы уверены, что хотите удалить пароль для "${password.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _passwords.remove(password);
              });
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Пароль удален')));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}

/// Остальные страницы - заглушки для демонстрации
class AddPasswordPage extends StatelessWidget {
  const AddPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить пароль')),
      body: const Center(child: Text('Страница добавления пароля')),
    );
  }
}

class EditPasswordPage extends StatelessWidget {
  final String passwordId;

  const EditPasswordPage({super.key, required this.passwordId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать пароль')),
      body: Center(child: Text('Редактирование пароля: $passwordId')),
    );
  }
}

class PasswordDetailsPage extends StatelessWidget {
  final String passwordId;

  const PasswordDetailsPage({super.key, required this.passwordId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Детали пароля')),
      body: Center(child: Text('Детали пароля: $passwordId')),
    );
  }
}

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Категории')),
      body: const Center(child: Text('Управление категориями')),
    );
  }
}

class PasswordGeneratorPage extends StatelessWidget {
  const PasswordGeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Генератор паролей')),
      body: const Center(child: Text('Генератор надежных паролей')),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('История')),
      body: const Center(child: Text('История действий')),
    );
  }
}

/// Модели данных
enum PasswordStrength { weak, medium, strong }

class VaultItem {
  final String id;
  final String title;
  final String username;
  final String category;
  bool isFavorite;
  final PasswordStrength strength;
  final DateTime lastUsed;
  final DateTime createdAt;

  VaultItem({
    required this.id,
    required this.title,
    required this.username,
    required this.category,
    required this.isFavorite,
    required this.strength,
    required this.lastUsed,
    required this.createdAt,
  });
}
