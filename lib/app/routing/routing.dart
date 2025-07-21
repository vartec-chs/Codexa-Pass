// Основной экспорт файл для системы роутинга Codexa Pass
// Использование: import 'package:codexa_pass/app/routing/routing.dart';

// Основная конфигурация роутера
export 'app_router.dart';

// Конфигурация маршрутов и константы
export 'route_config.dart';

// Система защиты маршрутов
export 'route_guards.dart';

// Анимации и переходы
export 'route_transitions.dart';

// Определения маршрутов по модулям
export 'routes/auth_routes.dart';
export 'routes/home_routes.dart';
export 'routes/vault_routes.dart';
export 'routes/settings_routes.dart';

// Зависимости для работы с роутингом
export 'package:go_router/go_router.dart';
export 'package:flutter_riverpod/flutter_riverpod.dart';
