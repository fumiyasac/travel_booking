import 'graphql_client_interface.dart';

/// テスト・Preview 用のスタブ実装。
///
/// デフォルトは空 Map を返す。テストで個別に動作を override する場合は
/// このクラスをサブクラス化するか、mockito で GraphQLClientInterface を
/// モックして使う。
class MockGraphQLClient implements GraphQLClientInterface {
  const MockGraphQLClient();

  @override
  Future<Map<String, dynamic>> query({
    required String document,
    Map<String, dynamic>? variables,
  }) async => const {};

  @override
  Future<Map<String, dynamic>> mutate({
    required String document,
    Map<String, dynamic>? variables,
  }) async => const {};
}
