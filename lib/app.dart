import 'package:codexa_pass/app/theme/colors/colors_base.dart';
import 'package:codexa_pass/app/theme/theme.dart';
import 'package:codexa_pass/app/routing/routing.dart';
import 'package:codexa_pass/generated/l10n.dart';
import 'package:codexa_pass/core/logging/logging.dart';
import 'package:codexa_pass/core/error/error_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';

/// WrapperApp - основная обертка приложения с инициализацией всех систем
class WrapperApp extends ConsumerStatefulWidget {
  final ProviderContainer container;

  const WrapperApp({super.key, required this.container});

  @override
  ConsumerState<WrapperApp> createState() => _WrapperAppState();
}

class _WrapperAppState extends ConsumerState<WrapperApp>
    with WidgetsBindingObserver {
  bool _systemsInitialized = false;
  String? _initializationError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeSystems();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_systemsInitialized) {
      AppLifecycleLogger.logStateChange(state);
    }
  }

  /// Инициализация всех систем приложения
  Future<void> _initializeSystems() async {
    try {
      // Инициализируем систему аналитики
      await _initializeAnalytics();

      // Логируем успешную инициализацию
      await AppLogger.instance.info(
        'All app systems initialized successfully',
        logger: 'WrapperApp',
        metadata: {
          'timestamp': DateTime.now().toIso8601String(),
          'platform': Theme.of(context).platform.name,
        },
      );

      if (mounted) {
        setState(() {
          _systemsInitialized = true;
        });
      }
    } catch (e, stackTrace) {
      await AppLogger.instance.error(
        'Failed to initialize app systems',
        error: e,
        stackTrace: stackTrace,
        logger: 'WrapperApp',
      );

      if (mounted) {
        setState(() {
          _initializationError = e.toString();
        });
      }
    }
  }

  /// Инициализация системы аналитики
  Future<void> _initializeAnalytics() async {
    try {
      // Пока что просто логируем, что аналитика будет инициализирована
      await AppLogger.instance.info(
        'Analytics system ready for initialization',
        logger: 'WrapperApp',
      );
    } catch (e, stackTrace) {
      await AppLogger.instance.error(
        'Failed to initialize analytics',
        error: e,
        stackTrace: stackTrace,
        logger: 'WrapperApp',
      );
      // Аналитика не критична, продолжаем работу
    }
  }

  @override
  Widget build(BuildContext context) {
    // Показываем экран загрузки пока системы не инициализированы
    if (!_systemsInitialized) {
      return _buildLoadingScreen();
    }

    // Показываем экран ошибки если инициализация не удалась
    if (_initializationError != null) {
      return _buildErrorScreen();
    }

    // Основной интерфейс приложения
    return GlobalLoaderOverlay(
      duration: Durations.medium4,
      reverseDuration: Durations.medium4,
      overlayColor: Colors.black.withValues(alpha: 0.8),
      overlayWidgetBuilder: (_) {
        return Center(
          child: SpinKitCubeGrid(color: ColorsBase.primary, size: 50),
        );
      },
      child: Builder(
        builder: (context) {
          return const App();
        },
      ),
    );
  }

  /// Экран загрузки при инициализации
  Widget _buildLoadingScreen() {
    return MaterialApp(
      title: 'Codexa Pass',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: Scaffold(
        backgroundColor: ColorsBase.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpinKitCubeGrid(color: Colors.white, size: 80),
              const SizedBox(height: 32),
              const Text(
                'Codexa Pass',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Инициализация систем...',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Экран ошибки инициализации
  Widget _buildErrorScreen() {
    return MaterialApp(
      title: 'Codexa Pass',
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                const Text(
                  'Ошибка инициализации',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  _initializationError ?? 'Неизвестная ошибка',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _systemsInitialized = false;
                      _initializationError = null;
                    });
                    _initializeSystems();
                  },
                  child: const Text('Попробовать снова'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// App - основное приложение с роутингом и локализацией
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Codexa Pass',

      // Локализация
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,

      // Темы
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Роутинг
      routerConfig: router,

      // Настройки
      debugShowCheckedModeBanner: false,

      // Builders для обработки ошибок
      builder: (context, child) {
        return ErrorBoundary(
          onError: (error) {
            // Синхронное логирование без await
            AppLogger.instance.error(
              'App-level error occurred',
              error: error,
              logger: 'App',
            );
          },
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
