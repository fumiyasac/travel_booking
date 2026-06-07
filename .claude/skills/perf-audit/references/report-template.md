# パフォーマンス監査レポート テンプレート

state-audit の checklist.md フォーマットに準拠した重大度付きレポート形式。

---

## 出力テンプレート

```markdown
# ⚡ パフォーマンス監査レポート

**対象**: `<ViewModel 名 / 画面名>`
**ファイル**: `lib/presentation/viewmodels/<name>_viewmodel.dart`
         `lib/presentation/screens/<name>/<name>_screen.dart`
**実施日**: <YYYY-MM-DD>

---

## サマリー

| 重大度 | 件数 |
|---|---|
| 🔴 critical | N |
| 🟡 warning  | N |
| 🔵 info     | N |

---

## 観点1: keepAlive / autoDispose の設計

### 🔴 critical / 🟡 warning / 🔵 info — <問題タイトル>

**該当箇所**: `<ファイルパス>:<行番号>`

**問題**:
<問題の説明。なぜパフォーマンス上の問題になるかを具体的に記述>

**現状コード**:
\`\`\`dart
// 問題のあるコード
\`\`\`

**修正案**:
\`\`\`dart
// 修正後のコード
\`\`\`

---（問題がない場合）---
✅ 問題なし — keepAlive / autoDispose の設計は適切です。

---

## 観点2: 不要な rebuild の検出

### 🟡 warning — <問題タイトル>

**該当箇所**: `<ファイルパス>:<行番号>`

**問題**:
<問題の説明>

**現状コード**:
\`\`\`dart
// 問題のあるコード
\`\`\`

**修正案**:
\`\`\`dart
// 修正後のコード（select() / Consumer の適用例）
\`\`\`

---（問題がない場合）---
✅ 問題なし — rebuild スコープは適切に制御されています。

---

## 観点3: GraphQL クエリの効率

### 🟡 warning — <問題タイトル>

**該当箇所**: `lib/data/datasources/remote/travel_plan_remote_datasource.dart:<行番号>`

**問題**:
<問題の説明。取得しているフィールドと実際に使っているフィールドの差を示す>

**現状クエリ（抜粋）**:
\`\`\`graphql
# 過剰取得しているフィールド
\`\`\`

**修正案**:
\`\`\`graphql
# 最小限に絞ったクエリ
\`\`\`

---（問題がない場合）---
✅ 問題なし — GraphQL クエリのフィールド選択は適切です。

---

## 観点4: リソースリークの可能性

### 🔴 critical / 🟡 warning — <問題タイトル>

**該当箇所**: `<ファイルパス>:<行番号>`

**問題**:
<何がリークするか・どのタイミングで問題が顕在化するかを説明>

**現状コード**:
\`\`\`dart
// リークしているコード
\`\`\`

**修正案**:
\`\`\`dart
// 修正後のコード
\`\`\`

---（問題がない場合）---
✅ 問題なし — リソース解放は適切に実装されています。

---

## 総評

<全体を通じた評価。特に優先度の高い修正 1〜2 件を強調する>

---

💡 state-audit と組み合わせるとより網羅的です。
   /state-audit <対象名> で三態管理・二重実行・copyWith の一貫性も確認できます。
```

---

## 実際の出力例（HomeScreen / PlanListViewModel）

```markdown
# ⚡ パフォーマンス監査レポート

**対象**: `PlanListViewModel / HomeScreen`
**ファイル**: `lib/presentation/viewmodels/plan_list_viewmodel.dart`
         `lib/presentation/screens/home/home_screen.dart`

---

## サマリー

| 重大度 | 件数 |
|---|---|
| 🔴 critical | 0 |
| 🟡 warning  | 3 |
| 🔵 info     | 2 |

---

## 観点1: keepAlive / autoDispose の設計

### 🟡 warning — planIsFavorite の autoDispose によるスクロール時の Stream 再接続

**該当箇所**: `lib/presentation/viewmodels/plan_list_viewmodel.dart:54`

**問題**:
`planIsFavorite` は `@riverpod`（autoDispose）のため、ListView スクロールで
カードが再描画されるたびに Stream が再生成される。
20件リストでは最大 20 本の Stream が同時生成される可能性がある。

**現状コード**:
\`\`\`dart
@riverpod
Stream<bool> planIsFavorite(Ref ref, String planId) {
  final dataSource = ref.watch(favoriteLocalDataSourceProvider);
  return dataSource.watchFavorites()
      .map((favorites) => favorites.any((f) => f.planId == planId));
}
\`\`\`

**修正案（favorites を上位で1本 watch する）**:
\`\`\`dart
// ViewModel 側で全お気に入りIDを1本の Stream で管理
@riverpod
Stream<Set<String>> favoritePlanIds(Ref ref) {
  final dataSource = ref.watch(favoriteLocalDataSourceProvider);
  return dataSource.watchFavorites()
      .map((list) => list.map((f) => f.planId).toSet());
}

// カード側は bool を引数で受け取るだけ（Stream 不要）
class PlanCard extends StatelessWidget {  // ConsumerWidget → StatelessWidget に変更可
  final TravelPlan plan;
  final bool isFavorite;
  const PlanCard({super.key, required this.plan, required this.isFavorite});
  ...
}
\`\`\`

---

## 観点2: 不要な rebuild の検出

### 🟡 warning — HomeScreen.build() が PlanListState 全体を watch

**該当箇所**: `lib/presentation/screens/home/home_screen.dart:47`

**問題**:
`isLoadingMore` が変化するだけで AppBar・検索バー・フィルターボタンを含む
画面全体が再ビルドされる。ページネーション中のスクロールで頻発する。

**現状コード**:
\`\`\`dart
final state = ref.watch(planListViewModelProvider);  // 全 State を監視
\`\`\`

**修正案**:
\`\`\`dart
// リスト部分のみ Consumer で囲んで rebuild 範囲を限定
body: Consumer(
  builder: (context, ref, _) {
    final plans = ref.watch(
      planListViewModelProvider.select((s) => s.plans),
    );
    return ListView.builder(...);
  },
),
\`\`\`

---

## 観点3: GraphQL クエリの効率

### 🟡 warning — リスト用クエリで全画像・全ハイライトを取得

**該当箇所**: `lib/data/datasources/remote/travel_plan_remote_datasource.dart:12`

**問題**:
`_getPlansQuery` でリスト表示に必要なのはプライマリ画像 URL 1 枚だけだが、
全画像（複数枚）と全ハイライト（3〜5 件）を取得している。
20件 × 平均4画像 = 最大 80 件の画像レコードが毎回転送される。

**修正案**:
\`\`\`graphql
# リスト専用クエリを追加してフィールドを最小化
query GetTravelPlanList($filter: PlanFilterInput, $page: Int, $pageSize: Int) {
  travelPlans(filter: $filter, page: $page, pageSize: $pageSize) {
    plans {
      id title destination country region
      price discountPrice effectivePrice durationDays
      category difficulty rating reviewCount isAvailable availableSpots
      tags
      images { url isPrimary }   # プライマリ画像のみで十分
    }
    totalCount hasNextPage currentPage totalPages
  }
}
\`\`\`

---

## 観点4: リソースリークの可能性

✅ 問題なし — `ScrollController`・`TextEditingController`・`GraphQLHttpClient` は
   すべて適切に解放されています（`dispose()` / `ref.onDispose` 確認済み）。

---

## 総評

致命的なリークはありません。優先度の高い修正は以下の 2 件です:
1. **🟡 `_getPlansQuery` の過剰取得**（即時対応可・通信量削減効果が大きい）
2. **🟡 HomeScreen の全 State watch**（rebuild 頻度を下げ、ページネーション時のガクつきを軽減）

---

💡 state-audit と組み合わせるとより網羅的です。
   /state-audit home で三態管理・二重実行・copyWith の一貫性も確認できます。
```
