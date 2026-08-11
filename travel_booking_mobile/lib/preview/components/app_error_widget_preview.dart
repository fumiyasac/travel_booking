import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../core/error/app_error.dart';
import '../../presentation/widgets/app_error_widget.dart';

@widgetbook.UseCase(name: 'NetworkError（再試行あり）', type: AppErrorWidget)
Widget buildAppErrorWidgetNetwork(BuildContext context) {
  return AppErrorWidget(
    error: const NetworkError(),
    onRetry: () {},
  );
}

@widgetbook.UseCase(name: 'GraphQLError', type: AppErrorWidget)
Widget buildAppErrorWidgetGraphQL(BuildContext context) {
  return const AppErrorWidget(
    error: GraphQLError('サーバーとの通信中にエラーが発生しました。'),
  );
}

@widgetbook.UseCase(name: 'ValidationError', type: AppErrorWidget)
Widget buildAppErrorWidgetValidation(BuildContext context) {
  return const AppErrorWidget(
    error: ValidationError('メールアドレスが指定されていません', field: 'email'),
  );
}

@widgetbook.UseCase(name: 'UnknownError', type: AppErrorWidget)
Widget buildAppErrorWidgetUnknown(BuildContext context) {
  return const AppErrorWidget(
    error: UnknownError(),
  );
}
