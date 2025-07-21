import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../route_config.dart';
import '../route_transitions.dart';

/// Маршруты главной страницы
class HomeRoutes {
  static List<RouteBase> get routes => [
    // Главная страница
    GoRoute(
      path: AppRoutes.home,
      name: RouteNames.home,
      pageBuilder: (context, state) => buildTransitionPage(
        context: context,
        state: state,
        child: const HomePage(),
        transitionType: AppTransitions.fade,
      ),
      routes: [
        // Поиск
        GoRoute(
          path: '/search',
          name: RouteNames.search,
          pageBuilder: (context, state) => buildTransitionPage(
            context: context,
            state: state,
            child: const SearchPage(),
            transitionType: AppTransitions.slideUp,
          ),
        ),

        // Аналитика
        GoRoute(
          path: '/analytics',
          name: RouteNames.analytics,
          pageBuilder: (context, state) => buildTransitionPage(
            context: context,
            state: state,
            child: const AnalyticsPage(),
            transitionType: AppTransitions.slide,
          ),
        ),
      ],
    ),
  ];
}

/// Главная страница приложения
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<PasswordEntry> _recentPasswords = [
    PasswordEntry(
      id: '1',
      title: 'Google',
      username: 'user@example.com',
      lastUsed: DateTime.now().subtract(const Duration(hours: 2)),
      category: 'Социальные сети',
    ),
    PasswordEntry(
      id: '2',
      title: 'GitHub',
      username: 'developer',
      lastUsed: DateTime.now().subtract(const Duration(days: 1)),
      category: 'Разработка',
    ),
    PasswordEntry(
      id: '3',
      title: 'Банк',
      username: 'client123',
      lastUsed: DateTime.now().subtract(const Duration(days: 2)),
      category: 'Финансы',
    ),
  ];

  final List<QuickAction> _quickActions = [
    QuickAction(
      title: 'Добавить пароль',
      icon: Icons.add,
      color: Colors.blue,
      onTap: (context) => context.push(AppRoutes.addPassword),
    ),
    QuickAction(
      title: 'Генератор',
      icon: Icons.shuffle,
      color: Colors.green,
      onTap: (context) => context.push(AppRoutes.generator),
    ),
    QuickAction(
      title: 'Поиск',
      icon: Icons.search,
      color: Colors.orange,
      onTap: (context) => context.push('${AppRoutes.home}/search'),
    ),
    QuickAction(
      title: 'Аналитика',
      icon: Icons.analytics,
      color: Colors.purple,
      onTap: (context) => context.push('${AppRoutes.home}/analytics'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Codexa Pass'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('${AppRoutes.home}/search'),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreMenu(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Приветствие
              _buildWelcomeSection(),
              const SizedBox(height: 24),

              // Быстрые действия
              _buildQuickActionsSection(),
              const SizedBox(height: 24),

              // Статистика
              _buildStatsSection(),
              const SizedBox(height: 24),

              // Последние пароли
              _buildRecentPasswordsSection(),
              const SizedBox(height: 24),

              // Советы по безопасности
              _buildSecurityTipsSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addPassword),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Доброе утро!';
    } else if (hour < 18) {
      greeting = 'Добрый день!';
    } else {
      greeting = 'Добрый вечер!';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ваши пароли в безопасности',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Быстрые действия', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: _quickActions.length,
          itemBuilder: (context, index) {
            final action = _quickActions[index];
            return Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => action.onTap(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(action.icon, size: 32, color: action.color),
                      const SizedBox(height: 8),
                      Text(
                        action.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              title: 'Всего паролей',
              value: '23',
              icon: Icons.security,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatItem(
              title: 'Слабые пароли',
              value: '3',
              icon: Icons.warning,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatItem(
              title: 'Безопасность',
              value: '87%',
              icon: Icons.shield,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecentPasswordsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Недавно использованные',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.vault),
              child: const Text('Посмотреть все'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentPasswords.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final password = _recentPasswords[index];
            return _buildPasswordCard(password);
          },
        ),
      ],
    );
  }

  Widget _buildPasswordCard(PasswordEntry password) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            password.title.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(password.title),
        subtitle: Text(password.username),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTimeAgo(password.lastUsed),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                password.category,
                style: TextStyle(fontSize: 10, color: Colors.blue.shade800),
              ),
            ),
          ],
        ),
        onTap: () =>
            context.push('${AppRoutes.passwordDetails}/${password.id}'),
      ),
    );
  }

  Widget _buildSecurityTipsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.orange.shade600),
              const SizedBox(width: 8),
              Text(
                'Совет по безопасности',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'У вас есть 3 слабых пароля. Рекомендуем обновить их для повышения безопасности.',
            style: TextStyle(color: Colors.orange.shade700),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.push(AppRoutes.security),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Проверить безопасность'),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч назад';
    } else {
      return '${difference.inDays} д назад';
    }
  }

  Future<void> _refreshData() async {
    // Имитация обновления данных
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        // Обновление данных
      });
    }
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Создать резервную копию'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.backup);
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Аналитика'),
            onTap: () {
              Navigator.pop(context);
              context.push('${AppRoutes.home}/analytics');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Настройки'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.settings);
            },
          ),
        ],
      ),
    );
  }
}

/// Страница поиска
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  List<PasswordEntry> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Поиск паролей...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: _performSearch,
          autofocus: true,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
        ],
      ),
      body: _buildSearchBody(),
    );
  }

  Widget _buildSearchBody() {
    if (_searchController.text.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Введите запрос для поиска',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Ничего не найдено',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final password = _searchResults[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                password.title.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(password.title),
            subtitle: Text(password.username),
            trailing: Text(password.category),
            onTap: () =>
                context.push('${AppRoutes.passwordDetails}/${password.id}'),
          ),
        );
      },
    );
  }

  void _performSearch(String query) {
    setState(() {
      _isSearching = true;
    });

    // Имитация поиска
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
          if (query.isEmpty) {
            _searchResults = [];
          } else {
            // Имитация результатов поиска
            _searchResults = [
              PasswordEntry(
                id: '1',
                title: 'Google',
                username: 'user@example.com',
                lastUsed: DateTime.now(),
                category: 'Социальные сети',
              ),
            ];
          }
        });
      }
    });
  }
}

/// Страница аналитики
class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Аналитика')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Статистика безопасности',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Здесь будет детальная аналитика безопасности ваших паролей.'),
            // TODO: Добавить графики и детальную статистику
          ],
        ),
      ),
    );
  }
}

/// Модель записи пароля
class PasswordEntry {
  final String id;
  final String title;
  final String username;
  final DateTime lastUsed;
  final String category;

  PasswordEntry({
    required this.id,
    required this.title,
    required this.username,
    required this.lastUsed,
    required this.category,
  });
}

/// Модель быстрого действия
class QuickAction {
  final String title;
  final IconData icon;
  final Color color;
  final void Function(BuildContext) onTap;

  QuickAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
