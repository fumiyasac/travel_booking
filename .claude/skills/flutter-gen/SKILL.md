---
name: flutter-gen
description: |
  Riverpod の .g.dart ファイルを melos run build_runner でコード生成する。
  @riverpod アノテーションを持つ ViewModel・Provider を追加・変更した後に実行が必要。
  「コード生成して」「build_runner を実行して」「Provider が見つからない」
  「getter 'xxxProvider' isn't defined」「.g.dart を再生成して」などの
  状況でこのスキルを使用する。
allowed-tools:
  - Bash
  - Read
metadata:
  version: "1.0.0"
---

# flutter-gen — Riverpod コード生成

`@riverpod` アノテーションを持つクラスが変更・追加された後に `.g.dart` ファイルを再生成します。

## 実行手順

### 1. 対象ファイルの確認

変更された `@riverpod` 付きファイルを確認する：

```bash
grep -r "@riverpod" travel_booking_mobile/lib --include="*.dart" -l
```

### 2. コード生成実行

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking && melos run build_runner
```

### 3. 生成結果の確認

生成・更新された `.g.dart` ファイルを確認する：

```bash
find travel_booking_mobile/lib -name "*.g.dart" -newer travel_booking_mobile/lib/main.dart
```

### 4. エラー発生時の対処

**コンフリクトエラー** (`Already exists a generated file`) が出た場合：
コマンドに `--delete-conflicting-outputs` が含まれているので自動解消される。

**構文エラー** が出た場合：
エラーメッセージのファイルパスを確認し、`@riverpod` アノテーションの記述ミスを修正してから再実行する。

### 5. 完了報告

生成されたファイル一覧と変更内容を日本語で報告する。

## 注意事項

- `*.g.dart` ファイルは自動生成のため **手動編集禁止**
- ウォッチモードを使う場合は Claude Code 外で `melos run build_runner:watch` を実行する
- `melos run test` でテストも通ることを確認する
