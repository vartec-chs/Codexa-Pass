import '../services/analytics_service.dart';
import '../models/analytics_events.dart';

/// Трекер для отслеживания управления паролями
class PasswordTracker {
  final AnalyticsService _analyticsService;

  PasswordTracker(this._analyticsService);

  /// Отслеживание создания пароля
  Future<void> trackPasswordCreated({
    String? category,
    String? passwordStrength,
    bool? isGenerated,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.passwordManagement.name,
      eventName: PasswordManagementEvents.passwordCreated,
      parameters: {
        'category': category,
        'password_strength': passwordStrength,
        'is_generated': isGenerated ?? false,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание просмотра пароля
  Future<void> trackPasswordViewed({
    String? category,
    String? source,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.passwordManagement.name,
      eventName: PasswordManagementEvents.passwordViewed,
      parameters: {
        'category': category,
        'source': source ?? 'list',
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание копирования пароля
  Future<void> trackPasswordCopied({
    String? category,
    String? copyType,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.passwordManagement.name,
      eventName: PasswordManagementEvents.passwordCopied,
      parameters: {
        'category': category,
        'copy_type': copyType ?? 'password',
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание редактирования пароля
  Future<void> trackPasswordEdited({
    String? category,
    List<String>? changedFields,
    String? editReason,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.passwordManagement.name,
      eventName: PasswordManagementEvents.passwordEdited,
      parameters: {
        'category': category,
        'changed_fields': changedFields,
        'edit_reason': editReason,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание удаления пароля
  Future<void> trackPasswordDeleted({
    String? category,
    String? deleteReason,
    bool? isBulkDelete,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.passwordManagement.name,
      eventName: PasswordManagementEvents.passwordDeleted,
      parameters: {
        'category': category,
        'delete_reason': deleteReason ?? 'user_action',
        'is_bulk_delete': isBulkDelete ?? false,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание генерации пароля
  Future<void> trackPasswordGenerated({
    int? length,
    bool? includeUppercase,
    bool? includeLowercase,
    bool? includeNumbers,
    bool? includeSymbols,
    String? strengthLevel,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.passwordManagement.name,
      eventName: PasswordManagementEvents.passwordGenerated,
      parameters: {
        'length': length,
        'include_uppercase': includeUppercase,
        'include_lowercase': includeLowercase,
        'include_numbers': includeNumbers,
        'include_symbols': includeSymbols,
        'strength_level': strengthLevel,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание проверки силы пароля
  Future<void> trackPasswordStrengthChecked({
    required String strengthLevel,
    int? score,
    List<String>? weaknesses,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.passwordManagement.name,
      eventName: PasswordManagementEvents.passwordStrengthChecked,
      parameters: {
        'strength_level': strengthLevel,
        'score': score,
        'weaknesses': weaknesses,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание поиска паролей
  Future<void> trackPasswordSearched({
    required String searchQuery,
    int? resultsCount,
    String? searchType,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.passwordManagement.name,
      eventName: PasswordManagementEvents.passwordSearched,
      parameters: {
        'search_query_length': searchQuery.length,
        'results_count': resultsCount,
        'search_type': searchType ?? 'simple',
        'has_results': (resultsCount ?? 0) > 0,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание фильтрации паролей
  Future<void> trackPasswordFiltered({
    required String filterType,
    String? filterValue,
    int? resultsCount,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.passwordManagement.name,
      eventName: PasswordManagementEvents.passwordFiltered,
      parameters: {
        'filter_type': filterType,
        'filter_value': filterValue,
        'results_count': resultsCount,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание сортировки паролей
  Future<void> trackPasswordSorted({
    required String sortBy,
    required String sortOrder,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.passwordManagement.name,
      eventName: PasswordManagementEvents.passwordSorted,
      parameters: {
        'sort_by': sortBy,
        'sort_order': sortOrder,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание категоризации пароля
  Future<void> trackPasswordCategorized({
    required String oldCategory,
    required String newCategory,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.passwordManagement.name,
      eventName: PasswordManagementEvents.passwordCategorized,
      parameters: {
        'old_category': oldCategory,
        'new_category': newCategory,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание добавления тегов к паролю
  Future<void> trackPasswordTagged({
    required List<String> tags,
    String? action,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.passwordManagement.name,
      eventName: PasswordManagementEvents.passwordTagged,
      parameters: {
        'tags': tags,
        'tags_count': tags.length,
        'action': action ?? 'add',
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание добавления в избранное
  Future<void> trackPasswordFavorited({
    String? category,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.passwordManagement.name,
      eventName: PasswordManagementEvents.passwordFavorited,
      parameters: {
        'category': category,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание удаления из избранного
  Future<void> trackPasswordUnfavorited({
    String? category,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.passwordManagement.name,
      eventName: PasswordManagementEvents.passwordUnfavorited,
      parameters: {
        'category': category,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание массовых операций с паролями
  Future<void> trackBulkPasswordOperation({
    required String operationType,
    required int affectedCount,
    String? criteria,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.passwordManagement.name,
      eventName: PasswordManagementEvents.bulkPasswordOperation,
      parameters: {
        'operation_type': operationType,
        'affected_count': affectedCount,
        'criteria': criteria,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание автозаполнения пароля
  Future<void> trackPasswordAutofill({
    String? domain,
    String? appName,
    bool? isSuccessful,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.passwordManagement.name,
      eventName: 'password_autofilled',
      parameters: {
        'domain': domain,
        'app_name': appName,
        'is_successful': isSuccessful ?? true,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание импорта паролей
  Future<void> trackPasswordImport({
    required String source,
    required int importedCount,
    int? duplicatesFound,
    int? errorsCount,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.passwordManagement.name,
      eventName: 'passwords_imported',
      parameters: {
        'source': source,
        'imported_count': importedCount,
        'duplicates_found': duplicatesFound ?? 0,
        'errors_count': errorsCount ?? 0,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание экспорта паролей
  Future<void> trackPasswordExport({
    required String format,
    required int exportedCount,
    bool? isEncrypted,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.passwordManagement.name,
      eventName: 'passwords_exported',
      parameters: {
        'format': format,
        'exported_count': exportedCount,
        'is_encrypted': isEncrypted ?? false,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }
}
