import '../../../core/config/graphql_client_interface.dart';
import '../../models/auth_user.dart';

class AuthRemoteDataSource {
  final GraphQLClientInterface _client;

  const AuthRemoteDataSource(this._client);

  static const _loginMutation = r'''
    mutation Login($input: LoginInput!) {
      login(input: $input) {
        token
        user {
          id
          email
          name
        }
      }
    }
  ''';

  static const _registerMutation = r'''
    mutation Register($input: RegisterInput!) {
      register(input: $input) {
        token
        user {
          id
          email
          name
        }
      }
    }
  ''';

  Future<(String token, AuthUser user)> login({
    required String email,
    required String password,
  }) async {
    final data = await _client.mutate(
      document: _loginMutation,
      variables: {
        'input': {'email': email, 'password': password},
      },
    );
    final payload = data['login'] as Map<String, dynamic>;
    final token = payload['token'] as String;
    final user = AuthUser.fromJson(payload['user'] as Map<String, dynamic>);
    return (token, user);
  }

  Future<(String token, AuthUser user)> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final data = await _client.mutate(
      document: _registerMutation,
      variables: {
        'input': {'email': email, 'password': password, 'name': name},
      },
    );
    final payload = data['register'] as Map<String, dynamic>;
    final token = payload['token'] as String;
    final user = AuthUser.fromJson(payload['user'] as Map<String, dynamic>);
    return (token, user);
  }
}
