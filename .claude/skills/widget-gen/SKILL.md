---
name: widget-gen
description: |
  lib/presentation/widgets/ に新しい共通ウィジェットの雛形を生成する。
  rating_stars / loading_indicator / app_error_widget のコーディング規約に準拠する。
  以下のような発言で自動起動すること：
  - 「共通ウィジェットを追加したい」
  - 「新しいウィジェットを作って」
  - 「〜のウィジェットコンポーネントを生成して」
  - 「StatefulWidget の雛形が欲しい」
argument-hint: "<ウィジェット名(snake_case)> [--stateful] [--test]"
allowed-tools:
  - Read
  - Edit
  - Bash
disable-model-invocation: false
---

# widget-gen — 共通ウィジェット雛形生成

引数: `$ARGUMENTS`

`lib/presentation/widgets/` に既存 3 ウィジェットの規約に準拠した雛形を生成します。
ボイラープレートとテンプレートコード: `references/widget-template.md` を参照。

---

## Step 1: 引数を解析する

`$ARGUMENTS` を以下のルールで解析する。

| 位置・フラグ | 変数 | 説明 |
|---|---|---|
| `$0` | ウィジェット名（snake_case） | 例: `price_badge`、`empty_state` |
| `--stateful` | StatefulWidget フラグ | 省略時は `StatelessWidget` を生成 |
| `--test` | テスト生成フラグ | `test/widgets/<name>_test.dart` も生成 |

snake_case → PascalCase 変換を行う（例: `price_badge` → `PriceBadge`）。

---

## Step 2: 既存ウィジェットを参照して規約を把握する

以下の 4 ファイルを Read して、コーディング規約を確認する。

```
travel_booking_mobile/lib/presentation/widgets/rating_stars.dart
travel_booking_mobile/lib/presentation/widgets/loading_indicator.dart
travel_booking_mobile/lib/presentation/widgets/app_error_widget.dart
travel_booking_mobile/lib/core/theme/app_theme.dart
```

確認するポイント:
- import の順序（`flutter/material.dart` → 外部パッケージ → `../../core/theme/app_theme.dart`）
- `const` コンストラクタに `super.key` を使っていること
- `@override` を `build()` に必ず付けること
- 色は `AppTheme.xxxColor` 定数を使い、ハードコード値（`Color(0x...)` 直書き）は使わないこと
- `Column`/`Row` の可変子は `...[if ...]` スプレッド構文で追加すること

---

## Step 3: 重複チェック

出力先ファイルがすでに存在する場合は**警告を出して中断**する。

```bash
ls travel_booking_mobile/lib/presentation/widgets/<widget_name>.dart 2>/dev/null \
  && echo "CONFLICT" || echo "OK"
```

`CONFLICT` の場合:
```
⚠️ lib/presentation/widgets/<widget_name>.dart はすでに存在します。
別の名前を指定するか、既存ファイルを編集してください。
```

---

## Step 4: ウィジェットファイルを生成する

出力先: `travel_booking_mobile/lib/presentation/widgets/<widget_name>.dart`

`references/widget-template.md` の該当テンプレートを基に生成する:
- `--stateful` なし → `## StatelessWidget テンプレート` セクション
- `--stateful` あり → `## StatefulWidget テンプレート` セクション

**必須規約（テンプレートから逸脱しないこと）:**
- `part of` 宣言は使わない
- クラス直上に責務を示す 1 行コメントを記述する（例: `// 価格とバッジを表示する共通ウィジェット`）
- `const` コンストラクタを必ず実装する（StatefulWidget は Widget クラス側に付ける）
- `@override` は省略しない
- 色は `AppTheme` 定数のみ使用（`import '../../core/theme/app_theme.dart'` を追加）
- `@riverpod` / `ConsumerWidget` は生成しない
  → ViewModel 連携が必要な場合は `/add-feature` を案内して中断する

---

## Step 5: --test フラグがある場合はテストを生成する

出力先: `travel_booking_mobile/test/widgets/<widget_name>_test.dart`

`references/widget-template.md` の `## ウィジェットテスト テンプレート` セクションを基に生成する。

**テスト規約:**
- `testWidgets` を使う（`test()` は使わない）
- `pumpWidget` のラップは `MaterialApp` のみ（`ProviderScope` 不要）
- 以下の 3 グループ以上を含める:
  1. **表示確認** — 必須パラメータで正しく描画されるか
  2. **コールバック確認** — タップ/入力などのインタラクションが機能するか
  3. **エッジケース** — 省略可能パラメータが null/空のときに壊れないか

---

## Step 6: 静的解析を実行する

```bash
cd travel_booking_mobile && dart analyze lib/presentation/widgets/<widget_name>.dart 2>&1
```

エラーが出た場合はその場で修正してから完了とする。

完了レポートを以下の形式で出力する:

```
✅ ウィジェット生成完了
- クラス名:   <PascalCase>
- ファイル:   lib/presentation/widgets/<widget_name>.dart
- 種別:       StatelessWidget / StatefulWidget
- テスト:     test/widgets/<widget_name>_test.dart（--test 指定時のみ）
- 静的解析:   No issues found
```
