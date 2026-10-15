import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_booking_mobile/core/error/app_error.dart';
import 'package:travel_booking_mobile/presentation/widgets/async_state_builder.dart';
import 'package:travel_booking_mobile/presentation/widgets/app_error_widget.dart';
import 'package:travel_booking_mobile/presentation/widgets/loading_indicator.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AsyncStateBuilder', () {
    testWidgets('isLoading: true, data: null → LoadingIndicator が表示される', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          AsyncStateBuilder<String>(
            isLoading: true,
            error: null,
            data: null,
            builder: (s) => Text(s),
          ),
        ),
      );

      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(find.byType(AppErrorWidget), findsNothing);
    });

    testWidgets(
      'error: NetworkError, data: null → AppErrorWidget + リトライボタンが表示される',
      (tester) async {
        bool retried = false;
        await tester.pumpWidget(
          _wrap(
            AsyncStateBuilder<String>(
              isLoading: false,
              error: const NetworkError(),
              data: null,
              onRetry: () => retried = true,
              builder: (s) => Text(s),
            ),
          ),
        );

        expect(find.byType(AppErrorWidget), findsOneWidget);
        expect(find.text('再試行'), findsOneWidget);

        await tester.tap(find.text('再試行'));
        expect(retried, isTrue);
      },
    );

    testWidgets(
      'error: ValidationError, data: null → AppErrorWidget でリトライボタンが出ない',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            AsyncStateBuilder<String>(
              isLoading: false,
              error: const ValidationError('入力が不正です'),
              data: null,
              onRetry: () {},
              builder: (s) => Text(s),
            ),
          ),
        );

        expect(find.byType(AppErrorWidget), findsOneWidget);
        expect(find.text('再試行'), findsNothing);
      },
    );

    testWidgets('data: 有効な値 → builder が呼ばれてコンテンツが表示される', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AsyncStateBuilder<String>(
            isLoading: false,
            error: null,
            data: 'hello',
            builder: (s) => Text(s),
          ),
        ),
      );

      expect(find.text('hello'), findsOneWidget);
      expect(find.byType(LoadingIndicator), findsNothing);
      expect(find.byType(AppErrorWidget), findsNothing);
    });

    testWidgets('isLoading: true, data: 有効な値 → コンテンツが表示される（ローディングではない）', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          AsyncStateBuilder<String>(
            isLoading: true,
            error: null,
            data: 'existing data',
            builder: (s) => Text(s),
          ),
        ),
      );

      // loadMore 中でも既存データを表示し続ける
      expect(find.text('existing data'), findsOneWidget);
      expect(find.byType(LoadingIndicator), findsNothing);
    });

    testWidgets(
      'data: null, isLoading: false, error: null → emptyBuilder が呼ばれる',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            AsyncStateBuilder<String>(
              isLoading: false,
              error: null,
              data: null,
              emptyBuilder: () => const Text('empty state'),
              builder: (s) => Text(s),
            ),
          ),
        );

        expect(find.text('empty state'), findsOneWidget);
        expect(find.byType(LoadingIndicator), findsNothing);
        expect(find.byType(AppErrorWidget), findsNothing);
      },
    );

    testWidgets('emptyBuilder 省略時は SizedBox.shrink が返る', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AsyncStateBuilder<String>(
            isLoading: false,
            error: null,
            data: null,
            builder: (s) => Text(s),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(LoadingIndicator), findsNothing);
      expect(find.byType(AppErrorWidget), findsNothing);
    });

    testWidgets('カスタム loadingWidget が使われる', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AsyncStateBuilder<String>(
            isLoading: true,
            error: null,
            data: null,
            loadingWidget: const Text('custom loading'),
            builder: (s) => Text(s),
          ),
        ),
      );

      expect(find.text('custom loading'), findsOneWidget);
      expect(find.byType(LoadingIndicator), findsNothing);
    });
  });
}
