import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codexa_pass/app/theme/theme_provider.dart';
import 'package:codexa_pass/core/config/constants.dart';
import 'package:codexa_pass/features/setup/domain/services/setup_error_service.dart';
import 'package:codexa_pass/features/setup/presentation/widgets/setup_error_widget.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _initializeSetup();
  }

  /// Инициализация setup экрана с обработкой ошибок
  Future<void> _initializeSetup() async {
    final errorService = ref.read(setupErrorServiceProvider);

    try {
      // Здесь можно добавить любую логику инициализации
      // Например, проверка состояния приложения, загрузка настроек и т.д.
    } catch (e, stackTrace) {
      await errorService.handleInitializationError(
        e,
        stackTrace,
        context: context,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeSetup() async {
    final errorService = ref.read(setupErrorServiceProvider);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_first_run', false);

      if (mounted) {
        context.go('/');
      }
    } catch (e, stackTrace) {
      await errorService.handlePreferencesError(
        e,
        stackTrace,
        context: context,
      );

      // Попробуем навигацию даже если настройки не сохранились
      if (mounted) {
        try {
          context.go('/');
        } catch (navError, navStackTrace) {
          await errorService.handleNavigationError(
            navError,
            navStackTrace,
            context: context,
          );
        }
      }
    }
  }

  /// Безопасная смена темы с обработкой ошибок
  Future<void> _safeChangeTheme(
    String themeName,
    Future<void> Function() themeChanger,
  ) async {
    final errorService = ref.read(setupErrorServiceProvider);

    try {
      await themeChanger();
    } catch (e, stackTrace) {
      await errorService.handleThemeError(
        themeName,
        e,
        stackTrace,
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Error Display
            const SetupErrorWidget(),

            // App Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      onPressed: _previousPage,
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                  Text(
                    AppConstants.appName,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Page Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 2,
                onDotClicked: (index) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                effect: ExpandingDotsEffect(
                  activeDotColor: theme.colorScheme.primary,
                  dotColor: theme.colorScheme.primary.withOpacity(0.3),
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3,
                  spacing: 8,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildWelcomePage(context, theme),
                  _buildThemeSelectionPage(context, theme),
                ],
              ),
            ),

            // Bottom Navigation
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: Text(
                        'Назад',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  ElevatedButton(
                    onPressed: _currentPage < 1 ? _nextPage : _completeSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentPage < 1 ? 'Далее' : 'Готово',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Welcome Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.security,
              size: 60,
              color: theme.colorScheme.primary,
            ),
          ),

          const SizedBox(height: 32),

          // Welcome Title
          Text(
            'Добро пожаловать в\n${AppConstants.appName}',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 16),

          // Welcome Description
          Text(
            'Ваш надежный менеджер паролей для безопасного хранения и управления всеми вашими аккаунтами.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 48),

          // Features List
          _buildFeatureItem(
            context,
            theme,
            Icons.lock_outline,
            'Безопасное шифрование',
            'Все ваши данные защищены современным шифрованием',
          ),

          const SizedBox(height: 16),

          _buildFeatureItem(
            context,
            theme,
            Icons.sync,
            'Синхронизация',
            'Доступ к паролям на всех ваших устройствах',
          ),

          const SizedBox(height: 16),

          _buildFeatureItem(
            context,
            theme,
            Icons.fingerprint,
            'Биометрия',
            'Быстрый и безопасный доступ по отпечатку',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 24),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelectionPage(BuildContext context, ThemeData theme) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Theme Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.palette_outlined,
              size: 60,
              color: theme.colorScheme.primary,
            ),
          ),

          const SizedBox(height: 32),

          // Theme Title
          Text(
            'Выберите тему',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 16),

          // Theme Description
          Text(
            'Настройте внешний вид приложения под свои предпочтения. Вы всегда сможете изменить это в настройках.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 48),

          // Theme Options
          Column(
            children: [
              _buildThemeOption(
                context,
                theme,
                themeMode,
                ThemeMode.light,
                Icons.wb_sunny_outlined,
                'Светлая тема',
                'Классический светлый интерфейс',
                () => _safeChangeTheme(
                  'light',
                  () => themeNotifier.setLightTheme(),
                ),
              ),

              const SizedBox(height: 16),

              _buildThemeOption(
                context,
                theme,
                themeMode,
                ThemeMode.dark,
                Icons.nights_stay_outlined,
                'Темная тема',
                'Темный интерфейс для комфорта глаз',
                () => _safeChangeTheme(
                  'dark',
                  () => themeNotifier.setDarkTheme(),
                ),
              ),

              const SizedBox(height: 16),

              _buildThemeOption(
                context,
                theme,
                themeMode,
                ThemeMode.system,
                Icons.settings_system_daydream_outlined,
                'Как в системе',
                'Автоматически следует настройкам системы',
                () => _safeChangeTheme(
                  'system',
                  () => themeNotifier.setSystemTheme(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeData theme,
    ThemeMode currentTheme,
    ThemeMode targetTheme,
    IconData icon,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    final isSelected = currentTheme == targetTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.2)
                    : theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 24),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
