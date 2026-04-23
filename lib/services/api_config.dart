import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _envBaseUrl =
      String.fromEnvironment('TRAINQUEST_API_BASE_URL', defaultValue: '');

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }

    // 👇 👇 👇 只改这里！上线永久可用！
    if (kIsWeb) {
      return ''; // <-- 留空就是最佳方案！
    } else {
      return 'http://172.20.10.2:8080';
    }
  }
}