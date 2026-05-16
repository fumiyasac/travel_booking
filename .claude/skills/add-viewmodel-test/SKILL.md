---
name: add-viewmodel-test
description: |
  指定 ViewModel のユニットテストを Mockito + ProviderContainer パターンで追加・拡充する。
  未テストのメソッドを自動検出し、成功/失敗/エッジケースを網羅したテストを生成する。
  テスト生成後に build_runner でモッククラスを再生成し melos run test で確認する。
  「テストを追加して」「〜のテストを書いて」「テストカバレッジを上げたい」
  「新しいメソッドのテストがない」などのリクエストで使用する。
argument-hint: "ViewModel名 (例: booking, favorite, plan_list, plan_detail)"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
metadata:
  version: "1.0.0"
---

# add-viewmodel-test — ViewModel テスト追加

ViewModel名: `$ARGUMENTS`

テストコードのパターン詳細: `references/test-pattern.md` を参照。

## 実行手順

### 1. 対象ファイルの読み込み

```
Read: travel_booking_mobile/lib/presentation/viewmodels/{arguments}_viewmodel.dart
```

### 2. 既存テストの確認

テストファイルが存在するか確認する：
```bash
ls /Users/sakaifumiya/Desktop/FlutterApp/travel_booking/travel_booking_mobile/test/viewmodels/
```

| パターン | 対応 |
|---|---|
| テストファイルあり | 既存テストを読み込み、未テストのパブリックメソッドを特定して追加 |
| テストファイルなし | `references/test-pattern.md` のテンプレートで新規作成 |

### 3. 未テストのメソッドを特定

ViewModel のパブリックメソッドを列挙し、既存テストと照合する：
- `loadXxx()` / `fetchXxx()`
- `updateXxx(value)` 系メソッド
- `reset()` / `clearError()` / `clearXxx()`
- ページネーション: `loadMore()`
- フィルター: `updateFilter()` / `resetFilter()`

### 4. テストケースの設計

各メソッドについて以下のケースを設計する：
- **初期状態**: デフォルト値の確認
- **成功パス**: モックが正常値を返す → state が期待通りに更新される
- **失敗パス**: モックが例外を投げる → `error` がセットされ `isLoading: false` になる
- **入力バリデーション**: 不正な値が渡された場合の動作
- **エッジケース**: 空リスト・null・境界値・二重実行防止

### 5. テストコードの生成・追加

`references/test-pattern.md` のテンプレートに従ってコードを生成または追加する。

テストデータは日本語の現実的な値を使う（例: `'東京エクスプローラー5日間'`）。

### 6. モッククラスの再生成

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking && melos run build_runner
```

`{arguments}_viewmodel_test.mocks.dart` が生成・更新されたことを確認する。

### 7. テスト実行

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking && melos run test
```

失敗したテストがあれば原因を日本語で説明し修正する。

### 8. 完了報告

追加したテストケース一覧と、カバーされるようになった動作を日本語で報告する。
