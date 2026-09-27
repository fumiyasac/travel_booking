import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_booking_mobile/presentation/widgets/booking_step_indicator.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(20), child: child),
    ),
  );

  group('BookingStepIndicator', () {
    testWidgets('totalSteps=3 でステップが3つ表示されること', (tester) async {
      await tester.pumpWidget(wrap(const BookingStepIndicator(currentStep: 0)));
      await tester.pumpAndSettle();

      // デフォルトラベルが3つ表示される
      expect(find.text('旅行者情報'), findsOneWidget);
      expect(find.text('日程・人数'), findsOneWidget);
      expect(find.text('入力確認'), findsOneWidget);
    });

    testWidgets('stepLabels がカスタム値で正しく表示されること', (tester) async {
      const labels = ['Step A', 'Step B', 'Step C'];
      await tester.pumpWidget(
        wrap(
          const BookingStepIndicator(
            currentStep: 0,
            totalSteps: 3,
            stepLabels: labels,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Step A'), findsOneWidget);
      expect(find.text('Step B'), findsOneWidget);
      expect(find.text('Step C'), findsOneWidget);
    });

    testWidgets('currentStep=0 のとき未完了ステップはステップ番号を表示すること', (tester) async {
      await tester.pumpWidget(wrap(const BookingStepIndicator(currentStep: 0)));
      await tester.pumpAndSettle();

      // Step 0 はアクティブ（番号 '1' 表示）、Step 1/2 は未到達（'2', '3' 表示）
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      // チェックアイコンは表示されない
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('currentStep=1 のとき Step 0 が完了（チェックアイコン）になること', (tester) async {
      await tester.pumpWidget(wrap(const BookingStepIndicator(currentStep: 1)));
      await tester.pumpAndSettle();

      // Step 0 は完了 → チェックアイコン 1 つ
      expect(find.byIcon(Icons.check), findsOneWidget);
      // Step 1 はアクティブ（番号 '2'）、Step 2 は未到達（番号 '3'）
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('currentStep=2 のとき Step 0/1 が完了（チェックアイコン 2 つ）になること', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const BookingStepIndicator(currentStep: 2)));
      await tester.pumpAndSettle();

      // Step 0/1 は完了 → チェックアイコン 2 つ
      expect(find.byIcon(Icons.check), findsNWidgets(2));
      // Step 2 はアクティブ（番号 '3'）
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('totalSteps=2 でステップが2つ表示されること', (tester) async {
      await tester.pumpWidget(
        wrap(
          const BookingStepIndicator(
            currentStep: 0,
            totalSteps: 2,
            stepLabels: ['確認', '完了'],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('確認'), findsOneWidget);
      expect(find.text('完了'), findsOneWidget);
      // 番号は '1' と '2'
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });
  });
}
