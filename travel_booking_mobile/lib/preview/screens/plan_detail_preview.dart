import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// ignore: depend_on_referenced_packages
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../data/models/travel_plan.dart';
import '../../presentation/screens/plan_detail/plan_detail_screen.dart';
import '../mock_data.dart';
import '../mock_providers.dart';

// Preview 専用 GoRouter（予約画面への遷移先なし・クラッシュ回避）
final _previewRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SizedBox.shrink(),
    ),
  ],
);

// overrides を直接 ProviderScope.overrides に渡すことで
// List<Override> の型推論を Dart に委ねる
Widget _wrap({
  TravelPlan? plan,
  bool throwError = false,
  bool loading = false,
  String planId = 'mock_detail',
}) =>
    ProviderScope(
      overrides: previewOverridesWith(
        plan: plan,
        throwError: throwError,
        loading: loading,
      ),
      child: MaterialApp.router(
        routerConfig: _previewRouter,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ja', 'JP')],
        builder: (context, _) => PlanDetailScreen(planId: planId),
      ),
    );

// ── シナリオ 1: 正常表示（集合場所・ハイライトあり） ─────────────────────────
@widgetbook.UseCase(name: '正常表示', type: PlanDetailScreen)
Widget buildPlanDetailNormal(BuildContext context) {
  return _wrap(plan: mockPlanDetail);
}

// ── シナリオ 2: 割引価格あり ────────────────────────────────────────────────
@widgetbook.UseCase(name: '割引価格あり', type: PlanDetailScreen)
Widget buildPlanDetailDiscount(BuildContext context) {
  return _wrap(plan: mockPlanParis);
}

// ── シナリオ 3: ローディング中（LoadingIndicator 表示） ──────────────────────
@widgetbook.UseCase(name: 'ローディング中', type: PlanDetailScreen)
Widget buildPlanDetailLoading(BuildContext context) {
  return _wrap(loading: true);
}

// ── シナリオ 4: エラー状態（AppErrorWidget 表示） ─────────────────────────────
@widgetbook.UseCase(name: 'エラー状態', type: PlanDetailScreen)
Widget buildPlanDetailError(BuildContext context) {
  return _wrap(throwError: true);
}
