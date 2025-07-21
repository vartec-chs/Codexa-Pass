import 'package:codexa_pass/app/common/widget/title_bar.dart';
import 'router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:go_transitions/go_transitions.dart';
import 'package:universal_platform/universal_platform.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    observers: [GoTransition.observer],
    redirect: (context, state) async {
      return null;

      // final prefs = await SharedPreferences.getInstance();
      // final isFirstRun = prefs.getBool('is_first_run') ?? true;
      // if (isFirstRun) {
      //   await prefs.setBool('is_first_run', false);
      //   return WelcomeScreen.routePath;
      // }
      // return null;
    },
    routes: UniversalPlatform.isDesktop
        ? [
            ShellRoute(
              builder: (context, state, child) {
                return Column(
                  children: [
                    TitleBar(),
                    Expanded(child: child),
                  ],
                );
              },
              routes: routes,
            ),
          ]
        : routes,
  );
});
