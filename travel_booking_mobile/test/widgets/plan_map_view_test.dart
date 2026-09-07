import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_booking_mobile/presentation/widgets/plan_map_view.dart';

void main() {
  const validLat = 35.6762;
  const validLng = 139.6503;
  const meetingPoint = '東京駅 八重洲口';

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('latitude が 0 のとき何も描画されないこと (SizedBox.shrink)', (tester) async {
    await tester.pumpWidget(wrap(
      const PlanMapView(
          latitude: 0, longitude: validLng, meetingPoint: meetingPoint),
    ));

    expect(find.text(meetingPoint), findsNothing);
    expect(find.byIcon(Icons.map_outlined), findsNothing);
  });

  testWidgets('longitude が 0 のとき何も描画されないこと (SizedBox.shrink)', (tester) async {
    await tester.pumpWidget(wrap(
      const PlanMapView(
          latitude: validLat, longitude: 0, meetingPoint: meetingPoint),
    ));

    expect(find.text(meetingPoint), findsNothing);
    expect(find.byIcon(Icons.map_outlined), findsNothing);
  });

  // テスト環境では GOOGLE_MAPS_API_KEY が未設定のため _Fallback が描画される
  testWidgets('有効な座標で API キー未設定のときフォールバック UI が表示されること', (tester) async {
    await tester.pumpWidget(wrap(
      const PlanMapView(
          latitude: validLat, longitude: validLng, meetingPoint: meetingPoint),
    ));

    expect(find.byIcon(Icons.map_outlined), findsOneWidget);
    expect(find.text(meetingPoint), findsOneWidget);
  });

  testWidgets('フォールバック UI に異なる meetingPoint の値が正しく表示されること', (tester) async {
    const anotherPoint = '大阪城公園 正門';
    await tester.pumpWidget(wrap(
      const PlanMapView(
          latitude: validLat, longitude: validLng, meetingPoint: anotherPoint),
    ));

    expect(find.text(anotherPoint), findsOneWidget);
    expect(find.text(meetingPoint), findsNothing);
  });
}
