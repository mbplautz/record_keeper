import 'package:package_info_plus/package_info_plus.dart';

class AppVersion {
  static String version = '';
  static String buildNumber = '';
  static bool _initialized = false;

  static Future<void> load() async {
    if (_initialized) return;
    final info = await PackageInfo.fromPlatform();
    version = info.version;
    buildNumber = info.buildNumber;
    _initialized = true;
  }
}
