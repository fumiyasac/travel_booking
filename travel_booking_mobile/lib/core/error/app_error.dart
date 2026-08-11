sealed class AppError {
  const AppError(this.message);
  final String message;

  // ViewModel の e.toString() との互換性を維持する
  @override
  String toString() => message;
}

class NetworkError extends AppError {
  const NetworkError([super.message = '通信エラーが発生しました']);
}

class GraphQLError extends AppError {
  const GraphQLError(super.message, {this.code});
  final String? code;
}

class ValidationError extends AppError {
  const ValidationError(super.message, {this.field});
  final String? field;
}

class UnknownError extends AppError {
  const UnknownError([super.message = '予期しないエラーが発生しました']);
}
