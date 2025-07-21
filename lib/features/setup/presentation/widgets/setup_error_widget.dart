import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:codexa_pass/core/error/error_system.dart';
import 'package:codexa_pass/features/setup/domain/errors/setup_errors.dart';
import 'package:codexa_pass/features/setup/domain/services/setup_error_service.dart';

/// Виджет для отображения ошибок setup экрана
class SetupErrorWidget extends ConsumerWidget {
  const SetupErrorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupErrors = ref.watch(setupErrorsProvider);

    if (setupErrors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Обнаружены проблемы',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ...setupErrors
              .take(3)
              .map((error) => _buildErrorItem(context, error, ref)),

          if (setupErrors.length > 3) ...[
            const SizedBox(height: 8),
            Text(
              'И еще ${setupErrors.length - 3} ошибок...',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.onErrorContainer.withOpacity(0.7),
              ),
            ),
          ],

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _clearErrors(ref),
                child: Text(
                  'Очистить',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorItem(
    BuildContext context,
    SetupError error,
    WidgetRef ref,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _getErrorIcon(error.severity),
            size: 16,
            color: Theme.of(context).colorScheme.error,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  error.userFriendlyMessage,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),

                if (error.canRetryOperation) ...[
                  const SizedBox(height: 4),

                  InkWell(
                    onTap: () => _retryError(error, ref),
                    child: Text(
                      'Повторить попытку',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.error,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getErrorIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Icons.info_outline;
      case ErrorSeverity.warning:
        return Icons.warning_amber_outlined;
      case ErrorSeverity.error:
        return Icons.error_outline;
      case ErrorSeverity.critical:
        return Icons.dangerous_outlined;
      case ErrorSeverity.fatal:
        return Icons.report_problem_outlined;
    }
  }

  void _clearErrors(WidgetRef ref) {
    final errorService = ref.read(setupErrorServiceProvider);
    errorService.clearErrors();
  }

  void _retryError(SetupError error, WidgetRef ref) {
    // Здесь можно добавить логику повтора для конкретного типа ошибки
    switch (error.runtimeType) {
      case SetupPreferencesError:
        // Повтор сохранения настроек
        break;
      case SetupThemeError:
        // Повтор смены темы
        break;
      case SetupNavigationError:
        // Повтор навигации
        break;
      default:
        break;
    }
  }
}

/// Виджет для отображения статистики ошибок setup экрана
class SetupErrorStatsWidget extends ConsumerWidget {
  const SetupErrorStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupErrors = ref.watch(setupErrorsProvider);

    if (setupErrors.isEmpty) {
      return const SizedBox.shrink();
    }

    final errorStats = <ErrorSeverity, int>{};
    for (final error in setupErrors) {
      errorStats[error.severity] = (errorStats[error.severity] ?? 0) + 1;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Статистика ошибок',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 8),

          ...errorStats.entries.map(
            (entry) => _buildStatItem(context, entry.key, entry.value),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    ErrorSeverity severity,
    int count,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            _getErrorIcon(severity),
            size: 14,
            color: _getErrorColor(severity, context),
          ),

          const SizedBox(width: 6),

          Text(
            '${severity.name}: $count',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getErrorIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Icons.info_outline;
      case ErrorSeverity.warning:
        return Icons.warning_amber_outlined;
      case ErrorSeverity.error:
        return Icons.error_outline;
      case ErrorSeverity.critical:
        return Icons.dangerous_outlined;
      case ErrorSeverity.fatal:
        return Icons.report_problem_outlined;
    }
  }

  Color _getErrorColor(ErrorSeverity severity, BuildContext context) {
    switch (severity) {
      case ErrorSeverity.info:
        return Colors.blue;
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.error:
        return Theme.of(context).colorScheme.error;
      case ErrorSeverity.critical:
        return Colors.red.shade700;
      case ErrorSeverity.fatal:
        return Colors.red.shade900;
    }
  }
}
