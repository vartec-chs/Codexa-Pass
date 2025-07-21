import '../services/analytics_service.dart';
import '../models/analytics_events.dart';

/// Трекер для отслеживания интерфейса пользователя
class UITracker {
  final AnalyticsService _analyticsService;

  UITracker(this._analyticsService);

  /// Отслеживание просмотра экрана
  Future<void> trackScreenViewed({
    required String screenName,
    String? previousScreen,
    Map<String, String>? screenParameters,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackScreenView(
      screenName: screenName,
      parameters: {
        'previous_screen': previousScreen,
        'screen_parameters': screenParameters,
        'timestamp': DateTime.now().toIso8601String(),
        ...?context,
      },
    );
  }

  /// Отслеживание нажатия кнопки
  Future<void> trackButtonClicked({
    required String buttonName,
    required String screenName,
    String? buttonType,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.userInterface.name,
      eventName: UserInterfaceEvents.buttonClicked,
      parameters: {
        'button_name': buttonName,
        'screen_name': screenName,
        'button_type': buttonType,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание открытия меню
  Future<void> trackMenuOpened({
    required String menuType,
    required String screenName,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.userInterface.name,
      eventName: UserInterfaceEvents.menuOpened,
      parameters: {
        'menu_type': menuType,
        'screen_name': screenName,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание закрытия меню
  Future<void> trackMenuClosed({
    required String menuType,
    required String screenName,
    int? timeOpenMs,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.userInterface.name,
      eventName: UserInterfaceEvents.menuClosed,
      parameters: {
        'menu_type': menuType,
        'screen_name': screenName,
        'time_open_ms': timeOpenMs,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание поиска
  Future<void> trackSearchPerformed({
    required String searchQuery,
    required String searchContext,
    int? resultsCount,
    int? searchTimeMs,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.userInterface.name,
      eventName: UserInterfaceEvents.searchPerformed,
      parameters: {
        'search_query_length': searchQuery.length,
        'search_context': searchContext,
        'results_count': resultsCount,
        'search_time_ms': searchTimeMs,
        'has_results': (resultsCount ?? 0) > 0,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание применения фильтра
  Future<void> trackFilterApplied({
    required String filterType,
    required String filterValue,
    required String screenName,
    int? resultsCount,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.userInterface.name,
      eventName: UserInterfaceEvents.filterApplied,
      parameters: {
        'filter_type': filterType,
        'filter_value': filterValue,
        'screen_name': screenName,
        'results_count': resultsCount,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание применения сортировки
  Future<void> trackSortApplied({
    required String sortField,
    required String sortOrder,
    required String screenName,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.userInterface.name,
      eventName: UserInterfaceEvents.sortApplied,
      parameters: {
        'sort_field': sortField,
        'sort_order': sortOrder,
        'screen_name': screenName,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание смены темы
  Future<void> trackThemeChanged({
    required String oldTheme,
    required String newTheme,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.userInterface.name,
      eventName: UserInterfaceEvents.themeChanged,
      parameters: {
        'old_theme': oldTheme,
        'new_theme': newTheme,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание смены языка
  Future<void> trackLanguageChanged({
    required String oldLanguage,
    required String newLanguage,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.userInterface.name,
      eventName: UserInterfaceEvents.languageChanged,
      parameters: {
        'old_language': oldLanguage,
        'new_language': newLanguage,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание начала онбординга
  Future<void> trackOnboardingStarted({
    String? version,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.userInterface.name,
      eventName: UserInterfaceEvents.onboardingStarted,
      parameters: {
        'onboarding_version': version,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание завершения онбординга
  Future<void> trackOnboardingCompleted({
    String? version,
    int? durationMs,
    int? stepsCompleted,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.userInterface.name,
      eventName: UserInterfaceEvents.onboardingCompleted,
      parameters: {
        'onboarding_version': version,
        'duration_ms': durationMs,
        'steps_completed': stepsCompleted,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание пропуска онбординга
  Future<void> trackOnboardingSkipped({
    String? version,
    int? stepSkipped,
    String? skipReason,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.userInterface.name,
      eventName: UserInterfaceEvents.onboardingSkipped,
      parameters: {
        'onboarding_version': version,
        'step_skipped': stepSkipped,
        'skip_reason': skipReason,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание начала обучения
  Future<void> trackTutorialStarted({
    required String tutorialName,
    String? triggerSource,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.userInterface.name,
      eventName: UserInterfaceEvents.tutorialStarted,
      parameters: {
        'tutorial_name': tutorialName,
        'trigger_source': triggerSource,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание завершения обучения
  Future<void> trackTutorialCompleted({
    required String tutorialName,
    int? durationMs,
    bool? isCompleted,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.userInterface.name,
      eventName: UserInterfaceEvents.tutorialCompleted,
      parameters: {
        'tutorial_name': tutorialName,
        'duration_ms': durationMs,
        'is_completed': isCompleted ?? true,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание запроса помощи
  Future<void> trackHelpRequested({
    required String helpTopic,
    required String screenName,
    String? helpType,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.userInterface.name,
      eventName: UserInterfaceEvents.helpRequested,
      parameters: {
        'help_topic': helpTopic,
        'screen_name': screenName,
        'help_type': helpType ?? 'in_app',
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание использования ярлыков/горячих клавиш
  Future<void> trackShortcutUsed({
    required String shortcut,
    required String action,
    required String screenName,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.userInterface.name,
      eventName: 'shortcut_used',
      parameters: {
        'shortcut': shortcut,
        'action': action,
        'screen_name': screenName,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание жестов
  Future<void> trackGestureUsed({
    required String gestureType,
    required String action,
    required String screenName,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.userInterface.name,
      eventName: 'gesture_used',
      parameters: {
        'gesture_type': gestureType,
        'action': action,
        'screen_name': screenName,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание взаимодействия с диалогами
  Future<void> trackDialogInteraction({
    required String dialogType,
    required String action,
    String? dialogResult,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.userInterface.name,
      eventName: 'dialog_interaction',
      parameters: {
        'dialog_type': dialogType,
        'action': action,
        'dialog_result': dialogResult,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание использования виджетов
  Future<void> trackWidgetInteraction({
    required String widgetType,
    required String action,
    required String screenName,
    Map<String, dynamic>? widgetData,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.userInterface.name,
      eventName: 'widget_interaction',
      parameters: {
        'widget_type': widgetType,
        'action': action,
        'screen_name': screenName,
        'widget_data': widgetData,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание ошибок UI
  Future<void> trackUIError({
    required String errorType,
    required String screenName,
    String? errorMessage,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackError(
      errorType: errorType,
      errorMessage: errorMessage ?? 'UI Error',
      additionalData: {
        'screen_name': screenName,
        'error_category': 'ui',
        'timestamp': DateTime.now().toIso8601String(),
        ...?context,
      },
    );
  }
}
