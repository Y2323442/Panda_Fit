import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _envBaseUrl =
      String.fromEnvironment('TRAINQUEST_API_BASE_URL', defaultValue: '');

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }

    // 🔥 这是你 Vercel 部署后的正确地址
    if (kIsWeb) {
      return 'https://panda-five-delta.vercel.app/api';
    } else {
      return 'https://panda-five-delta.vercel.app/api';
    }
  }
}