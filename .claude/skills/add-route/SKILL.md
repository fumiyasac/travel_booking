---
name: add-route
description: |
  app_router.dart に GoRoute を追加し、必要に応じてボトムナビの
  StatefulShellBranch も更新する。
  add-feature の直後に使うことが多い。
  以下の発言で自動起動すること：
  - 「ルートを追加して」
  - 「画面をルーティングに登録して」
  - 「GoRouter に追加して」
  - 「ボトムナビに新しいタブを追加して」
argument-hint: "<path> <ScreenName> [--tab]"
allowed-tools:
  - Read
  - Edit
  - Bash
disable-model-invocation: false
---

# add-route — GoRoute 追加スキル

引数: `$ARGUMENTS`

`app_router.dart` にルートを追加し、必要に応じてボトムナビも更新します。
テンプレート: `references/route-template.md` を参照。

## 引数パース

`$ARGUMENTS` を以下のように解釈する：

| 位置 | 変数 | 例 |
|------|------|----|
| 第1引数 | `$PATH_ARG` | `/booking-history`、`/plan/:id/review` |
| 第2引数 | `$SCREEN_CLASS` | `BookingHistoryScreen`、`ReviewScreen` |
| フラグ | `--tab` | 存在すれば **タブ追加モード** で動作 |

パスにパラメータ（`:id` など）が含まれる場合は **パラメータ付きルート** として扱う。

## Step 1: 現在のルーター設定を Read する

`travel_booking_mobile/lib/core/router/app_router.dart` を Read して以下を確認する：

- 既存 GoRoute のパス一覧（重複チェック用）
- `StatefulShellBranch` の数（= 現在のタブ数、次の index 採番に使用）
- `BottomNavigationBarItem` の定義箇所

**重複チェック**: `$PATH_ARG` が既存ルートと完全一致する場合は
「パス `$PATH_ARG` は既に登録されています」と警告して **中断** する。

## Step 2: 対象 Screen ファイルの存在を確認する

```bash
find travel_booking_mobile/lib/presentation/screens -name "*.dart" | grep -i <snake_case_of_SCREEN_CLASS>
```

ファイルが存在しない場合は以下を案内して **中断** する：

```
⚠️  $SCREEN_CLASS のファイルが見つかりません。
   先に /add-feature <機能名> で雛形を生成してください。
```

## Step 3a: 通常ルート追加（`--tab` なし）

`references/route-template.md` のテンプレートを Read してから編集する。

### パスの親子関係を判断する

- パスが `/` や `/favorites` などのトップレベルブランチ配下に入るべきか判断する
- ネストが必要な場合は親 GoRoute の `routes: [...]` に追加する
- トップレベルに追加する場合（例: `/booking/confirmation/:id` のような独立ルート）は
  `StatefulShellRoute` の **外側** の `routes` リストに追加する

### 編集する

パラメータなしルートの場合:

```dart
GoRoute(
  path: '$PATH_ARG',
  name: '<kebab-case-name>',
  builder: (context, state) => const $SCREEN_CLASS(),
),
```

パラメータ付きルートの場合:

```dart
GoRoute(
  path: '$PATH_ARG',
  name: '<kebab-case-name>',
  builder: (context, state) {
    final <param> = state.pathParameters['<param>']!;
    return $SCREEN_CLASS(<param>: <param>);
  },
),
```

`extra` を使う場合は `state.extra as Map<String, dynamic>?` でキャストする
（`booking-confirmation` ルートの実装を参考にすること）。

## Step 3b: タブルート追加（`--tab` あり）

`references/route-template.md` のタブテンプレートを Read してから編集する。

### 採番ルール

1. Read で確認した `StatefulShellBranch` の数 = 現在のタブ数 N
2. 新しい branch は N 番目（0-indexed）になる
3. **ハードコード厳禁**: 必ず Read した値から計算すること

### 追加する内容（2箇所）

**① `branches` リストの末尾に `StatefulShellBranch` を追加**:

```dart
StatefulShellBranch(
  routes: [
    GoRoute(
      path: '/$PATH_ARG',
      name: '<kebab-case-name>',
      builder: (context, state) => const $SCREEN_CLASS(),
    ),
  ],
),
```

**② `BottomNavigationBarItem` リストの末尾に追加**:

```dart
BottomNavigationBarItem(
  icon: Icon(Icons.<appropriate_outlined_icon>),
  activeIcon: Icon(Icons.<appropriate_icon>),
  label: '<日本語ラベル>',
),
```

アイコンはスクリーン名から意味的に適切なものを選択する。

## Step 4: 静的解析で構文エラーを確認する

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking/travel_booking_mobile && dart analyze lib/core/router/app_router.dart
```

エラーがあれば修正してから次に進む。

## 完了報告

編集した箇所をコードブロックで示し、以下を案内する：

```
✅ ルート追加完了

追加したルート: $PATH_ARG → $SCREEN_CLASS

推奨フロー:
  add-feature → add-route（←今ここ） → add-viewmodel-test

次のステップ:
  /add-viewmodel-test <機能名> でテストも追加できます
```
