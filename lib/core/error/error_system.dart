// Основные модели
export 'models/app_error.dart';
export 'models/error_severity.dart';
export 'models/error_display_type.dart';
export 'models/result.dart';

// Утилиты
export 'utils/error_config.dart';
export 'utils/error_formatter.dart';
export 'utils/error_deduplicator.dart';

// Контроллеры
export 'controllers/error_controller.dart';
export 'controllers/error_queue_controller.dart';

// Обработчики
export 'handlers/error_handler.dart';
export 'handlers/error_recovery_handler.dart';
export 'handlers/error_analytics_handler.dart';

// UI компоненты
export 'ui/error_boundary.dart';
export 'ui/error_widgets/error_display_widget.dart';
export 'ui/error_dialogs/error_dialogs.dart';
export 'ui/demo/error_demo_page.dart';

// Расширения
export 'extensions/result_extensions.dart';
