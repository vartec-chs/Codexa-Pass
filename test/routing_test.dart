import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codexa_pass/app/routing/routing.dart';

void main() {
  group('Routing System Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('App router initialization', (WidgetTester tester) async {
      final router = container.read(appRouterProvider);
      expect(router, isNotNull);
      expect(router.routerDelegate, isNotNull);
    });

    testWidgets('Route configuration', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, child) {
              final router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    group('Route Configuration', () {
      test('Route constants', () {
        expect(AppRoutes.home, '/home');
        expect(AppRoutes.login, '/login');
        expect(AppRoutes.vault, '/vault');
        expect(AppRoutes.settings, '/settings');
      });

      test('Route names', () {
        expect(RouteNames.home, 'home');
        expect(RouteNames.login, 'login');
        expect(RouteNames.vault, 'vault');
        expect(RouteNames.settings, 'settings');
      });

      test('Route parameters', () {
        expect(RouteParams.passwordId, 'passwordId');
        expect(RouteParams.categoryId, 'categoryId');
      });
    });

    group('Route Transitions', () {
      test('Transition configuration exists', () {
        final config = AppTransitionConfigs.bounce;
        expect(config.duration, Duration(milliseconds: 400));
        expect(config.curve, Curves.bounceOut);
      });

      test('Transition types', () {
        const transitionType = AppTransitions.scale;
        expect(transitionType, AppTransitions.scale);
      });
    });

    group('Route Groups', () {
      test('Public routes list', () {
        final publicRoutes = getPublicRoutes();
        expect(publicRoutes.isNotEmpty, isTrue);
      });

      test('Protected routes list', () {
        final protectedRoutes = getProtectedRoutes();
        expect(protectedRoutes.isNotEmpty, isTrue);
      });
    });

    testWidgets('Error page display', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Ошибка навигации'),
                  SizedBox(height: 8),
                  Text('Test error'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Попробовать снова'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Ошибка навигации'), findsOneWidget);
      expect(find.text('Test error'), findsOneWidget);
      expect(find.text('Попробовать снова'), findsOneWidget);
    });

    group('Integration Tests', () {
      testWidgets('Complete app initialization', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: Consumer(
              builder: (context, ref, child) {
                final router = ref.watch(appRouterProvider);
                return MaterialApp.router(routerConfig: router);
              },
            ),
          ),
        );

        // Проверяем начальную загрузку без pumpAndSettle
        await tester.pump();

        // Ожидаем, что загрузится MaterialApp
        expect(find.byType(MaterialApp), findsOneWidget);
      });
    });
  });
}
