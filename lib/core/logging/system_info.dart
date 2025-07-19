import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Класс для сбора системной информации устройства и приложения
class SystemInfo {
  static SystemInfo? _instance;

  PackageInfo? _packageInfo;
  DeviceInfoPlugin? _deviceInfoPlugin;

  // Информация о приложении
  String? _appName;
  String? _packageName;
  String? _version;
  String? _buildNumber;

  // Информация об устройстве
  String? _deviceModel;
  String? _osVersion;
  String? _deviceId;
  String? _architecture;
  Map<String, dynamic>? _deviceDetails;

  SystemInfo._internal() {
    _deviceInfoPlugin = DeviceInfoPlugin();
  }

  static SystemInfo get instance {
    _instance ??= SystemInfo._internal();
    return _instance!;
  }

  /// Инициализация системной информации
  Future<void> initialize() async {
    try {
      await _loadPackageInfo();
      await _loadDeviceInfo();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка инициализации SystemInfo: $e');
      }
    }
  }

  /// Загрузка информации о приложении
  Future<void> _loadPackageInfo() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      _appName = _packageInfo?.appName;
      _packageName = _packageInfo?.packageName;
      _version = _packageInfo?.version;
      _buildNumber = _packageInfo?.buildNumber;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка загрузки информации о приложении: $e');
      }
    }
  }

  /// Загрузка информации об устройстве
  Future<void> _loadDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        await _loadAndroidInfo();
      } else if (Platform.isIOS) {
        await _loadIOSInfo();
      } else if (Platform.isWindows) {
        await _loadWindowsInfo();
      } else if (Platform.isLinux) {
        await _loadLinuxInfo();
      } else if (Platform.isMacOS) {
        await _loadMacOSInfo();
      } else {
        _deviceModel = 'Unknown';
        _osVersion = 'Unknown';
        _deviceId = 'Unknown';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка загрузки информации об устройстве: $e');
      }
    }
  }

  /// Загрузка информации для Android
  Future<void> _loadAndroidInfo() async {
    final androidInfo = await _deviceInfoPlugin!.androidInfo;
    _deviceModel = '${androidInfo.brand} ${androidInfo.model}';
    _osVersion =
        'Android ${androidInfo.version.release} (API ${androidInfo.version.sdkInt})';
    _deviceId = androidInfo.id;
    _architecture = androidInfo.supportedAbis.isNotEmpty
        ? androidInfo.supportedAbis.first
        : 'Unknown';

    _deviceDetails = {
      'manufacturer': androidInfo.manufacturer,
      'brand': androidInfo.brand,
      'model': androidInfo.model,
      'device': androidInfo.device,
      'product': androidInfo.product,
      'board': androidInfo.board,
      'hardware': androidInfo.hardware,
      'androidId': androidInfo.id,
      'fingerprint': androidInfo.fingerprint,
      'bootloader': androidInfo.bootloader,
      'display': androidInfo.display,
      'host': androidInfo.host,
      'tags': androidInfo.tags,
      'type': androidInfo.type,
      'isPhysicalDevice': androidInfo.isPhysicalDevice,
      'supportedAbis': androidInfo.supportedAbis,
      'supported32BitAbis': androidInfo.supported32BitAbis,
      'supported64BitAbis': androidInfo.supported64BitAbis,
      'systemFeatures': androidInfo.systemFeatures,
      'version': {
        'baseOS': androidInfo.version.baseOS,
        'codename': androidInfo.version.codename,
        'incremental': androidInfo.version.incremental,
        'previewSdkInt': androidInfo.version.previewSdkInt,
        'release': androidInfo.version.release,
        'sdkInt': androidInfo.version.sdkInt,
        'securityPatch': androidInfo.version.securityPatch,
      },
    };
  }

  /// Загрузка информации для iOS
  Future<void> _loadIOSInfo() async {
    final iosInfo = await _deviceInfoPlugin!.iosInfo;
    _deviceModel = iosInfo.model;
    _osVersion = '${iosInfo.systemName} ${iosInfo.systemVersion}';
    _deviceId = iosInfo.identifierForVendor;
    _architecture = iosInfo.utsname.machine;

    _deviceDetails = {
      'name': iosInfo.name,
      'systemName': iosInfo.systemName,
      'systemVersion': iosInfo.systemVersion,
      'model': iosInfo.model,
      'localizedModel': iosInfo.localizedModel,
      'identifierForVendor': iosInfo.identifierForVendor,
      'isPhysicalDevice': iosInfo.isPhysicalDevice,
      'utsname': {
        'sysname': iosInfo.utsname.sysname,
        'nodename': iosInfo.utsname.nodename,
        'release': iosInfo.utsname.release,
        'version': iosInfo.utsname.version,
        'machine': iosInfo.utsname.machine,
      },
    };
  }

  /// Загрузка информации для Windows
  Future<void> _loadWindowsInfo() async {
    final windowsInfo = await _deviceInfoPlugin!.windowsInfo;
    _deviceModel = windowsInfo.computerName;
    _osVersion =
        '${windowsInfo.productName} (Build ${windowsInfo.buildNumber})';
    _deviceId = windowsInfo.deviceId;
    _architecture = 'Windows ${windowsInfo.numberOfCores} cores';

    _deviceDetails = {
      'computerName': windowsInfo.computerName,
      'numberOfCores': windowsInfo.numberOfCores,
      'systemMemoryInMegabytes': windowsInfo.systemMemoryInMegabytes,
      'userName': windowsInfo.userName,
      'majorVersion': windowsInfo.majorVersion,
      'minorVersion': windowsInfo.minorVersion,
      'buildNumber': windowsInfo.buildNumber,
      'platformId': windowsInfo.platformId,
      'csdVersion': windowsInfo.csdVersion,
      'servicePackMajor': windowsInfo.servicePackMajor,
      'servicePackMinor': windowsInfo.servicePackMinor,
      'suitMask': windowsInfo.suitMask,
      'productType': windowsInfo.productType,
      'reserved': windowsInfo.reserved,
      'buildLab': windowsInfo.buildLab,
      'buildLabEx': windowsInfo.buildLabEx,
      'digitalProductId': windowsInfo.digitalProductId,
      'displayVersion': windowsInfo.displayVersion,
      'editionId': windowsInfo.editionId,
      'installDate': windowsInfo.installDate,
      'productId': windowsInfo.productId,
      'productName': windowsInfo.productName,
      'registeredOwner': windowsInfo.registeredOwner,
      'releaseId': windowsInfo.releaseId,
      'deviceId': windowsInfo.deviceId,
    };
  }

  /// Загрузка информации для Linux
  Future<void> _loadLinuxInfo() async {
    final linuxInfo = await _deviceInfoPlugin!.linuxInfo;
    _deviceModel = linuxInfo.prettyName;
    _osVersion = '${linuxInfo.name} ${linuxInfo.version}';
    _deviceId = linuxInfo.machineId ?? 'Unknown';
    _architecture = 'Linux';

    _deviceDetails = {
      'name': linuxInfo.name,
      'version': linuxInfo.version,
      'id': linuxInfo.id,
      'idLike': linuxInfo.idLike,
      'versionCodename': linuxInfo.versionCodename,
      'versionId': linuxInfo.versionId,
      'prettyName': linuxInfo.prettyName,
      'buildId': linuxInfo.buildId,
      'variant': linuxInfo.variant,
      'variantId': linuxInfo.variantId,
      'machineId': linuxInfo.machineId,
    };
  }

  /// Загрузка информации для macOS
  Future<void> _loadMacOSInfo() async {
    final macOSInfo = await _deviceInfoPlugin!.macOsInfo;
    _deviceModel = macOSInfo.model;
    _osVersion = 'macOS ${macOSInfo.osRelease}';
    _deviceId = macOSInfo.systemGUID;
    _architecture = macOSInfo.arch;

    _deviceDetails = {
      'computerName': macOSInfo.computerName,
      'hostName': macOSInfo.hostName,
      'arch': macOSInfo.arch,
      'model': macOSInfo.model,
      'kernelVersion': macOSInfo.kernelVersion,
      'osRelease': macOSInfo.osRelease,
      'activeCPUs': macOSInfo.activeCPUs,
      'memorySize': macOSInfo.memorySize,
      'cpuFrequency': macOSInfo.cpuFrequency,
      'systemGUID': macOSInfo.systemGUID,
    };
  }

  // Геттеры для информации о приложении
  String get appName => _appName ?? 'Unknown';
  String get packageName => _packageName ?? 'Unknown';
  String get version => _version ?? 'Unknown';
  String get buildNumber => _buildNumber ?? 'Unknown';
  String get fullVersion => '$version+$buildNumber';

  // Геттеры для информации об устройстве
  String get deviceModel => _deviceModel ?? 'Unknown';
  String get osVersion => _osVersion ?? 'Unknown';
  String get deviceId => _deviceId ?? 'Unknown';
  String get architecture => _architecture ?? 'Unknown';
  String get platform => Platform.operatingSystem;

  /// Получение полной информации о системе в виде строки
  String getSystemInfoString() {
    final buffer = StringBuffer();

    buffer.writeln('=== ИНФОРМАЦИЯ О ПРИЛОЖЕНИИ ===');
    buffer.writeln('Название: $appName');
    buffer.writeln('Пакет: $packageName');
    buffer.writeln('Версия: $fullVersion');
    buffer.writeln('');

    buffer.writeln('=== ИНФОРМАЦИЯ ОБ УСТРОЙСТВЕ ===');
    buffer.writeln('Платформа: $platform');
    buffer.writeln('Модель: $deviceModel');
    buffer.writeln('ОС: $osVersion');
    buffer.writeln('Архитектура: $architecture');
    buffer.writeln('ID устройства: $deviceId');
    buffer.writeln('');

    buffer.writeln('=== РЕЖИМ СБОРКИ ===');
    buffer.writeln('Debug: $kDebugMode');
    buffer.writeln('Release: $kReleaseMode');
    buffer.writeln('Profile: $kProfileMode');

    return buffer.toString();
  }

  /// Получение краткой информации о системе
  String getShortSystemInfo() {
    return '$appName $fullVersion на $platform ($deviceModel, $osVersion)';
  }

  /// Получение детальной информации об устройстве
  Map<String, dynamic>? getDeviceDetails() {
    return _deviceDetails;
  }

  /// Получение информации о приложении в виде Map
  Map<String, String> getAppInfo() {
    return {
      'appName': appName,
      'packageName': packageName,
      'version': version,
      'buildNumber': buildNumber,
      'fullVersion': fullVersion,
    };
  }

  /// Получение информации о платформе в виде Map
  Map<String, String> getPlatformInfo() {
    return {
      'platform': platform,
      'deviceModel': deviceModel,
      'osVersion': osVersion,
      'architecture': architecture,
      'deviceId': deviceId,
      'isDebug': kDebugMode.toString(),
      'isRelease': kReleaseMode.toString(),
      'isProfile': kProfileMode.toString(),
    };
  }
}
