import 'package:flutter/material.dart';

import '../../core/error/app_error.dart';
import 'app_error_widget.dart';
import 'loading_indicator.dart';

/// loading / error / data の3状態分岐を共通化するウィジェット。
///
/// - [isLoading] && [data] == null → [loadingWidget]（省略時は [LoadingIndicator]）
/// - [error] != null && [data] == null → [AppErrorWidget]（NetworkError の場合のみ [onRetry] を表示）
/// - [data] == null かつ loading でも error でもない → [emptyBuilder]（省略時は [SizedBox.shrink]）
/// - [data] != null → [builder]（[isLoading] が true でも data があればコンテンツを表示し続ける）
class AsyncStateBuilder<T> extends StatelessWidget {
  const AsyncStateBuilder({
    required this.isLoading,
    required this.error,
    required this.data,
    required this.builder,
    this.onRetry,
    this.loadingWidget,
    this.emptyBuilder,
    super.key,
  });

  final bool isLoading;
  final AppError? error;
  final T? data;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;

  /// カスタムローディング表示。省略時は [LoadingIndicator]。
  final Widget? loadingWidget;

  /// データが空（null）かつ loading でも error でもない場合のウィジェット。
  /// 省略時は [SizedBox.shrink]。
  final Widget Function()? emptyBuilder;

  @override
  Widget build(BuildContext context) {
    // loadMore 中（data あり + isLoading）はコンテンツを表示し続ける
    if (isLoading && data == null) {
      return loadingWidget ?? const LoadingIndicator();
    }
    // 初回取得エラーのみ全画面エラー表示（data あり = 既存コンテンツを継続表示）
    if (error != null && data == null) {
      return AppErrorWidget(
        error: error!,
        onRetry: error is NetworkError ? onRetry : null,
      );
    }
    if (data == null) {
      return emptyBuilder?.call() ?? const SizedBox.shrink();
    }
    return builder(data as T);
  }
}
