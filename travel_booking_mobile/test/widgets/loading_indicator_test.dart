import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_booking_mobile/presentation/widgets/loading_indicator.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
      debugShowCheckedModeBanner: false, home: Scaffold(body: child));

  testWidgets('CircularProgressIndicator が常に表示されること', (tester) async {
    await tester.pumpWidget(wrap(const LoadingIndicator()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('message が指定されたときテキストが表示されること', (tester) async {
    await tester.pumpWidget(wrap(const LoadingIndicator(message: '読み込み中...')));

    expect(find.text('読み込み中...'), findsOneWidget);
  });

  testWidgets('message が null のとき Text ウィジェットが存在しないこと', (tester) async {
    await tester.pumpWidget(wrap(const LoadingIndicator()));

    expect(find.byType(Text), findsNothing);
  });
}
