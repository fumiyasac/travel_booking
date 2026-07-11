# Preview ケーステンプレート集

Screen 用4シナリオと Widget 用ケースのテンプレート。
`<ScreenName>` / `<WidgetName>` を対象名に置換して使うこと。

---

## 1. Screen Preview テンプレート（4シナリオ）

`lib/preview/screens/<screen_name>_preview.dart` に生成する。

```dart
// lib/preview/screens/<screen_name>_preview.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// ignore: depend_on_referenced_packages
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../presentation/screens/<screen_dir>/<screen_name>_screen.dart';
import '../mock_providers.dart';

// Preview 専用 GoRouter（遷移先なし・クラッシュ回避）
final _previewRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SizedBox.shrink(),
    ),
  ],
);

Widget _wrap(List<Override> overrides) => ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        routerConfig: _previewRouter,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ja', 'JP')],
        builder: (context, _) => const <ScreenName>Screen(),  // ここを <ScreenName> に置換
      ),
    );

// ── シナリオ 1: 正常表示（10件取得） ──────────────────────────────────────
@widgetbook.UseCase(name: '正常表示', type: <ScreenName>Screen)  // ここを <ScreenName> に置換
Widget build<ScreenName>Normal(BuildContext context) {         // ここを <ScreenName> に置換
  return _wrap(previewOverridesWith());
}

// ── シナリオ 2: 空リスト（データなし） ───────────────────────────────────
@widgetbook.UseCase(name: '空リスト', type: <ScreenName>Screen)  // ここを <ScreenName> に置換
Widget build<ScreenName>Empty(BuildContext context) {           // ここを <ScreenName> に置換
  return _wrap(previewOverridesWith(isEmpty: true));
}

// ── シナリオ 3: ローディング中（shimmer 表示） ────────────────────────────
@widgetbook.UseCase(name: 'ローディング中', type: <ScreenName>Screen)  // ここを <ScreenName> に置換
Widget build<ScreenName>Loading(BuildContext context) {                // ここを <ScreenName> に置換
  return _wrap(previewOverridesWith(loading: true));
}

// ── シナリオ 4: エラー状態（AppErrorWidget 表示） ─────────────────────────
@widgetbook.UseCase(name: 'エラー状態', type: <ScreenName>Screen)  // ここを <ScreenName> に置換
Widget build<ScreenName>Error(BuildContext context) {               // ここを <ScreenName> に置換
  return _wrap(previewOverridesWith(throwError: true));
}
```

### ConsumerStatefulWidget を持つ Screen の注意点

Screen 内に `ScrollController` や `TabController` があり `ConsumerStatefulWidget` の場合、
Preview 内でもライフサイクルが動くため通常は問題ない。
ただし `WidgetsBinding.instance.addObserver` などの外部依存があれば
Preview 用 stub を `mock_providers.dart` に追加すること。

---

## 2. Widget Preview テンプレート（prop 網羅型）

`lib/preview/components/<widget_name>_preview.dart` に生成する。

```dart
// lib/preview/components/<widget_name>_preview.dart
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../presentation/widgets/<widget_name>.dart';

// ── ケース 1: 基本表示（必須 prop のみ） ──────────────────────────────────
@widgetbook.UseCase(name: '基本表示', type: <WidgetName>)  // ここを <WidgetName> に置換
Widget build<WidgetName>Basic(BuildContext context) {      // ここを <WidgetName> に置換
  return const Center(
    child: <WidgetName>(               // ここを <WidgetName> に置換
      // 必須 prop をここに記入
    ),
  );
}

// ── ケース 2: オプション prop あり ────────────────────────────────────────
@widgetbook.UseCase(name: 'オプションあり', type: <WidgetName>)  // ここを <WidgetName> に置換
Widget build<WidgetName>WithOptions(BuildContext context) {      // ここを <WidgetName> に置換
  return const Center(
    child: <WidgetName>(               // ここを <WidgetName> に置換
      // 必須 + オプション prop をここに記入
    ),
  );
}

// ── ケース 3: エッジケース（境界値・最大値・空文字） ──────────────────────
@widgetbook.UseCase(name: 'エッジケース', type: <WidgetName>)  // ここを <WidgetName> に置換
Widget build<WidgetName>Edge(BuildContext context) {            // ここを <WidgetName> に置換
  return const Center(
    child: <WidgetName>(               // ここを <WidgetName> に置換
      // 極端な値・null 許容フィールドの省略など
    ),
  );
}
```

---

## 3. 既存ウィジェットの UseCase 参照例

実際の `lib/preview/components/rating_stars_preview.dart` から抽出。
新規 Widget ケース追加時のスタイル規約として参照すること。

```dart
// 高評価（レビュー数あり）
@widgetbook.UseCase(name: '高評価（レビュー数あり）', type: RatingStars)
Widget buildRatingStarsHigh(BuildContext context) {
  return const Center(child: RatingStars(rating: 4.8, reviewCount: 128));
}

// 中評価（レビュー数なし）
@widgetbook.UseCase(name: '中評価（レビュー数なし）', type: RatingStars)
Widget buildRatingStarsMedium(BuildContext context) {
  return const Center(child: RatingStars(rating: 3.5, showCount: false));
}

// 低評価（大サイズ）
@widgetbook.UseCase(name: '低評価（大サイズ）', type: RatingStars)
Widget buildRatingStarsLarge(BuildContext context) {
  return const Center(
    child: RatingStars(rating: 1.5, reviewCount: 3, size: 24),
  );
}
```

**規約:**
- 関数名は `build<WidgetName><Scenario>` 形式（PascalCase）
- `@widgetbook.UseCase(name: '日本語説明', type: WidgetクラスそのもNの型)` 形式
- `const Center(child: ...)` でラップして画面中央に表示
- `Riverpod` が不要な Widget は `ProviderScope` 不要（純粋な StatelessWidget）

---

## 4. Riverpod を使う Widget の UseCase（ConsumerWidget）

`PlanCard` のように Riverpod Provider を参照するウィジェットの場合:

```dart
// lib/preview/components/plan_card_preview.dart（参照例）
@widgetbook.UseCase(name: '東京プラン', type: PlanCard)
Widget buildPlanCardTokyo(BuildContext context) {
  return ProviderScope(
    overrides: previewProviderOverrides,  // favorites Provider を差し替え
    child: Center(
      child: PlanCard(plan: mockPlanTokyo),
    ),
  );
}
```

- `ProviderScope(overrides: previewProviderOverrides)` で Provider を差し替える
- `Widgetbook.material` の外側に `ProviderScope` を置くのは**NG**（Widgetbook が管理する）
- 各 UseCase 関数の中で `ProviderScope` を使う

---

## 5. Knobs を使った動的プロパティ（オプション）

Widgetbook の `BuildContext` から knobs を取得してインタラクティブに値を変更できる。

```dart
@widgetbook.UseCase(name: 'Knobs付き', type: RatingStars)
Widget buildRatingStarsKnob(BuildContext context) {
  final rating = context.knobs.double.slider(
    label: '評価',
    initialValue: 4.0,
    min: 0.0,
    max: 5.0,
  );
  final showCount = context.knobs.boolean(
    label: 'レビュー数を表示',
    initialValue: true,
  );
  return Center(
    child: RatingStars(
      rating: rating,
      reviewCount: showCount ? 128 : null,
    ),
  );
}
```

prop の組み合わせが多い Widget に使うと効果的。ただし `const` が外れるためパフォーマンスに注意。
