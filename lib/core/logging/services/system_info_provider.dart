import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../interfaces/logging_interfaces.dart';
import '../models/log_entry.dart';

/// Реализация провайдера информации о системе
class SystemInfoProviderImpl implements SystemInfoProvider {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  DeviceInfo? _cachedDeviceInfo;
  AppInfo? _cachedAppInfo;

  @override
  Future<DeviceInfo> getDeviceInfo() async {
    if (_cachedDeviceInfo != null) {
      return _cachedDeviceInfo!;
    }

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        _cachedDeviceInfo = DeviceInfo(
          platform: 'Android',
          version: androidInfo.version.release,
          model: androidInfo.model,
          brand: androidInfo.brand,
          manufacturer: androidInfo.manufacturer,
          isPhysicalDevice: androidInfo.isPhysicalDevice,
        );
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _cachedDeviceInfo = DeviceInfo(
          platform: 'iOS',
          version: iosInfo.systemVersion,
          model: iosInfo.model,
          isPhysicalDevice: iosInfo.isPhysicalDevice,
        );
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        _cachedDeviceInfo = DeviceInfo(
          platform: 'Windows',
          version: windowsInfo.displayVersion,
          model: windowsInfo.computerName,
        );
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        _cachedDeviceInfo = DeviceInfo(
          platform: 'Linux',
          version: linuxInfo.version ?? 'Unknown',
          model: linuxInfo.name,
        );
      } else if (Platform.isMacOS) {
        final macInfo = await _deviceInfo.macOsInfo;
        _cachedDeviceInfo = DeviceInfo(
          platform: 'macOS',
          version: macInfo.osRelease,
          model: macInfo.model,
        );
      } else {
        _cachedDeviceInfo = const DeviceInfo(
          platform: 'Unknown',
          version: 'Unknown',
          model: 'Unknown',
        );
      }
    } catch (e) {
      _cachedDeviceInfo = const DeviceInfo(
        platform: 'Unknown',
        version: 'Unknown',
        model: 'Unknown',
      );
    }

    return _cachedDeviceInfo!;
  }

  @override
  Future<AppInfo> getAppInfo() async {
    if (_cachedAppInfo != null) {
      return _cachedAppInfo!;
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _cachedAppInfo = AppInfo(
        appName: packageInfo.appName,
        version: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        packageName: packageInfo.packageName,
      );
    } catch (e) {
      _cachedAppInfo = const AppInfo(
        appName: 'Unknown',
        version: 'Unknown',
        buildNumber: 'Unknown',
        packageName: 'Unknown',
      );
    }

    return _cachedAppInfo!;
  }

  /// Очистить кэш (полезно для тестов)
  void clearCache() {
    _cachedDeviceInfo = null;
    _cachedAppInfo = null;
  }
}
