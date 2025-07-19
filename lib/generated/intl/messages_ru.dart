// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ru';

  static String m0(error) => "Ошибка удаления старого лог-файла: ${error}";

  static String m1(error) => "Ошибка инициализации файла логов: ${error}";

  static String m2(error) => "Ошибка ротации логов: ${error}";

  static String m3(error) => "Ошибка записи в лог-файл: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "logAllFilesCleared": MessageLookupByLibrary.simpleMessage(
      "Все лог-файлы очищены",
    ),
    "logErrorClearingFiles": MessageLookupByLibrary.simpleMessage(
      "Ошибка очистки лог-файлов",
    ),
    "logErrorDeletingOldFile": m0,
    "logErrorGettingDirectory": MessageLookupByLibrary.simpleMessage(
      "Ошибка получения директории логов",
    ),
    "logErrorGettingFileList": MessageLookupByLibrary.simpleMessage(
      "Ошибка получения списка лог-файлов",
    ),
    "logErrorInitFile": m1,
    "logErrorRotation": m2,
    "logErrorWritingToFile": m3,
  };
}
