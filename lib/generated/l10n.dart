// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Error initializing log file: {error}`
  String logErrorInitFile(String error) {
    return Intl.message(
      'Error initializing log file: $error',
      name: 'logErrorInitFile',
      desc: 'Error message when log file initialization fails',
      args: [error],
    );
  }

  /// `Error rotating logs: {error}`
  String logErrorRotation(String error) {
    return Intl.message(
      'Error rotating logs: $error',
      name: 'logErrorRotation',
      desc: 'Error message when log rotation fails',
      args: [error],
    );
  }

  /// `Error deleting old log file: {error}`
  String logErrorDeletingOldFile(String error) {
    return Intl.message(
      'Error deleting old log file: $error',
      name: 'logErrorDeletingOldFile',
      desc: 'Error message when deleting old log file fails',
      args: [error],
    );
  }

  /// `Error writing to log file: {error}`
  String logErrorWritingToFile(String error) {
    return Intl.message(
      'Error writing to log file: $error',
      name: 'logErrorWritingToFile',
      desc: 'Error message when writing to log file fails',
      args: [error],
    );
  }

  /// `Error getting log directory`
  String get logErrorGettingDirectory {
    return Intl.message(
      'Error getting log directory',
      name: 'logErrorGettingDirectory',
      desc: 'Error message when getting log directory fails',
      args: [],
    );
  }

  /// `Error getting log file list`
  String get logErrorGettingFileList {
    return Intl.message(
      'Error getting log file list',
      name: 'logErrorGettingFileList',
      desc: 'Error message when getting log file list fails',
      args: [],
    );
  }

  /// `All log files cleared`
  String get logAllFilesCleared {
    return Intl.message(
      'All log files cleared',
      name: 'logAllFilesCleared',
      desc: 'Message when all log files are cleared',
      args: [],
    );
  }

  /// `Error clearing log files`
  String get logErrorClearingFiles {
    return Intl.message(
      'Error clearing log files',
      name: 'logErrorClearingFiles',
      desc: 'Error message when clearing log files fails',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
