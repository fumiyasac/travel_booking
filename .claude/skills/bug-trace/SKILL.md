---
name: bug-trace
description: |
  エラーメッセージやスタックトレースからバグの原因箇所を特定し修正する。
  Riverpod コード生成・GraphQL 通信・JSON パース・Navigation・State 管理の
  5 系統に加え、preview-setup（Widgetbook）/ backend-resolver（TypeScript/GraphQL）の
  エラーにも対応。修正後に静的解析とテストを確認する。
  「エラーが出た」「バグを直して」「〜という例外が発生する」
  「クラッシュする」「動かない」などの状況で自動起動する。
argument-hint: "エラーメッセージまたはスタックトレース"
allowed-tools:
  - Read
  - Edit
  - Bash
metadata:
  version: "1.0.0"
---

# bug-trace — バグ原因特定と修正

エラー内容: `$ARGUMENTS`

エラーパターン辞書: `references/error-patterns.md` を参照。

## 実行手順

### 1. エラー種別の判定

`references/error-patterns.md` のパターンテーブルと照合してエラーを分類する。

**Riverpod / コード生成系の判定:**
- `The getter 'xxxProvider' isn't defined` → コード生成忘れ
- `ProviderNotFoundException` → Provider 未登録

**GraphQL 通信系の判定:**
- `Exception: GraphQL request failed` → Resolver または接続エラー
- `SocketException` / `Connection refused` → Docker 未起動または IP 違い

**JSON パース系の判定:**
- `Null check operator used on a null value` → nullable 処理漏れ
- `type 'Null' is not a subtype of type` → 型キャスト誤り

**Navigation 系の判定:**
- `GoException: No routes for location` → ルート定義漏れ

**State 管理系の判定:**
- ローディングが終わらない / 状態が更新されない → copyWith または isLoading 制御の問題

**preview-setup（Widgetbook）系の判定:**
- `No WidgetbookApp found` / `Could not find an annotation of type App` → `@widgetbook.App()` 未設定またはコード生成忘れ
- `can't be assigned to the parameter type 'Override'` → `overrideWith` 構文不一致
- `GoException: no routes for location`（Preview 内） → Preview 用 `_previewRouter` が未定義
- `The named parameter 'xxx' isn't defined`（`mock_data.dart`） → モデル変更後の mock_data.dart 未同期

**backend-resolver（TypeScript/GraphQL）系の判定:**
- `Type 'XXX' is not assignable to type 'Resolver'` → typeDefs と Resolver の型不一致
- `Transaction already closed` / `P2002` → `$transaction` 内の `await` 抜けまたは unique 制約違反
- `Type 'XXX' was defined more than once` → typeDefs.ts 内の重複定義
- `Cannot connect to the Docker daemon` → Docker 未起動

### 2. スタックトレースからファイル特定

スタックトレースが含まれる場合、ファイルパスと行番号を抽出して該当コードを読み込む：

```
Read: <スタックトレースから抽出したファイルパス>
```

### 3. 原因の説明

日本語でバグの原因を説明する（ファイルパス:行番号 を明示）。

### 4. 修正の実施

コードを修正する。修正前後の差分を示す。

### 5. 波及確認

同様のバグが他の箇所に潜んでいないかを検索する：

```bash
# 同じパターンを他のファイルでも検索
grep -r "<問題のパターン>" \
  /Users/sakaifumiya/Desktop/FlutterApp/travel_booking/travel_booking_mobile/lib \
  --include="*.dart" -n
```

### 6. 修正後の確認

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking && melos run analyze
```

関連テストがある場合：
```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking && melos run test
```

### 7. 報告

修正内容・修正ファイル・根本原因・再発防止策を日本語でまとめて報告する。
