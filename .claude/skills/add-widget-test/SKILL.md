---
name: add-widget-test
description: |
  指定した Widget の Widget テストを自動生成する。
  add-viewmodel-test（ViewModel 単体テスト）の姉妹スキル。
  以下の発言で自動起動すること：
  - 「Widget テストを追加して」
  - 「ウィジェットのテストを書いて」
  - 「UIコンポーネントのテストを追加したい」
  - 「widget-gen したあとテストを書きたい」
argument-hint: "<WidgetName> [--with-callback] [--with-error]"
allowed-tools:
  - Read
  - Edit
  - Bash
disable-model-invocation: false
---

# add-widget-test — Widget テスト自動生成

対象: `$ARGUMENTS`

> **add-viewmodel-test との使い分け**
> - ViewModel のビジネスロジック（状態変化・API呼び出し）→ `/add-viewmodel-test`
> - Widget の UI 表示・インタラクション → `/add-widget-test`（このスキル）

テストコードのパターン詳細: `references/widget-test-template.md` を参照。

## 引数

| 引数 | 説明 |
|---|---|
| `<WidgetName>` | 対象 Widget のクラス名（例: `BookingStepIndicator`、`PlanCard`） |
| `--with-callback` | `onTap` / `onRetry` 等コールバック prop のテストを重点的に生成 |
| `--with-error` | `AppError` 型分岐テストを生成（`AppErrorWidget` 系が対象） |

---

## Step 1: 対象 Widget を Read して構造を把握する

引数からファイルパスを解決する：

```
lib/presentation/widgets/<widget_name>.dart
```

スクリーン固有ウィジェットの場合（`screens/` 配下）:
```bash
find travel_booking_mobile/lib/presentation/screens -name "<widget_name>.dart"
```

Read 後に以下を抽出する：
- コンストラクタ引数（props）の一覧と型・デフォルト値
- `VoidCallback` / `ValueChanged` 等のコールバック prop
- 条件分岐（`if` / `switch` / sealed class パターン）の有無
- ガード処理（`if (x == null) return SizedBox.shrink()` 等）
- 使用しているアイコン定数（`Icons.xxx`）とテキスト文字列

---

## Step 2: 既存テストの確認

```bash
ls travel_booking_mobile/test/widgets/
```

| パターン | 対応 |
|---|---|
| テストファイルあり | 既存テストを Read し、不足しているケースを追記する |
| テストファイルなし | `references/widget-test-template.md` のテンプレートで新規作成する |

---

## Step 3: テストファイルを生成・更新する

出力先: `test/widgets/<widget_name>_test.dart`

`references/widget-test-template.md` を Read してから実装する。
**必ず Widget のソースコードを Read した内容に基づいてテストを書くこと**（テンプレートをそのままコピーしない）。

### 必須テストグループ: 表示確認

```dart
group('表示確認', () {
  // 最低限のテストケース（2〜3件）
  // 各 prop の代表値でウィジェットが正常レンダリングされること
  // 主要なテキスト・アイコンが find.text / find.byIcon で見つかること
});
```

検証に使う Finder の選び方:
- テキスト → `find.text('文字列')`
- アイコン → `find.byIcon(Icons.xxx)`
- 型検索 → `find.byType(WidgetType)`（ただし `ElevatedButton.icon` は不可。`find.text('ラベル')` を使う）
- 存在確認 → `findsOneWidget` / `findsNothing`

### 必須テストグループ: エッジケース

```dart
group('エッジケース', () {
  // null 許容フィールドが null のとき（Widget が非表示になること等）
  // ガード処理のテスト（座標が 0 のとき SizedBox.shrink が返る等）
  // 空文字 / 最大値 / 最小値
});
```

### --with-callback の場合に追加: コールバック確認

```dart
group('コールバック確認', () {
  // var called = false パターンで発火を検証
  // find.text('ラベル') でボタンを特定してタップ
  // ElevatedButton.icon は find.byType(ElevatedButton) では見つからない（Flutter 3.22+）
});
```

### --with-error の場合に追加: エラー型分岐

```dart
group('NetworkError', () { ... });
group('GraphQLError', () { ... });
group('ValidationError', () { ... });
group('UnknownError', () { ... });
```

各グループ: アイコン・タイトル・message 表示を検証（2〜3件）。
リトライボタンは `find.text('再試行')` で確認する（`find.byType(ElevatedButton)` は不可）。

---

## Step 4: テスト実行で確認する

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking
dart run melos run test -- --run-skipped -- test/widgets/<widget_name>_test.dart
```

失敗したテストがあれば原因を日本語で説明し修正してから再実行する。

全件パス後に全 Widget テストも確認する：

```bash
dart run melos run test -- --run-skipped -- test/widgets/
```

---

## 完了後の案内

```
✅ Widget テストを追加しました

追加したテストケース:
  （グループ名とケース一覧）

テストピラミッドの現状:
  ViewModel テスト: test/viewmodels/ — /add-viewmodel-test で追加
  Widget テスト:   test/widgets/    — /add-widget-test（このスキル）で追加
  Resolver テスト: src/__tests__/   — Jest（手動追加）

次のステップ（任意）:
  /preview-setup <WidgetName> → Widgetbook Preview ケースを追加
```

---

## 注意事項

- `ProviderScope` は不要（StatelessWidget / StatefulWidget の純粋な Widget テスト）
  `ConsumerWidget`（Riverpod 依存あり）のテストは Provider のモックが必要なため、
  このスキルの対象外。手動で対応する。
- `ElevatedButton.icon()` は Flutter 3.22+ で `_ElevatedButtonWithIcon`（private サブクラス）を返す。
  `find.byType(ElevatedButton)` ではヒットしないため、必ず `find.text('ラベル')` を使う。
- テストケースは各グループ 2〜3 件に絞る（網羅しすぎない）
- `debugShowCheckedModeBanner: false` を `MaterialApp` に付けると `Text` 検索の誤検知を防げる
