import 'package:codexa_pass/app/theme/theme_provider.dart';
import 'package:codexa_pass/app/theme/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:window_manager/window_manager.dart';

class TitleBar extends ConsumerWidget {
  const TitleBar({super.key});

  final BoxConstraints constraints = const BoxConstraints(
    maxHeight: 40,
    maxWidth: 40,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);
    // final dbNotifier = ref.read(databaseNotifierProvider.notifier);
    // final dbState = ref.read(databaseNotifierProvider);

    final currentTheme = ref.watch(themeProvider);
    final isDark = currentTheme == ThemeMode.dark;
    return DragToMoveArea(
      child: Container(
        height: 40,
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                'ObsidiKey - Password Manager',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  letterSpacing: 0.0,
                  decoration: TextDecoration.none,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textDirection: TextDirection.ltr,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,

                spacing: 2,

                children: [
                  // IconButton(
                  //   icon: Icon(
                  //     isDark ? Icons.light_mode : Icons.dark_mode,
                  //     size: 20,
                  //   ),
                  //   tooltip: isDark ? 'Светлая тема' : 'Темная тема',
                  //   constraints: constraints,
                  //   onPressed: () => themeNotifier.toggleTheme(),
                  // ),
                  ThemeSwitcher(),
                  IconButton(
                    icon: Icon(Icons.remove, size: 20),
                    tooltip: 'Свернуть',
                    constraints: constraints,
                    onPressed: () async => await windowManager.minimize(),
                  ),
                  IconButton(
                    padding: const EdgeInsets.all(6),
                    tooltip: 'Развернуть',
                    constraints: constraints,
                    icon: Icon(Icons.minimize, size: 20),
                    onPressed: () async => await windowManager.maximize(),
                  ),
                  IconButton(
                    padding: const EdgeInsets.all(6),
                    tooltip: 'Закрыть',
                    hoverColor: Colors.red,
                    constraints: constraints,
                    icon: Icon(Icons.close, size: 20),
                    onPressed: () async => {
                      // if (dbState.runtimeType.toString() == '_Connected')
                      // {await dbNotifier.closeDatabase()},
                      await windowManager.close(),
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
