import '../models/database_metadata.dart';

class CredentialsStoreState {
  final bool isInitialized;
  final bool isDatabaseOpen;
  final bool isLoading;
  final List<DatabaseMetadata> databases;
  final String? currentDatabasePassword;
  final String? errorMessage;
  final DateTime? lastActivity;
  final DatabaseConnectionStatus status;

  const CredentialsStoreState({
    this.isInitialized = false,
    this.isDatabaseOpen = false,
    this.isLoading = false,
    this.databases = const [],
    this.currentDatabasePassword,
    this.errorMessage,
    this.lastActivity,
    this.status = DatabaseConnectionStatus.disconnected,
  });

  CredentialsStoreState copyWith({
    bool? isInitialized,
    bool? isDatabaseOpen,
    bool? isLoading,
    List<DatabaseMetadata>? databases,
    String? currentDatabasePassword,
    String? errorMessage,
    DateTime? lastActivity,
    DatabaseConnectionStatus? status,
  }) {
    return CredentialsStoreState(
      isInitialized: isInitialized ?? this.isInitialized,
      isDatabaseOpen: isDatabaseOpen ?? this.isDatabaseOpen,
      isLoading: isLoading ?? this.isLoading,
      databases: databases ?? this.databases,
      currentDatabasePassword:
          currentDatabasePassword ?? this.currentDatabasePassword,
      errorMessage: errorMessage ?? this.errorMessage,
      lastActivity: lastActivity ?? this.lastActivity,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CredentialsStoreState &&
        other.isInitialized == isInitialized &&
        other.isDatabaseOpen == isDatabaseOpen &&
        other.isLoading == isLoading &&
        other.databases == databases &&
        other.currentDatabasePassword == currentDatabasePassword &&
        other.errorMessage == errorMessage &&
        other.lastActivity == lastActivity &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(
      isInitialized,
      isDatabaseOpen,
      isLoading,
      databases,
      currentDatabasePassword,
      errorMessage,
      lastActivity,
      status,
    );
  }

  @override
  String toString() {
    return 'CredentialsStoreState('
        'isInitialized: $isInitialized, '
        'isDatabaseOpen: $isDatabaseOpen, '
        'isLoading: $isLoading, '
        'databases: ${databases.length}, '
        'status: $status, '
        'errorMessage: $errorMessage)';
  }
}

enum DatabaseConnectionStatus {
  disconnected,
  connecting,
  connected,
  locked,
  error,
}

extension DatabaseConnectionStatusX on DatabaseConnectionStatus {
  String get displayName {
    switch (this) {
      case DatabaseConnectionStatus.disconnected:
        return 'Отключено';
      case DatabaseConnectionStatus.connecting:
        return 'Подключение...';
      case DatabaseConnectionStatus.connected:
        return 'Подключено';
      case DatabaseConnectionStatus.locked:
        return 'Заблокировано';
      case DatabaseConnectionStatus.error:
        return 'Ошибка';
    }
  }

  bool get isConnected => this == DatabaseConnectionStatus.connected;
  bool get isDisconnected => this == DatabaseConnectionStatus.disconnected;
  bool get isLocked => this == DatabaseConnectionStatus.locked;
  bool get hasError => this == DatabaseConnectionStatus.error;
  bool get isConnecting => this == DatabaseConnectionStatus.connecting;
}
