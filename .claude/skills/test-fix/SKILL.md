---
name: test-fix
description: |
  テストを自動実行して失敗を検出し、プロジェクト固有のエラーパターンを参照して
  自動修復するサブエージェントスキル。context: fork で独立実行するため
  本会話のコンテキストを汚さない。
  以下のような発言で自動起動すること：
  - 「テストが壊れた」
  - 「テストを修復して」
  - 「CIが落ちている」
  - 「テストエラーを直して」
  - 「テストが通らない」
  - 「test が fail している」
argument-hint: "[--flutter|--backend|--all]"
context: fork
allowed-tools:
  - Read
  - Edit
  - Bash
---

# test-fix — 壊れたテスト自動検出・修復

対象オプション: `$ARGUMENTS`

`context: fork` で独立実行するため本会話のコンテキストを汚しません。
エラーパターン詳細: `references/error-fix-patterns.md` を参照。

---

## オプション

| オプション | 対象 | コマンド |
|---|---|---|
| `--flutter`（省略時デフォルト） | Flutter ViewModel テスト + Widget テスト | `dart run melos run test` |
| `--backend` | Node.js / Jest テスト | `cd travel_booking_backend && npm test` |
| `--all` | Flutter + Backend 両方 | 両方順に実行 |

---

## Step 1: テストを実行して失敗ログを収集する

### Flutter テスト（`--flutter` または `--all` または引数なし）

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking
dart run melos run test 2>&1 | tee /tmp/test_output.txt
```

失敗したテストファイルと行番号をリストアップする：

```bash
grep -E "^(FAILED|ERROR|✗)" /tmp/test_output.txt | head -30
```

### Backend テスト（`--backend` または `--all`）

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking/travel_booking_backend
npm test 2>&1 | tee /tmp/backend_test_output.txt
```

---

## Step 2: エラーをカテゴリ分類する

`references/error-fix-patterns.md` を Read してから、各エラーメッセージを以下の5カテゴリに分類する。

| カテゴリ | 識別キーワード |
|---|---|
| **A: コード生成未実行** | `The getter '.*Provider' isn't defined` / `Target of URI hasn't been generated` |
| **B: Flutter 3.22+ Finder 問題** | `Expected: exactly one matching node` / `find.byType(ElevatedButton)` |
| **C: Mock ファイル未生成** | `Target of URI doesn't exist: '.*\.mocks\.dart'` |
| **D: assert 違反** | `Failed assertion` / `AssertionError` |
| **E: TypeScript / Jest エラー** | `error TS` / `FAIL src/` / `Cannot find module` |

分類結果を以下の形式で表示する：

```
検出されたエラー:
  [A] travel_booking_mobile/lib/presentation/viewmodels/xxx_viewmodel.dart:12
      The getter 'xxxProvider' isn't defined

  [D] test/widgets/rating_stars_test.dart:34
      AssertionError: 'rating >= 0.0': is not true
```

---

## Step 3: カテゴリ別に修正を適用する

修正内容を実施する前に、検出されたエラーと修正方針の一覧をユーザーに提示し確認を取る：

```
以下の修正を行います:
  1. [A] build_runner を再実行してコード生成ファイルを更新
  2. [D] rating_stars.dart の rating.clamp(0.0, 5.0) を追加

続行してよいですか？
```

ユーザーの確認後、`references/error-fix-patterns.md` の対応セクションに従って修正を実施する。

### カテゴリ A: コード生成未実行

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking
dart run melos run build_runner
```

実行後、`*.g.dart` ファイルが更新されたか確認する：

```bash
git diff --name-only | grep '\.g\.dart'
```

### カテゴリ B: Flutter 3.22+ Finder 問題

該当テストファイルを Read して `find.byType(ElevatedButton)` の箇所を特定し、
`find.text('ボタンラベル')` に置換する。

ボタンラベルは対応する Widget ソース（`lib/presentation/widgets/` 配下）を Read して確認する。

### カテゴリ C: Mock ファイル未生成

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking
dart run melos run build_runner
```

`build_runner` 後に `.mocks.dart` ファイルが生成されたか確認：

```bash
ls travel_booking_mobile/test/viewmodels/*.mocks.dart
```

### カテゴリ D: assert 違反

該当 Widget ソースファイルを Read してから、
`references/error-fix-patterns.md` の「カテゴリ D」セクションを参照して修正を適用する。

### カテゴリ E: TypeScript / Jest エラー

エラーメッセージを Read して原因を特定する。
`references/error-fix-patterns.md` の「カテゴリ E」セクションを参照して修正する。

TypeScript ビルドエラーは Docker 起動後に確認する：

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking/travel_booking_backend
docker compose exec backend npx tsc --noEmit
```

---

## Step 4: 修正後にテストを再実行して全パスを確認する

### Flutter

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking
dart run melos run test
```

### Backend

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking/travel_booking_backend
npm test
```

全件パスした場合：

```
✅ test-fix 完了

修正内容:
  （各カテゴリの修正サマリ）

テスト結果:
  Flutter: XX テスト全パス
  Backend: YY テスト全パス（--all の場合）

次のステップ（任意）:
  /add-viewmodel-test <名前>  → ViewModel テストを追加
  /add-widget-test <名前>     → Widget テストを追加
```

失敗が残っている場合はエラーメッセージを表示し、
`references/error-fix-patterns.md` に該当パターンがないケースを「未知のエラー」として報告する。

---

## 注意事項

- `context: fork` のため修正ファイルは本会話に反映されない。確認後に git status でユーザーが差分確認する。
- `build_runner` は冪等なので、カテゴリ A / C が両方検出された場合は1回の実行でよい。
- `.g.dart` と `.mocks.dart` は手動編集禁止。修正は元ファイル（`@riverpod` / `@GenerateMocks` 付きクラス）に対して行う。
- Backend テストは Docker が起動していない場合、型チェックのみ実施してテスト実行をスキップする。
