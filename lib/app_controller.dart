import 'package:flutter/foundation.dart';

class AppController extends ChangeNotifier {
  AppController();

  bool _bootstrapping = false;
  bool _authenticating = false;
  String? _authError;

  bool get isBootstrapping => _bootstrapping;
  bool get isAuthenticating => _authenticating;
  bool get isAuthenticated => true; // 永远已登录
  String get baseUrl => ''; // 空地址，不请求
  String? get authError => _authError;

  // 永远不需要初始化
  Future<void> bootstrap() async {
    _bootstrapping = false;
    notifyListeners();
  }

  // 🔥 直接登录成功，不调用任何API
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _authenticating = true;
    notifyListeners();

    try {
      // 直接成功，不发请求
      _authError = null;
    } catch (error) {
      _authError = error.toString();
    } finally {
      _authenticating = false;
      notifyListeners();
    }
  }

  // 注册也直接成功
  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _authenticating = true;
    notifyListeners();

    try {
      _authError = null;
    } catch (error) {
      _authError = error.toString();
    } finally {
      _authenticating = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    notifyListeners();
  }

  Future<void> clearAuthError() async {
    _authError = null;
    notifyListeners();
  }
}