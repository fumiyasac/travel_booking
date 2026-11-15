import '../models/auth_user.dart';

abstract interface class AuthRepository {
  Future<AuthUser> login({required String email, required String password});
  Future<AuthUser> register({
    required String email,
    required String password,
    required String name,
  });
  Future<void> logout();
  AuthUser? getCurrentUser();
  Future<String?> getToken();
}
