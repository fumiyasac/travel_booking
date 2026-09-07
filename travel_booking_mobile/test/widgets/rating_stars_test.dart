import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_booking_mobile/presentation/widgets/rating_stars.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('RatingBarIndicator と rating テキスト "5.0" が表示されること',
      (tester) async {
    await tester.pumpWidget(wrap(const RatingStars(rating: 5.0)));

    expect(find.byType(RatingBarIndicator), findsOneWidget);
    expect(find.text('5.0'), findsOneWidget);
  });

  testWidgets('rating 3.5 で "3.5" テキストが表示されること', (tester) async {
    await tester.pumpWidget(wrap(const RatingStars(rating: 3.5)));

    expect(find.text('3.5'), findsOneWidget);
  });

  testWidgets('rating 0.0 で "0.0" テキストが表示されること', (tester) async {
    await tester.pumpWidget(wrap(const RatingStars(rating: 0.0)));

    expect(find.text('0.0'), findsOneWidget);
  });

  testWidgets('reviewCount が指定されたとき "(128)" が表示されること', (tester) async {
    await tester.pumpWidget(
      wrap(const RatingStars(rating: 4.5, reviewCount: 128)),
    );

    expect(find.text('(128)'), findsOneWidget);
  });

  testWidgets('showCount=false のとき reviewCount テキストが非表示になること', (tester) async {
    await tester.pumpWidget(
      wrap(const RatingStars(rating: 4.5, reviewCount: 128, showCount: false)),
    );

    expect(find.text('(128)'), findsNothing);
  });

  testWidgets('rating が負の値 (-1.0) でもクラッシュせず RatingBarIndicator が表示されること',
      (tester) async {
    await tester.pumpWidget(wrap(const RatingStars(rating: -1.0)));

    expect(find.byType(RatingBarIndicator), findsOneWidget);
  });

  testWidgets('rating が上限超え (6.0) でもクラッシュせず RatingBarIndicator が表示されること',
      (tester) async {
    await tester.pumpWidget(wrap(const RatingStars(rating: 6.0)));

    expect(find.byType(RatingBarIndicator), findsOneWidget);
    expect(find.text('6.0'), findsOneWidget);
  });
}
