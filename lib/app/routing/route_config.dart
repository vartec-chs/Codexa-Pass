/// Константы для маршрутов приложения
class AppRoutes {
  // Публичные маршруты (без аутентификации)
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Защищенные маршруты (требуют аутентификации)
  static const String home = '/home';
  static const String vault = '/vault';
  static const String addPassword = '/add-password';
  static const String editPassword = '/edit-password';
  static const String passwordDetails = '/password-details';
  static const String history = '/history';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String security = '/security';
  static const String backup = '/backup';
  static const String about = '/about';

  // Дополнительные маршруты
  static const String search = '/search';
  static const String categories = '/categories';
  static const String generator = '/generator';
  static const String analytics = '/analytics';
}

/// Имена маршрутов для навигации
class RouteNames {
  // Публичные маршруты
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';
  static const String resetPassword = 'reset-password';

  // Защищенные маршруты
  static const String home = 'home';
  static const String vault = 'vault';
  static const String addPassword = 'add-password';
  static const String editPassword = 'edit-password';
  static const String passwordDetails = 'password-details';
  static const String history = 'history';
  static const String settings = 'settings';
  static const String profile = 'profile';
  static const String security = 'security';
  static const String backup = 'backup';
  static const String about = 'about';

  // Дополнительные маршруты
  static const String search = 'search';
  static const String categories = 'categories';
  static const String generator = 'generator';
  static const String analytics = 'analytics';
}

/// Параметры маршрутов
class RouteParams {
  static const String passwordId = 'passwordId';
  static const String categoryId = 'categoryId';
  static const String userId = 'userId';
  static const String token = 'token';
  static const String email = 'email';
}

/// Параметры запроса
class QueryParams {
  static const String returnUrl = 'return_url';
  static const String category = 'category';
  static const String search = 'search';
  static const String filter = 'filter';
  static const String sort = 'sort';
  static const String page = 'page';
  static const String limit = 'limit';
}

/// Конфигурация маршрутов для разных разделов приложения
class RouteConfig {
  /// Публичные маршруты (доступны без аутентификации)
  static const List<String> publicRoutes = [
    AppRoutes.splash,
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.forgotPassword,
    AppRoutes.resetPassword,
  ];

  /// Защищенные маршруты (требуют аутентификации)
  static const List<String> protectedRoutes = [
    AppRoutes.home,
    AppRoutes.vault,
    AppRoutes.addPassword,
    AppRoutes.editPassword,
    AppRoutes.passwordDetails,
    AppRoutes.history,
    AppRoutes.settings,
    AppRoutes.profile,
    AppRoutes.security,
    AppRoutes.backup,
    AppRoutes.about,
    AppRoutes.search,
    AppRoutes.categories,
    AppRoutes.generator,
    AppRoutes.analytics,
  ];

  /// Маршруты главного меню (отображаются в нижней навигации)
  static const List<String> mainMenuRoutes = [
    AppRoutes.home,
    AppRoutes.vault,
    AppRoutes.addPassword,
    AppRoutes.history,
    AppRoutes.settings,
  ];

  /// Маршруты настроек
  static const List<String> settingsRoutes = [
    AppRoutes.settings,
    AppRoutes.profile,
    AppRoutes.security,
    AppRoutes.backup,
    AppRoutes.about,
  ];

  /// Проверка, является ли маршрут публичным
  static bool isPublicRoute(String route) {
    return publicRoutes.contains(route);
  }

  /// Проверка, является ли маршрут защищенным
  static bool isProtectedRoute(String route) {
    return protectedRoutes.contains(route);
  }

  /// Проверка, является ли маршрут частью главного меню
  static bool isMainMenuRoute(String route) {
    return mainMenuRoutes.any((menuRoute) => route.startsWith(menuRoute));
  }

  /// Получение начального маршрута в зависимости от состояния аутентификации
  static String getInitialRoute({required bool isAuthenticated}) {
    return isAuthenticated ? AppRoutes.home : AppRoutes.splash;
  }

  /// Получение маршрута по умолчанию для аутентифицированных пользователей
  static String getDefaultAuthenticatedRoute() {
    return AppRoutes.home;
  }

  /// Получение маршрута по умолчанию для неаутентифицированных пользователей
  static String getDefaultUnauthenticatedRoute() {
    return AppRoutes.login;
  }
}
