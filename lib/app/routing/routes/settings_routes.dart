import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../route_config.dart';
import '../route_transitions.dart';

/// Маршруты настроек
class SettingsRoutes {
  static List<RouteBase> get routes => [
    // Главная страница настроек
    GoRoute(
      path: AppRoutes.settings,
      name: RouteNames.settings,
      pageBuilder: (context, state) => buildTransitionPage(
        context: context,
        state: state,
        child: const SettingsPage(),
        transitionType: AppTransitions.fade,
      ),
      routes: [
        // Профиль
        GoRoute(
          path: '/profile',
          name: RouteNames.profile,
          pageBuilder: (context, state) =>
              SpecializedTransitions.buildSettingsTransition(
                state: state,
                child: const ProfilePage(),
              ),
        ),

        // Безопасность
        GoRoute(
          path: '/security',
          name: RouteNames.security,
          pageBuilder: (context, state) =>
              SpecializedTransitions.buildSettingsTransition(
                state: state,
                child: const SecurityPage(),
              ),
        ),

        // Резервное копирование
        GoRoute(
          path: '/backup',
          name: RouteNames.backup,
          pageBuilder: (context, state) =>
              SpecializedTransitions.buildSettingsTransition(
                state: state,
                child: const BackupPage(),
              ),
        ),

        // О приложении
        GoRoute(
          path: '/about',
          name: RouteNames.about,
          pageBuilder: (context, state) =>
              SpecializedTransitions.buildSettingsTransition(
                state: state,
                child: const AboutPage(),
              ),
        ),
      ],
    ),
  ];
}

/// Главная страница настроек
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        children: [
          // Секция аккаунта
          _buildSection(
            title: 'Аккаунт',
            children: [
              _buildSettingsTile(
                title: 'Профиль',
                subtitle: 'Управление профилем и персональными данными',
                icon: Icons.person,
                onTap: () => context.push('${AppRoutes.settings}/profile'),
              ),
              _buildSettingsTile(
                title: 'Безопасность',
                subtitle: 'Настройки безопасности и аутентификации',
                icon: Icons.security,
                onTap: () => context.push('${AppRoutes.settings}/security'),
              ),
            ],
          ),

          // Секция данных
          _buildSection(
            title: 'Данные',
            children: [
              _buildSettingsTile(
                title: 'Резервное копирование',
                subtitle: 'Создание и восстановление резервных копий',
                icon: Icons.backup,
                onTap: () => context.push('${AppRoutes.settings}/backup'),
              ),
              _buildSettingsTile(
                title: 'Импорт/Экспорт',
                subtitle: 'Импорт и экспорт данных',
                icon: Icons.import_export,
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),

          // Секция приложения
          _buildSection(
            title: 'Приложение',
            children: [
              _buildSettingsTile(
                title: 'Уведомления',
                subtitle: 'Настройка уведомлений',
                icon: Icons.notifications,
                trailing: Switch(value: true, onChanged: (value) {}),
              ),
              _buildSettingsTile(
                title: 'Тема',
                subtitle: 'Светлая/темная тема',
                icon: Icons.palette,
                trailing: const Text('Системная'),
                onTap: () => _showThemeDialog(context),
              ),
              _buildSettingsTile(
                title: 'Язык',
                subtitle: 'Язык интерфейса',
                icon: Icons.language,
                trailing: const Text('Русский'),
                onTap: () => _showLanguageDialog(context),
              ),
            ],
          ),

          // Секция помощи
          _buildSection(
            title: 'Помощь и поддержка',
            children: [
              _buildSettingsTile(
                title: 'Справка',
                subtitle: 'Руководство пользователя',
                icon: Icons.help,
                onTap: () => _showComingSoon(context),
              ),
              _buildSettingsTile(
                title: 'Обратная связь',
                subtitle: 'Отправить отзыв или сообщить об ошибке',
                icon: Icons.feedback,
                onTap: () => _showComingSoon(context),
              ),
              _buildSettingsTile(
                title: 'О приложении',
                subtitle: 'Информация о версии и разработчиках',
                icon: Icons.info,
                onTap: () => context.push('${AppRoutes.settings}/about'),
              ),
            ],
          ),

          // Секция выхода
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout),
              label: const Text('Выйти из аккаунта'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        ...children,
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Функция будет доступна в следующих версиях'),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите тему'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Системная'),
              value: 'system',
              groupValue: 'system',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: const Text('Светлая'),
              value: 'light',
              groupValue: 'system',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: const Text('Темная'),
              value: 'dark',
              groupValue: 'system',
              onChanged: (value) => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите язык'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Русский'),
              value: 'ru',
              groupValue: 'ru',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: 'ru',
              onChanged: (value) => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти из аккаунта'),
        content: const Text(
          'Вы уверены, что хотите выйти из аккаунта? '
          'Все данные останутся сохраненными.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.login);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}

/// Страница профиля
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController(text: 'Иван Иванов');
  final _emailController = TextEditingController(text: 'ivan@example.com');
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            child: Text(_isEditing ? 'Сохранить' : 'Редактировать'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Аватар
            const Center(
              child: Stack(
                children: [
                  CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blue,
                      child: Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Форма
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Имя',
                border: OutlineInputBorder(),
              ),
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              enabled: _isEditing,
            ),
            const SizedBox(height: 32),

            // Статистика
            if (!_isEditing) _buildStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Статистика аккаунта',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildStatRow('Всего паролей', '23'),
          _buildStatRow('Дата регистрации', '15 мая 2024'),
          _buildStatRow('Последний вход', '2 часа назад'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

/// Страница безопасности
class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _biometricEnabled = true;
  bool _autoLockEnabled = true;
  String _autoLockTimeout = '5 минут';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Безопасность')),
      body: ListView(
        children: [
          // Аутентификация
          _buildSection(
            title: 'Аутентификация',
            children: [
              SwitchListTile(
                title: const Text('Биометрическая аутентификация'),
                subtitle: const Text('Вход по отпечатку пальца или Face ID'),
                value: _biometricEnabled,
                onChanged: (value) {
                  setState(() {
                    _biometricEnabled = value;
                  });
                },
              ),
              ListTile(
                title: const Text('Изменить мастер-пароль'),
                subtitle: const Text('Пароль для доступа к приложению'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showChangePasswordDialog(),
              ),
            ],
          ),

          // Автоматическая блокировка
          _buildSection(
            title: 'Автоматическая блокировка',
            children: [
              SwitchListTile(
                title: const Text('Автоблокировка'),
                subtitle: const Text('Блокировать приложение при неактивности'),
                value: _autoLockEnabled,
                onChanged: (value) {
                  setState(() {
                    _autoLockEnabled = value;
                  });
                },
              ),
              if (_autoLockEnabled)
                ListTile(
                  title: const Text('Время до блокировки'),
                  subtitle: Text(_autoLockTimeout),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showTimeoutDialog(),
                ),
            ],
          ),

          // Анализ безопасности
          _buildSection(
            title: 'Анализ безопасности',
            children: [
              ListTile(
                title: const Text('Проверить пароли'),
                subtitle: const Text('Найти слабые и повторяющиеся пароли'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _runSecurityAnalysis(),
              ),
              ListTile(
                title: const Text('Отчет о безопасности'),
                subtitle: const Text('Детальный анализ безопасности'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSecurityReport(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        ...children,
        const Divider(height: 1),
      ],
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить мастер-пароль'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Текущий пароль'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: 'Новый пароль'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: 'Подтвердите пароль'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Изменить'),
          ),
        ],
      ),
    );
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Время до блокировки'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['1 минута', '5 минут', '15 минут', '30 минут', '1 час']
              .map(
                (timeout) => RadioListTile<String>(
                  title: Text(timeout),
                  value: timeout,
                  groupValue: _autoLockTimeout,
                  onChanged: (value) {
                    setState(() {
                      _autoLockTimeout = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _runSecurityAnalysis() {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Анализ безопасности'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Проверка паролей...'),
          ],
        ),
      ),
    );

    // Симуляция анализа
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      _showAnalysisResults();
    });
  }

  void _showAnalysisResults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Результаты анализа'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✅ Сильные пароли: 18'),
            Text('⚠️ Слабые пароли: 3'),
            Text('🔄 Повторяющиеся: 2'),
            Text('📅 Устаревшие: 1'),
            SizedBox(height: 8),
            Text('Рекомендуется обновить 6 паролей'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  void _showSecurityReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Детальный отчет будет доступен в следующих версиях'),
      ),
    );
  }
}

/// Страница резервного копирования
class BackupPage extends StatelessWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Резервное копирование')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Автоматическое резервное копирование
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Автоматическое резервное копирование',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Последняя резервная копия: 2 часа назад'),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Включить автоматическое копирование'),
                    value: true,
                    onChanged: (value) {},
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Действия
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Создать резервную копию'),
                  subtitle: const Text('Создать копию всех данных'),
                  onTap: () => _createBackup(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('Восстановить из копии'),
                  subtitle: const Text('Восстановить данные из файла'),
                  onTap: () => _restoreBackup(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cloud_download),
                  title: const Text('Скачать копию'),
                  subtitle: const Text('Экспортировать данные в файл'),
                  onTap: () => _downloadBackup(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Информация
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Информация о копиях',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Всего копий', '5'),
                  _buildInfoRow('Размер данных', '2.1 МБ'),
                  _buildInfoRow('Частота копирования', 'Ежедневно'),
                  _buildInfoRow('Место хранения', 'Локально'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _createBackup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Создание резервной копии...'),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Резервная копия создана успешно')),
      );
    });
  }

  void _restoreBackup(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Функция восстановления будет доступна в следующих версиях',
        ),
      ),
    );
  }

  void _downloadBackup(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Функция скачивания будет доступна в следующих версиях'),
      ),
    );
  }
}

/// Страница "О приложении"
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('О приложении')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Логотип и название
          const Center(
            child: Column(
              children: [
                Icon(Icons.security, size: 80, color: Colors.blue),
                SizedBox(height: 16),
                Text(
                  'Codexa Pass',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Версия 1.0.0', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Описание
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Описание',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Codexa Pass - это безопасный менеджер паролей с продвинутой системой логирования и шифрования. '
                    'Приложение поможет вам создавать, хранить и управлять паролями безопасным способом.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Информация
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Лицензия'),
                  subtitle: const Text('MIT License'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLicense(context),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Политика конфиденциальности'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPrivacyPolicy(context),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Условия использования'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showTerms(context),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Исходный код'),
                  subtitle: const Text('GitHub'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _openGitHub(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Разработчики
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Разработчики',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Разработано с ❤️ командой Codexa'),
                  SizedBox(height: 4),
                  Text('© 2024 Codexa. Все права защищены.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLicense(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('MIT License'),
        content: SingleChildScrollView(
          child: Text(
            'MIT License\n\n'
            'Copyright (c) 2024 Codexa\n\n'
            'Permission is hereby granted, free of charge, to any person obtaining a copy...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: null, // Navigator.pop(context)
            child: Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Открытие политики конфиденциальности...')),
    );
  }

  void _showTerms(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Открытие условий использования...')),
    );
  }

  void _openGitHub(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Открытие репозитория на GitHub...')),
    );
  }
}
