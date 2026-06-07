import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../presentation/screens/home/widgets/plan_card.dart';
import '../mock_data.dart';
import '../mock_providers.dart';

@widgetbook.UseCase(name: '通常プラン（お気に入りなし）', type: PlanCard)
Widget buildPlanCardDefault(BuildContext context) {
  return ProviderScope(
    overrides: previewProviderOverrides,
    child: PlanCard(plan: mockPlanTokyo),
  );
}

@widgetbook.UseCase(name: 'セールプラン（割引バッジあり）', type: PlanCard)
Widget buildPlanCardSale(BuildContext context) {
  return ProviderScope(
    overrides: previewProviderOverrides,
    child: PlanCard(plan: mockPlanParis),
  );
}

@widgetbook.UseCase(name: 'ハード難易度プラン', type: PlanCard)
Widget buildPlanCardHard(BuildContext context) {
  return ProviderScope(
    overrides: previewProviderOverrides,
    child: PlanCard(plan: mockPlanHimalayas),
  );
}
