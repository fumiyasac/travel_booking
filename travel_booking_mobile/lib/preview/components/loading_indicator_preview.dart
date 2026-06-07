import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../presentation/widgets/loading_indicator.dart';

@widgetbook.UseCase(name: 'メッセージあり', type: LoadingIndicator)
Widget buildLoadingIndicatorWithMessage(BuildContext context) {
  return const LoadingIndicator(message: 'プランを読み込んでいます...');
}

@widgetbook.UseCase(name: 'メッセージなし', type: LoadingIndicator)
Widget buildLoadingIndicatorNoMessage(BuildContext context) {
  return const LoadingIndicator();
}
