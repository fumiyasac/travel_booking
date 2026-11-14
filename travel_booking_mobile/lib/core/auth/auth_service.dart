import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/auth_user.dart';

part 'auth_service.g.dart';

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) => AuthService();

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  final _storage = const FlutterSecureStorage();
  AuthUser? _currentUser;

  Future<void> saveAuth(String token, AuthUser user) async {
    _currentUser = user.copyWith(token: token);
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  AuthUser? getCurrentUser() => _currentUser;

  Future<AuthUser?> restoreSession() async {
    final token = await _storage.read(key: _tokenKey);
    final userJson = await _storage.read(key: _userKey);
    if (token == null || userJson == null) return null;
    try {
      final user = AuthUser.fromJson(
        jsonDecode(userJson) as Map<String, dynamic>,
      );
      _currentUser = user.copyWith(token: token);
      return _currentUser;
    } catch (_) {
      await logout();
      return null;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  bool get isLoggedIn => _currentUser != null;
}
