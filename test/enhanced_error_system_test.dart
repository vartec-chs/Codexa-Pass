import 'package:flutter_test/flutter_test.dart';
import 'package:codexa_pass/core/error/enhanced_error_system.dart';
import 'package:codexa_pass/core/logging/logging.dart';

void main() {
  group('Enhanced Error System Tests', () {
    group('BaseAppError', () {
      test('should create error with required fields', () {
        final error = ValidationError.required('email');

        expect(error.code, 'validation_required');
        expect(error.message, 'Поле "email" обязательно для заполнения');
        expect(error.category, ErrorCategory.validation);
        expect(error.isCritical, false);
        expect(error.shouldCreateCrashReport, false);
      });

      test('should create critical error', () {
        final error = SecurityError.unauthorizedAccess();

        expect(error.isCritical, true);
        expect(error.shouldCreateCrashReport, true);
        expect(error.crashReportType, CrashType.fatal);
      });

      test('should convert to JSON', () {
        final error = NetworkError.serverError(500, 'Internal error');
        final json = error.toJson();

        expect(json['code'], 'net_server_error');
        expect(json['message'], 'Ошибка сервера (500)');
        expect(json['category'], 'network');
        expect(json['isCritical'], true);
        expect(json['context'], {'statusCode': 500});
      });
    });

    group('Result<T>', () {
      test('Success should work correctly', () {
        final result = Success<String>('test value');

        expect(result.isSuccess, true);
        expect(result.isFailure, false);
        expect(result.value, 'test value');
        expect(result.error, null);
      });

      test('Failure should work correctly', () {
        final error = ValidationError.required('field');
        final result = Failure<String>(error);

        expect(result.isSuccess, false);
        expect(result.isFailure, true);
        expect(result.value, null);
        expect(result.error, error);
      });

      test('fold should work correctly', () {
        final successResult = Success<int>(42);
        final failureResult = Failure<int>(ValidationError.required('test'));

        final successValue = successResult.fold(
          (value) => 'Success: $value',
          (error) => 'Error: ${error.message}',
        );

        final failureValue = failureResult.fold(
          (value) => 'Success: $value',
          (error) => 'Error: ${error.message}',
        );

        expect(successValue, 'Success: 42');
        expect(failureValue, 'Error: Поле "test" обязательно для заполнения');
      });

      test('map should transform success value', () {
        final result = Success<int>(5);
        final mapped = result.map((value) => value * 2);

        expect(mapped.isSuccess, true);
        expect(mapped.value, 10);
      });

      test('map should preserve failure', () {
        final error = ValidationError.required('test');
        final result = Failure<int>(error);
        final mapped = result.map((value) => value * 2);

        expect(mapped.isFailure, true);
        expect(mapped.error, error);
      });

      test('flatMap should work correctly', () {
        final result = Success<int>(5);
        final chained = result.flatMap(
          (value) => value > 0
              ? Success<String>('positive')
              : Failure<String>(ValidationError.required('positive')),
        );

        expect(chained.isSuccess, true);
        expect(chained.value, 'positive');
      });

      test('where should filter correctly', () {
        final result = Success<int>(5);
        final error = ValidationError.required('positive');

        final validResult = result.where((value) => value > 0, error);
        final invalidResult = result.where((value) => value < 0, error);

        expect(validResult.isSuccess, true);
        expect(invalidResult.isFailure, true);
        expect(invalidResult.error, error);
      });

      test('recover should work correctly', () {
        final error = ValidationError.required('test');
        final result = Failure<String>(error);
        final recovered = result.recover((error) => 'default value');

        expect(recovered.isSuccess, true);
        expect(recovered.value, 'default value');
      });

      test('getOrElse should return default for failure', () {
        final successResult = Success<String>('value');
        final failureResult = Failure<String>(ValidationError.required('test'));

        expect(successResult.getOrElse('default'), 'value');
        expect(failureResult.getOrElse('default'), 'default');
      });

      test('orThrow should throw error for failure', () {
        final error = ValidationError.required('test');
        final result = Failure<String>(error);

        expect(() => result.orThrow(), throwsA(error));
      });
    });

    group('ErrorHandler', () {
      test('safe should catch exceptions', () {
        final result = ErrorHandler.safe(
          () => int.parse('invalid'),
          errorCode: 'parse_error',
          category: ErrorCategory.validation,
        );

        expect(result.isFailure, true);
        expect(result.error!.category, ErrorCategory.validation);
      });

      test('safe should return success for valid operations', () {
        final result = ErrorHandler.safe(
          () => int.parse('123'),
          category: ErrorCategory.validation,
        );

        expect(result.isSuccess, true);
        expect(result.value, 123);
      });

      test('safeAsync should work with async operations', () async {
        final result = await ErrorHandler.safeAsync(() async {
          await Future.delayed(Duration(milliseconds: 10));
          return 'async result';
        }, category: ErrorCategory.network);

        expect(result.isSuccess, true);
        expect(result.value, 'async result');
      });

      test('safeAsync should catch async exceptions', () async {
        final result = await ErrorHandler.safeAsync(() async {
          await Future.delayed(Duration(milliseconds: 10));
          throw Exception('async error');
        }, category: ErrorCategory.network);

        expect(result.isFailure, true);
        expect(result.error!.category, ErrorCategory.network);
      });

      test('safeAsyncWithTimeout should timeout', () async {
        final result = await ErrorHandler.safeAsyncWithTimeout(
          () async {
            await Future.delayed(Duration(seconds: 2));
            return 'result';
          },
          Duration(milliseconds: 100),
          category: ErrorCategory.network,
        );

        expect(result.isFailure, true);
        expect(result.error, isA<NetworkError>());
        expect(result.error!.code, 'net_timeout');
      });

      test('retry should work correctly', () async {
        int attempts = 0;

        final result = await ErrorHandler.retry(
          () async {
            attempts++;
            if (attempts < 3) {
              return Failure(NetworkError.timeout());
            }
            return Success('success after retry');
          },
          maxAttempts: 3,
          delay: Duration(milliseconds: 10),
        );

        expect(result.isSuccess, true);
        expect(result.value, 'success after retry');
        expect(attempts, 3);
      });

      test('retry should fail after max attempts', () async {
        int attempts = 0;

        final result = await ErrorHandler.retry(
          () async {
            attempts++;
            return Failure(NetworkError.timeout());
          },
          maxAttempts: 2,
          delay: Duration(milliseconds: 10),
        );

        expect(result.isFailure, true);
        expect(attempts, 2);
      });

      test('retry should respect retryIf condition', () async {
        int attempts = 0;

        final result = await ErrorHandler.retry(
          () async {
            attempts++;
            return Failure(ValidationError.required('test'));
          },
          maxAttempts: 3,
          delay: Duration(milliseconds: 10),
          retryIf: (error) => error.category == ErrorCategory.network,
        );

        expect(result.isFailure, true);
        expect(attempts, 1); // Should not retry validation errors
      });
    });

    group('Error Categories', () {
      test('should have correct prefixes', () {
        expect(ErrorCategory.authentication.prefix, 'auth');
        expect(ErrorCategory.encryption.prefix, 'crypto');
        expect(ErrorCategory.database.prefix, 'db');
        expect(ErrorCategory.network.prefix, 'net');
        expect(ErrorCategory.validation.prefix, 'validation');
        expect(ErrorCategory.storage.prefix, 'storage');
        expect(ErrorCategory.security.prefix, 'security');
        expect(ErrorCategory.system.prefix, 'system');
        expect(ErrorCategory.ui.prefix, 'ui');
        expect(ErrorCategory.business.prefix, 'business');
        expect(ErrorCategory.unknown.prefix, 'unknown');
      });
    });

    group('Predefined Errors', () {
      test('AuthenticationError factory methods', () {
        final invalidCreds = AuthenticationError.invalidCredentials();
        expect(invalidCreds.code, 'auth_invalid_credentials');

        final sessionExpired = AuthenticationError.sessionExpired();
        expect(sessionExpired.code, 'auth_session_expired');

        final biometricFailed = AuthenticationError.biometricFailed();
        expect(biometricFailed.code, 'auth_biometric_failed');
      });

      test('ValidationError factory methods', () {
        final required = ValidationError.required('email');
        expect(required.code, 'validation_required');
        expect(required.field, 'email');

        final invalidFormat = ValidationError.invalidFormat('phone');
        expect(invalidFormat.code, 'validation_invalid_format');
        expect(invalidFormat.field, 'phone');

        final tooShort = ValidationError.tooShort('password', 8);
        expect(tooShort.code, 'validation_too_short');
        expect(tooShort.context!['minLength'], 8);
      });

      test('NetworkError factory methods', () {
        final noConnection = NetworkError.noConnection();
        expect(noConnection.code, 'net_no_connection');

        final timeout = NetworkError.timeout();
        expect(timeout.code, 'net_timeout');

        final serverError = NetworkError.serverError(500);
        expect(serverError.code, 'net_server_error');
        expect(serverError.isCritical, true);
        expect(serverError.context!['statusCode'], 500);

        final clientError = NetworkError.serverError(404);
        expect(clientError.isCritical, false);
      });

      test('DatabaseError factory methods', () {
        final connectionFailed = DatabaseError.connectionFailed();
        expect(connectionFailed.code, 'db_connection_failed');
        expect(connectionFailed.isCritical, true);

        final queryFailed = DatabaseError.queryFailed('SELECT * FROM users');
        expect(queryFailed.code, 'db_query_failed');
        expect(queryFailed.context!['query'], 'SELECT * FROM users');

        final recordNotFound = DatabaseError.recordNotFound('users', '123');
        expect(recordNotFound.code, 'db_record_not_found');
        expect(recordNotFound.context!['table'], 'users');
        expect(recordNotFound.context!['id'], '123');
      });

      test('StorageError factory methods', () {
        final fileNotFound = StorageError.fileNotFound('/path/to/file');
        expect(fileNotFound.code, 'storage_file_not_found');
        expect(fileNotFound.context!['path'], '/path/to/file');

        final accessDenied = StorageError.accessDenied('/protected/file');
        expect(accessDenied.code, 'storage_access_denied');

        final insufficientSpace = StorageError.insufficientSpace();
        expect(insufficientSpace.code, 'storage_insufficient_space');
        expect(insufficientSpace.isCritical, true);
      });
    });

    group('ChainBuilder', () {
      test('should chain operations correctly', () {
        final initial = Success<int>(5);
        final result = ErrorHandler.chain(initial)
            .then((value) => Success<String>('Value: $value'))
            .then((str) => Success<int>(str.length))
            .build();

        expect(result.isSuccess, true);
        expect(result.value, 8); // "Value: 5".length
      });

      test('should stop on first error', () {
        final initial = Success<int>(5);
        final error = ValidationError.required('test');

        final result = ErrorHandler.chain(initial)
            .then((value) => Failure<String>(error))
            .then((str) => Success<int>(str.length))
            .build();

        expect(result.isFailure, true);
        expect(result.error, error);
      });
    });

    group('Extensions', () {
      test('Future.toResult should work', () async {
        final successFuture = Future.value('success');
        final result = await successFuture.toResult(
          category: ErrorCategory.network,
        );

        expect(result.isSuccess, true);
        expect(result.value, 'success');
      });

      test('Future.toResult should catch errors', () async {
        final errorFuture = Future<String>.error(Exception('test error'));
        final result = await errorFuture.toResult(
          category: ErrorCategory.network,
        );

        expect(result.isFailure, true);
        expect(result.error!.category, ErrorCategory.network);
      });

      test('Future.toResultWithTimeout should timeout', () async {
        final slowFuture = Future.delayed(Duration(seconds: 1), () => 'slow');
        final result = await slowFuture.toResultWithTimeout(
          Duration(milliseconds: 100),
          category: ErrorCategory.network,
        );

        expect(result.isFailure, true);
        expect(result.error, isA<NetworkError>());
      });
    });
  });
}
