import 'dart:io';

import '../../core/auth/auth_service.dart';
import '../../core/config/graphql_config.dart';
import '../../core/error/app_error.dart';
import '../datasources/remote/auth_remote_data_source.dart';
import '../models/auth_user.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final AuthService _authService;

  const AuthRepositoryImpl(this._dataSource, this._authService);

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final (token, user) = await _dataSource.login(
        email: email,
        password: password,
      );
      await _authService.saveAuth(token, user);
      return user.copyWith(token: token);
    } on SocketException {
      throw const NetworkError();
    } on HttpException catch (e) {
      throw NetworkError(e.message.isNotEmpty ? e.message : '通信エラーが発生しました');
    } on GraphQLResponseException catch (e) {
      throw GraphQLError(e.message);
    } on AppError {
      rethrow;
    } catch (e) {
      throw GraphQLError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final (token, user) = await _dataSource.register(
        email: email,
        password: password,
        name: name,
      );
      await _authService.saveAuth(token, user);
      return user.copyWith(token: token);
    } on SocketException {
      throw const NetworkError();
    } on HttpException catch (e) {
      throw NetworkError(e.message.isNotEmpty ? e.message : '通信エラーが発生しました');
    } on GraphQLResponseException catch (e) {
      throw GraphQLError(e.message);
    } on AppError {
      rethrow;
    } catch (e) {
      throw GraphQLError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> logout() => _authService.logout();

  @override
  AuthUser? getCurrentUser() => _authService.getCurrentUser();

  @override
  Future<String?> getToken() => _authService.getToken();
}
