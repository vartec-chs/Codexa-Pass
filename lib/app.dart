import 'package:codexa_pass/app/routing/routes.dart';
import 'package:codexa_pass/app/theme/colors/colors_base.dart';
import 'package:codexa_pass/app/theme/theme.dart';
import 'package:codexa_pass/app/theme/theme_provider.dart';
import 'package:codexa_pass/core/config/constants.dart';
import 'package:codexa_pass/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';

class WrapperApp extends ConsumerWidget {
  const WrapperApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        final theme = Theme.of(context);
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.dark,
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: theme.colorScheme.surface,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: child!,
        );
      },
    );
  }
}
