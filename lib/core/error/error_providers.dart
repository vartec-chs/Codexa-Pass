import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codexa_pass/core/error/enhanced_app_error.dart';
import 'package:codexa_pass/core/error/error_handler.dart';

/// Провайдер для текущего состояния ошибки
final errorStateProvider = StateProvider<BaseAppError?>((ref) => null);

/// Провайдер для списка последних ошибок
final recentErrorsProvider = StateProvider<List<BaseAppError>>((ref) => []);

/// Провайдер для счетчика критических ошибок
final criticalErrorCountProvider = StateProvider<int>((ref) => 0);

/// Провайдер для флага показа диалогов ошибок
final showErrorDialogsProvider = StateProvider<bool>((ref) => true);

/// Миксин для работы с ошибками в Riverpod
mixin ErrorProviderMixin {
  /// Добавляет ошибку в состояние
  void addError(WidgetRef ref, BaseAppError error) {
    // Устанавливаем текущую ошибку
    ref.read(errorStateProvider.notifier).state = error;

    // Добавляем к последним ошибкам
    final recentErrors = ref.read(recentErrorsProvider);
    final updatedErrors = [error, ...recentErrors].take(10).toList();
    ref.read(recentErrorsProvider.notifier).state = updatedErrors;

    // Увеличиваем счетчик критических ошибок
    if (error.isCritical) {
      ref.read(criticalErrorCountProvider.notifier).state++;
    }
  }

  /// Очищает текущую ошибку
  void clearCurrentError(WidgetRef ref) {
    ref.read(errorStateProvider.notifier).state = null;
  }

  /// Очищает все ошибки
  void clearAllErrors(WidgetRef ref) {
    ref.read(errorStateProvider.notifier).state = null;
    ref.read(recentErrorsProvider.notifier).state = [];
    ref.read(criticalErrorCountProvider.notifier).state = 0;
  }

  /// Обрабатывает ошибку с использованием провайдеров
  void handleErrorWithProvider(WidgetRef ref, BaseAppError error) {
    addError(ref, error);

    // Используем глобальный обработчик ошибок
    GlobalErrorHandler().handleError(error);
  }
}

/// Консьюмер виджет с автоматической обработкой ошибок
abstract class ErrorAwareConsumerWidget extends ConsumerWidget
    with ErrorProviderMixin {
  const ErrorAwareConsumerWidget({super.key});
}

/// Консьюмер StatefulWidget с автоматической обработкой ошибок
abstract class ErrorAwareConsumerStatefulWidget extends ConsumerStatefulWidget
    with ErrorProviderMixin {
  const ErrorAwareConsumerStatefulWidget({super.key});
}

/// Состояние с автоматической обработкой ошибок
abstract class ErrorAwareConsumerState<T extends ConsumerStatefulWidget>
    extends ConsumerState<T>
    with ErrorProviderMixin {
  /// Обрабатывает ошибку в контексте данного состояния
  void handleError(BaseAppError error) {
    handleErrorWithProvider(ref, error);
  }
}

/// Утилиты для работы с ошибками в провайдерах
class ErrorProviderUtils {
  /// Создает провайдер для конвертации ошибок
  static Provider<BaseAppError> createErrorConverter<T>(
    T Function() action,
    BaseAppError Function(dynamic error) converter,
  ) {
    return Provider<BaseAppError>((ref) {
      try {
        action();
        // Если действие выполнилось успешно, возвращаем простую "успешную" ошибку
        return UIError.widgetBuildFailed(
          'SUCCESS',
          'Operation completed successfully',
        );
      } catch (error) {
        return converter(error);
      }
    });
  }

  /// Создает Future провайдер с обработкой ошибок
  static FutureProvider<T> createSafeFutureProvider<T>(
    Future<T> Function() action,
    BaseAppError Function(dynamic error) errorConverter,
  ) {
    return FutureProvider<T>((ref) async {
      try {
        return await action();
      } catch (error) {
        final appError = errorConverter(error);
        ref.read(errorStateProvider.notifier).state = appError;
        throw appError;
      }
    });
  }

  /// Создает Stream провайдер с обработкой ошибок
  static StreamProvider<T> createSafeStreamProvider<T>(
    Stream<T> Function() streamFactory,
    BaseAppError Function(dynamic error) errorConverter,
  ) {
    return StreamProvider<T>((ref) {
      return streamFactory().handleError((error) {
        final appError = errorConverter(error);
        ref.read(errorStateProvider.notifier).state = appError;
        throw appError;
      });
    });
  }
}
