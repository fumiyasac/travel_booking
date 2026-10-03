/// GraphQL クライアントの抽象インターフェース。
///
/// DataSource が依存する [query] / [mutate] の 2 メソッドのみを定義する。
/// テストでは実装クラスの代わりにこのインターフェースをモックする。
abstract interface class GraphQLClientInterface {
  /// GraphQL クエリを送信して `data` フィールドを返す。
  Future<Map<String, dynamic>> query({
    required String document,
    Map<String, dynamic>? variables,
  });

  /// GraphQL ミューテーションを送信して `data` フィールドを返す。
  Future<Map<String, dynamic>> mutate({
    required String document,
    Map<String, dynamic>? variables,
  });
}
