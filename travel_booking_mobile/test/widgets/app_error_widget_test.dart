import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_booking_mobile/core/error/app_error.dart';
import 'package:travel_booking_mobile/presentation/widgets/app_error_widget.dart';

void main() {
  Widget wrap({required AppError error, VoidCallback? onRetry}) => MaterialApp(
        home: Scaffold(
          body: AppErrorWidget(error: error, onRetry: onRetry),
        ),
      );

  // ── NetworkError ──────────────────────────────────────────────────
  group('NetworkError', () {
    testWidgets('wifi_off アイコンと "ネットワークエラー" タイトルが表示されること', (tester) async {
      await tester.pumpWidget(wrap(error: const NetworkError()));

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('ネットワークエラー'), findsOneWidget);
    });

    testWidgets('デフォルト message が表示されること', (tester) async {
      await tester.pumpWidget(wrap(error: const NetworkError()));

      expect(find.text('通信エラーが発生しました'), findsOneWidget);
    });

    testWidgets('onRetry あり → "再試行" ラベルと refresh アイコンが表示されること', (tester) async {
      await tester
          .pumpWidget(wrap(error: const NetworkError(), onRetry: () {}));

      expect(find.text('再試行'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('リトライボタンをタップすると onRetry コールバックが呼ばれること', (tester) async {
      var called = false;
      await tester.pumpWidget(
        wrap(error: const NetworkError(), onRetry: () => called = true),
      );

      await tester.tap(find.text('再試行'));
      expect(called, isTrue);
    });
  });

  // ── GraphQLError ──────────────────────────────────────────────────
  group('GraphQLError', () {
    testWidgets('error_outline アイコンと "サーバーエラー" タイトルが表示されること', (tester) async {
      await tester.pumpWidget(wrap(error: const GraphQLError('サーバー内部エラー')));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('サーバーエラー'), findsOneWidget);
    });

    testWidgets('指定した message が表示されること', (tester) async {
      await tester.pumpWidget(wrap(error: const GraphQLError('サーバー内部エラー')));

      expect(find.text('サーバー内部エラー'), findsOneWidget);
    });

    testWidgets('onRetry が null のときリトライボタンが表示されないこと', (tester) async {
      await tester.pumpWidget(wrap(error: const GraphQLError('サーバー内部エラー')));

      expect(find.text('再試行'), findsNothing);
    });
  });

  // ── ValidationError ───────────────────────────────────────────────
  group('ValidationError', () {
    testWidgets('warning_amber_rounded アイコンと "入力エラー" タイトルが表示されること',
        (tester) async {
      await tester.pumpWidget(
        wrap(error: const ValidationError('メールアドレスが不正です', field: 'email')),
      );

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.text('入力エラー'), findsOneWidget);
    });

    testWidgets('指定した message が表示されること', (tester) async {
      await tester.pumpWidget(
        wrap(error: const ValidationError('メールアドレスが不正です')),
      );

      expect(find.text('メールアドレスが不正です'), findsOneWidget);
    });

    testWidgets('onRetry が null のときリトライボタンが表示されないこと', (tester) async {
      await tester.pumpWidget(wrap(error: const ValidationError('入力値エラー')));

      expect(find.text('再試行'), findsNothing);
    });
  });

  // ── UnknownError ──────────────────────────────────────────────────
  group('UnknownError', () {
    testWidgets('help_outline アイコンと "エラーが発生しました" タイトルが表示されること', (tester) async {
      await tester.pumpWidget(wrap(error: const UnknownError()));

      expect(find.byIcon(Icons.help_outline), findsOneWidget);
      expect(find.text('エラーが発生しました'), findsOneWidget);
    });

    testWidgets('デフォルト message "予期しないエラーが発生しました" が表示されること', (tester) async {
      await tester.pumpWidget(wrap(error: const UnknownError()));

      expect(find.text('予期しないエラーが発生しました'), findsOneWidget);
    });
  });
}
