---
name: perf-audit
description: |
  指定した ViewModel または画面について、このプロジェクト固有の
  パフォーマンス問題を4観点で静的解析してレポートする。
  state-audit（状態管理）の姉妹スキル。パフォーマンスが担当領域。
  以下のような発言で自動起動すること：
  - 「パフォーマンスをチェックして」
  - 「不要な rebuild が起きていないか確認して」
  - 「keepAlive の設定が正しいか見て」
  - 「GraphQL の呼び出しが多すぎる気がする」
  - 「〜のパフォーマンスを監査して」
argument-hint: "<画面名または ViewModel 名>"
allowed-tools:
  - Read
  - Bash
context: fork
disable-model-invocation: false
---

# perf-audit — パフォーマンス静的監査

対象: `$ARGUMENTS`（省略時は `home` / `PlanListViewModel` を対象とする）

`context: fork` で独立実行するため本会話のコンテキストを汚しません。
チェックリストの詳細: `references/perf-checklist.md`
レポートフォーマット: `references/report-template.md`

---

## 役割分担（state-audit との違い）

| スキル | 担当領域 |
|---|---|
| **state-audit** | 三態管理・二重実行防止・copyWith 一貫性・Provider の ref 使い分け |
| **perf-audit** | rebuild 最小化・keepAlive 設計・GraphQL 効率・リソースリーク |

---

## Step 1: 対象ファイルを特定して Read する

`$ARGUMENTS` から画面名・ViewModel 名を解釈して以下を Read する。

```
travel_booking_mobile/lib/presentation/viewmodels/<name>_viewmodel.dart
travel_booking_mobile/lib/presentation/viewmodels/<name>_viewmodel.g.dart
travel_booking_mobile/lib/presentation/screens/<name>/<name>_screen.dart
```

DataSource や Repository も観点3（GraphQL）の確認のために必要であれば Read する:
```
travel_booking_mobile/lib/data/datasources/remote/travel_plan_remote_datasource.dart
```

---

## Step 2: 4観点で解析する

各観点の Bad / Good コード例は `references/perf-checklist.md` を Read してから実施する。

### 観点1: keepAlive / autoDispose の設計

以下の判断基準で各 Provider を評価する:

| Provider の種類 | 推奨設定 |
|---|---|
| StreamController / StreamSubscription を持つ | `keepAlive: true` + `ref.onDispose` |
| アプリ全体で共有するリポジトリ・ストレージ | `keepAlive: true` |
| 画面スコープのデータ取得 | `@riverpod`（autoDispose） |
| カード単位の短命 Stream（`planIsFavorite` 等） | `@riverpod`（autoDispose）だが ListView での再生成コストに注意 |

確認すること:
- `keepAlive: true` が必要な Provider に設定されているか
- `StreamController` を持つ Provider が `autoDispose` のまま放置されていないか
- `ref.onDispose` でリソース解放が漏れていないか

### 観点2: 不要な rebuild の検出

確認すること:
- `ref.watch(someProvider)` でState 全体を監視していないか
  → 一部のフィールドしか使わない場合は `.select()` に変更できる
- `ConsumerStatefulWidget` の `build()` 内で `ref.watch` のスコープが広すぎないか
  → 画面全体 vs `Consumer` / `select` で必要な Widget に絞れるか
- `ConsumerStatefulWidget.build()` 内でウィジェットを即時生成していないか
  → 重いサブウィジェットを `const` にできるか

### 観点3: GraphQL クエリの効率

確認すること:
- リスト画面（`_getPlansQuery`）でも detail 専用フィールドを取得していないか
  → `itinerary` / `includedItems` / `excludedItems` / `reviews` の過剰取得
- スクロール無限読み込みのトリガー閾値がハードコードの px 値になっていないか
  → `maxScrollExtent - 300` パターン（端末ごとにアイテム高さが違うため不正確）
- 同じ画面で同一クエリが複数 Provider から重複発火していないか

### 観点4: リソースリークの可能性

確認すること:
- `ConsumerStatefulWidget.dispose()` で `ScrollController` / `TextEditingController` / `AnimationController` が全て解放されているか
- `StreamSubscription` フィールドが `ref.onDispose` または `dispose()` でキャンセルされているか
- `GraphQLHttpClient` が `ref.onDispose(client.dispose)` で破棄されているか

---

## Step 3: レポートを出力する

`references/report-template.md` のフォーマットで出力する。

重大度の基準:
- **critical**: メモリリーク・クラッシュリスク・即修正が必要
- **warning**: 不要な rebuild・過剰 GraphQL 取得・修正推奨
- **info**: 将来的なリスク・改善の余地

問題がなかった観点には `✅ 問題なし` と明記する。
各問題には必ず修正方法の提案（コードスニペット付き）を付記する。

---

## 終了時アナウンス

レポートの末尾に必ず以下を追記する:

```
💡 state-audit と組み合わせるとより網羅的です。
   /state-audit <対象名> で三態管理・二重実行・copyWith の一貫性も確認できます。
```
