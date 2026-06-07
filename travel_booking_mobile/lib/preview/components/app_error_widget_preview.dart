import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../presentation/widgets/app_error_widget.dart';

@widgetbook.UseCase(name: '再試行ボタンあり', type: AppErrorWidget)
Widget buildAppErrorWidgetWithRetry(BuildContext context) {
  return AppErrorWidget(
    message: 'ネットワークに接続できませんでした。',
    onRetry: () {},
  );
}

@widgetbook.UseCase(name: '再試行ボタンなし', type: AppErrorWidget)
Widget buildAppErrorWidgetNoRetry(BuildContext context) {
  return const AppErrorWidget(
    message: 'データの取得に失敗しました。しばらくしてから再度お試しください。',
  );
}
